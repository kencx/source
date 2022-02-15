---
title: "SSH Use in Scripts"
date: 2022-01-02T00:12:00+08:00
lastmod:
draft: false
toc: false
images:
---

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
- [Managing SSH for Scripts and Cron Jobs](https://www.linuxjournal.com/article/8257)
