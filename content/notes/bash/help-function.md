---
title: "Help Function"
date: 2023-04-01T00:04:00+08:00
lastmod: 2023-04-01T00:04:00+08:00
draft: false
toc: false
tags:
  - bash
  - snippets
---

This snippet will print help text when given the following flags:

- `-h`
- `-help`
- `--help`
- `h`
- `help`

```bash
if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./script.sh foo bar'

...

    exit
fi
```

## References
- [Shell Script Best Practices](https://sharats.me/posts/shell-script-best-practices/)
