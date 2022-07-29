---
title: "Troubleshooting Networking Issues"
date: 2022-04-19T15:14:15+08:00
lastmod: 2022-04-19T15:14:15+08:00
draft: false
toc: true
tags:
- networking
---

These notes provide basic troubleshooting guidelines to networking issues.

We will work our way up the network layers.

## Layer 1 - Physical Layer {#physical-layer}
1. Check that the network cable is working and plugged in.
2. Check the network interface is up

```bash
$ ip [-br] link
```

If there is any indication of `DOWN`, enable the interface

```bash
$ ip link set eth0 up
```

3. For further issues such as packet loss, corruption or collisions, we can view
the interface's statistics with `-s`

```bash
$ ip -s link show eth0
```

It would be best to troubleshoot these issues with more advanced tools like
Wireshark or tcpdump.

## Layer 2 - Data Link Layer {#data-link-layer}
A common problem is that an ARP entry might not have been populated.

1. Check entries in the ARP table

```bash
$ ip neigh
```

Ensure the MAC address is populated and `REACHABLE` (or `STALE`)

2. If a device (eg. router) was replaced recently, its new ARP entry might not
   have been added yet as the table caches previous entries for an amount of
   time. Manually delete the existing entry to force a new ARP discovery

```bash
$ ip neigh delete [ip] dev eth0
```

## Layer 3 - Network Layer {#network-layer}
1. Ensure the host machine's IP address is present

```bash
$ ip -br a
```

If absent, the problem could be:
- a network configuration error in the config file
- DHCP

2. Ping the Internet

```bash
$ ping 8.8.8.8
$ ping google.com
```

If the ping with an IP is working, but not the DNS, skip to [DNS](#dns).

3. Otherwise, check that the route to the default gateway is present

```bash
$ ip route
```

4. If there is trouble continue to other hosts on the LAN (`no route to host`),
   check if a route between the hosts exists

```bash
$ ip route show 10.10.10.0/24
10.10.10.0/24 via 192.188.64.5 dev eth0
```

If it does not exist, add a new route with

```bash
ip route add 10.10.10.0/24 via 192.188.64.5
```

>Note that this new route is not permanent. Rebooting the host will delete the
>route.

## Layer 4 - Transport Layer {#transport-layer}
Applications listen on sockets, which consist of an IP address and a port.

1. Check that the application is listening on the local port

```bash
$ ss -nltup4
```

2. For remote ports, use `telnet` to troubleshoot **TCP** port connections

```bash
$ telnet host.example.com [port]
```

If there is no connection:
- the application is not listening on the port
- A firewall is filtering traffic

3. To troubleshoot **UDP** (and also TCP) ports, we can use `nc`

```bash
$ nc [ip] -p [port]
```

4. If a more powerful alternative is required, use `nmap` to perform port
   scanning or determine if ports are closed or filtered.

## DNS {#dns}
DNS is difficult to troubleshoot as it depends on the Linux distro, host system
configuration, installed packages and other reasons. This attempts to list a few
general solutions to DNS issues that have worked for me

1. If the resolved IP from `nslookup` or `dig` is wrong or different to that of `ping`, it might be a `/etc/hosts` entry problem.

2. If the response returns `Could not resolve hostname...`, check that the
   hostname exists in the authoritative nameserver

```bash
$ dig [@nameserver] [hostname]
```

If a `NOERROR` status is returned, it indicates a successful query and the
hostname does not exist. Add the hostname to the server.

If the nameserver cannot be reached, `connection timed out...`, check that the
host can communicate with the nameserver. Ensure your device is not blocking
outgoing DNS traffic.

3. If the response returns `Temporary failure in name resolution`, it indicates
   a badly configured `/etc/resolv.conf` file.

4. If the response returns `Name or service not found...`, it indicates none of the
configured nameservers are reachable.

5. If the response returns `Non-recoverable failure in name resolution`, it
   indicates the nameserver is reachable but has been configured to not accept
   DNS queries from you or your zone.

## References {#references}
- [Beginner's Guide to Network Troubleshooting](https://www.redhat.com/sysadmin/beginners-guide-network-troubleshooting-linux)
- [Basic Network Troubleshooting](https://www.netmeister.org/blog/basic-network-troubleshooting.html)
