---
title: "Command vs shell module"
date: 2023-01-03
lastmod: 2023-01-03
draft: false
toc: false
tags:
- ansible
---

## Command

The `command` module executes commands on targets. These commands will **not** be
processed through a shell. Environment variables like `$HOME` and shell operations like
redirection and piping (`<, >, |`) will not work.

## Shell

With the `shell` module, commands are executed through a shell (default: `/bin/sh`) on
the target. Shell operations like redirection and variable expansion will work.

It is recommended to use `command` unless shell operations are used.
