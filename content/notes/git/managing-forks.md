---
title: "Managing Forks"
date: 2023-07-07
lastmod: 2023-07-07
draft: false
toc: true
tags:
- git
---

## Syncing Git Fork

When contributing to a forked repository, it is good practice to make changes on
a feature branch and keep the master branch clean. This is helpful when trying
to sync upstream changes with the fork.

1. Add the upstream repository as a remote:

```bash
$ git remote add upstream [url]
```

2. Fetch all changes from the upstream remote:

```bash
$ git fetch upstream
```

3. Merge changes from upstream to master branch:

```bash
$ git checkout master
$ git merge upstream/master
```

If the local master branch does not have any unique commits, Git will perform a
fast-forward. Otherwise, we must take extra steps to resolve merge conflicts.

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
