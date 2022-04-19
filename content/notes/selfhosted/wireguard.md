---
title: "Wireguard"
date: 2022-02-20T01:51:41+08:00
lastmod: 2022-02-20T01:51:41+08:00
draft: true
toc: false
---

This page contains my notes for setting up a Wireguard VPN to access my home
server remotely. It requires **NO** port forwarding.

[add diagram here]

The following prerequisites are needed:
1. A VPS with the necessary security hardening.
2. At least 2 clients - 1 on the home server and 1 on an external device
   (phone, laptop etc.)
3. (Optional but recommended) A local DNS server and a valid domain

## Installation
Install Wireguard on the VPS server. We will be doing a bare-metal install of Wireguard due to several reasons:
1. Wireguard with Docker is a pain in the ass (believe me, I tried) for very
   minimal benefit.
2. Wireguard plays well with the Linux kernel anyway.

I use this [script](https://github.com/Nyr/wireguard-install) for a quick
install. Run the script more than once to add new clients. This
should generate a `/etc/wireguard/wg0.conf` for the Wireguard server on the VPS
and a corresponding `/root/{client-name}.conf` for each client added.

Next, install wireguard on both clients. On Android, there are dedicated
Wireguard apps on the
[Playstore](https://play.google.com/store/apps/details?id=com.wireguard.android&hl=en_SG&gl=US)
and [Fdroid](https://f-droid.org/en/packages/com.wireguard.android/).

## Configuration
Copy-paste the contents of the generated `{client-name}.conf` files to each client's `/etc/wireguard/wg0.conf`.

On all Wireguard instances, start Wireguard with `wg-quick up wg0`. If everything is configured well, there should be no errors when you run `sudo wg show`.

Finally, for a sanity check, ensure all instances can ping one another with the provided Wireguard IP.
```bash
$ ping 10.7.0.[1,2,3]
```

The VPS and external client should now be able to access the home server and its
running applications. For example, if we are running an NGINX server on port 80,
it should be accessible with `10.7.0.2:80` where `10.7.0.2` is the home server's
IP.

However, IP addresses are cumbersome. Ideally, we want to access our
applications using subdomains. This requires (non-trivial) additional set up.

## DNS Resolution within the Wireguard Subnet

This covers how to enable DNS resolution without a running Wireguard subnet. A
good understanding of computer networking is necessary. Knowledge of `nslookup`,
`dig` and `iptables` is also useful.

There should already be local DNS server running and a domain. We assume that
the DNS server is running on the same machine as the home server, or at least on
the same local network.

Now, to use the local DNS servers on the external wireguard instances, we need
to configure their DNS resolution. There are multiple steps to take note of.

### Local Home Server

Firstly, on the *local* home server, ensure that `DNS=` in `wg0.conf` is set to
the DNS server's IP. If the DNS server is within a Docker container, ensure that
the container has a static IP.

>If you are using Pihole, ensure that Pihole is listening on all interfaces,
>including wg0. This can be set under `Settings` > `DNS`

Double check that the correct DNS servers are being used. The local domains
should return your local DNS server's IP.

```bash
$ nslookup google.com		# global domain
$ nslookup local.xyz 		# local domain
```

### External Servers

On the external clients (phone, laptop), set the `DNS` in `wg0.conf` to the home
server's Wireguard subnet IP.

Also ensure that the correct DNS server is used for your local DNS namespaces as
well. This is done by editing the DNS nameservers using
[systemd-resolved](https://gist.github.com/brasey/fa2277a6d7242cdf4e4b7c720d42b567#solution)
or
[dnsmasq](https://askubuntu.com/questions/191226/dnsmasq-failed-to-create-listening-socket-for-port-53-address-already-in-use)

Running `nslookup` on your VPS should be successful and return the client's IP.

```bash
$ nslookup local.xyz
```

If all goes well, you should be able to perform DNS resolution of your local
domains on all WG instances. However, we're not done yet. Although the servers
know your local domain name exists, the packets are not being accepted just yet.

## Port Forwarding in Wireguard

We want to be able to connect to all devices in our local subnet through
Wireguard. By default, incoming requests are dropped due to the local firewall
and NAT.

```
phone --> VPS --> NAT/Firewall --> Home Pi Server
```

Instead, we require port forwarding within the local Pi server. We follow this
[guide](https://gist.github.com/insdavm/b1034635ab23b8839bf957aa406b5e39) for a
client-to-client setup. In `wg0.conf`, we add the following instructions:

```
PreUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```
This accepts requests from `wg0` and disguises them as coming from `eth0`.

Next, we must add the LAN subnet into the **server's** 	`wg0.conf`:
```bash
# VPS WG server's wg0.conf
[Interface]
...

[Peer]
PublicKey=<publickey>
AllowedIPs=10.10.0.2, 192.100.80.0/24
...
```
where `192.100.80.0/24` is the LAN subnet. Without this, Wireguard will drop all requests travelling from the external client to the local subnet client. This acts like a routing table.

We should be able to access our local subnet through our external WG client with DNS resolution now.

## References for iptables
- [Wireguard Site to Site](https://gist.github.com/insdavm/b1034635ab23b8839bf957aa406b5e39)
- [VPS to Home Server Reverse Proxy](https://www.selfhosted.pro/hl/wireguard_vps/) port forwarding on port 80 and 443./
- [Wireguard Routing](https://kaspars.net/blog/wireguard-routing)
- [Point to Site port forwarding](https://www.procustodibus.com/blog/2021/04/wireguard-point-to-site-port-forwarding/)
