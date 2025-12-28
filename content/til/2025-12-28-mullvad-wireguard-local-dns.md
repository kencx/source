+++
title = "How to use custom DNS servers with Mullvad"
date = "2025-12-28"
updated = "2025-12-28"

[taxonomies]
tags = ["wireguard", "mullvad", "dns", "networking"]
+++

When using [Mullvad](https://mullvad.net) with Wireguard, it is known to hijack
DNS traffic and redirect it to their own DNS servers. While this is helpful to
prevent [DNS leaks](https://mullvad.net/en/help/dns-leaks), it also prevents the use
of a custom DNS server.

Fortunately, Mullvad supports the creation of a Mullvad device with DNS
hijacking disabled.

1. Fetch a Mullvad access token with your account number:

```sh
MULLVAD_ACCOUNT_NUMBER="123456789"

MULLVAD_ACCESS_TOKEN=$(curl -s -X POST 'https://api.mullvad.net/auth/v1/token' \
	-H 'accept: application/json' \
	-H 'content-type: application/json' \
	-d '{ "account_number": "'${MULLVAD_ACCOUNT_NUMBER}'" }' \
	| jq -r .access_token)
```

2. Generate a new Wireguard key pair:

```bash
WG_PRIVATE_KEY="$(wg genkey)"
WG_PUBLIC_KEY="$(wg pubkey <<<"${WG_PRIVATE_KEY}")"
```


3. Create a new device on Mullvad with the new key and `hijack_dns: false`:

```bash
# post hijack_dns setting and get device name and ipaddr
MULLVAD_RESPONSE=$(curl -s -X POST 'https://api.mullvad.net/accounts/v1/devices' \
	-H "Authorization: Bearer ${MULLVAD_ACCESS_TOKEN}" \
	-H 'content-type: application/json' \
	-d '{"pubkey":"'${WG_PUBLIC_KEY}'","hijack_dns":false}')
```

4. Print the required information for setting up a Wireguard client with the new
   Mullvad device:

```sh
echo "Mullvad Device Name: $(echo ${MULLVAD_RESPONSE} | jq -r .name)"
echo "WG_PUBLIC_KEY=${WG_PUBLIC_KEY}"
echo "WG_PRIVATE_KEY=${WG_PRIVATE_KEY}"
echo "WG_IPV4_ADDRESSES=$(echo ${MULLVAD_RESPONSE} | jq -r .ipv4_address)"
echo "WG_IPV6_ADDRESSES=$(echo ${MULLVAD_RESPONSE} | jq -r .ipv6_address)"
```


As a Bash script:

```bash
#!/usr/bin/env bash

account_number="123456789"

WG_PRIVATE_KEY="$(wg genkey)"
WG_PUBLIC_KEY="$(wg pubkey <<<"${WG_PRIVATE_KEY}")"

MULLVAD_ACCESS_TOKEN=$(curl -s -X POST 'https://api.mullvad.net/auth/v1/token' \
	-H 'accept: application/json' \
	-H 'content-type: application/json' \
	-d '{ "account_number": "'${MULLVAD_ACCOUNT_NUMBER}'" }' \
	| jq -r .access_token)

MULLVAD_RESPONSE=$(curl -s -X POST 'https://api.mullvad.net/accounts/v1/devices' \
	-H "Authorization: Bearer ${MULLVAD_ACCESS_TOKEN}" \
	-H 'content-type: application/json' \
	-d '{"pubkey":"'${WG_PUBLIC_KEY}'","hijack_dns":false}')

echo "Mullvad Device Name: $(echo ${MULLVAD_RESPONSE} | jq -r .name)"
echo "WG_PUBLIC_KEY=${WG_PUBLIC_KEY}"
echo "WG_PRIVATE_KEY=${WG_PRIVATE_KEY}"
echo "WG_IPV4_ADDRESSES=$(echo ${MULLVAD_RESPONSE} | jq -r .ipv4_address)"
echo "WG_IPV6_ADDRESSES=$(echo ${MULLVAD_RESPONSE} | jq -r .ipv6_address)"
```


## Bonus - Setup Wireguard with systemd-networkd

`systemd-networkd` supports the setup of a Wireguard client natively.

Create the following files and populate the respective public/private keys and
IP addresses from the variables above:

```

/etc/systemd/network/99-wg0.netdev
[NetDev]
Name=wg0
Kind=wireguard
Description=WireGuard VPN

[WireGuard]
FirewallMark=0x8888
ListenPort=51820
RouteTable=off
PrivateKey=<private key>

[WireGuardPeer]
PublicKey=<peer public key>
AllowedIPs=0.0.0.0/0
AllowedIPs=::0/0
Endpoint=<endpoint>:<port>
```


```
/etc/systemd/network/99-wg0.network
[Match]
Name=wg0

[Network]
Address=<ipv4 addr>
Address=<ipv6 addr>

[RoutingPolicyRule]
Family=both
SuppressPrefixLength=0
Priority=999
Table=main

[RoutingPolicyRule]
Family=both
FirewallMark=0x8888
InvertRule=true
Table=1000
Priority=1000

[Route]
Gateway=0.0.0.0
Table=1000

[Route]
Gateway=::
Table=1000
```


## References
- [Arch Wiki - Mullvad](https://wiki.archlinux.org/title/Mullvad#With_systemd-networkd)
- [Mullvad - Use custom DNS](https://github.com/mullvad/mullvadvpn-app/issues/473)
