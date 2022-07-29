---
title: "Rebase"
date: 2022-02-20T01:33:05+08:00
lastmod:
draft: false
toc: true
tags:
  - git
---

>**Warning**:
>Before performing any rebasing, ensure that you are not overwriting any changes
>from other contributors or colleagues.

## Amend commit message N commits ago

In order to **amend** a commit message from many commits ago, we need to perform
an interactive rebase

```bash
$ git rebase -i HEAD~N
```

If its the initial commit,

```bash
$ git rebase -i --root
```

You would be put into your editor with the various commits. Identify the commit
you would like to amend the message of and replace `pick` with `reword`. Save
and quit.

```bash
reword 43f8707f9 fix: wrong commit message
pick cea1fb88a fix: ...
pick aa540c364 fix: ...
pick c5e078656 chore: ...
pick 11ce0ab34 fix: ...
```

Make the changes and use `git log` to check. Finally, force push the changes.

```bash
$ git push -f [remote] [branch]
```

## Squash the last N commits
To **squash** the last N commits, we perform an interactive rebase.

```bash
$ git rebase -i HEAD~N
```

Similarly, you would be placed into the editor. For the commits you wish to squash, replace `pick` with `squash`, **up to the parent commit**.

```bash
pick 43f8707f9 fix: ...
pick cea1fb88a fix: ...   # <-- we squash all future commits into this commit
squash aa540c364 fix: ...
squash c5e078656 chore: ...
squash 11ce0ab34 fix: ...
```

Save and write a new commit message. Force push the changes.

```bash
$ git push -f [remote] [branch]
```

## Pull squashed commits

You might have squashed remote commits that you wish to pull to a separate local
repository, that contains the unsquashed commits. In order to maintain the same
history, we must perform a `fetch` to prevent merging.

```bash
$ git fetch
$ git checkout [branch]
$ git reset --hard @{upstream}
```

We then checkout the branch with the squashed commits and perform a reset to
make the local branch point at the same commit as the remote branch.
