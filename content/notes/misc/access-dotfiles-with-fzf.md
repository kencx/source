---
title: "Access dotfiles With fzf and fd"
date: 2021-11-30T23:37:40+08:00
draft: false
toc: false
images:
---

{{< figure src="/img/fzf-configs.png" caption="config selection window" class="center" >}}

I use this particular script to easily access my dotfiles or configuration files.

It uses the dependencies `fd` for fast lookup of the files, `fzf` as the selection menu and `bat` for the preview.

``` bash
#!/bin/bash
# configs

FILEPATH="$HOME/dotfiles/dots"
CONFIGS='(zsh|bspwm|sxhkd|polybar|starship|rofi|dunst|config|nvim|lua|init.lua|tmux|picom)'
EXCLUDE='{autostart,bin}'

FILE=$(fd $CONFIGS --exclude $EXCLUDE --type f --hidden "$FILEPATH" | \
    fzf --ansi --cycle \
    --delimiter='/' \
    --with-nth=-2,-1 \
    --layout=reverse \
    --margin=5% \
    --prompt="config > " \
    --preview-window 'right:70%' \
    --preview 'bat --color=always --style=numbers --line-range=:500 {}'
        ) \
    && "$EDITOR" "$FILE"
```

First, it searches through the given directory with `fd`, making sure to include hidden files.

```bash
fd $CONFIGS --exclude $EXCLUDE --type f --hidden "$FILEPATH"
```

The result is piped into `fzf` to be processed. The `delimiter` and `with-nth`
flags ensure only the filename and its parent directory are shown, instead of
the full path.

 ```bash
 --delimiter='/'
 --with-nth=-2,-1
 ```

`fzf` allows for customization of the prompt and layout. Refer to its docs for
more details.

 ```bash
 --layout=reverse
 --margin=5%
 --prompt="config > "
 ```

Using `bat` as the preview is optional and allows for a nice colored layout with
syntax highlighting.

 ```bash
--preview-window 'right:70%' \
--preview 'bat --color=always --style=numbers --line-range=:500 {}'
 ```

 The selection `$FILE` is then opened with the selected editor, `nvim`, in my
 case to open an instance of the selected config file.

 I bind this script to a hotkey in sxhkd for quick access
 ```bash
 super + z
 	$TERMINAL $HOME/bin/configs
 ```

