---
title: "Caching SSH Keys"
date: 2023-03-10
lastmod: 2023-03-10
draft: false
toc: true
tags:
- ssh
---

If a passphrase was provided during key pair generation, it must be typed for every use of the key.

To eliminate this, `ssh-agent` and `ssh-add` can be used to cache the private key.

```bash
$ eval "$(ssh-agent)" 			# start ssh-agent
$ ssh-add ~/.ssh/[key-name] 	# adds private key into cache
$ ssh-add -l 					# check current cached fingerprints
```

Now, we only need to pass the passphrase once for authentication.

## Automatic Persistent Caching
There are also tools that can help cache SSH keys to `ssh-agent` automatically on boot.

### Funtoo Keychain
To persist cached SSH keys into `ssh-agent`, we can use [keychain](https://github.com/funtoo/keychain) as an ssh-agent frontend.

```bash
$ pacman -S keychain
```

{{< alert type="info" >}}
Funtoo `keychain` is different from macOS's Keychain Access.
{{< /alert >}}

Add the following to your `.bashrc`, `.bash_profile` or start up file:

```bash
eval $(keychain --eval --quiet id_ed25519 ~/.ssh/custom_key)
[ -f $HOME/.keychain/$HOST-sh ] && . $HOME/.keychain/$HOST-sh 2>/dev/null
```

On boot, `keychain` will:

1. Start `ssh-agent` if it has not already been started.
2. Add the given SSH keys to `ssh-agent` if they have not already been cached.
   If any of the keys are encrypted with a passphrase, you will be prompted for
   it here.
3. `keychain` caches the decrypted private key in memory. New shells will be
   able to use the cached SSH keys without prompt until the system is rebooted.

## References
- [Arch Wiki - SSH keys/Keychain](https://wiki.archlinux.org/title/SSH_keys#Keychain)
