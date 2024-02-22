---
title: "Xinit"
date: 2022-12-29T20:03:58+08:00
lastmod: 2022-12-29T20:03:58+08:00
draft: false
toc: true
tags:
- linux
- Xorg
---

>When debugging GUI issues, you can switch to a different tty with
>`Ctrl+Alt+F{1-7}`.

[xinit](https://wiki.archlinux.org/title/Xinit) is used to start window managers
for desktop environments. It starts a
[Xorg](https://wiki.archlinux.org/title/Xorg) (or X) display server on Linux
systems.

## Installation

1. Install the required packages

```bash
$ pacman -S xorg-server xorg-xinit xterm
```

>`xterm` is necessary for xorg to work properly on a fresh install.

2. Install the required [video
   drivers](https://wiki.archlinux.org/title/xorg#Driver_installation)

```bash
# identity your graphics card
$ lspci -v | grep -A1 -e VGA -e 3D

# install appropriate driver
$ pacman -S xf86-video[-intel|-amdgpu]
```

## Configuration

1. Copy default `xinitrc` to home directory

```bash
$ cp /etc/X11/xinit/xinitrc ~/.xinitrc
```

2. Edit the file by replacing the default programs with your desired startup
   commands

```bash
# .xinitrc
...
sxhkd &
exec bspwm
```

3. Run Xorg with [startx](https://man.archlinux.org/man/startx.1). Do not use
   `exec startx`.

```bash
$ startx
```

4. To [autostart X at
   login](https://wiki.archlinux.org/title/Xinit#Autostart_X_at_login), include
   the following in the user's `.bash_profile` (or end of `.zshrc`),

```bash
# .bash_profile
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
	exec startx
fi
```

To [redirect](https://wiki.archlinux.org/title/Xorg#Session_log_redirection) all
stdout and stderr output from the Xorg session to a log file `.xorg.log`, use
the following `startx` command instead:

```bash
startx -- -keeptty > ~/.xorg.log 2>&1
```

5. If using a [display
   manager](https://wiki.archlinux.org/title/Display_manager) like
   [LightDM](https://wiki.archlinux.org/title/LightDM), you must manage
   [sessions
   startup](https://wiki.archlinux.org/title/LightDM#X_session_wrapper) with
   [`~/.xprofile`](https://wiki.archlinux.org/title/Xprofile) or run [`xinitrc`
   as a
   session](https://wiki.archlinux.org/title/Display_manager#Run_~/.xinitrc_as_a_session)

```bash
# .xprofile
sxhkd &
```

>If using [`ly`](https://github.com/fairyglade/ly), xinitrc support is enabled
>of out the box.

## References
- [Arch Wiki - xinit](https://wiki.archlinux.org/title/xinit)
