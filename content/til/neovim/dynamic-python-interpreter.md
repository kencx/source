---
title: "Dynamic Python Interpreter with pylsp"
date: 2023-08-17
lastmod: 2023-08-17
draft: false
toc: false
tags:
- neovim
- python
- lua
- snippets
---

This snippet dynamically selects the Python interpreter used with
[pylsp](https://github.com/python-lsp/python-lsp-server) in Neovim. It does so
by checking for the existence of a Python [virtual environment]({{< ref
"til/python/virtual-environments.md" >}}) in the project's root directory. If
a venv exists, `pylsp` will use its environment. Otherwise, it will fallback to
the global interpreter.

First, we want to retrieve the name of the venv's subdirectory. If the
venv has been activated, Vim may detect it with `$VIRTUAL_ENV`. If not, we
recursively search for a [`pyvenv.cfg`]({{< ref
"til/python/virtual-environments.md#what-goes-into-a-venv" >}}) from the
project's root directory

```lua
local function get_python_venv(workspace)
	-- use activated venv
	if vim.env.VIRTUAL_ENV then
		return path.join(vim.env.VIRTUAL_ENV)
	end

	-- find and use venv
	local match = vim.fs.find("pyvenv.cfg", { type = "file", path = workspace })
	if #match == 1 and match[1] ~= "" then
		return path.dirname(match[1])
	end
end
```

If a venv is found, return the local Python interpreter. Otherwise, the global
interpreter is used

```lua
local function get_python_path(workspace)
	local venv = get_python_venv(workspace)
	if venv ~= nil and venv ~= "" then
		vim.api.nvim_notify("set venv to" .. path.join(venv, "bin", "python"), 1, {})
		return path.join(venv, "bin", "python")
	end

	-- default to global python
	return vim.fn.exepath("python3") or vim.fn.exepath("python")
end
```

Finally, we set `pylsp`'s `plugins.jedi.environment` to the dynamic path with
the functions above

```lua
local configs = require("lspconfig/configs")

return {
	cmd = { "pylsp" },
	filetypes = { "python" },
	settings = {
		pylsp = {
			plugins = {
				jedi = {
					environment = get_python_path(configs.root_dir),
				},
			},
		},
	},
}
```

{{< alert type="note" >}}
`lspconfig`'s `root_dir` function is used here to fetch the project's root
directory.
{{< /alert >}}

## References

- [pylsp - Virtual Environments?](https://github.com/python-lsp/python-lsp-server/issues/29)
