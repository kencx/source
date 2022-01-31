---
title: "Server Security Hardening"
date: 2022-01-23T21:00:11+08:00
draft: false
toc: false
---

This guide follows a few key security hardening steps that should be performed
in the first 5 minutes of starting a Linux server.

## Creating a non root user

On some distributions, we login directly as `root`. However, we should always
operate with the [Principle of Least
Privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege). Hence,
we want to create a new non-root user

```bash
$ useradd -m johndoe
$ passwd johndoe
```

This creates a new user `johndoe` with a home directory, and prompts for a new
password. Although there are no restrictions, ensure your entered password is
complex enough. You can check for the new user in `/etc/passwd`.

Next, we want to ensure your new user can run commands as root. Check that the
`sudo` group exists and that members of the group have permissions to run
commands as root:

```bash
$ sudo visudo
# Your /etc/sudoers file should contain the following line
---
%sudo ALL=(ALL:ALL) ALL
```

>NEVER edit `/etc/sudoers` directly. `visudo` is safer as it prevents you from locking yourself
>out of the file by performing syntax checks.

Now, add the user to the `sudo` group:
```bash
$ usermod -aG sudo johndoe
$ groups johndoe # ensure sudo is listed
```

## SSH Config

>Before making any SSH changes, it is good to have a second terminal open to
>prevent yourself from being locked out.

If you have not done so, consider using SSH keys to login to your server,
instead of a password. Coupled with disabling password authentication, it is a
safer and faster method of accessing your server.

To secure SSH in your server, make the following changes to your default SSH
configuration file `etc/ssh/sshd_config`.

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
This next step has mixed reviews among the community. By changing your SSH port
away from the default port 22, we stop the constant barrage of bots trying to
access your public facing servers[^1]. However, more advanced bots would simply
locate your custom port anyway. It is good to weed out the spam in your log
files though. Just remember to make the same port changes to all other
applications that requires your SSH port (like ufw).

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
 network. Its never hurts to have it. Install `ufw` as your firewall `sudo apt
 install ufw`

```bash
$ sudo ufw default deny incoming
$ sudo ufw default allow outgoing
$ sudo ufw allow ssh     # or your custom ssh port
$ sudo ufw enable
$ sudo ufw status verbose
```

>If you are using Docker on your server with `ufw`, you should know that Docker
>complete ignores and bypasses your ufw rules. Read more about this issue and
>how to solve it [here](https://github.com/chaifeng/ufw-docker).

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
[here](https://github.com/kencx/lab/tree/master/playbooks/roles/security) for
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
