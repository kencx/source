---
title: "Keymap: Go to Ansible Role"
date: 2023-08-16
lastmod: 2023-08-16
draft: false
toc: false
tags:
- neovim
- lua
- ansible
---

This function navigates to the `tasks/main.yml` file of the Ansible role that is under the cursor.

```lua
ansible_goto_role_paths = { "./roles", "~/.ansible/roles" }

local function gotoRole()
	if ansible_goto_role_paths then
		role_paths = ansible_goto_role_paths
	else
		role_paths = { "./roles" }
	end

	local cword = vim.fn.expand("<cWORD>")
	local tasks_dir = util.path.join(cword, "tasks")

	for _, p in ipairs(role_paths) do
		-- check if relative or absolute path
		if p:match("^%./") or p:match("^%.%./") then
			full_path = util.path.join(util.path.cwd(), p, tasks_dir)
		else
			full_path = util.path.join(vim.fs.dirname(p), vim.fs.basename(p), tasks_dir)
		end

		local match = vim.fs.find("main.yml", { type = "file", path = full_path })
		if #match == 1 and match[1] ~= "" then
			vim.cmd("e " .. match[1])
			return
		end
	end
	print(tasks_dir .. "/main.yml not found")
end
```

- Vim's `expand("<cWORD>")` is used to get the word under the cursor. We use
  `<cWORD>` (instead of `<cword>`) to handle fully qualified role names from
  Ansible Galaxy that may be separated by dots `.` (eg. `geerlingguy.docker`).

Finally, bind the above function to a keymap in `ansible/*.{yml,yaml}` files:

```lua
vim.api.nvim_create_autocmd(event = { "BufRead", "BufNewFile" }, {
    group = "ansibleGoToRole",
    pattern = { "*/ansible/*.yml", "*/ansible/*.yaml" },
    callback = function()
        vim.keymap.set({ "n", "v" }, "<Leader>gar", gotoRole, {})
    end
})
```

## References
- [Relevant Gist](https://gist.github.com/mtyurt/3529a999af675a0aff00eb14ab1fdde3)
