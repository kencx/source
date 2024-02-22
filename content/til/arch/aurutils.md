---
title: "aurutils"
date: 2023-07-07
lastmod: 2023-07-07
draft: false
toc: false
tags:
- arch-linux
- aur
---

[aurutils](https://github.com/AladW/aurutils) is an alternative helper that
provides a collection of scripts to automate management of AUR packages. Unlike
higher-level wrapper tools, aurutils' approach to managing packages involves
working with [custom repositories]({{< ref "til/arch/custom-repository.md"
>}}).

Packages are download and built to a local repository, before being installed by
`pacman`:

```bash
$ aur sync -d [database-name] --no-view [package]
$ sudo pacman -Syu [package]
```

where `database-name` is the name of the custom repository specified in `/etc/pacman.conf`.

To remove a package,

```bash
$ repo-remove /path/to/db/db.tar.xz [package]
$ rm -rf /path/to/db/[package]
$ sudo pacman -Syu
```

List all added packages from a database:

```bash
$ aur repo --list -d [database-name]
```

List all available upgrades:

```bash
$ aur repo --database [database-name] --list -S | aur vercmp --quiet
```

Sync and upgrade all packages in database:

```bash
$ aur sync -d [database-name] --no-view --upgrades -k0
```

{{< alert type="info" >}}
- [aurto](https://github.com/alexheretic/aurto) is a wrapper tool for `aurutils`.
- [aura](https://github.com/kencx/aura) is my own custom wrapper script for
  `aurutils`.
{{< /alert >}}

## References
- [Arch Linux Wiki - AUR](https://wiki.archlinux.org/title/Arch_User_Repository)
- [aurutils](https://github.com/AladW/aurutils)
- [aurutils installation and
  configuration](https://gist.github.com/geosharma/afe1ea9ebe58cb67aaaba62a0d47bc7a)
