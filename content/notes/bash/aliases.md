---
title: "Aliases"
date: 2023-04-01
lastmod: 2023-04-01
draft: true
toc: false
tags:
- bash
---

Aliases allow a string to be substituted for a word:

```bash
$ alias hello="echo hello world"
$ hello
hello world
```

Since aliases are textual substitutions, we can append arguments to them

```
$ hello foo
hello world foo
```

## No Recursive Expansion
When a command is tested for aliases, a word that is identical to the alias being expanded is not expanded recursively. For example, the alias

```bash
alias ls='ls -F'
```

is not expanded recursively.

## Bypassing Aliases
If we wish to run a command which we have assigned an alias of the same name, we can bypass them in two ways:

- Using the `command` builtin for commands

```bash
$ alias rm="echo 'Do not use rm'"

# runs /usr/bin/rm directly
$ command rm
```

Similarly, it works for builtins with `builtin`:

```bash
$ builtin cd /
```

- Escaping *any* character within the command

```bash
$ \rm
$ \r\m
```

## Using Alises with sudo
Because only the first word in a command is checked for aliases, a command like

```bash
$ sudo ll
```

results in only `sudo` being checked for aliases and `ll` being ignored. However, if the last character of an alias is a space or tab, Bash will check the next command word for aliases as well.

As such, we can use `sudo` with aliases by aliasing `sudo` to:

```bash
alias sudo='sudo '
```

## References
- [Shell aliases and bypassing them](https://www.youtube.com/watch?v=6okEabkL_q0)
- [Aliases not available when using sudo](https://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo)
