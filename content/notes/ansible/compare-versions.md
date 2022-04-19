---
title: "Compare Versions"
date: 2022-04-19T12:07:24+08:00
lastmod: 2022-04-19T12:07:24+08:00
draft: false
toc: false
---

To compare two versions of software, use the `version()` test.

The first task checks the installed version of Python on the remote host. The
second task compares `installed_python_version` with `latest_python_version` in
the vars file and updates Python if necessary.

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
- [Ansible - Playbook Tests](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tests.html)
