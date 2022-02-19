---
title: "Compose Best Practices"
date: 2022-02-19T22:51:48+08:00
lastmod:
draft: true
toc: false
tags:
  - docker
---

#### List services in order you expect them to start

Also add the `depends_on` directive to prevent premature failing of containers
that have dependencies.

#### Double quote all strings

Speaks for itself.

#### Pin versions of image

Never use `latest` tag in case of breaking changes.

#### Never forward database ports

Database ports are never public facing.

#### Naming conflicts in multiple compose instances

Label all containers with the service name to prevent clashing or confusion
between containers across compose instances. For example,

```yaml
services:
	app-name:
		...

	app-name_db:
		...
```

This way, we do not confuse this stack's database with another.
