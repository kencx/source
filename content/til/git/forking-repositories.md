---
title: "Forking Repositories"
date: 2023-07-07
lastmod: 2023-10-30
draft: false
toc: true
tags:
- git
---

There are two common reasons to fork a project:

- To contribute to the upstream repository
- To maintain a custom version of the same project

## Contributing to Upstream Repository

When contributing to a project, we perform the following steps:
1. Fork the upstream repository
2. Clone the forked repository

```bash
$ git clone git@github.com:kencx/foo.git && cd foo
```

3. Create a feature branch

```bash
$ git checkout -b feature-branch
```

It is good practice to make our changes on a feature branch for two reasons:
- Having a clean `master` branch for future PRs
- [Merging any upstream changes](#syncing-fork) into `master` cleanly

4. Make and commit changes on the feature branch
5. Push the feature branch to our fork

```bash
$ git push origin feature-branch
```

6. Open a pull request with the upstream repository

### Syncing Fork

If we work regularly with a project, we would want to keep our forked repository
in sync with the upstream. To do so, we must add the upstream repository as a
remote and set the local `master` branch to track the `master` from `upstream`:

```bash
$ git remote add upstream [clone-url]
$ git fetch upstream
$ git checkout master
$ git branch --set-upstream-to=upstream/master
```

With this, we can easily update any feature branch or pull request with upstream changes:

```bash
$ git checkout master
$ git rebase upstream/master
# or
$ git pull --rebase
```

{{< alert type="note" >}}
You may need to stash any uncommitted changes with `git stash` before rebasing.
{{< /alert >}}

Then, with the `master` branch updated, we can rebase our feature branch on top
of the new changes in `master`:

```bash
$ git checkout feature-branch
$ git rebase master
```

If the local `master` branch does not have any unique commits, Git will perform a fast-forward. Otherwise, we must take extra steps to resolve merge conflicts. This is why it is helpful to use feature branches, even on a fork.

## Maintaining a Custom Fork

Alternatively, we may fork a repository to maintain a custom fork of the
repository. In this case, we would make changes that might not be merged into
the upstream repository. Trying to fetch and merge upstream changes would hence,
require a separate `upstream_master` branch.

1. Create the `upstream_master` branch:

```bash
$ git checkout -b upstream_master
```

2. Fetch upstream changes to this branch:

```bash
$ git remote add upstream [url]
$ git fetch
```

3. Merge upstream changes to `upstream_master`

```bash
$ git merge upstream upstream_master
```

4. Now, we have two `master` branches:
    - The `master` branch with your custom changes
    - The `upstream_master` branch with the upstream changes

```bash
$ git diff upstream_master master --stat
```

We can choose to either rebase our changes on top of the upstream changes:

```bash
$ git checkout master
$ git rebase upstream_master
```

Or we can choose to merge these upstream changes directly:

```bash
$ git checkout master
$ git merge upstream_master --no-ff
```

This would require the `--no-ff` flag since the two branch histories have
diverged. Resolve any merge conflicts and perform a merge commit.

{{< alert type="info" >}}
If you wish to contribute a change upstream, create a third (feature) branch to
host these changes. Submit a pull request then merge the changes after.
{{< /alert >}}


## References

- [How to update or sync a forked repository?](https://stackoverflow.com/questions/7244321/how-do-i-update-or-sync-a-forked-repository-on-github)
