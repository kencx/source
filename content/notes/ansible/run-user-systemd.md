---
title: "Run user systemd units"
date: 2023-01-03
lastmod: 2023-01-03
draft: false
toc: false
tags:
- ansible
- systemd
- snippet
---

For user systemd to work, the executing user must have its own instance of dbus started
and accessible. The user dbus process is started on normal login, but not during an
Ansible run.

This would result in the error `'Failed to connect to bus: no such file or directory'`.

To give the user access, we must provide the `XDG_RUNTIME_DIR` env variable.

```yml
- Get user UID
  command: "id -u {{ user }}"
  register: uid
  check_mode: false
  changed_when: true

- name: Enable service
  become: true
  become_user: "{{ user }}"
  environment:
    XDG_RUNTIME_DIR: "/run/user/{{ uid.stdout }}"
  systemd:
    name: service
    state: started
    enabled: true
    scope: user
```

## References
- [Ansible systemd module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/systemd_module.html)
