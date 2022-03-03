---
title: "Installing Nvidia Drivers on Ubuntu"
date: 2022-02-25T23:21:25+08:00
lastmod:
draft: false
toc: false
---

This guide is for Ubuntu/Debian systems only.

## Installation

1. Identify your graphics card

```bash
$ lshw -C display
```

2. Determine the necessary driver version for your card at the
   [Nvidia](https://www.nvidia.com/Download/index.aspx) site.

3. Search for a list of Nvidia drivers in Ubuntu/Debian systems with

```bash
$ apt search nvidia-driver | less
```

4. Install the appropriate driver recommended by Nvidia in step 2.

```bash
$ sudo apt install nvidia-driver-510
```

5. Reboot your system.

## Updates

There are 2 forms of driver updates - minor and major.

#### Minor Updates

Minor updates happen when there is a patch to the currently installed driver
version. Nvidia drivers do not update with `sudo apt upgrade`, but with `sudo apt
full-upgrade` instead.

1. Check the update list to ensure you know what you are updating

```bash
$ sudo apt list --upgradable
```

2. Perform the update

```bash
$ sudo apt full-upgrade
```

3. Reboot your system.

#### Major Updates

Major updates happen when there is a new driver released.

1. Firstly, check that the driver is compatible with your graphics
   card on the [Nvidia](https://www.nvidia.com/Download/index.aspx) site. Older
   cards might not be supported.

2. Perform a full installation of the new version with `sudo apt
   install`. The installation should remove any old driver versions at the same
   time.

```bash
$ sudo apt install nvidia-driver-[new-version-num]
```

3. Reboot your system

## References
- [Nvidia - ArchWiki](https://wiki.archlinux.org/title/NVIDIA)
