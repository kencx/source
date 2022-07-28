---
title: "Human Readable Output"
date: 2022-04-19T12:08:07+08:00
lastmod: 2022-04-19T12:08:07+08:00
draft: false
toc: false
tags:
- ansible
---

By default, Ansible returns an output in json format when running playbooks.
This makes it very hard to debug long errors. We can change its output to a more
human readable yaml format.

Include this in your global or local `ansible.cfg`.
```
# ansible.cfg
[default]
stdout_callback=yaml
```

Alternatively, run the playbook with the environment variable
`ANSIBLE_STDOUT_CALLBACK=yaml`

```bash
$ ANSIBLE_STDOUT_CALLBACK=yaml ansible-playbook main.yml
```
