---
title: "keyb - A hotkey cheatsheet in the terminal"
date: 2023-07-12T00:18:00+08:00
lastmod: 2023-07-12
draft: true
toc: true
tags:
- projects
---

[`keyb`](https://github.com/kencx/keyb) is a lightweight hotkey cheatsheet in
the terminal. It can create and view custom hotkey cheatsheets in a nice TUI.

{{< figure src="/posts/images/keyb.gif" caption="keyb demo" class="center" >}}

It is *fully* customizable[^1], supports fuzzy filtering, vim keybindings and
its output can be exported to fzf or rofi.

It does not support:

- Auto-detection of key bindings for applications
- Setting of key bindings for applications
- Command selection

## Motivation

I built `keyb` because I often have trouble remembering hotkeys, and wanted a
quick, no-nonsense way to list and search through my hotkeys. It would also be
good if it was possible to fulfil the following criteria:

- Contain ALL my hotkeys, regardless of the application or software
- Support fuzzy-finding
- Be quickly accessible via a custom hotkey

There wasn't any such tool that I could find, but two came close and heavily
influenced the UX of `keyb`:

- [awesomewm](https://awesomewm.org/)'s shortcut menu
- A [custom
  script](https://github.com/kencx/dotfiles/blob/master/dots/bin/bin/kbinds)
  that uses `fzf` to parse `sxhkd` bindings (this was what I went with before
  building `keyb`)

awesomewm's shortcut menu came really close to what I really wanted. The only
problem was that I was locked into using awesomewm, which was a dealbreaker for
me. I mean, no hate for awesomewm but I just prefer bspwm.

{{< figure src="/posts/images/awesomewm-shortcut-menu.png" caption="awesomewm shortcut menu. [Source](https://stackoverflow.com/questions/73519361/awesome-wm-shortcut-to-toggle-or-make-a-window-sticky-this-shortcut-is-not-show)" class="center" >}}

The alternative was a custom script that utilized `fzf` to parse my `bspwm` and
`sxhkd` bindings. This was good but I wanted to include bindings for other
software like neovim and tmux.

## Design

If you go back to the demo gif, you can see that `keyb` borrows heavily from
`fzf`'s style, but it presents the hotkeys in a table with headings and
two columns - the description and the actual keybind.

The headings help to visually split all hotkeys by their application, and was
influenced by awesomewm's shortcut menu. These headings are fully customizable
and how you split them is dependent on how you organized your `keyb`
configuration file (more on that later).

The fuzzy filtering is similar to that in `fzf` but it offers two modes: normal
and heading mode. Normal filtering simply filters all rows except the headings,
while heading filtering filters for heading rows only. Heading mode is activated
by prefixing the search input with `h:`.

> For my issues with heading mode, see [here](#heading-mode).

## Bubbletea

`keyb` is built in Go, with the
[bubbletea](https://github.com/charmbracelet/bubbletea/tree/master) framework.

## Configuration

`keyb` works by listing all your hotkeys in a `keyb.yml` file. Hotkeys are
classified into sections with a name and an (optional) prefix field.

```yml
- name: bspwm
  keybinds:
    - name: terminal
      key: Super + Return
```

This name goes to become the heading's name. The prefix is a key combination
that is prepended to every hotkey in that section. This is useful for specific
applications with a common leading hotkey like `tmux`:

```yml
- name: tmux
  prefix: ctrl + b
  keybinds:
    - name: Create new window
      key: c
    - name: Prev, next window
      key: Shift + {←, →}
      ignore_prefix: true
```

The configurability of the `keyb.yml` file allows you to list any application's
hotkeys with any custom keybinds you want. You can even split an application's
hotkeys into different groups or modes - normal, insert, visual mode in vim.

> See my
> [keyb.yml](https://github.com/kencx/dotfiles/blob/master/dots/keyb/.config/keyb/custom.yml)
> for some examples.


## Improvements

While I am happy with the state of `keyb` now, I do have a few ideas for improving it.

### Heading Mode

Personally, I find heading mode cumbersome to activate, especially when I use it
so frequently. Naturally, [others](https://github.com/kencx/keyb/issues/16)
agree with this. However, I'm struggling to find a good method to combine
filtering through headings and the normal rows due to a few issues:

- How should we prioritize the search results when there exists a heading
and a description with the same text? It doesn't make sense to only show the
heading row without its constituents. But, if the specific heading has a lot of
constituent rows, it would drown out the rest of the filtered descriptions.
- It would be good if we can toggle between combined filtering and
filtering only non-headings rows.
- It would also be good to implement filtering within the filtered sub-table.

The best idea I have now would be to implement a truncated sub-table that can be
expanded into its own view, which can be filtered.

### Command Selection and Remapping

I recently discovered [xdotool](https://github.com/jordansissel/xdotool) and
[xremap](https://github.com/k0kubun/xremap) which can be used to perform command
selection and remapping respectively. I think it would be pretty cool if `keyb`
could be extended to work with these tools.

`xremap` reads a specific `config.yml` to remap hotkeys. Something like this
could probably be implemented:

```bash
$ keyb --export-xremap | xremap
```

`xdotool` can simulate keystrokes from stdin. This input could be easily piped
from `keyb` when a specific keybind is selected:

```bash
$ keyb | xdotool key
```

### Reading Config from a Directory

I found my `keyb.yml` to be getting a little long and it would be great if it
could be split into multiple files. This feature seems easy enough and I just
need to find some time to implement this.


[^1]: Feel free to [open an issue](https://github.com/kencx/keyb/issues) if you
    feel there's something that should be customized that isn't
