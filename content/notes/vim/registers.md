---
title: "Registers"
date: 2022-02-25T23:29:53+08:00
lastmod: 2022-02-25T23:29:53+08:00
draft: false
toc: true
tags:
- vim
---

Registers are Vim's way of storing text cut, copied and pasted text.

Specify the register to use by prefixing the command with `"{register}`.

- To yank a word into register `a`, press `"ayiw`
- Paste the word with `"ap`

```
""       Unnamed register
"[a-z]   Named register
"0       Yank register
"_       Black hole register
"+       X11 clipboard
"=       Expression register

# read only registers
"%       Name of the current file
".       Last inserted text
"/       Last search pattern
```

## Overwrite word with yanked text

- Yank the word with `yiw`
- Navigate to the word to be overwritten and delete it `diw`
- Paste from the yank register `"0P`

## Paste from Register in Insert Mode

In insert mode, press `<C-r>0` to paste register `0` at the current cursor position.

## Expression Register

The expression register allows the evaluation of Vim script code and returns the
result in the `=` register. It is useful for simple arithmetic.

- In insert mode, press `<C-r> =` to open the register
- Evaluate the expression and hit `<CR>`

## References

- [Practical
  Vim](https://www.oreilly.com/library/view/practical-vim-2nd/9781680501629/)
