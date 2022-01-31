---
title: "SSH Quickstart"
date: 2021-11-25T00:42:06+08:00
publishDate: 2021-12-01
lastmod: 2021-12-03
draft: false
toc: false
images:
---

Generate a new key pair. This will prompt for an optional passphrase and file
name.
```bash
$ ssh-keygen -t ed25519 -c "comment"
```
Add the public key to the server's `authorized_keys` file.
```bash
$ ssh-copy-id -i ~/.ssh/key.pub user@ip
```
To eliminate the need to type the passphrase for every use of the key, we can
cache the private key with `ssh-agent` and `ssh-add`
```bash
$ eval "$(ssh-agent)"
$ ssh-add ~/.ssh/private-key-file
$ ssh-add -l	# check current cached keys
```
The key pair should be fully configured for use
```bash
$ ssh user@ip
```

## Permissions

For SSH to work properly, all files must have the correct permissions:

| file		  | permissions			|
|------------ | ------------------- |
| ~/.ssh/	  | d r x - - - - - -   |
| public key  | - r w - r - - r - - |
| private key | - r w - - - - - - - |

# Advanced

## SSH Use in Scripts

You might want to use SSH in scripting or cron jobs. Ideally, this would require a *non-interactive* SSH instance where the given passphrase would be entered automatically. This is, however, extremely challenging.

The alternative would be to use a key pair *without* a passphrase. To ensure this is safe, a number of steps must be taken to secure it further.

Within the server's `authorized_keys` file, we can include the following:
```bash
from="hostA,hostB" command="command" ssh-ed25519 AAAA....
```

For each SSH key within the file, we restrict logins to only `hostA` and `hostB` with `from=""`. However, this might be breached by spoofing an IP or pretending to be the host.

Next, we further restrict the hosts to only perform a single command with `command=""` and exiting immediately. To run multiple commands, use a script (within the server) instead. This restricts the attacker greatly if the key pair were to be compromised.

### Note
For the above to be useful, a second key pair has to be generated for the same host. To add another public key without overwriting the first, use

```bash
$ cat ~/.ssh/newkey.pub | ssh -l user host "cat >> .ssh/authorized_keys"
```

or you can create a new user for this task. It is also useful to tag the keys with comments `-c "comment"` to easily identify them.

# References
- [SSH Crash Course](https://www.youtube.com/watch?v=hQWRp-FdTpc)
- [OpenSSH Full Guide](https://www.youtube.com/watch?v=YS5Zh7KExvE)
- [Managing SSH for Scripts and Cron Jobs](https://www.linuxjournal.com/article/8257)
