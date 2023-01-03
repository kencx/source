---
title: "Include role default variables in Molecule"
date: 2023-01-03
lastmod: 2023-01-03
draft: false
toc: false
tags:
- ansible
---

By default, Molecule does not include the default variables of a role in its verify
stage. To ensure they are included, add the following to `verify.yml`,

```yaml
- name: Verify
  hosts: all
  tasks:
    - name: include default vars
      ansible.builtin.include_vars:
        dir: "{{ lookup('env', 'MOLECULE_PROJECT_DIRECTORY') }}/defaults/"
        extensions:
          - 'yml'

    - name: include host vars
      ansible.builtin.include_vars:
        file: "{{ lookup('env', 'MOLECULE_EPHEMERAL_DIRECTORY') }}/inventory/host_vars/{{ ansible_hostname }}"
...
```

## References
- [Github - verify stage does not include role defaults](https://github.com/ansible-community/molecule/issues/3587)
