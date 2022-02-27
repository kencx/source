---
title: "Syncthing"
date: 2021-12-31T01:56:46+08:00
draft: false
toc: false
images:
---

[Syncthing](https://github.com/syncthing/syncthing) is an open source and free,
file synchronization software that is:

- A P2P network that sends all changes to all connected instances.
- Multi-Platform compatible[^1]
- FOSS

What Syncthing is **not**:
- A cloud platform
- A backup alternative

AFAIK, there is no IOS app for Syncthing.

## Central Server
In my home network, I have a Raspberry Pi running as a central server. I use Syncthing as my personal "Dropbox" alternative to share documents between my devices. This server is then backed up locally and remotely with `restic`.

Connected to the central server are multiple nodes or hosts that consume the synced data. These include my PC, Android phone and laptop. For each individual node, I control the folders that are synced, including whether data is sent one-way or both ways. This ensures no excessive data is shared.

For example, I sync my markdown notes between the server and my phone for a quick reference, but not my full image gallery. Newly captured images on my phone are also sent, one-way, back to the server for storage.

## Installation
Docker compose is the simplest method of installation on Linux. An image and compose file template is provided by [linuxserver.io](https://hub.docker.com/r/linuxserver/syncthing).

By default, the syncthing volume structure is confusing. Instead, I choose to mount the `config` and `data` folders separately.

```bash
volumes:
	- ./config:/config
	- ./sync:/data
```

## Configuration

The first, crucial thing to do is to turn on GUI authentication. This prevents others from accessing your Syncthing interface without the correct credentials. The option is found under `Settings > GUI`.

Although Syncthing does not store data in the cloud, it does safeguard against accidental deletion or change with file versioning. This is turned off by default. A good practice would be to enable simple file versioning with 5 copies for at least 30 days.

>When used with Traefik, accessing the Web GUI results in a redirect loop. Solve this by opening the port to the Web GUI, accessing it via `IP:PORT` and turning off TLS:
>
>```
>Actions -> Advanced -> GUI -> Use TLS (ensure it is unchecked)
>```
>
>As Traefik ensures HTTPS, this is no longer necessary.


# References
- [theselfhostingblog - How to set up a headless syncthing network](https://theselfhostingblog.com/posts/how-to-set-up-a-headless-syncthing-network/)


[^1]: For Windows, [Synctrayzor](https://github.com/canton7/SyncTrayzor) is useful as a tray utility launcher.
