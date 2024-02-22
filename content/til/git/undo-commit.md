---
title: "Undoing a commit"
date: 2023-10-30
lastmod: 2023-10-30
draft: false
toc: false
tags:
- git
---

After a commit, we can perform a soft reset to undo a commit.
```bash
$ git reset --soft HEAD
```

To undo this undo, we can perform a hard reset with `ORIG_HEAD`:

```bash
$ git reset --hard ORIG_HEAD
```

Alternatively, we can also use `git reflog` in both cases.

## References
- [Recovering from Git mistakes with ORIG_HEAD](https://www.youtube.com/watch?v=yhtq_PSekdo)
