---
title: "Tagging"
date: 2022-12-29T17:07:42+08:00
lastmod: 2022-12-29T17:07:42+08:00
draft: false
toc: true
tags:
- git
---

Git has the ability to tag specific points in a repository's history as being important. Tagging is typically used to mark release points (v1.0, v2.0 etc.)

```bash
$ git tag
$ git tag -l [regex]
```

## Creating Tags
Git supports two types of tags: lightweight & annotated.

1. Lightweight tags are pointers to a specific commit.
```bash
$ git tag [tagname]
```

2. Annotated tags are stored as full objects in the database. They are checksummed, contain the tagger name, email and date, have a message and can be signed and verified.

```bash
$ git tag -a [tagname] [-m message]
```

If `-m` is not given when creating an annotated tag, an editor will be opened to enter your tag message.

{{< alert type="note" >}}
To tag a past commit, we have to specify the commit checksum `git tag -a v1.2 9fceb02`.
{{< /alert >}}

## Deleting tags
To delete tags locally and remotely,

```bash
$ git tag -d [tagname]  # local
$ git push origin --delete [tagname]  # remote
```

## Pushing tags
To explicitly push tags to a remote

```bash
$ git push origin [tagname]
$ git push origin --tags  # pushes all tags
```

## Checkout tags

To view the versions of files a tag is pointing to, we can `git checkout` a tag.
This puts the repository into a "detached `HEAD`" state which may have some side
effects.

In this state, any committed changes will be unreachable and not be on
any branch. It can only be accessed with the commit hash. Instead, to make
changes, create a new branch with

```bash
$ git checkout -b [branch-name] [tagname]
```

## References
- [Git SCM - Tagging](https://git-scm.com/book/en/v2/Git-Basics-Tagging)
