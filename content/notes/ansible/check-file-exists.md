---
title: "Check if file exists"
date: 2023-01-03
lastmod: 2023-01-03
draft: false
toc: false
tags:
- ansible
- snippets
---

```yaml
tasks:
  - name: Check if path exists
    stat:
	    path: "/path/to/file"
	register: result

  - name: Do something if path exists
    command: ...
    when: result.stat.exists

  - name: Do something else if path does not exists
    command: ...
    when: not result.stat.exists
```
