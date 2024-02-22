---
title: "Shell Parameters"
date: 2023-04-01T00:47:42+08:00
lastmod: 2023-04-01T00:47:42+08:00
draft: false
toc: true
tags:
  - bash
---

## Summary

| Parameter | Description                                           |
| --------- | ----------------------------------------------------- |
| `$0`      | Pathname of script                                    |
| `$N`      | Positional parameter                                  |
| `$#`      | Number of command line parameters                     |
| `$*`      | All command line parameters                           |
| `$@`      | All command line arguments                            |
| `$?`      | Exit status of most recent executed command           |
| `$$`      | Process ID of shell                                   |
| `$!`      | Process ID of most recent executed background command |
| `$-`      | Flags used in current shell                           |
| `$_`      | Last argument of previous command                     |

## Positional Parameters

A positional parameter is a parameter denoted by one or more digits (except `0`).
When calling a script with arguments, these arguments can be referenced with
positional parameters:

```bash
${N}
```

where `N` is the single digit.

If the positional parameter consists of more than one digit, it must be enclosed
in braces:

```bash
${25}
```

Positional parameters cannot be assigned directly with assignment statements,
but can be set and unset with `set` and `shift` builtins.

{{< alert type="note" >}}
For a script to process multiple arguments separately, use `shift`.
{{< /alert >}}

Positional parameters are temporarily replaced when a shell function is executed.

## Special Parameters

Certain parameters are treated by the shell specially. These parameters may only
be referenced and never assigned.

### $*

`$*` expands to a list of positional parameters. When wrapped in double quotes
`""`, it expands into a single double-quoted string containing all positional
parameters, separated by the `IFS` variable.  Without double quotes, each
positional parameter expands to a separate word.

```bash
$ ./foo "foo" "bar baz bin"
```

With double quotes:

```bash
$1 = foo bar baz bin
$2 =
$3 =
$4 =
```

Without double quotes:

```bash
$1 = foo
$2 = bar
$3 = baz
$4 = bin
```

### $@

`$@` expands to a list of positional parameters. When surrounded with double
quotes `""`, it expands into a separate word.

```bash
$ ./foo "foo" "bar baz bin"
```

With double quotes:

```bash
$1 = word
$2 = words with spaces
$3 =
$4 =
```

Without double quotes:

```bash
$1 = foo
$2 = bar
$3 = baz
$4 = bin
```

{{< alert type="note" >}}
When writing shell scripts, `"$@"` is the more useful parameter as it preserves
the integrity of each given argument.
{{< /alert >}}

### $_

In an interactive shell, `$_` expands to the last argument of the previous
command.

```bash
$ echo "test"
test
$ echo "$_"
test
```

This is useful when working with long file paths:

```bash
$ cat /long/file/path

# opens previous long file path
$ vim $_
```

or when creating and entering a directory:

```bash
$ mkdir /path/to/dir
$ cd $_
```

## References
- [Bash Manual - Shell Parameters](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameters.html)
