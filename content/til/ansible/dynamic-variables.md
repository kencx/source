---
title: "Dynamic Variables"
date: 2023-07-12
lastmod: 2023-07-12
draft: false
toc: false
tags:
- ansible
---

Moustaches do not stack in Jinja. The following is **not** valid syntax:

```yml
debug:
	msg: "{{ {{ application }}.version }}"
```

To interpolate variables or build dynamic variables, we must use the `vars`
dictionary:

```yml
- hosts: all
  vars:
    application: foo
    foo:
      version: 1.0
  tasks:
	# version=1.0
	- debug:
		msg: "version={{ vars[application].version }}"
```

`vars[application].version` will be interpolated into `foo.version`. The above
can also be represented with the [vars lookup
plugin](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/vars_lookup.html#vars-lookup):

```yml
debug:
	msg: "version={{ lookup('vars', application).version }}"
```

For inventory variables, we must use the `hostvars` dictionary instead:

```yml
debug:
  msg: "{{ hostvars[inventory_hostname][bar] }}"
```

To concatenate variables dynamically, the `+` operator or the `~` (tilde)
operator in Jinja converts all operands into strings and concatenates them:

```yaml
- hosts: all
  vars:
    region: "east"
    east_ip: ["192.168.86.1"]
  tasks:
	  # 'east_ip' -> '192.168.86.1'
    - debug:
        # msg: "{{ lookup('vars', region + '_ip') }}"
        msg: "{{ lookup('vars', region ~ '_ip') }}"
```

## References
- [Ansible docs - How to interpolate variables or dynamic variable names](https://docs.ansible.com/ansible/latest/reference_appendices/faq.html#when-should-i-use-also-how-to-interpolate-variables-or-dynamic-variable-names)
- [How to use Ansible nested variables](https://stackoverflow.com/questions/46209556/how-can-i-use-ansible-nested-variable)
- [Jinja - Other Operators](https://jinja.palletsprojects.com/en/3.0.x/templates/#other-operators)
