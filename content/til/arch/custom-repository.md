---
title: "Hosting Custom Repository in S3"
date: 2023-07-07
lastmod: 2023-07-07
draft: false
toc: true
tags:
- arch-linux
- aur
---

This document details some information about hosting a custom Arch repository in
a S3 bucket with aurutils.

A custom repository is useful for hosting ready-built AUR packages that are used
across multiple Arch systems.

## Architecture

To host a custom repository, we require:

- Build Server on an Arch Linux system
- File server (Nginx etc.) or S3 storage server (Minio, Amazon S3 etc.)

The build server will download the packages from the AUR, built them in a chroot
environment and add them to the repository database. We then mirror the local
repository directory to a S3 bucket that can be used to serve the files
remotely to clients.

## Build Server

The build server is where the AUR packages are downloaded and built. It must be
hosted on an Arch Linux system, or at least a distro with the available tools
(`base-devel`, `pacman`) to build and manage the packages.

1. Install `base-devel` and [aurutils](https://github.com/AladW/aurutils) (and
   optionally `vifm`)

```bash
$ pacman -S base-devel

$ git clone https://aur.archlinux.org/aurutils.git
$ cd aurutils
$ makepkg -si
```

2. Create the repository directory. In this example, we will be using
   `/var/cache/pacman/custom`.

```bash
$ mkdir -p /var/cache/pacman/custom
```

{{< alert type="note" >}}
Avoid naming the repository `local` as this is reserved by `pacman`.
{{< /alert >}}

3. Create the repository database in the repository directory

```bash
$ repo-add /var/cache/pacman/custom/custom.db.tar.xz
$ sudo chown -R $USER:$USER /var/cache/pacman/custom
```

{{< alert type="note" >}}
Optionally, you may choose to create a dedicated `aur` user to manage the
repository. Be sure to use only this dedicated user to perform operations on the
repository.
{{< /alert >}}

4. Add the custom repository to the local `pacman.conf`

```conf
## /etc/pacman.conf
[custom]
SigLevel = Optional TrustAll
Server = file:///var/cache/pacman/custom
```

5. Sync the new repository with `pacman`:

```bash
$ pacman -Syu
```

6. Add packages from the AUR with `aurutils`:

```bash
## we must specify --root if a remote repository url was given
$ aur sync --no-view --database custom [--root /var/cache/pacman/custom] [package]

## or manually a package with repo-add
$ repo-add /var/cache/pacman/custom/custom.db.tar.xz /path/to/[package].pkg.tar.zst

## install package with pacman
$ sudo pacman -S [package]
```

Remove packages with `repo-remove`:

```bash
$ repo-remove /var/cache/pacman/custom/custom.db.tar.xz [package]
$ rm -rf /var/cache/pacman/custom/[package]
$ sudo pacman -Syu
```

List and update packages:

```bash
## list packages
$ aur repo --list --database custom

## update installed packages
$ aur sync -u
```

## Serving Repository Remotely

To serve the repository files remotely, we require a traditional file server
(Nginx etc.) or S3 server (S3, Minio etc.)

An S3 server like Minio can mirror the repository directory to an initialized S3
bucket:

```bash
$ mcli mirror /var/cache/pacman/custom minio/aur --overwrite --remove
```

Now, we can choose to switch out the local path in the `pacman.conf` for a
remote URL to the S3 bucket:

```
[custom]
SigLevel = Optional TrustAll
Server = https://aur.example.com
```

The packages can also be accessed via the Minio API:

```bash
$ curl http://minio.tld:9000/bucket/file -o output
```

## Clients

Any remote clients that wish to use the repository can simply use the S3
bucket's remote URL:

```
[custom]
SigLevel = Optional TrustAll
Server = https://aur.example.com
```

## References
- [Arch Wiki - pacman/Custom Local
  Repository](https://wiki.archlinux.org/title/Pacman/Tips_and_tricks##Custom_local_repository)
- [Arch Linux Local
  Repo](https://blog.cavelab.dev/2023/02/arch-linux-local-repo/##aur-build-server)
- [Hosting an Arch Linux Repository in an Amazon S3
  Bucket](https://disconnected.systems/blog/archlinux-repo-in-aws-bucket/##dependencies)
- [aurutils](https://github.com/AladW/aurutils)
- [aurutils installation and
  configuration](https://gist.github.com/geosharma/afe1ea9ebe58cb67aaaba62a0d47bc7a)
