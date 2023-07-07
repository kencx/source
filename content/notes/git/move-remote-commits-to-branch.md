---
title: "Move remote commits to different branch"
date: 2022-12-29T17:04:34+08:00
lastmod: 2022-12-29T17:04:34+08:00
draft: false
toc: false
tags:
- git
---

>This action can be potentially destructive!! Take care when performing such commands.

Scenario: In the process of making a change, you forked the Git repository and
committed a change directly on the `master` branch instead of creating a new
`feature-x` branch. You don't realise until after you have pushed the commit to
remote.

The following commands create a new branch with the commit and reset the remote
`master` branch.

```bash
$ git branch [feature-x] master
$ git reset --hard $PREVIOUS_SHA
$ git push -f origin master
$ git push origin [feature-x]
```

## References
- [Moving pushed commits to a different branch](https://stackoverflow.com/questions/9086886/git-moving-pushed-commits-to-a-different-branch)
