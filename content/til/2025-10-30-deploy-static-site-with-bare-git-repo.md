+++
title = "How to deploy a static site with a bare git repository"
date = "2025-10-30"
updated = 2026-03-31

[taxonomies]
tags = ["git"]
+++

It is possible to deploy a static site without CI/CD by using a bare git
repository on a remote server.

1. Initialize a bare git repository on the remote server

```sh
$ git clone --bare https://github.com/kencx/source.git blog.git
```

2. Create a target worktree directory on the remote server

```sh
$ mkdir blog
```

3. Create the following git post-receive hook script inside the bare git
   repository

This script checks out a copy of the working directory into the directory we
created above, before running `zola build` to build the static site.

```sh
$ touch blog.git/hooks/post-receive
$ cat <<EOF > blog.git/hooks/post-receive
#/bin/sh
set -e

TARGET="/path/to/blog"
GIT_DIR="/path/to/blog.git"
BRANCH="master"

while read oldrev newrev ref; do
  if [ "$ref" = "refs/heads/$BRANCH" ]; then
    echo "Ref $ref received. Deploying $BRANCH branch..."
    git --work-tree="$TARGET" --git-dir="$GIT_DIR" clean -fd
    git --work-tree="$TARGET" --git-dir="$GIT_DIR" checkout -f "$BRANCH"
    cp "$GIT_DIR/refs/heads/$BRANCH" "$TARGET/$BRANCH"
    cd "$TARGET" && zola build
  else
    echo "Ref $ref received. Doing nothing..."
  fi
done
EOF
$ chmod u+x blog.git/hooks/post-receive
```

{% alert(type="Note") %}
This script builds the static files in the directory `$TARGET/public`.
{% end %}

4. On your local system, setup a new remote in the git repository,

```sh
$ cd /path/to/repo

$ git remote add origin git@github.com:kencx/source.git
```

5. Add multiple sources to the same remote `origin`

```sh
# add the original source as a push remote
$ git remote set-url --add --push origin git@github.com:kencx/source.git

# add the bare git repository in the server on the same remote
$ git remote set-url --add --push origin ssh://foo@my.server/path/to/blog.git
```

6. Pushing to this remote will push to both remotes at the same time

```sh
# Pushing to origin will push to both remotes at the same time
$ git push origin master
```

7. Point your web server to `/path/to/blog/public` to serve the static site
