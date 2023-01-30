---
title: "Arch Linux Installation"
date: 2022-12-29T17:19:20+08:00
lastmod: 2022-12-29T17:19:20+08:00
draft: false
toc: true
tags:
- linux
- arch linux
---

## Pre-Installation
### Prepare Installation Medium
Copy the Arch Linux ISO to a USB flash drive

```bash
$ dd bs=4M if=path/to/iso of=/dev/sdX conv=fsync oflag=direct status=progress
```

Plug the flash drive into your device and select it at boot.

### Verify the boot mode
Check if your system is booted in BIOS or UEFI mode.

```bash
$ ls /sys/firmware/efi/efivars
```

If the command lists the directory's contents without error, the system is booted in
UEFI mode. Otherwise, the system may be booted in BIOS mode.

### Connect to Internet
1. Ensure the network interface is listed and enabled

```bash
$ ip link
$ ip link set eth0 up
```

2. If using wireless, ensure your wireless card is [not blocked](https://wiki.archlinux.org/title/Network_configuration/Wireless#Rfkill_caveat).

```bash
$ rfkill list
$ rfkill unblock wifi
```

3. Connect to the network. If using Wifi, authenticate using
   [iwctl](https://wiki.archlinux.org/title/Iwd#iwctl)

4. Configure your network connection. DHCP should work out of the box, managed by `systemd-networkd` and `systemd-resolved`.

For static IPs, add an IP address, set up your routing table and configure DNS servers:

```bash
# add IP address
$ ip address add 10.10.10.100/24 dev eth0

# add route
$ ip route add default via 10.10.10.1 dev eth0
```

5. Verify the connection

```bash
$ ping archlinux.org
```

### Update system clock
```bash
$ timedatectl set-ntp true
$ timedatectl set-timezone Asia/Singapore
$ timedatectl status
```

### Partitions
Partition the base disk based on the boot type:

#### BIOS/MBR
| Mount point | Partition           | Type         | Size      |
| ----------- | ------------------- | ------------ | --------- |
| `[SWAP]`    | /dev/swap_partition | Linux swap   | >512MiB   |
| `/mnt`      | /dev/root_partition | Linux x86-64 | Remainder |

#### BIOS/GPT
| Mount point | Partition           | Type                | Size      |
| ----------- | ------------------- | ------------------- | --------- |
| None        | /dev/sdX1           | BIOS boot partition | 1MB       |
| `[SWAP]`    | /dev/swap_partition | Linux swap          | >512MiB   |
| `/mnt`      | /dev/root_partition | Linux x86-64        | Remainder |

#### UEFI
| Mount point | Partition                 | Type                  | Size                 |
| ----------- | ------------------------- | --------------------- | -------------------- |
| `/mnt/boot` | /dev/efi_system_partition | EFI system partition | >300 MiB             |
| `[SWAP]`    | /dev/swap_partition       | Linux swap            | >512MiB              |
| `/mnt`      | /dev/root_partition       | Linux x86-64          | Remainder            |
| `/mnt/home` | /dev/home_partition       | Linux x86-64          | Remainder (optional) |


{{< alert type="note" >}}
If the disk from which you want to boot [already has an EFI system
partition](https://wiki.archlinux.org/title/EFI_system_partition#Check_for_an_existing_partition
"EFI system partition"), do not create another one, but use the existing partition
instead.
{{< /alert >}}

```bash
$ lsblk
$ fdisk /dev/sda
```

Format the partitions:

```bash
$ mkswap /dev/sda1         # for swap partition (optional)
$ mkfs.ext4 /dev/sda2      # for root partition
$ mkfs.fat -F 32 /dev/sda3 # for efi partition (if present)
```

Mount the file systems:

```bash
$ swapon /dev/sda1                  # swap (optional)
$ mount /dev/sda2 /mnt              # root partition
$ mount --mkdir /dev/sda3 /boot/efi # (uefi only) boot partition
```

## Installation

```bash
$ pacstrap -K /mnt base linux linux-firmware
```

You can substitute [linux](https://archlinux.org/packages/?name=linux) for a [kernel](https://wiki.archlinux.org/title/Kernel "Kernel") package of your choice, or you could omit it entirely when installing in a container.


{{< alert type="info" >}}
If such an [error](https://bbs.archlinux.org/viewtopic.php?id=282191) is encountered:

```bash
error: openssl signature from "Pierre Schmitz <pierre@archlinux.org>" is marginal trust
:: File /mnt/var/cache/pacman/pkg/openssl-3.0.7-4-x86_64.pkg.tar.zst is corrupted (invalid or corrupted package (PGP signature)).
```

Consider updating the keyring first with `pacman -Sy archlinux-keyring`.
{{< /alert >}}


## Configuration
### Fstab and Chroot
Generate an fstab file, then chroot into the new system

```bash
$ genfstab -U /mnt >> /mnt/etc/fstab
$ arch-chroot /mnt
```

### GRUB
Install and configure [grub](https://wiki.archlinux.org/title/GRUB):

```bash
$ pacman -S grub efibootmgr

# for uefi
$ grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot --removable

# for bios
# /dev/sda is the disk where grub is to be installed
$ grub-install --target=i386-pc /dev/sda

# generate config file
$ grub-mkconfig -o /boot/grub/grub.cfg
```

### Timezone
```bash
$ ln -s /usr/share/zoneinfo/Asia/Singapore /etc/localtime
$ hwclock --systohc
```

### Localization
```bash
$ vim /etc/locale.gen
# uncomment en_US.UTF-8 UTF-8
$ locale-gen
```

```bash
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "hostname" > /etc/hostname
```

### Create non-root user
```bash
$ passwd
$ useradd -m [username]
$ passwd [username]
```

Install and configure sudo

```bash
$ pacman -S sudo
$ export EDITOR=vim
$ visudo
# uncomment wheel ALL(ALL:)=ALL
```

Add user to wheel group (sudo). Logout and login again for changes to take effect.

```bash
$ usermod -aG wheel kenc
```

### Network Configuration
Install the necessary networking packages now.

```bash
$ pacman -S networkmanager iwd
```

If you forget to install and configure networking during the installation, and only realise after reboot, you can boot into the live USB again and perform the installation without re-installing the entire Arch system. Simply remount the drives and `arch-chroot /mnt` again.

### Reboot
```bash
# exit the chroot env
$ exit
$ umount -R /mnt
$ reboot
```

#### Alternative Methods
- Run [archinstall](https://github.com/archlinux/archinstall) for a quick, guided installation
- Arch Linux on USB

## References
- [Arch Wiki - Installation](https://wiki.archlinux.org/title/installation_guide)
