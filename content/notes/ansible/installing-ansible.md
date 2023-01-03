---
title: "Installing Ansible 2.12 with all dependencies with pipx"
date: 2022-04-19T12:19:39+08:00
lastmod: 2022-12-29T16:38:39+08:00
draft: false
toc: false
tags:
- ansible
---

>TLDR: See
>[here](https://github.com/kencx/dotfiles/blob/master/dots/bin/bin/install-ansible)
>for the full script.

Ansible's release history is [really confusing](https://docs.ansible.com/ansible/devel/reference_appendices/release_and_maintenance.html). Ansible's core package has taken on a number of names:
- ansible (pre 2.9)
- ansible-base (2.10)
- ansible-core (post 2.10)

and from Ansible 2.10, Ansible community packages have also split off into their own
"[Ansible Community package](https://github.com/ansible-community)" which has a
[different](https://docs.ansible.com/ansible/devel/reference_appendices/release_and_maintenance.html#ansible-community-package-release-cycle)
release cycle and its own versioning system.

To properly install the latest version of Ansible 2.12 without dependency
issues, I use [pipx](https://github.com/pypa/pipx)

```bash
# install or update pipx
$ python3 -m pip install --user pipx
$ python3 -m pipx ensurepath

# install ansible
$ pipx install --include-deps ansible
```

To include ansible-lint

```bash
$ pipx inject --include-apps ansible ansible-lint
```

To include [molecule](https://github.com/ansible-community/molecule) with the Docker and Vagrant driver,

```bash
$ pipx inject --include-apps ansible molecule
$ pipx inject --include-deps --include-apps ansible molecule-docker
$ pipx inject --include-deps --include-apps ansible molecule-vagrant
```

Finally, list all installed packages

```bash
$ pipx list --include-injected
apps are exposed on your $PATH at /home/${USER}/.local/bin
   package ansible 5.5.0, installed using Python 3.9.7
    - ansible
    - ansible-config
    - ansible-connection
    - ansible-console
    - ansible-doc
    - ansible-galaxy
    - ansible-inventory
    - ansible-lint
    - ansible-playbook
    - ansible-pull
    - ansible-test
    - ansible-vault
    - chardetect
    - distro
    - mol
    - molecule
    - normalizer
    Injected Packages:
      - ansible-lint 6.0.1
      - molecule 3.5.2
      - molecule-docker 1.1.0
      - molecule-vagrant 1.0.0
```
