---
title: "Get filename or extension"
date: 2023-07-30
lastmod: 2023-07-30
draft: false
toc: false
tags:
- bash
- snippets
---

Some methods of extracting the filename or file extension with Bash.

## Shell Parameter Expansion

```bash
$ path="/home/foo/hello.tar.gz"
$ filename=$(basename $path)

# extension
$ echo "${filename#*.}"
tar.gz

$ echo "${filename##*.}"
gz

# filename
$ echo "${filename%.*}"
hello.tar

$ echo "${filename%%.*}"
hello
```

## basename

```bash
$ basename /home/foo/hello.tar.gz .tar.gz
hello
```

## References
- [Bash - Shell Parameter Expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)
