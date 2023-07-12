---
title: "Arch Linux Installation on USB"
date: 2022-12-29T17:33:17+08:00
lastmod: 2022-12-29T17:33:17+08:00
draft: true
toc: true
tags:
- linux
- arch linux
---

This guide installs a **persistent** Arch Linux system on a USB drive. It will support
booting with both BIOS and UEFI.

## Prerequisites
### Prepare Installation Medium

```bash
$ dd bs=4M if=path/to/iso of=/dev/sdX conv=fsync oflag=direct status=progress
```

To support all systems (BIOS & UEFI), we recommend creating the subsequent partition layout:

```bash
# 10M BIOS partition, 500M EFI partition and a Linux partition
$ sgdisk -o -n 1:0:+10M -t 1:EF02 -n 2:0:+500M -t 2:EF00 -n 3:0:0 -t 3:8300 /dev/sdX
```

Format the EFI and Linux partitions:

```bash
$ mkfs.fat -F32 /dev/sdX2
$ mkfs.ext4 /dev/sdX3
```

>Do NOT format the /dev/sdX1 block. This is the BIOS/MBR partition.

Mount the partitions:

```bash
$ mkdir -p /mnt/usb/boot
$ mount /dev/sdX3 /mnt/usb
$ mount /dev/sdX2 /mnt/usb/boot
```

## Installation
### From an existing Arch Linux system

Install the `arch-install-scripts` package

```bash
$ pacman -S arch-install-scripts
```

From here, follow the [Arch Linux Installation]({{< ref "/notes/arch/arch-linux-install.md#installation" >}}) notes.


### From another Linux distribution

If you are installing Arch Linux from a different distro (Ubuntu, Debian etc.),
we must set up an environment from which the `arch-install-scripts` can be run.
They provide important commands such as `pacstrap, arch-chroot` etc. See
[here](https://wiki.archlinux.org/title/Install_Arch_Linux_from_existing_Linux#From_a_host_running_another_Linux_distribution)
to do this manually.

I recommend using [arch-bootstrap](https://github.com/tokland/arch-bootstrap) as
a out-of-the-box solution to bootstrap a base Arch system into any Linux distro.
With arch-bootstrap,

```bash
$ mkdir arch
$ ./arch-bootstrap ./arch
```

This will bootstrap a minimal Arch Linux system at the destination `./arch`. When
completed, `chroot` into `./arch` and continue the installation as if from an
[existing Arch Linux system](#from-an-existing-arch-linux-system).

## USB-Specific Configuration
### Bootloader
```bash
$ pacman -S grub efibootmgr

# Install grub for both BIOS and UEFI booting modes
$ grub-install --target=i386-pc --recheck _/dev/sdX_
$ grub-install --target=x86_64-efi --efi-directory /boot --recheck --removable
$ grub-mkconfig -o /boot/grub/grub.cfg
```

### noatime
Decrease excess writes to USB by ensuring the filesystems are mounted with `noatime`. Replace all `relatime` or `atime` options in `/etc/fstab` with `noatime`

### journal
Prevent `journald` from writing to the USB by configuring it to use RAM:

```bash
$ mkdir -p /etc/systemd/journald.conf.d
$ vim /etc/systemd/journald.conf.d/10-volatile.conf

---
[Journal]
Storage=volatile
SystemMaxUse=16M
RuntimeMaxUse=32M
```

### mkinitcpio
- Ensure needed modules are always included in the initcpio image. Remove `autodetect` from `HOOKS` in `/etc/mkinitcpio.conf`
- Disable fallback image generation by removing `fallback` from `PRESETS` in `/etc/mkinitcpio.d/linux.preset`. Delete the existing fallback image

```bash
$ rm /boot/initramfs-linux-fallback.img
$ mkinitcpio -P
$ grub-mkconfig -o /boot/grub/grub.cfg
```

## References
- [Install Arch Linux on removable medium](https://wiki.archlinux.org/title/Install_Arch_Linux_on_a_removable_medium)
- [arch-usb](https://mags.zone/help/arch-usb.html)
- [Arch Linux on a USB stick](https://www.youtube.com/watch?v=yaThYGr37DI)
