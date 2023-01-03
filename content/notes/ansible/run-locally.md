---
title: "Run playbooks locally"
date: 2023-01-03
lastmod: 2023-01-03
draft: false
toc: false
tags:
- ansible
---

### Run all tasks locally

```yaml
---
- name: Playbook example
  hosts: 127.0.0.1
  connection: local
  tasks:
    ...
```

### Run a **single** task locally

```yaml
tasks:
  - name: Local task
    local_action:
      module: git
      repo: ...
      dest: ...
```

### Run playbook locally from the command line

```bash
$ ansible-playbook --connection=local 127.0.0.1, main.yml
```

>The comma is mandatory after `127.0.0.1,`, otherwise `127.0.0.1` is treated as a filename.

or use an inventory file

```
[local]
localhost ansible_connection=local
```

```
ansible-playbook -i inventory --limit local main.yml
```
