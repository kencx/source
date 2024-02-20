---
title: "Managing hotkeys in Linux"
date: 2024-02-20T21:37:00+08:00
lastmod:
draft: true
toc: true
tags:
- hotkeys
---

When I first began learning Vim, I also started using tmux and a new window
manager (bspwm) at the same time. In hindsight, this was a bad idea
because I really struggled with remembering the correct hotkey combination for
things like:

- Resizing a window in bspwm
- Resizing a pane in tmux
- Creating a new split in vim
- Creating a new pane/window in tmux

If you used any combination of window manager, text editor and terminal
multiplexer before, I think you can see where I'm going. These are all very
similar operations in different programs and I mixed up the hotkeys for them ALL
THE TIME.

## Remembering Hotkeys

Naturally, I looked for methods to quickly reference these hotkey combinations
in a cheatsheet. Vim has
plugins like [which-key](https://github.com/liuchengxu/vim-which-key) (or
[which-key.nvim](https://github.com/folke/which-key.nvim)), tmux has the builtin
`Ctrl+b; ?` and bspwm has well... sxhkd which isn't really helpful by itself.

### 1. Sxhkd

I set out to create my own sxhkd reference. The `sxhkdrc` configuration file
looks like this:

```bash
# floating terminal
super + Return
	st

# tiled terminal
super + shift + Return
    st -c tiled

# rofi
super + space
	rofi -show drun -width -100
```

which can be parsed with `awk`:

```bash
awk '/^[a-zA-Z{]/ && last {print $0,"\t",last} {last=""} /^#/{last=$0}' \
    ~/.config/sxhkd/sxhkdrc | column -t -s $'\t'
```

to generate a list of hotkeys with a description:

```bash
super + Return            # floating terminal
super + shift + Return    # tiled terminal
super + space             # rofi
```

This can be paired with `fzf` to generate a nice table of hotkeys with a fuzzy
search:

```bash
fzf --tac --cycle \
    --layout=reverse \
    --border=rounded \
    --margin=1 \
    --padding=1 \
    --prompt='keys > ' \
    --ansi
```

Combine the above into a script and assign it a hotkey and you get a quick sxhkd
cheatsheet!

### 2. Towards A Global Cheatsheet

These reference sheets are great but I find it annoying to switch between 3
different cheatsheets.

I wanted a cheatsheet with the following features:

- All hotkeys, regardless of application or software
- Fuzzy search
- Quickly accessible via a hotkey

During research, [awesomewm](https://awesomewm.org/)'s shortcut menu comes
really close to what I really wanted. The only problem was that it involved
being locked into awesomewm, which wasn't great.

{{< figure src="awesomewm-shortcut-menu.png" caption="awesomewm shortcut menu. [Source](https://stackoverflow.com/questions/73519361/awesome-wm-shortcut-to-toggle-or-make-a-window-sticky-this-shortcut-is-not-show)" class="center" >}}

### 3. Building my own solution: keyb

I built [keyb](https://github.com/kencx/keyb) to fulfil my need for a global
cheatsheet.

It can be used to create and view custom hotkey cheatsheets in a TUI.  `keyb` is
built in Go, with the
[bubbletea](https://github.com/charmbracelet/bubbletea/tree/master) framework.

{{< figure src="keyb.gif" caption="keyb demo" class="center" >}}

Features:
- fully customizable
- supports fuzzy filtering
- vim keybindings
- output can be exported to fzf or rofi

Non-features:
- Auto-detection of key bindings for applications
- Setting of key bindings for applications
- Command selection

Its design is heavily inspired by `fzf`, but it presents the hotkeys in a table with headings and two columns - the description and the actual hotkey combination

<!-- Comparison image between fzf and keyb -->

The headings help to visually split all hotkeys by their application, and was
influenced by awesomewm's shortcut menu. These headings are fully customizable
and how you split them is dependent on how you wrote your `keyb` configuration
file.

The fuzzy filtering is similar to that in `fzf` but it offers two modes: normal
and heading mode. Normal filtering simply filters all rows except the headings,
while heading filtering filters for heading rows only. Heading mode is activated
by prefixing the search input with `h:`. However, a modal UX proves to be quite
cumbersome. My rough thoughts on how it can be improved are
[here](https://github.com/kencx/keyb/issues/16), although I have not implemented
any changes yet.

## Running Hotkeys

## Remapping Hotkeys

## References
