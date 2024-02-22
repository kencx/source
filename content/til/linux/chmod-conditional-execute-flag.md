---
title: "Conditional Execute Flag in chmod"
date: 2023-07-12
lastmod: 2023-07-12
draft: false
toc: false
tags:
- permissions
- linux
---

`X` (capital `x`) is a special flag that sets the execute bit conditionally:

- If the file is a directory, or has any execute bit set in its current
  permissions, it sets the execute bit `x`.
- If the file is a regular file with no execute bit set, it is ignored.

From the `chmod` [manpage](https://www.mankier.com/1/chmod):

>execute/search only if the file is a directory or already has execute
>permission for some user (X)

This special flag allows `chmod` to be used flexibly with a variety of file
types without having to distinguish between files and directories/executables.

## Example

```bash
$ chmod -R u=rwX,g=rX,o=rX foo/
```

The above will set in `foo/`:

- The owner permissions to read and write in all cases, and execute for
  directories and executables only.
- The group and other permissions to read in all cases, and execute for
  directories and executables only.

Because the `-R` flag is given, this is extended to all nested sub-directories
as well.

## References

- [What is the capital X in POSIX chmod](https://unix.stackexchange.com/questions/416877/what-is-a-capital-x-in-posix-chmod)
