---
title: "sxhkd Watcher"
date: 2023-04-01T00:46:00+08:00
lastmod: 2023-04-01T00:46:00+08:00
draft: false
toc: true
tags:
- sxhkd
- snippets
---

## Context

I use chord chains in `sxhkd` to create modal hotkeys, similar to those in Vim.
This allows the reuse of the same key combination for different commands,
by prefixing them with a different chord, effectively creating custom "modes".

>When multiple chords are separated by semicolons, the hotkey is a chord chain:
>the command will only be executed after receiving each chord of the chain in
>consecutive order.

For example, I have three hotkeys that use `super + h` in by prefixing them with
a different `super + [key]`:

```
# normal mode
# {focus, swap} the node in the given direction
super + {h,j,k,l}
    bspc node -f {west,south,north,east}

# node mode
# hide current window
super + n : super + h
    bspc node focused.window -g hidden=on

# preselect mode
# preselect the direction
super + p : super + {h,j,k,l}
    bspc node -p {west,south,north,east}
```

## Visual Indicator

One issue with this workflow is that there is no visual indicator for the
current activated chord; Vim has its status line to tell the user whether they
are in `NORMAL`, `INSERT` or `VISUAL`.

I often forget to leave the mode I had temporarily enabled, leading to
accidental executions of random commands, which is annoying at best and
potentially dangerous.

Thankfully, I discovered that `sxhkd` can output status information via a named
pipe. We can poll this output with a watcher script and pair it with our bar of
choice (`eww` for me) to show a visual indicator of the current mode.

## Implementation

1. Create a named pipe at `/var/run/user/[uid]/sxhkd.fifo`

```bash
$ mkfifo /var/run/user/1000/sxhkd.fifo
```

{{< alert type="note" >}}
To persist this named pipe at startup, initialize it in your [xinit]({{< ref
"/notes/linux/xinit.md" >}}) file.
{{< /alert >}}

2. Replace your `sxhkd` startup command (in `.xinitrc`) with

```
sxhkd -s /var/run/user/1000/sxhkd.fifo &
```

3. Restart `bspwm`  with `bspc quit` and login again.
4. Tail the new FIFO file with `cat /var/run/user/[uid]/sxhkd.fifo` to ensure it
   is working.
5. Watch the named pipe with a custom script `sxhkd-watcher`:

```bash
#!/bin/bash

SXHKD_FIFO="/var/run/user/1000/sxhkd.fifo"
cat $SXHKD_FIFO | while read line; do
case ${line} in
    # EEnd chain
    E*)
        echo "Normal mode" ;;
    "Hsuper + n")
        echo "Node mode" ;;
    "Hsuper + p")
        echo "Preselect mode" ;;
   esac
done
```

6. Poll the script with your bar of choice (`polybar`, `eww` etc.).

## References
- [man - sxhkd](https://www.mankier.com/1/sxhkd)
- [sxhkd - Allow running a command at start of colon chain](https://github.com/baskerville/sxhkd/issues/140)
