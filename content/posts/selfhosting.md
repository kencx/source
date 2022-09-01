---
title: "A Beginner's Journey in Selfhosting"
date: 2021-12-31T22:36:13+08:00
lastmod: 2022-09-01
draft: false
toc: true
images:
tags:
  - selfhosted
---

>Selfhosting is the practice of running and maintaining a service or website
>using a private web server, instead of using an external service outside of
>your own control.

I first learnt about selfhosting in Oct 2021 when I was trying to find out how
to best learn and work with Ansible and Docker. I decided to get a Raspberry
Pi and there began my journey...

{{< figure src="/posts/images/selfhosted-initial-commit.png" caption="Initial commit from a now private Git repo" alt="Initial commit" class="center" width="250px">}}

## Planck

The Planck is a Raspberry Pi 4B booted from a NVME M.2 drive. It runs
[DietPi](https://dietpi.com/) OS and the following dockerized services:

- Portainer - container management tool
- ~~Nginx Proxy Manager~~ [Traefik]({{< ref "/notes/selfhosted/traefik.md" >}}) - reverse proxy
- [Syncthing]({{< ref "/notes/selfhosted/syncthing.md" >}}) - personal Dropbox
- FireflyIII - budgeting software
- Pihole - DNS server and adblocker
- Calibre-Web - ebook database
- Miniflux - RSS feed reader
- Linkding - bookmark manager

For external access to the Planck, I run a Wireguard VPN server in an external
DigitalOcean VPS. The server connects to 2 clients - the Planck and my Android
phone. With the VPN, none of the above services are directly exposed to the
Internet.

## Challenges

### Networking

The largest challenge for me was networking since I had zero prior knowledge. My
first resource was [Computer Networks - Andrew
Tanenbaum](https://www.amazon.com/Computer-Networks-5th-Andrew-Tanenbaum/dp/0132126958).
It contained a wealth of knowledge but was incredibly dry and boring.
[HomeNetHowTo](https://www.homenethowto.com/) was much more helpful because it
focused on a typical home network and the very basics.

Armed with these basics, I managed to set up and access my desired local
services. Naturally, this wasn't very safe, and I got tired of typing IPs and
ports.

So I needed local DNS resolution.

I bought a domain on Namecheap and configured Pihole to serve as my local DNS
server. With the heavy lifting from [Nginx Proxy
Manager](https://nginxproxymanager.com/), I had a working reverse proxy,
complete with SSL certificates and DNS resolution.

This served me well for about three days before I wanted external access to
these local services.

However, I vastly overestimated my existing skills and spent more than 3 days
trying to get [Wireguard](https://www.wireguard.com/) working. This was
partially due to my insistence on avoiding external port forwarding. Without
diving into the details (I'll leave it for my notes), requests from an external
WG client (my phone) can access my home server via

```
phone --> VPS --> Pi
```

To do this, I had to ensure that the external client was using the local DNS
server for name resolution, and that requests that arrived via the `wg0`
interface were port forwarded (via iptables) to their destinations. This was a
non-trivial for me then, but I really did learn *a lot* from the whole process,
about DNS configuration, iptables or just networking administration as a whole.

## Future

The Planck was a good starting point but I decided to go a step further into
just selfhosting on a Raspberry Pi - by starting a home lab. I will be purchasing a
cheap Intel NUC to run Proxmox hypervisor and possibly a NAS in the near future.

This time, I aim to set up automation pipelines with some goals:
- Infrastructure as code
- Automated deployment
- Automated configuration management
- CI/CD
- Logging, monitoring etc.

More lessons await to be learnt!

## Useful Resources that helped me a lot
- [Awesome Selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted)
- [DevOpswithDocker](https://devopswithdocker.com/)
- [Docker Deep Dive](https://www.amazon.com/Docker-Deep-Dive-Nigel-Poulton/dp/1521822808)
- [The Linux Command Line](https://linuxcommand.org/tlcl.php)
- [Unix and Linux System Administration Handbook](https://www.amazon.com/UNIX-Linux-System-Administration-Handbook/dp/0134277554)
- [HomeNetHowTo](https://www.homenethowto.com/)
- [Securing a Linux Server](https://github.com/imthenachoman/How-To-Secure-A-Linux-Server#the-ssh-server)
- [Let's Encrypt Certificates on NPM](https://blog.gurucomputing.com.au/doing-more-with-docker/lets-encrypt-certificates/)
- [Point to DigitalOcean nameservers from common domain registrars](https://blog.gurucomputing.com.au/doing-more-with-docker/lets-encrypt-certificates/)
- [Traefik Docker Tutorial](https://www.smarthomebeginner.com/traefik-2-docker-tutorial/)
- [Configuring devices to use Pihole as DNS server](https://discourse.pi-hole.net/t/how-do-i-configure-my-devices-to-use-pi-hole-as-their-dns-server/245)
- [Ansible for DevOps](https://www.ansiblefordevops.com/)
