+++
title = "How to install a package from the edge branch in Alpine Linux"
date = "2026-10-20"
updated = "2026-10-20"

[taxonomies]
tags = ["alpine linux"]
+++

To install a specific package from the `edge` branch WITHOUT upgrading all
packages, add the following to `/etc/apk/repositories`:

```
@community https://dl-cdn.alpinelinux.org/alpine/edge/community
@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing
```

Install a specific package from the edge branch:

```
apk update
apk add zola@community
```
