# Source
Source for [blog](https://ken.cheo.dev). Hosted on Hetzner behind Caddy.

Built with zola.

## Deploy

Build and deploy with a bare Git repo on the web server. No CI/CD required.

```bash
# push to multiple remotes at once
$ git remote add origin <source>
$ git remote set-url --add --push origin <source>
$ git remote set-url --add --push origin ssh://<user>@<host>/path/to/blog.git
$ git push origin <branch>
```

```bash
# setup bare Git repo
$ ssh <user>@<host>
~$ git clone --bare <source> blog.git

# build and serve with git post-receive hook and zola
~$ mkdir blog
~$ touch blog.git/hooks/post-receive
~$ cat <<EOF > blog.git/hooks/post-receive
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
~$ chmod u+x blog.git/hooks/post-receive
```
