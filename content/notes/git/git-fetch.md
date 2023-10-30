---
title: "Viewing fetched upstream changes"
date: 2022-04-19T12:44:09+08:00
lastmod: 2022-04-19T12:44:09+08:00
draft: false
toc: true
tags:
  - git
---

Its good practice to run `git fetch` instead of `git pull`. This way, we can
observe the fetched changes before choosing to merge or rebase our local
changes.

## Upstream HEAD Ref

The special ref `@{u}` or `HEAD@{u}` is equivalent to the remote `HEAD` of the
current branch's remote-tracking branch. For `master`, this is `origin/master`:

```bash
# all output the same commit hash
$ git rev-parse origin/master
$ git rev-parse HEAD@{u}
$ git rev-parse @{u}
```

## Viewing fetched commits

To view all fetched commits from the remote (`origin/master`) compared to the
local `master`, we can use `git log` in several similar forms

```bash
$ git log origin/master ^master
# equivalent to
$ git log HEAD@{u} ^master
# or
$ git log master..HEAD@{u}
```

Adding the `-p` to the above would also enable us to see the explicit diffs of
the fetched commits. Alternatively, we can use `git diff` as described below.

## Viewing fetched diffs

To show the fetched changes from the remote (`origin/master`), we can use `git
diff` with three combinations of specifiers to see different diffs:

```bash
# show incoming changes as DELETIONS.
# show local (staged and unstaged) changes
$ git diff origin/master

# show incoming changes as ADDITIONS.
# DOES NOT show local (staged and unstaged) changes
$ git diff HEAD..origin/master

# show incoming changes as ADDITIONS.
# excludes changes committed to local repository
$ git diff HEAD...origin/master
```

We can also add the flags `--stat` and `--name-only` to show a summary or
filenames only.

{{< alert type="note" >}}
For a simple fast-forward operation, `..` and `...` are equivalent.
{{< /alert >}}

If a remote-tracking branch is configured, we can also use `HEAD@{u}` or `@{u}`
to refer to `origin/master`:

```bash
$ git diff ...HEAD@{u}
# equivalent to
$ git diff ...@{u}
# or
$ git checkout master
$ git diff master...origin/master
```

## References

- [How to check real git diff before merging from remote branch](https://stackoverflow.com/questions/4944376/how-to-check-real-git-diff-before-merging-from-remote-branch)
- [Git Tools - Revision Selection](https://git-scm.com/book/en/v2/Git-Tools-Revision-Selection#Commit-Ranges)
