---
title: "Visualizing modal hotkeys in sxhkd"
date: 2024-02-20T23:36:00+08:00
lastmod:
draft: false
toc: true
tags:
- hotkeys
- sxhkd
---

In [sxhkd](https://github.com/baskerville/sxhkd), multiple chords can be chained
to create modal hotkeys.

{{< quote source="[sxhkd](https://www.mankier.com/1/sxhkd)" >}}
When multiple chords are separated by semicolons, the hotkey is a chord chain:
the command will only be executed after receiving each chord of the chain in
consecutive order.
{{< /quote >}}

This allows a single key combination to be reused for different commands by
prefixing it with a different chord, resulting in "modes" like those in Vim.

For example, these are three hotkeys that use `super + h`, each prefixed with a
different `super + [key]` to represent various modes:

```bash
# normal mode
# focus the node in the given direction
super + {h,j,k,l}
    bspc node -f {west,south,north,east}

# node mode
# hide current window
super + n : super + h
    bspc node focused.window -g hidden=on

# preselect mode
# preselect in the given direction
super + p : super + {h,j,k,l}
    bspc node -p {west,south,north,east}
```

## Visualizing Custom Modes

One issue with this workflow is that there is no visual indicator for the
current activated "mode"; Vim has its status line to tell the user whether they
are in `NORMAL`, `INSERT` or `VISUAL` mode, but sxhkd has nothing since this is
a custom solution.

I often forget to leave the mode I had temporarily enabled, leading to
accidental executions of random commands, which can be extremely frustrating.

After some research, I discovered that `sxhkd` can output status information via
a named pipe with the `-s` flag. We can poll this output with a watcher script
and pair it with our bar of choice (`eww` for me) to show a visual indicator of
the current sxhkd mode.

## Implementation

First, create a named pipe at `/var/run/user/[uid]/sxhkd.fifo`:

```bash
$ mkfifo /var/run/user/1000/sxhkd.fifo
```

Start `sxhkd` with the `-s` flag pointing at the new named pipe:

```bash
$ sxhkd -s /var/run/user/1000/sxhkd.fifo &
```

Restart `bspwm` and read from the named pipe file to check that it is
working:

```bash
$ cat /var/run/user/1000/sxhkd.fifo
```

Pressing any `sxhkd` hotkeys will show the status information with this weird
output:

```bash
Cbspc node -f east
BBegin chain
Hsuper + n
EEnd chain
BBegin chain
Hsuper + p
EEnd chain
```

A chord chain begins with `BBegin chain` and ends with `EEnd chain`. With this
information, we can create a watcher script that reads from the named pipe and
runs a custom command based on the output.

For example, I would like to show that "node mode" is activated when `Hsuper +
n` is outputted and deactivated when `EEnd chain` is outputted. This can be done
with a switch-case statement in Bash:

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

Finally, we poll this script with `polybar` or `eww` to show a visual
indicator on the bar.

{{< alert type="note" >}}
To persist the named pipe at startup, initialize it in your `.xinitrc` file and
ensure `sxhkd` starts up with the `-s` flag.
{{< /alert >}}

## References
- [man - sxhkd](https://www.mankier.com/1/sxhkd)
- [sxhkd - Allow running a command at start of colon chain](https://github.com/baskerville/sxhkd/issues/140)
