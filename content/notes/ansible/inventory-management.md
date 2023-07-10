---
title: "Ansible inventory management"
date: 2022-10-02T21:21:02+08:00
lastmod:
draft: false
toc: true
tags:
- ansible
---

## Debugging Inventory Files

Use `ansible-inventory` to check the validity of inventory, `group_vars` and
`host_vars` files. The `--vars` flag produces a neat graph that depicts the
variables that are applied to the defined hosts.

```bash
$ ansible-inventory --graph --vars
```

## Limiting Hosts
It is common to define `hosts: all` in a general/common playbook.

```yaml
- hosts: all
  tasks:
    - name: Example task
      ping:
```

On occasion, we can choose to limit a specific run of a playbook to a particular host
or group with the `--limit` flag.


```bash
$ ansible-playbook -i inventory/hosts.yml --limit webserver
```

It is advisable to include the `--list-hosts` flag to confirm the host or group that the
playbook will run in.

## Targeting Groups
For greater control over which groups of hosts to run a playbook against, Ansible offers
the following patterns:

| Pattern        | Description                                   |
| -------------- | --------------------------------------------- |
| all            | All hosts                                     |
| host1          | One host                                      |
| host1,host2    | Multiple hosts                                |
| webservers     | One group                                     |
| webservers:dbs | Multiple groups                               |
| webservers:!db | All hosts in webservers excluding those in db |
| webservers:&db | Any hosts in webservers that are also in db   |

These can be used within a playbook, or on the command line with the `--limit` flag or `-i`
flag.

## References

- [Ansible - Targeting hosts and groups](https://docs.ansible.com/ansible/latest/user_guide/intro_patterns.html#using-patterns)
- [Override hosts variable of Ansible playbook](https://stackoverflow.com/questions/33222641/override-hosts-variable-of-ansible-playbook-from-the-command-line)
