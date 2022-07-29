---
title: "Security Hardening"
date: 2022-01-23T21:00:11+08:00
lastmod: 2022-02-16
draft: false
toc: true
tags:
- security
- selfhosted
- linux
---

This guide follows a few key security hardening steps that should be performed
in the first 5 minutes of starting a new Linux server.

## Creating a non root user

Always follow the [Principle of Least
Privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege). Create a
new non-root user with a home directory. Add a complex password.

```bash
$ useradd -m johndoe
$ passwd johndoe
```

You can check for the new user in `/etc/passwd`.

For your new user to run commands as root, it has to be added to the `sudo`
group. First, check that the `sudo` group exists:

```bash
$ sudo visudo
# Your /etc/sudoers file should contain the following line
---
%sudo ALL=(ALL:ALL) ALL
```

>NEVER edit `/etc/sudoers` directly. `visudo` is safer as it prevents you from locking yourself
>out of the file by performing syntax checks.

Then, add the user to the `sudo` group:

```bash
$ usermod -aG sudo johndoe
$ groups johndoe
johndoe: johndoe, sudo
```

## SSH Config

>Before making any SSH changes, it is good to have a second terminal open to
>prevent yourself from being locked out.

Use SSH keys to login to your server, instead of passwords. Better yet, disable
password authentication for a safer and faster method of access.

To do so, make the following changes to your default SSH configuration file
`etc/ssh/sshd_config`.

```
PasswordAuthentication no
PermitRootLogin no
```
Firstly, we want to disable password authentication and direct root login.
Ensure you have set up your SSH keys before making this change. By disabling
passwords, we completely prevent hackers from brute forcing your password,
making it impossible to login without a private key. Its also good to permit
root login, since no one should really be using the `root` account anyway.

```
Port [custom-port]
```

This next step has mixed reviews. By changing your SSH port away from the
default port 22, we stop the constant barrage of bots trying to access your
public facing servers[^1]. However, more advanced bots would simply locate your
custom port anyway. It is good to weed out the spam in your log files though.
Just remember to make the same port changes to all other applications that
requires your SSH port (like ufw).

```
LoginGraceTime 30 # in sec
MaxAuthTries 3
MaxSessions 3
```
Next, I like to limit the grace times and max number of tries a user can attempt
to login with a failed password.

```
PermitEmptyPasswords no
X11Forwarding no
```

After you're happy with your changes, restart the ssh server with `sudo service
sshd restart`. Check your new config with `sudo sshd -T`.

## Firewall

 A firewall is the basic line of defense between your server and incoming
 network. Its never hurts to have it. `ufw` is a good firewall to have.

```bash
$ sudo apt install ufw
$ sudo ufw default deny incoming
$ sudo ufw default allow outgoing
$ sudo ufw allow ssh     # or your custom ssh port
$ sudo ufw enable
$ sudo ufw status verbose
```

>If you are using Docker on your server with `ufw`, you should know that Docker
>complete ignores and bypasses your ufw rules by default. Read more
>[here](https://github.com/chaifeng/ufw-docker) for a solution.

## Fail2Ban

`fail2ban` monitors for intrusion attempts and bans such IPs. It does so by
monitoring your access logs and bans any IP that fails to login for a set amount
of time after a number of tries. It can also permanently ban such IPs forever.
Install `fail2ban` with `sudo apt install fail2ban`.

Instead of overriding the default fail2ban config, we create a separate local
copy to prevent it from being overwritten.

```bash
# /etc/fail2ban/jail.d/ssh.local
[sshd]
enabled = true
banaction = ufw
port = ssh
filter = sshd
logpath = %(sshd_log)s

bantime = 1h
bantime.increment = true
bantime.factor = 24
bantime.maxtime = 5w
maxretry = 3
findtime = 60
```
This creates a jail for SSH that tells `fail2ban` to look at your SSH logs and
use `ufw` to ban any IPs as needed. The parameters for `bantime` set a
increasing bantime for each failed try, up to a maximum of 5 weeks.

Restart `fail2ban` and check its status.

```bash
$ sudo fail2ban-client reload
$ sudo fail2ban-client status sshd
```

Just make sure to not ban yourself when testing. Have a second SSH terminal
open (speaking from experience).

## Automation with Ansible

When setting up many servers, the aforementioned tasks can be somewhat of a
chore. Thankfully, they are easily automated with Ansible. I have written a basic
Ansible role
[here](https://github.com/kencx/playbooks/tree/master/playbooks/roles/security) for
these very tasks.

Jeff Geerling also has a (much better)
[role](https://github.com/geerlingguy/ansible-role-security) available, which I
recommend checking out, especially if you're interested in learning Ansible.

## Network Management
Once you have performed the basic security hardening, its good to look at
network management to ensure all web connections are secured as well. More info
at [network management](/notes/selfhosted/network-management).

# References
- [How to Secure a Linux Server](https://github.com/imthenachoman/How-To-Secure-A-Linux-Server)
- [Best way to add user to sudoer group](https://unix.stackexchange.com/questions/122087/what-is-the-best-way-to-add-a-user-to-the-sudoer-group)
- [ufw-docker](https://github.com/chaifeng/ufw-docker).

[^1]: This is also precisely why its important to secure your servers. There are
  countless numbers of automated bots trying to access any poorly secured
  servers for malicious use.
