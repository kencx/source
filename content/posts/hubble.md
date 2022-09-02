---
title: "Hubble Homelab"
date: 2022-07-25T16:30:00+08:00
lastmod: 2022-09-01
draft: false
toc: true
images:
tags:
  - homelab
  - selfhosted
---

After the [Planck]({{< ref "/posts/selfhosting.md" >}}), I wanted a dedicated
server for learning and working with DevOps concepts and tools.

## Hubble

Hubble is an Intel HP Elitedesk 800 G2 Mini NUC (i5-6500T, 8GB DDR4). It has more than 1 TB of local storage and 2TB of external storage for backups. There is no NAS (yet).

Hubble runs [Proxmox](https://www.proxmox.com/en/) OS with 2 VMs and 3 LXCs:

| Host     | Type   | Description                                     |
| -------- | ------ | ----------------------------------------------- |
| pfSense  | VM     | Virtualized pfSense router and firewall         |
| NFS      | VM     | Virtualized NAS server                          |
| cmd      | LXC    | Deployment and management tools (eg. Portainer) |
| dev      | LXC    | Dev environment for tinkering                   |
| prod     | LXC    | Prod environment for local services             |

### Networking

I wanted a homelab network that is entirely isolated from my LAN, so my family's
devices remain unaffected if anything in the homelab were to go down. As such,
the virtualized services of the homelab are located entirely in a private
subnet, gated by a virtualized pfSense router.

{{< figure src="/posts/images/homelab_network.jpg" caption="Homelab Network" alt="Homelab Network Diagram" class="center" width="450px">}}

>If you're shocked or horrified by the above diagram, I get it - my networking
>setup is less than ideal. Because of the lack of an Ethernet port in my room
>(and the inability to do anything about it), I tried to get Proxmox working with
>a WiFi-only setup but it was too painful. I then decided the next best thing was
>to purchase a cheap router that supported client bridging and put dd-wrt on it.
>
>The speeds are terrible but they are acceptable for me, the sole user of this
>homelab, for now. Feel free to throw me any suggestions on how this can be
>better under my constraints.

The Planck now only runs Pihole. It remains outside of the homelab network and
continues to serve as the local DNS server for my devices, as well as the
homelab. The typical route a DNS request from my homelab takes is:

```
Host -> Pfsense -> Pihole -> Upstream DNS server
```

>I decided against setting up a second DNS server within homelab subnet to avoid
>complicating things. This setup works perfectly fine for my current use cases.

The Wireguard VPN has also been retired for now, as I have not found the time to
get it working with the current networking setup.

### Infrastructure

The infrastructure setup comprises of:

1. Templating LXC images
2. Provisioning templates and mounting NFS shares
3. Running Docker services

LXC templates are generated from Ansible via a [build
pipeline](https://github.com/kencx/homelab-iac/tree/a7c4896e8abe5bba4c30f0187620bbd3c53eaed4/images)
that serves to:

1. Create a temporary LXC container
2. Bootstrap the container with security hardening, SSH keys, installation of common software
3. Create a base image of the container and deletes it after

The images are then provisioned via Terraform and Ansible performs any final
config management. Inside the provisioned LXCs, all services are running in
Docker containers, which are started and managed with docker compose files.

>I personally find this setup very clunky. The image build pipeline is prone to
>failure (which requires the ARP cache to be cleared to make way for a new
>temporary container with a new MAC address), all services are still managed with
>docker compose and docker images must still be updated manually.
>
>I do believe this can be greatly improved, with a container orchestration tool
>like [Nomad](https://www.nomadproject.io/) or
>[Kubernetes](https://kubernetes.io/).

### Storage

All guest LXCs in Hubble are mounted with NFS shares from a central, virtualized
VM running NFS. This enables all guest hosts to be destroyed and recreated
without losing their persistent data.

| Type of data     | Description                            |
| ---------------- | :------------------------------------: |
| Services' data   | Persistent data for running services   |
| Archival backups | Large archived files                   |
| LXC & VM backups | Backups of hosts performed by Proxmox  |
| Syncthing data   | Shared files between Syncthing clients |

All data is also backed up via [restic](https://restic.net/) and
[autorestic](https://autorestic.vercel.app/) to an external hard drive and
[Backblaze](https://www.backblaze.com/).

>As of the time of writing (Jul 2022), Hubble has remained online and stable for
>more than two months without maintenance, while I took a necessary break to
>prevent burnout.

## Challenges
### Analysis Paralysis

Moving from a simple SBC to a hypervisor was not simple. There were many new
concepts and tools to pick up (LVM storage, qemu, bridge networking etc.).
However, my greatest challenge was learning the best way to do things.

What storage solution is the best? How should I structure my network? Should I
run Docker containers in VMs or just LXCs? Or maybe Docker containers in LXCs? I
had analysis paralysis.

I'm not sure if the choices I made were the best, but they made sense to me
given the constraints, information and technical skills I had.

### Storage Woes

To cover actual problems I encountered, two come to mind. The first was storage
issues I faced between the NFS server, Proxmox host and guest LXCs.

The initial storage setup I had was extremely brittle in hindsight. Here's the
problem: unprivileged LXCs cannot mount NFS shares directly. Proxmox does not
support this the last time I checked (as of 28/04/22).

The workaround is to mount the shares to the Proxmox host, and bind mount these
directories from the host to the unprivileged LXCs. Seems unnecessarily
complicated, I know.

```
NFS server -- mount NFS share --> Proxmox host -- bind mount --> Unprivileged LXC
```

Then comes the problem of permissions. From the NFS server to its client
(Proxmox host), I enabled `no_root_squash` (for now), allowing unrestricted
read, write access. From the Proxmox host to the unprivileged LXC, Proxmox
performs permissions mapping from UID `XXXX` to UID `10XXXX`. This is what makes
the unprivileged LXC *unprivileged*.

The solution seemed straightforward: Create a group with GID `101000` on the NFS
server which will cascade all permissions down to the LXC. That worked great -
the user could read and write files both ways.

Then came Docker. Within the LXCs, I was bind mounting directories to my Docker
services. In some of these containers, they run as root. I try to change the
default UID and GID for most of my containers but sometimes, the container
doesn't work well due to how the maintainer manages permissions within the
image. A lot of the times, the problem arises when the container tries to change
ownerships and permissions of files on startup.

I discovered that while I could read and write files both ways, I could modify
permissions and ownerships on the NFS server only. I couldn't change permissions
and ownerships on the LXC (and as such, within the Docker containers as well).
To this day, I'm still unsure why.

I tried working with ACLs to modify permissions, but I just couldn't grasp it,
and had to find an alternative.

The alternative: I decided to turn the affects LXCs into privileged LXCs that
support the mounting of NFS shares. This removes the need for bind mounting from
the Proxmox host and fixed all permissions problems I had. The only difference
between privileged and unprivileged LXCs was the aforementioned mapping of UIDs
and GIDs, which means an attacker would gain root access if they break out of
the container.

I found this to be an acceptable risk for my homelab, mainly because my homelab
is isolated in its own subnet behind a firewall, which in turn is behind my LAN
router with no open ports to the Internet. If an attacker were to gain root
access to these LXCs, I believe that would be the least of my problems.

### Single Point Failures

The second problem I faced was amusingly also to do with NFS.

I woke up one Sunday morning to discover all the Proxmox guest hosts were
returning "Status Unknown". I also noticed that the scheduled weekly backups
were still ongoing since they began five hours ago. Not good.

Without thinking, I decided to go for the easiest solution: turn it off and on
again and hope for the best. On boot, I checked for data loss. Everything seemed
normal and all files were supposedly there. It was then I also realised I needed
a better way to check for data loss and backup integrity.

Next, I tried to identity the root cause:

- I had 3 guest backups scheduled at 4am
- The guest backups folder is a NFS share mounted to the Proxmox host
- The NFS server is a guest VM

```bash
$ less /var/log/syslog # in pve host
May  1 04:00:03 pve pvescheduler[2524137]: <root@pam> starting task UPID:pve:002683EE:0B94819A:626D9543:vzdump:101:root@pam:
May  1 04:00:03 pve pvescheduler[2524142]: INFO: starting new backup job: vzdump 101 --compress zstd --storage backups --mailnotification always --prune-backups 'keep-monthly=6,keep-weekly=5,keep-yearly=1' --quiet 1 --node pve --mode snapshot
May  1 04:00:04 pve pvescheduler[2524142]: INFO: Starting Backup of VM 101 (qemu)
May  1 04:00:07 pve pvescheduler[2524142]: VM 101 qmp command failed - VM 101 qmp command 'guest-ping' failed - got timeout
May  1 04:00:22 pve pvestatd[1365]: VM 101 qmp command failed - VM 101 qmp command 'query-proxmox-support' failed - got timeout
May  1 04:00:24 pve pvestatd[1365]: got timeout
May  1 04:00:24 pve pvestatd[1365]: status update time (8.245 seconds)
May  1 04:00:32 pve pvestatd[1365]: VM 101 qmp command failed - VM 101 qmp command 'query-proxmox-support' failed - unable to connect to VM 101 qmp socket - timeout after 31 retries
...
May  1 04:06:55 pve kernel: [1943198.483123] nfs: server 10.10.10.102 not responding, timed out
May  1 04:10:37 pve pvescheduler[2524142]: VM 101 qmp command failed - VM 101 qmp command 'backup-cancel' failed - unable to connect to VM 101 qmp socket - timeout after 5957 retries
May  1 04:11:22 pve pvescheduler[2524142]: VM 101 qmp command failed - VM 101 qmp command 'cont' failed - unable to connect to VM 101 qmp socket - timeout after 448 retries
```

From above, the backup of the pfSense VM starts at 4am, but times out three
seconds later. It continues to retry the backup until the NFS server becomes
unreachable, three minutes later. Since the backup destination is the mounted
NFS share, the backup continues to fail.

>Side note: I also discovered that the static route from the Proxmox host to NFS
>server disappeared on reboot. I had forgotten to set up a permanent route.

While I can only speculate on the exact cause, it's possible that the
virtualized pfSense faced a network issue, causing the entire homelab to come to
a standstill. A risk of running a virtualized router on the same machine as your
entire homelab is that it poses a single point of failure (SPOF) to the entire
system.

Following this incident, I moved all backups to a separate destination folder
and synchronize it with the mounted NFS share after. pfSense continues to run
virtually on the same machine. While it's probably a good idea to move the
instance to a dedicated machine, I lack the money to find another server, so
it's an acceptable risk I'm willing to endure.

At the point of writing, this is the first and last time a similar incident
occurred.

## Future
The first iteration of Hubble has been a great learning experience. Looking
forward, the second iteration of Hubble will definitely involve container
orchestration and service discovery tools. I am also saving up for a dedicated
NAS server, although it will be constrained by my terrible networking setup.

Let's see where we'll be in another six months.