---
title: "Amending a commit"
date: 2023-10-30
draft: false
toc: true
tags:
  - git
---

## Amending the latest commit

To amend the last commit while keeping the same commit message:

```bash
$ git commit --amend --no-edit
```

The `--amend` flag is equivalent to manually performing an [undo]({{< ref
"til/git/undo-commit.md" >}}), adding the changes and creating a new commit:

```bash
$ git reset --soft HEAD^
$ # make changes
$ git commit --reuse-message=ORIG_HEAD
```

## Amending a commit message

To amend the last commit message:

```bash
$ git commit --amend
```

This creates a new commit that will replace the current `HEAD`, but with a new
commit message.

## Amending a pushed commit

If a commit is amended after it has been pushed, we must run a force push to the
remote:

```bash
$ git push -f <remote-name> <branch_name>
```
{{< alert type="note" >}}
Ensure no other changes have been made by others before you push.
{{< /alert >}}
