---
title: "Base Box Specifications"
date: 2023-01-23
lastmod: 2023-01-23
draft: false
toc: true
tags:
- vagrant
---

A base box consists of a minimum set of software and default settings. These
[general
specifications](https://developer.hashicorp.com/vagrant/docs/boxes/base)
include:

- A `vagrant` user must exist
- The `root` and `vagrant` user must both use `vagrant` as password
- Password-less sudo for the `vagrant` user with the following in the `sudoers`
  file:

```bash
vagrant ALL=(ALL) NOPASSWD: ALL
```

- The `.ssh` folder and `authorized_keys` file must have the [appropriate
  permissions]({{< relref "/notes/ssh/ssh-cheatsheet.md#permissions" >}}).
- Public key authentication for user `vagrant` with known [insecure key
  pair](https://github.com/hashicorp/vagrant/tree/master/keys).
- Set `UseDNS no` in `sshd_config`. This avoids a reverse DNS lookup when
  connecting to the SSH client.


## Insecure By Default

The above standard specifications mean that base boxes are insecure by default.
They are accessible by anyone due to the publicly available private key.

A number of changes have been implemented to provide some measure of security:

- From Vagrant 1.2.3, the default SSH forwarded port binds to `127.0.0.1` so
  only local connections are allowed to access the box.
- From Vagrant 1.7.0, Vagrant replaces the default insecure SSH key pair with a
  randomly generated key pair on the first `vagrant up`.

{{< alert type="note" >}}
To use a custom SSH key pair, see
[Add custom SSH key pair]({{< ref "notes/vagrant/custom-key-pair.md" >}}).
{{< /alert >}}

## Using a Different Username

Most Vagrant base boxes have only 2 users with SSH access: `root` and `vagrant`.
Both are configured to use public key authentication using the insecure key pair.

To be able to login as a different user,

1. Inside the created box, create the user manually, with its `.ssh` directory.

```bash
$ sudo useradd -s /bin/bash -G sudo -m foo
$ sudo mkdir -p /home/foo/.ssh
$ sudo touch /home/foo/.ssh/authorized_keys
$ sudo chown foo:foo -R /home/test/.ssh
$ sudo chmod 0700 /home/foo/.ssh
$ sudo chmod 0600 /home/foo/.ssh/authorized_keys
```

2. Add your custom public key to `/home/foo/.ssh/authorized_keys`
3. Enable passwordless sudo for new user

```bash
$ sudo echo "foo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/foo
$ sudo chmod 0440 /etc/sudoers.d/foo
```

4. In the Vagrantfile, include:

```ruby
config.ssh.insert_key = false
config.ssh.username=foo
config.ssh.private_key_path="/path/to/private_key"
```

4. Run `vagrant ssh`

Steps 1-3 can be condensed into a shell script/Ansible playbook and passed to
the Vagrantfile's provisioner.

## References

- [Vagrant docs - Creating a base box](https://developer.hashicorp.com/vagrant/docs/boxes/base)
