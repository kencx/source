---
title: "SSH Cheatsheet"
date: 2021-11-25T00:42:06+08:00
lastmod: 2021-12-03
draft: false
toc: false
tags:
- ssh
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
| :---------: | :------------------ |
| ~/.ssh/	  | d r - x - - - - - - |
| public key  | - r w - r - - r - - |
| private key | - r w - - - - - - - |

# References
- [SSH Crash Course](https://www.youtube.com/watch?v=hQWRp-FdTpc)
- [OpenSSH Full Guide](https://www.youtube.com/watch?v=YS5Zh7KExvE)
