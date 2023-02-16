---
title: "Compose - Best Practices"
date: 2022-02-19T22:51:48+08:00
lastmod:
draft: false
toc: false
tags:
  - docker
  - docker-compose
---

#### List services in order you expect them to start

Add the `depends_on` directive to prevent premature failing of containers
that have dependencies.

```yaml
services:
	app_db:
		...

	app:
		depends_on: app_db
		...
```

#### Double quote all strings

Speaks for itself.

#### Pin versions of image explicitly

Never use `latest` tag in case of breaking changes.

#### Never forward database ports

Database ports are never public facing.

#### Label all containers with service name

To prevent clashing or confusion between containers across compose instances.

```yaml
services:
	app_db:
		...

	app:
		...
```
