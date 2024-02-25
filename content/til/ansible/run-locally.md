---
title: "Run playbooks locally"
date: 2023-01-03
lastmod: 2023-01-03
draft: false
toc: false
tags:
- ansible
---

## From the command line

```bash
$ ansible-playbook --connection=local 127.0.0.1, main.yml
```

{{< alert type="note" >}}
The comma is mandatory after `127.0.0.1,`, otherwise `127.0.0.1` is treated
as a filename.
{{< /alert >}}

## With an inventory file

```text
[local]
localhost ansible_connection=local
```

```bash
$ ansible-playbook -i inventory --limit local main.yml
```

## Within a playbook

### All tasks

```yaml
- name: Playbook example
  hosts: 127.0.0.1
  connection: local
  tasks:
    ...
```

### A single task

Using the `local_action` module:

```yaml
tasks:
  - name: Local task
    local_action:
      module: git
      repo: ...
      dest: ...
```

or using the `delegate_to` keyword:

```yml
tasks:
  - name: Local task
    git:
      repo: ...
      dest: ...
    delegate_to: localhost
```

## References

- [Ansible docs - Local
  Playbooks](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_delegation.html#local-playbooks)
