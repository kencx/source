---
title: "makepkg"
date: 2023-07-07
lastmod: 2023-07-07
draft: true
toc: true
tags:
- arch-linux
- aur
---

`makepkg` is a script to automate the building of packages. It is provided by
the `pacman` package and used with `PKGBUILD` files to build AUR packages.

By default, `makepkg` creates package tarballs in the `$PWD` and downloads
source data directly to `src/`. Custom paths can be configured with:

- `PKGDEST` - directory for storing resulting packages
- `SRCDEST` - directory for storing source data. Symlinks to `src/`
- `SRCPKGDEST` - directory for storing resulting source packages built with
  `makepkg -S`

## Usage

{{< alert type="warning" >}}
`makepkg` **cannot** be run as root. A dedicated user or the `nobody` user should be used to run `makepkg` if necessary.
{{< /alert >}}

1. Install the required dependencies:

```bash
$ pacman -S --needed base-devel
```

2. Acquire the build files from the AUR

```bash
$ git clone https://aur.archlinux.org/[package].git
```

3. View the contents of PKGBUILD:

```bash
$ cd [package]
$ less PKGBUILD
```

4. Build the package with `makepkg`

```bash
$ makepkg [-sci]
```

- `-s` installs the necessary dependencies
- `-i` installs the package file `pkgname-pkgver.pkg.tar.zst`
- `-c` cleans up leftover files and directories

### Update Files

To upgrade the same package, update the files in the package's directory

```bash
$ cd [package]
$ git pull
```

## Optimization
### Compression
Skip compression of package file by changing `PKGEXT`:

```conf
#PKGEXT='.pkg.tar.xz'
PKGEXT='.pkg.tar'
```

Utilize multiple cores with `COMPRESSXZ`:

```conf
COMPRESSXZ=(xz -c -z --threads=0 -)
```

These variables can also be added as environment variables:

```bash
$ PKGEXT=.pkg.tar makepkg
```

# References
- [Arch Linux Wiki - AUR](https://wiki.archlinux.org/title/Arch_User_Repository)
- [Arch Linux Wiki - makepkg](https://wiki.archlinux.org/title/Makepkg#Tips_and_tricks)
- [Arch Linux Wiki - PKGBUILD](https://wiki.archlinux.org/title/PKGBUILD)
- [Arch Linux Wiki - Creating Packages](https://wiki.archlinux.org/title/creating_packages)
