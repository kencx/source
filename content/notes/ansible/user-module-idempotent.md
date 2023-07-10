---
title: "Make user module idempotent"
date: 2022-12-30
lastmod: 2022-12-30
draft: false
toc: false
tags:
- ansible
---

When creating a user with Ansible's [user](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/user_module.html) module, the output will always show as changed.

```yaml
- name: Create user
  user:
    name: "{{ user }}"
    create_home: true
    password: "{{ password | password_hash('sha512') }}"
    state: present
```

This is the case because setting a password with the `password_hash` filter:

```
{{ password | password_hash('sha512') }}
```

is not idempotent - the hash's salt changes with every
run of `password_hash`.

## Solution

There are two ways to make it idempotent:
1. Run with specific salt

```yaml
- name: Create user
  user:
    name: "{{ user }}"
    create_home: true
    password: "{{ password | password_hash('sha512', 'salt') }}"
    state: present
```

2. Update the password `on_create` only

```yaml
- name: Create user
  user:
    name: "{{ user }}"
    create_home: true
    password: "{{ password | password_hash('sha512') }}"
    update_password: on_create
    state: present
```

## References
- [ansible user module always shows changed](https://stackoverflow.com/questions/56869949/ansible-user-module-always-shows-changed)
