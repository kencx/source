---
title: "Git Fetch"
date: 2022-04-19T12:44:09+08:00
lastmod: 2022-04-19T12:44:09+08:00
draft: false
toc: false
tags:
  - git
---

It is good practice to run `git fetch` instead of `git pull` when collecting changes from remote.

To view all fetched commits from the remote "master" compared to the local "master":

```bash
$ git log origin/master ^master
```

To view all files that will be modified after a `git pull`,

```bash
$ git fetch && git diff HEAD @{u} --name-only
```

To view all changes that will be applied (in the files) after `git pull`

```bash
$ git fetch && git diff HEAD @{u}
```

To view all changes that will be applied INCLUDING uncommitted local changes,

```bash
$ git fetch && git diff @{u}
```
