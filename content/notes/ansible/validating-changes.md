---
title: "Validating Changes"
date: 2022-02-20T01:43:02+08:00
lastmod:
draft: false
toc: false
tags:
- ansible
---

`changed_when` and `failed_when` are useful in *validation* tasks in order to
maintain idempotency:
- checking if the latest version of the software is installed.
- checking if the software is running well after changing its configuration

For example, the task of checking for the installed version of Python3 has no
change or failure condition, and it should not fail if Python3 is not installed.

```yaml
tasks:
  - name: check for installed version
    command: python3 --version
    ignore_errors: true
    changed_when: false
    failed_when: false
    register: python_installed_version
```

When performing validation commands, setting `changed_when` to false maintains
idempotency as there is no change condition.

```yaml
tasks:
  - name: validate nginx conf
    command: nginx -t
    changed_when: false
```

# References
- [Validating Ansible Changes](https://adamj.eu/tech/2014/10/31/validating-ansible-changes/)
