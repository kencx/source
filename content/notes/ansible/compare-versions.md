---
title: "Compare versions"
date: 2022-04-19T12:07:24+08:00
lastmod: 2022-12-29T16:38:39+08:00
draft: false
toc: false
tags:
- ansible
- snippets
---

To compare two versions of software, use the `version()` Jinja
[test](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_tests.html#comparing-versions):

```yaml
# vars.yml
latest_python_version: '1.6.2'
```

```yaml
# main.yml
tasks:
  - name: Check Python version
    command: "python3 --version"
    ignore_errors: true
    changed_when: false
    failed_when: false
    register: installed_python_version

  - name: "Install Python {{ latest_python_version }}"
    apt:
      name: "{{ python_package }}"
      state: present
    when: installed_python_version is version(latest_python_version, '<')
```

## References
- [Ansible - Playbook Tests; Comparing Versions](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_tests.html#comparing-versions)
