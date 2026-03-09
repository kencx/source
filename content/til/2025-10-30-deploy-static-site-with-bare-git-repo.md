+++
title = "How to deploy a static site with a bare git repository"
date = "2025-10-30"
updated = "2025-10-30"

[taxonomies]
tags = ["git"]
+++

On your server,

```bash
# initialize the bare git repository
$ git clone --bare https://github.com/kencx/source.git blog.git

# create the target directory
$ mkdir blog

# create the git post-receive hook
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
    cp "$GIT_DIR/refs/heads/$BRANCH" "$TARGET/master"
    cd "$TARGET" && zola build
  else
    echo "Ref $ref received. Doing nothing..."
  fi
done
EOF
$ chmod u+x blog.git/hooks/post-receive
```

On your local system, setup a new remote in the git repository,

```bash
$ cd /path/to/repo

$ git remote add origin git@github.com:kencx/source.git

# add the original source as a push remote
$ git remote set-url --add --push origin git@github.com:kencx/source.git

# add the bare git repository in the server on the same remote
$ git remote set-url --add --push origin ssh://foo@my.server/path/to/blog.git

# Pushing to origin will push to both remotes at the same time
$ git push origin master
```

Point your web server to `/path/to/blog` to serve the static site.
