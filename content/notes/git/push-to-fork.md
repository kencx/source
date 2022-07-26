---
title: "Pushed to Forked PR"
date: 2022-07-26T21:48:42+08:00
draft: false
toc: false
tags:
  - git
---

Say a contributor has submitted a PR to **your** project. Before merging, you would
like to perform a minor change to their PR.

The contributor `contributor` made changes to their branch `feature` and created a
PR to merge the changes into `origin/master`.

#### Requirements

- The contributor forked your project
- The contributor submitted a pull request from their fork to your project
  repository
- The contributor has [explicitly
  allowed](https://stackoverflow.com/questions/20928727/adding-commits-to-another-persons-pull-request-on-github)
  you to push to their branch. This is usually the case if you are a maintainer.



#### Steps

1. Add the contributor's fork as a remote `contributor`

```bash
$ git remote add [contributor] https://github.com/[contributor]/repo.git
$ git remote -v
```

2. Pull their list of branches

```bash
$ git fetch [contributor]
```

3. Create a new branch `contributor-feature` from the branch they created the PR
   from

```bash
$ git checkout -b [contributor]-[feature] [contributor]/[feature]
```

4. Make the necessary changes.
5. Push the changes back to the PR by pushing to their branch

```bash
$ git push [contributor] [contributor-feature]:[feature]
```

Take care of the push arguments

```bash
$ git push <repository> <refspec>
```

where

- `<repository>` is the destination remote
- `<refspec>` is the source object AND destination ref/branch to update, in the
  format: `<src>:<dest-ref>`

## References

- [Push to someone else's pull request](https://gist.github.com/wtbarnes/56b942641d314522094d312bbaf33a81)
- [git-push](https://git-scm.com/docs/git-push)
