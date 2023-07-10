---
title: "SSH Use in Scripts"
date: 2022-01-02T00:12:00+08:00
lastmod:
draft: false
toc: false
tags:
- ssh
---

Automated scripting with SSH is very difficult as it requires a
*non-interactive* SSH instance where the passphrase must be entered
automatically.

The alternative would be to use a key pair *without* a passphrase. To ensure this is
safe, a number of steps must be taken to secure it further.

For each SSH key, we restrict logins to only certain hosts with the
`from=` keyword AND restrict these hosts to only perform a single command with
the `command=` keyword, before exiting immediately.

```bash
# ~/.ssh/authorized_keys
from="hostA,hostB" command="command" ssh-ed25519 AAAA....
```

Without the command restriction, attackers may pretend to be the host by
spoofing an IP. To run multiple commands, use a script (within the server)
instead. This restricts the attacker greatly if the key pair were to be
compromised.

## Note
For the above to be useful, a second key pair has to be generated for the same host. To
add another public key without overwriting the first, use

```bash
$ cat ~/.ssh/newkey.pub | ssh -l user host "cat >> .ssh/authorized_keys"
```

or you can create a new user for this task. It is also useful to tag the keys with
comments `-C "comment"` to easily identify them.

## References
- [Managing SSH for Scripts and Cron Jobs](https://www.linuxjournal.com/article/8257)
