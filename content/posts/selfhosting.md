---
title: "Selfhosting"
date: 2021-12-31T22:36:13+08:00
lastmod:
draft: true
toc: false
images:
tags:
  - selfhosted
---

I first learnt about selfhosting in Oct 2021. Currently, in January 2022, I have a Raspberry Pi home server mainly powered by Docker. It comprises of just 9 stacks and 12 containers, all of which are useful to me on a daily basis.

When I began selfhosting, I understood the perils of poor server security. The Internet is a dangerous place and I do not want to risk leaking any personal information whatsoever.

As such, I chose not to expose any services to the Internet directly with port forwarding. It was definitely possible to do so, in most cases. Was it difficult? Oh yes. But I learnt a lot about networking and security that I would say its worth it.

## Current Stack
As of Jan 2022, I run DietPi on a Raspberry Pi 4B, booted from an NVME M.2. Read
more about the setup [here](/notes/selfhosted/dietpi-server-setup).

There are 9 stacks, some of which I have written detailed notes for:
- Portainer - container management tool
- [Nginx Proxy Manager](/notes/selfhosted/npm) - reverse proxy manager
- [Syncthing](/notes/selfhosted/syncthing) - personal Dropbox
- FireflyIII - selfhosted budgeting service
- Pihole - DNS server and network-wide adblocker
- Calibre-Web - ebook database
- Miniflux - RSS feed reader
- Linkding - bookmark manager
- Healthchecks - service monitoring tool

Along with these containerized services, I have a Wireguard VPN server running in a DigitalOcean VPS. The VPS is necessary due to my condition of no port forwarding. I'm not taking any chances lmao.

The WG server connects to 2 WG clients - 1 in the Pi and 1 in my Android phone. This VPN allows me to connect to my Pi from outside my home network. In other words, I can access my locally selfhosted services when I'm away, which is very handy.

## Future

In 2022, I have big plans to upgrade to more powerful hardware to start
incorporating some DevOps related tools. This includes Gitea & Drone for
automated CI/CD, having 2-3 different environments (Dev, Staging & Production)
with Proxmox and work on automating deployments during code changes to my
compose files with Ansible.

I would also like to switch to pure NGINX to understand it better.
