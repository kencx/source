---
title: "Editing archive files with Vim"
date: 2024-02-23
lastmod:
draft: false
toc: false
tags:
- vim
- tar
---

Vim can be used to edit archive files of multiple formats directly[^1]:

```bash
$ vim foobar.zip
$ vim foobar.tar.gz
```


## References
```text
:help tar
:help zip
:help gzip
```

[^1]: Interestingly, I discovered this when I accidentally opened an `.epub` file
with vim
