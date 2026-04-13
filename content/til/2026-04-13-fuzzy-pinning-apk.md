+++
title = "How to use lax pinning in Alpine Linux"
date = "2026-04-13"
updated = "2026-04-13"

[taxonomies]
tags = ["alpine linux"]
+++

To pin the version to a major or minor release in `apk` (i.e. fuzzy matching):

```sh
# matches 3.X.Y-rZ
apk add 'openssl=~3'

# matches 3.5.Y-rZ
apk add 'openssl=~3.5'

# matches 3.5.1-rZ
apk add 'openssl=~3.5.1'
```

By default, `apk add` will avoid changing installed packages unless required.
This means if the installed version of `openssl` is `3.5.1`, and we run `apk add
openssl=~3.5` it will not be upgraded to `3.5.2` if its available.

To upgrade to the latest installable version (eg. `3.5.2`), we must use `apk add
--upgrade openssl=~3.5`.

## References
- [apk - Package Pinning](https://wiki.alpinelinux.org/wiki/Alpine_Package_Keeper#Package_pinning)
- [apk-add](https://man.archlinux.org/man/apk-add.8.en)
