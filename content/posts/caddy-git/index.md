---
title: "Automating blog deployments with my caddy-git fork"
date: 2024-02-25
lastmod:
draft: false
toc: true
tags:
- caddy
- automation
- git
- github_actions
---

{{< details "Summary" >}}
I discuss how I automated the process of deploying this blog with Github Actions
and my own forked version of caddy-git.
{{< /details >}}

This blog is built with the static site generator [Hugo](https://gohugo.io/).
When I make any changes to the source, I push the new commits to the GitHub
repository where GitHub Actions will build the static files with `actions-hugo`:

```yml
  steps:
    - name: Checkout codebase
      uses: actions/checkout@v4

    - name: Setup Hugo
      uses: peaceiris/actions-hugo@v2
      with:
        hugo-version: '0.119.0'
        extended: true

    - name: Delete public/
      run: rm -rf public/

    - name: Build site
      run: hugo --gc --minify --enableGitInfo
```

Then, the pipeline deploys the static files in `public/` to the branch `deploy`
on the same repository:

```yml
    - name: Deploy site to deploy branch
      run: |
        git worktree add deploy
        git config user.name "Deploy from CI"
        git config user.email ""

        cd deploy
        # Delete the ref to avoid keeping history.
        git update-ref -d refs/heads/deploy
        rm -rf *
        mv ../public/* .
        git add .
        git commit -m "Deploy $GITHUB_SHA to deploy"
        git push --force --set-upstream origin deploy
```

This method continuously rewrites history on that `deploy` branch but that's
okay as the full history of the source is still present in `master`. Take note
of this because it becomes important later.

At this stage, you can opt to serve the static files with GitHub Pages by
pointing it at the `deploy` branch. Or you can also serve the files through a
file server on your own server. I serve this site with the file server
[Caddy](https://caddyserver.com/) on a VPS.

{{< alert >}}
I opted to use Caddy instead of Nginx because it supports automatic HTTPS.
{{< /alert >}}

This is my `Caddyfile` configuration:

```caddyfile
ken.cheo.dev {
    root * /srv/source
    file_server

    try_files {path} {path}/ =404

    handle_errors {
        rewrite * /404.html
        file_server
    }
}
```
## Where's the automation?

Don't worry, I haven't forgotten about that. At this point, we still have to
figure out how to copy the static files from the Git repository's `deploy`
branch to our server. Let me give you the simplest way to do it: **Run a cronjob
on the server that automatically pulls the `deploy` branch at a given
interval.**

There, you can stop reading now.

Seriously, that's it.

I wasn't very satisfied with that. Surely I could have the changes be propagated
automatically without a cronjob? Okay, let's consider some of the methods that I
implemented that pull from the repository:

- Running a [webhook](https://github.com/adnanh/webhook) server on the VPS that
  listens for webhook requests from the source repository. When a new build is
  ready, [GitHub sends a POST
  request](https://docs.github.com/en/webhooks/using-webhooks/creating-webhooks)
  to the webhook server which runs a shell script to pull the new changes
- Containerizing the static files into a Nginx container. This Docker image
  built with GitHub Actions and run on the VPS with a sidecar
  [Watchtower](https://containrrr.dev/watchtower/) container that listens for
  new images. These new images are automatically pulled by Watchtower

These methods work but they are way too complex for something as simple as a
static site.

How about pushing the files to the server? You could opt to `scp` or `rsync` the
generated static files to the server using GitHub Actions. You would also have
to add your server IP and credentials as secrets in the repository, something I
would prefer not to do if I could.

## caddy-git

Caddy has a rich ecosystem of plugins. While browsing for interesting plugins, I
came across [caddy-git](https://github.com/greenpau/caddy-git), a plugin that
allows updating a directory backed by a Git repo.

With this configuration, you can configure Caddy to pull any updates from a
given repository's branch at a fixed interval:

```Caddyfile
{
    git {
        repo source {
            base_dir /srv
            url https://github.com/kencx/source.git
            branch deploy
            update every 1800
        }
    }
}
```

Wait a minute... we just replaced our cronjob with a Caddy plugin!

At this point, we could take the sane approach and go back to the cronjob... or
we could try out this shiny new thing we just found!

Let's add the above configuration to our Caddyfile and start it:

```text
2024/02/23 13:21:32.837 INFO    using provided configuration    {"config_file": "./Caddyfile", "config_adapter": ""}
2024/02/23 13:21:32.839 INFO    admin   admin endpoint started  {"address": "localhost:2019", "enforce_origin": false, "origins": ["//localhost:2019", "//[::1]:2019", "//127.0.0.1:2019"]}
2024/02/23 13:21:32.839 INFO    git     provisioning app instance       {"app": "git"}
2024/02/23 13:21:33.650 ERROR   git     failed managing repo    {"repo_name": "source", "error": "non-fast-forward update"}
2024/02/23 13:21:33.650 ERROR   git     failed configuring app instance {"app": "git", "error": "non-fast-forward update"}
Error: loading initial config: loading new config: loading git app module: provision git: non-fast-forward update
2024/02/23 21:21:33 [ERROR] exit status 1
```

Wait, what?

If you remember, our `deploy` branch's history is continuously overwritten with
every new build. This means pulling the repository's branch normally would
result into a non-fast-forward update, something that `caddy-git` does not
support.

Okay then, sometimes you just got to
[do it yourself](https://github.com/kencx/caddy-git/tree/force-pull).

## Forking caddy-git

{{< alert >}}
If you're not interested in the implementation details of the fork, please skip
to the [next section](#success).
{{< /alert >}}

Taking at look at the [source](https://github.com/greenpau/caddy-git) of
`caddy-git`, we see that it handles the fetching and pulling of the latest
commits in the `runUpdate()` method:

```go
func (r *Repository) runUpdate() error {
    // truncated
    w, err := repo.Worktree()

    // truncated
	if err := w.Pull(opts); err != nil {
		if err == git.NoErrAlreadyUpToDate {
			r.logger.Debug(
				"repo is already up to date",
				zap.String("repo_name", r.Config.Name),
			)
			return nil
		}
	}
    // truncated
}
```

Specifically, it initializes a worktree and attempts to pull the latest commits
from the remote repository. This isn't really telling us why its failing so we
have to go deeper and look at the implementation of the `w.Pull()` method.

The `caddy-git` plugin utilizes the `go-git`
[library](https://github.com/go-git/go-git/tree/master), a pure Go
implementation of Git. However, it seems that the `go-git` library [only
supports](https://github.com/go-git/go-git/blob/master/COMPATIBILITY.md#sharing-and-updating-projects)
fast-forward merges, throwing an `ErrNonFastForwardUpdate` error otherwise.

Okay, there should be a `force` option somewhere that we can add to override
this behaviour. Looking at the
[godocs](https://pkg.go.dev/github.com/go-git/go-git), there seems to be a
`Force` boolean in `PullOptions` that we could try:

```go
type PullOptions struct {
    // Force allows the pull to update a local branch even when the remote
	// branch does not descend from it.
	Force bool
}
```

On closer inspection, this [does not
work](https://github.com/go-git/go-git/issues/358).

{{< details "Why doesn't it work?" >}}
The `w.Pull()` method calls `w.PullContext()` which passes the `Force` boolean
in `PullOptions` to the `fetch()` method:

```go
func (w *Worktree) PullContext(ctx context.Context, o *PullOptions) error {
    // truncated

	remote, err := w.r.Remote(o.RemoteName)
	if err != nil {
		return err
	}

	fetchHead, err := remote.fetch(ctx, &FetchOptions{
        // truncated
		Force:           o.Force,
	})
```

This method merely fetches the references of the repository and doesn't merge
them. Its akin to running `git fetch` instead of `git fetch && git merge
FETCH_HEAD`. Adding the `Force` boolean allows `go-git` to fetch remote commits
of unrelated histories, but it does nothing of merging them.

Sure enough, we see this in the later part of
`PullContext()`:

```go
    ff, err := isFastForward(w.r.Storer, head.Hash(), ref.Hash(), earliestShallow)
    if err != nil {
        return err
    }

    if !ff {
        return ErrNonFastForwardUpdate
    }
```

where the error we encountered, `ErrNonFastForwardUpdate` is thrown with no way
to bypass it with the `Force` boolean.
{{< /details >}}

As such, we need to force the repository to destructively rewrite its local
history using another way. The most destructive action is `git reset --hard`,
and we can use it to reset the repository HEAD to the latest remote reference:

```bash
$ git fetch origin
$ git reset --hard origin/deploy
```

To do so, first, we have to add an additional conditional in `caddy-git`'s
`runUpdate()` method that handles the `ErrNonFastForwardUpdate` error:

```go
func (r *Repository) runUpdate() error {
    // truncated

	if err := w.Pull(opts); err != nil {
		if err == git.NoErrAlreadyUpToDate {
			r.logger.Debug(
				"repo is already up to date",
				zap.String("repo_name", r.Config.Name),
			)
			return nil
		}
 		if err == git.ErrNonFastForwardUpdate && r.Config.Force {
            // implementation goes here
        } else {
            return err
        }
        // truncated
    }
    return nil
}
```

Next, we get the latest remote reference from the repository, i.e. the reference
that we wish to pull. Note that Git is able to find that reference because it
has fetched it earlier when running the `w.Pull()` method; it was just unable to
merge the two diverging histories.

```go
    if err == git.ErrNonFastForwardUpdate && r.Config.Force {
        remoteRef := plumbing.NewRemoteReferenceName(opts.RemoteName, r.Config.Branch)
        ref, err := repo.Reference(remoteRef, true)
        if err != nil {
            return err
        }
    }
```

Then, with that remote reference's hash, we perform a hard reset, effectively
rewriting all local history to match the remote reference's history.

```go
    if err == git.ErrNonFastForwardUpdate && r.Config.Force {
        // truncated

        resetOpts := &git.ResetOptions{
            Commit: ref.Hash(),
            Mode:   git.HardReset,
        }
        err = w.Reset(resetOpts)
        if err != nil {
            return err
        }

        r.logger.Info(
            "force hard reset from remote",
            zap.String("remote_ref", remoteRef.String()),
            zap.Any("commit", ref.Hash()),
        )
        return nil
    } else {
        return err
    }
```

All that's left now is to build a custom Caddy image with our fork and run it.

{{< details "Building the custom Caddy image" >}}
[xcaddy](https://github.com/caddyserver/xcaddy) can do this very simply
as it supports forks and branches:

```Dockerfile
FROM caddy:2.7.5-builder-alpine AS builder
RUN xcaddy build \
    --with github.com/greenpau/caddy-git=github.com/kencx/caddy-git@force-pull \
    --with github.com/caddy-dns/cloudflare

FROM caddy:2.7.5-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
```
{{< /details >}}

## Success

With our custom Caddy build, we can add the new flag to our `Caddyfile`:

```diff
{
    git {
        repo source {
            base_dir /srv
            url https://github.com/kencx/source.git
            branch deploy
+           force true
            update every 1800
        }
    }
}
```

and success!

```text
2024/02/23 13:22:44.049 INFO    using provided configuration    {"config_file": "./Caddyfile", "config_adapter": ""}
2024/02/23 13:22:44.050 INFO    admin   admin endpoint started  {"address": "localhost:2019", "enforce_origin": false, "origins": ["//localhost:2019", "//[::1]:2019", "//127.0.0.1:2019"]}
2024/02/23 13:22:44.050 INFO    git     provisioning app instance       {"app": "git"}
2024/02/23 13:22:44.727 INFO    git     force hard reset from remote    {"remote_ref": "refs/remotes/origin/deploy", "commit": "7b230c533992a957dedfd07260c0f0cc9b62a540"}
2024/02/23 13:22:44.727 INFO    git     provisioned app instance        {"app": "git"}
```

## Summary

Once again, here are all the things I tried in order to automate the deployment
of a static site from GitHub to a VPS server, in increasing complexity:

- Host the site on GitHub Pages or Netlify
- Run a cronjob on the server that automatically pulls the `deploy` branch at a
  given interval
- `scp` or `rsync` the generated static files to the server using GitHub Actions
- Containerize the static files into a Nginx container. This Docker image is run
  on the VPS with a sidecar [Watchtower](https://containrrr.dev/watchtower/)
  container that listens for new images
- Run a webhook server on the VPS that listens for webhook requests from the
  source repository. When a new build is ready, GitHub sends a POST request to
  the webhook server which runs a shell script to pull the new changes
- Fork `caddy-git` to implement a new `force` flag so that Caddy can
  successfully force pull the `deploy` branch at a given interval (the one I'm
  using now)

I must emphasize that I really do believe in simple implementations of software
and [reducing complexity](https://grugbrain.dev/#grug-on-complexity), especially
at work. But the reasons why I opted for the last method now were because:

- I was already using Caddy as a reverse proxy for some other sites hosted on
  the same VPS
- I was already building a custom image of `Caddy` because I was using the
  Cloudflare `caddy-dns` plugin

and most importantly,

- I found a non-trivial problem that I felt could be solved by tracing the
  source code in `caddy-git` and `go-git` and I was excited to come up with a
  solution that works

If you don't share any of these reasons, maybe just
[KISS](https://en.wikipedia.org/wiki/KISS_principle) and stick to the cronjob.
