+++
title = "I built a terminal hotkey cheatsheet"
date = "2024-02-22"
updated = "2024-02-22"

[taxonomies]
tags = ["keybinds", "sxhkd", "tui", "hotkeys"]

[extra]
toc = true
+++

{% details(summary="Summary") %}
I discuss how and why I built my own application
[keyb](https://github.com/kencx/keyb) to remember
custom hotkeys in Linux.
{% end %}

When I first began learning Vim, I also started using tmux and a new window
manager (bspwm) at the same time. In hindsight, this was a bad idea
because I really struggled with remembering the correct hotkey combination for
things like:

- Resizing a window in bspwm
- Resizing a pane in tmux
- Resizing a split in vim
- Creating a new split in vim
- Creating a new pane/window in tmux

These are all very similar operations in different programs and I mixed them up
ALL THE TIME.

## Remembering Hotkeys

I started looking for methods to quickly reference the hotkeys for these
operations. Vim has plugins like
[which-key](https://github.com/liuchengxu/vim-which-key) (or
[which-key.nvim](https://github.com/folke/which-key.nvim)), tmux has the builtin
`Ctrl+b; ?` and bspwm has well... sxhkd.

### Sxhkd

sxhkd (Simple X hotkey daemon) is commonly paired with bspwm as a hotkey manager
for X. It is configured with a `sxhkdrc` configuration file that looks like
this:

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

To create a quick reference sheet for `sxhkd`, we can parse the config file with
`awk`:

```bash
awk '/^[a-zA-Z{]/ && last {print $0,"\t",last} {last=""} /^#/{last=$0}' \
    ~/.config/sxhkd/sxhkdrc | \
    column -t -s $'\t'
```

to generate a list of hotkeys with a description like this:

```bash
super + Return            # floating terminal
super + shift + Return    # tiled terminal
super + space             # rofi
```

We can combine this with `fzf` to generate a table of hotkeys with fuzzy search:

{% figure(src="sxhkd_fzf.png") %}
A handy sxhkd cheatsheet
{% end %}

{% details(summary="Full script") %}
Use a hotkey to activate the script and you got an quick reference
cheatsheet!

```bash
#!/usr/bin/env bash

awk '/^[a-zA-Z{]/ && last {print $0,"\t",last} {last=""} /^#/{last=$0}' \
    ~/.config/sxhkd/sxhkdrc | \
    column -t -s $'\t' | \
    fzf --tac --cycle \
        --layout=reverse \
        --border=rounded \
        --margin=1 \
        --padding=1 \
        --prompt='keys > ' \
		--ansi
```
{% end %}

## Towards A Global Cheatsheet

This script was really great. In fact, it was so great that I consistently tried
to look up my Vim and tmux hotkeys on it as well, leading to confusion, then
frustration.

What I really wanted was a global cheatsheet that could store all my hotkeys
(even custom ones). Ideally, it should have fuzzy search and be presented in an
easy to read format (I've been spoiled by my `sxhkd` + `fzf` script).

Looking around, I saw that [awesomewm](https://awesomewm.org/)'s shortcut menu
comes really close to what I wanted, but there were two problems:

1. I would be locked into awesomewm. No hate to it, but I was already using
   bspwm
2. At a glance, its quite difficult to find the hotkey I want since there's no
   search function

{% figure(src="awesomewm_shortcut_menu.png") %}
awesomewm shortcut menu. [Source](https://stackoverflow.com/questions/73519361/awesome-wm-shortcut-to-toggle-or-make-a-window-sticky-this-shortcut-is-not-show)
{% end %}

## Building my own solution

I searched extensively for any customizable hotkey reference tool but couldn't
find one, so I built my own: [keyb](https://github.com/kencx/keyb). Its built in
Go and the fantastic
[bubbletea](https://github.com/charmbracelet/bubbletea/tree/master) framework.

{% figure(src="keyb.gif") %}
keyb demo
{% end %}

`keyb` requires you to create a hotkey file (`keyb.yml`) which you populate with
any keybinds you want to show:

```yml
- name: bspwm
  keybinds:
    - name: terminal
      key: Super + Return
```

From the gif, I think you can tell the design was heavily inspired by the custom
`sxhkd` + `fzf` script. All hotkeys and their descriptions are presented into a
two column table, separated into sections (or groups) and delimited by their
headers in bold.

The sections were inspired by awesomewm's shortcut menu and help to visually
split all hotkeys by their applications/software. These section and section
headers are fully customizable and how you split them is dependent on how you
wrote the `keyb.yml` file.

This allows you to split your hotkeys in any way you like. For example, I split
my bspwm and tmux hotkeys based on their purpose, and my neovim hotkeys based on
their plugins.

{% figure(src="keyb_split.png") %}
All hotkeys related to copy and pasting in tmux are in the tmux (copy) section
{% end %}

The other key feature of `keyb` is its fuzzy search. There are two search modes:

- Normal search: filters all rows except headers
- Header search: filters header rows only

This means that there are three different ways of presenting table rows:
non-filtered, normal search filtered and header search filtered. These three
tables had to be distinct enough that the user should know which mode they are
in without getting lost, but also similar enough to maintain a common UX
throughout. This was challenging to develop since I'm not a designer or UX
expert.

What I went with was this:

- **Non-filtered**: The default table with sections separated by their headers
  (in bold)
- **Normal search filtered**: The table is ordered by fuzzy search with no
  section and headers. Instead, headers are present just below the search bar
  for quick reference. I found headers to still be necessary to prevent
  confusion when there are hotkeys with similar descriptions and/or keybinds for
  different applications
- **Header search**: Table headers are ordered by fuzzy search with all their
  corresponding section hotkeys

To me, this UX seems straightforward and I don't get easily lost or forget which
mode I am in. However, this modal UX is far from perfect.

## Areas of Improvement

Firstly, `keyb` activates header search by checking for the prefix `h:` string
in the search bar. This proves to be quite cumbersome especially when you use
this mode often. I have some ideas on how to improve it, but nothing concrete so
far. My rough thoughts are [here](https://github.com/kencx/keyb/issues/16).

Secondly, it would be fantastic if we can set or rebind hotkeys using `keyb` as
well. This is entirely outside the scope of `keyb` but there are some tools that
do this, including [xremap](https://github.com/k0kubun/xremap) and
[keyd](https://github.com/rvaiya/keyd). One
[proposal](https://github.com/kencx/keyb/issues/29) I have is to allow `keyb` to
export a configuration file for these tools with the defined `keyb.yml` file
that's already present, allowing the user to set a single source of truth.

Lastly, `keyb` does not support command selection or keyboard input. Again, this
is outside the scope of `keyb` and more suited for tools like
[xdotool](https://github.com/jordansissel/xdotool). I also have a
[proposal](https://github.com/kencx/keyb/issues/30) to allow `keyb` to output
keyboard input that can be piped into `xdotool` when the user selects a given
row in the table.

I've been dogfooding `keyb` almost daily for more than a year now, so much that
I rarely need to refer to it now, which was kind of the point I guess? There
hasn't been major bugs or annoyances as far as I'm aware, but please feel free
to open an issue if you do try it out!
