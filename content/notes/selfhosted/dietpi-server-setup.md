---
title: "DietPi Server Setup"
date: 2021-12-20T17:06:11+08:00
draft: false
toc: true
tags:
- raspberry-pi
- dietpi
---

This guide is for a *headless* install and setup of the Raspberry Pi 4B over WiFi, with DietPi OS.

## Prerequisites
- Raspberry Pi board (preferably 3 and above)
- Raspberry Pi power supply[^1]
- SD card of at least 16GB
- SD card reader for your PC
- A basic understanding of computer networking - [a good beginner's guide](https://www.homenethowto.com/)

If you are not using wired Ethernet, ensure your board supports WiFi.

## Initial Setup

We will be using [DietPi](https://dietpi.com), a lightweight, optimized, Debian
based OS for SBCs.

Flash the OS image to the SD card with `dd`, [Balena
Etcher](https://www.balena.io/etcher/) or [Raspberry Pi
Imager](https://www.raspberrypi.com/software/).

### Enabling SSH

Because this is a headless install, we want to enable SSH before booting the Pi
to ensure we can access it.

On your PC, access the `/boot` folder of the flashed SD card. Create a new file
`ssh` (without `.txt` extension on Windows).

Next, if you are using DietPi, you want to update the following lines in
`dietpi.txt` and `dietpi-wifi.txt`:

```bash
# dietpi.txt
AUTO_SETUP_ACCEPT_LICENSE=1

AUTO_SETUP_TIMEZONE=Europe/London

AUTO_SETUP_NET_WIFI_ENABLED=1
AUTO_SETUP_NET_WIFI_COUNTRY_CODE={WIFI COUNTRY CODE}

AUTO_SETUP_NET_USESTATIC=1
AUTO_SETUP_NET_STATIC_IP={CUSTOM-IP}
AUTO_SETUP_NET_STATIC_MASK=255.255.255.0
AUTO_SETUP_NET_STATIC_GATEWAY={GATEWAY-IP}
AUTO_SETUP_NET_STATIC_DNS={DNS-SERVER-IP}

AUTO_SETUP_HEADLESS=1
AUTO_SETUP_AUTOMATED=1
CONFIG_BOOT_WAIT_FOR_NETWORK=2
```

```bash
# dietpi-wifi.txt
aWIFI_SSID[0]={NETWORK SSID}
aWIFI_KEY[0]={NETWORK PASSWORD}
```

- The system timezone follows a `Continent/Country` convention. Refer to the [TZ
manpage](https://www.mankier.com/3/tzset) for more details. This can also be set
later with `tzselect`.
- The WiFi country code must follow the 2 letter code convention from
[ISO_3166-1](https://en.wikipedia.org/wiki/ISO_3166-1).
- To understand what static IP and gateway to choose, run `ipconfig` or `ip -br a`
to get your PC's IP address and router gateway.
- The DNS server is typically the common Google DNS `8.8.8.8`.

{{< alert type="info" >}}
For any other OS, to enable Wifi, create a `wpa_supplicant.conf` file in the same `/boot` folder with the following contents:
```bash
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country={WIFI COUNTRY CODE}

network={
	ssid="{NETWORK SSID}"
	psk="{NETWORK PASSWORD}"
}
```
{{< /alert >}}

## First Boot

Insert the SD card into the Pi and execute the boot procedure. It should take
some time to start up. You can check its status by pinging it on your PC.

```bash
$ ping 192.25.56.3
PING 192.25.56.3 (192.25.56.3) 56(84) bytes of data.
```

Once completed, you can SSH into it with the default credentials `root` or
`dietpi` and the provided static IP from before
```bash
$ ssh dietpi@192.25.56.3
```

{{< alert type="note" >}}
For other OSes, try:
```bash
$ ssh pi@raspberry.local

# or
$ ssh pi@[ip-address]
```
{{< /alert >}}

## Post Boot Setup

- [Boot Raspberry Pi from an SSD](/notes/selfhosted/boot-pi-ssd)
- [Security Hardening](/notes/selfhosted/server-security-hardening).

## References

- [Headless Install of
DietPi](https://www.youtube.com/watch?v=vlMpn9u0Y4o&list=PLUKd6GYp0QDk-lvY234nRkpk6dIgYb9EM&index=11)

[^1]: Take note that RPi 3 and RPi 4 have different power supply adapters.
