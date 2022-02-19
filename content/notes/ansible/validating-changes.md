---
title: "Validating Changes"
date: 2022-02-20T01:43:02+08:00
lastmod:
draft: false
toc: false
---

## changed_when, failed_when

In certain tasks, it can be difficult to determine if a change has occurred or
we might want to *override* the change behaviour. We can do this with
`changed_when`.

```yaml
- name: Install dependencies via Composer
  command: "usr/local/bin/composer global require phpunit/phpunit --prefer-dist"
  register: composer
  changed_when: "'Nothing to install' not in composer.stdout"
```

Similarly, `failed_when` is used to override a fail condition

```yaml
- name: Import jenkins job via CLI
  shell: >
	  java -jar /opt/jenkins-cli.jar -s http://localhost:8080/create-job "My Job" < /usr/local/my-job.xml
  register: import
  failed_when: "import.stderr and 'exists' not in import.stderr"
```

In this case, Ansible reports a failure when the command returns an error AND
when the error does not contain `exists`.

### Use cases

`changed_when` and `failed_when` are also useful in *validation* commands.
- checking if the software is running well after changing its configuration
- checking if the latest version of the software is installed.

```yaml
tasks:
  - name: validate nginx conf
    command: nginx -t
	changed_when: false
```

In this example, `nginx -t` is a validation command. It checks if the
configuration is valid and throws an error if its not. The important line here
is setting `changed_when` to `false`, as it maintains idempotency.

```yaml
tasks:
  - name: check for latest version
    command: python3 --version
	ignore_errors: true
	changed_when: false
	failed_when: false
    register: python_installed_version
```

In the next example, we check if Python is installed by running `python3
--version`. It fails silently if Python is not installed with `ignore_errors`.
`changed_when` and `failed_when` are set to `false` as there is no change or
failure condition for this particular task.

## ignore_errors

Errors can be ignored with `ignore_errors: true` which might be useful in cases
where the errors do not indicate a problem, like the above example.

# References
- [Validating Ansible Changes](https://adamj.eu/tech/2014/10/31/validating-ansible-changes/)
