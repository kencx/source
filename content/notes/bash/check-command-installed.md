---
title: "Check Command Installed"
date: 2023-04-01
lastmod: 2023-04-01
draft: false
toc: false
tags:
- bash
- snippet
---

This snippet is useful when checking if a specific command is installed on the
system:

```bash
if ! [[ command -v "$foo" > /dev/null 2>&1 ]]; then
	...
fi
```

`command -v` returns the binary pathname of the given command.

However, the above snippet can work with aliases, functions and builtins, which
can be misleading when we have an executable of the same name. Instead, we can
use the following to detect the existence of a command that is provided by an
executable file found on the current `PATH`:

```bash
if ! [[ $(type -p "$1") ]]; then
	...
fi
```

## References
- [r/programming - Anybody can wrte good bash with a little effort](https://www.reddit.com/r/programming/comments/esu8gu/anybody_can_write_good_bash_with_a_little_effort/ffdk2pl/)
