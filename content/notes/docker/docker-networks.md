---
title: "Docker Networks"
date: 2022-02-16
draft: false
toc: false
tags:
  - docker
---

Docker has 5 network types, all configured through `docker0`.

#### Host Networking

The container shares the same network namespace as its host. These 2 commands
should return the same set of network interfaces.

```bash
$ docker run --net=host -it --rm alpine ip addr
$ ip addr
```

#### Bridge Networking

Each container runs in an isolated network namespace and use the **default
bridge** to connect to each other. The container should lack the `docker0`
interface, but have its own `eth0` veth pair with an IP.

```bash
$ docker run --net=bridge -it --rm alpine ip addr
```

This veth pair should exist on the host as well.

```bash
$ ip addr

9: vethbfa3d9c@if8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-b08c4105c645 state UP group default
    link/ether 9a:0f:11:4c:e1:5f brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet6 fe80::980f:11ff:fe4c:e15f/64 scope link
       valid_lft forever preferred_lft forever
```

#### Custom Bridge Networking
This is the same as bridge network but uses a custom bridge that was explicitly created.

```bash
$ docker network create foo
```

This creates a new bridge interface that is added to the host. All containers in
the custom bridge can communicate with other ports on that same bridge.

```bash
$ docker run -it --rm --name=container1 --network=foo alpine sh
$ docker run -it --rm --name=container2 --network=foo alpine sh
```

2 veth pairs should be created along with the bridge interface.

#### Container-defined Networking
The container created shares a network namespace with the specified container.

```bash
$ docker run -it --rm --name=container1 alpine sh
$ docker run -it --rm --name=container2 \
	--network=container:container1 alpine sh
```

Both containers share the same network interface.

#### No networking
Disables all networking for the container

```bash
$ docker run --net=none alpine ip addr
```

No interfaces are created except `lo` (localhost).

#### Others

Not discussed - Overlays, MacVLAN, IPvlan [networks](https://docs.docker.com/network/).

## Container Networking

Regardless of the network type used, networking from within the container is the same for all.

#### Publishing Ports

By default, containers do not publish any ports to the host. To make a port
available, it must be published with `--publish`. This creates a firewall rule
which maps a container port to the host port.

```bash
-p 8080:80                 # map container tcp 80 to host 8080
-p 192.168.86.2:8080:80    # map container tcp 80 to host of ip 1929168.86.2 on port 8080
```

#### IP Address, Hostname

A container is assigned an IP address for every Docker network it connects to.
IP addresses are assigned by the Docker daemon (which acts as a DHCP server),
along with a subnet mask and gateway.

When starting a container with a connect `--network`, a static IP can be
assigned with `--ip` or `--ip6`. Similarly, the container's hostname can be
overridden with `--hostname` (defaults to the container's ID).

#### DNS

A custom DNS server can be specified to each Docker container with `--dns`.
Google's DNS `8.8.8.8` is added if it no DNS server is given.

The container also inherits the DNS settings of the host in `/etc/resolv.conf`.
However, custom hosts in `/etc/hosts` are not inherited. To add additional
hosts, use the `--add-host` flag

```bash
$ docker run --add-host=test-host:93.184.216.34 --it alpine
```

## References
- [Deep Dive into Linux Networking and Docker](https://aly.arriqaaq.com/linux-networking-bridge-iptables-and-docker/)
- [Container Networking](https://docs.docker.com/config/containers/container-networking/)
