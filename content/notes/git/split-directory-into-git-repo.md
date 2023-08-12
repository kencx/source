---
title: "Split directory into new Git repository"
date: 2023-08-12
draft: false
toc: false
tags:
  - git
---

First, create a new branch in the root directory of your repo.

```bash
$ cd repo
$ git checkout -b new_branch
```

Next, in that new branch, specify the subdirectory to base the new repository
off

```bash
$ git filter-branch --prune-empty --subdirectory-filter path/to/subdirectory new_branch
```

Finally, create a new Github repository and change the remote, before pushing your changes

```bash
$ git remote set-url origin https://github.com/new/repo.git
$ git push -u origin new_branch
```

You can delete the branch after, but note that your original repository in
`master` is still unchanged.
