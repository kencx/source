---
title: "The Beginnings of Selfhosting"
date: 2021-12-31T22:36:13+08:00
lastmod: 2022-02-01
draft: false
toc: false
images:
tags:
  - selfhosted
---

>Selfhosting is the practice of running and maintaining a service or website
>using a private web server, instead of using an external service outside of
>your own control.

I first learnt about selfhosting in Oct 2021 when I was trying to find out how
to best learn about and practice Ansible and Docker. I decided to get a Raspberry
Pi and there begins my journey...

{{< figure src="/posts/images/selfhosted-initial-commit.png" caption="Initial commit from a now private Git repo" alt="Initial commit" class="center" width="250px">}}

## Planck

The Planck is a Raspberry Pi 4B booted from an NVME M.2 and it is my first foray
into selfhosting. It runs Dietpi OS and the following Dockerized services:

- Portainer - container management tool
- ~~Nginx Proxy Manager~~ [Traefik]({{< ref "/notes/selfhosted/traefik.md" >}}) - reverse proxy
- [Syncthing]({{< ref "/notes/selfhosted/syncthing.md" >}}) - personal Dropbox
- FireflyIII - budgeting software
- Pihole - DNS server and network-wide adblocker
- Calibre-Web - ebook database
- Miniflux - RSS feed reader
- Linkding - bookmark manager

To enable external access to the Planck, I have a Wireguard VPN server running
in a DigitalOcean VPS. The Wireguard server connects to 2 clients - the Planck
and my Android phone.

The VPN is necessary as I chose not to expose any services to the Internet via
port forwarding. I was (and still am) much too afraid of attackers. It was
extremely challenging and I spent more than 3 days trying to get Wireguard
working.

Still, I learnt a lot more about computer networking than I would have from
*just* reading a textbook.

## Future

The Planck was a good starting point but I decided to go a step further into
just selfhosting on a Raspberry Pi - by starting a home lab. I will be purchasing a
cheap Intel NUC to run Proxmox hypervisor and possibly a NAS in the near future.

This time, I aim to set up automation pipelines on an on-prem server with the
following goals:
- Infrastructure as code
- Automated deployment
- Automated configuration management
- CI/CD
- Immutable infrastructure
- Logging, monitoring etc.

More lessons await to be learnt!

## Useful Resources that helped me a lot
- [Awesome Selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted)
- [DevOpswithDocker](https://devopswithdocker.com/)
- [Docker Deep Dive](https://www.amazon.com/Docker-Deep-Dive-Nigel-Poulton/dp/1521822808)
- [The Linux Command Line](https://linuxcommand.org/tlcl.php)
- [Unix and Linux System Administration Handbook]()
- [HomeNetHowTo](https://www.homenethowto.com/)
- [Securing a Linux Server](https://github.com/imthenachoman/How-To-Secure-A-Linux-Server#the-ssh-server)
- [Let's Encrypt Certificates on NPM](https://blog.gurucomputing.com.au/doing-more-with-docker/lets-encrypt-certificates/)
- [Point to DigitalOcean nameservers from common domain registrars](https://blog.gurucomputing.com.au/doing-more-with-docker/lets-encrypt-certificates/)
- [Traefik Docker Tutorial](https://www.smarthomebeginner.com/traefik-2-docker-tutorial/)
- [Configuring devices to use Pihole as DNS server](https://discourse.pi-hole.net/t/how-do-i-configure-my-devices-to-use-pi-hole-as-their-dns-server/245)
- [Ansible for DevOps](https://www.ansiblefordevops.com/)
