+++
title = "About the conditional execute flag in chmod"
date = "2025-06-20"
updated = "2025-06-20"
draft = false
[taxonomies]
tags = ["linux"]
+++

`X` (capital `x`) is a special flag in `chmod` that:

{% quote(source="[chmod(1)](https://www.mankier.com/1/chmod)") %}
execute/search only if the file is a directory or already has execute
permission for some user (X)
{% end %}

In other words, it ignores any regular files that does not have the execute bit
`x` set (non-executables). This is useful when trying to recursively `chmod +x`
a directory of files and sub-directories without having to distinguish between
the regular files and directories/executables.

## Usage

```bash
$ chmod -R u=rwX,g=rX,o=rX foo/
```

The above will set in `foo/` and its sub-directories:

- The owner permissions to read and write in all cases, and execute for
  directories and executables only.
- The group and other permissions to read in all cases, and execute for
  directories and executables only.

## References

- [What is the capital X in POSIX chmod](https://unix.stackexchange.com/questions/416877/what-is-a-capital-x-in-posix-chmod)
