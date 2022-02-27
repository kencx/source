---
title: "Booting Raspberry Pi from SSD"
date: 2021-12-20T17:06:11+08:00
draft: false
toc: false
---

You will need an [NVME M.2
stick](https://www.amazon.com/Samsung-970-EVO-Plus-MZ-V7S1T0B/dp/B07MFZY2F2/ref=sr_1_3?crid=5UQNN0OJ6RNT&keywords=nvme+samsung&qid=1640853863&sprefix=nvme+samsung+%2Caps%2C468&sr=8-3),
a USB-C case and a USB-3.0 to USB-C cable for the best results.

Firstly, turn off your Pi, remove the SD card and insert it into your PC.
Identify the device name of your card with `sudo fdisk -l`. Run `dd` with the
following flags

```bash
$ dd if=/dev/sd-card of=~/Downloads/pi_copy.img
```
**DO NOT** mix up `if` (the input) and `of` (the output) or you might destroy the file system.

This produces an `.img` file that can be flashed into the SSD with the same
[software](#flash-os) as before. Or you could use `dd` to flash it
manually. Plug the SSD into your Pi and it should boot normally without the SD
card.

>If you are on Windows, the easiest way to do this is to use
>[Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/).

This next step is often missed: Check if the partition in the SSD has been
resized. When the `.img` file was flashed, it is possible that the 256GB SSD has
been resized to 16GB (your SD card's size). If so, resize the drive back to
256GB. If you are using DietPi, `dietpi-drive_manager` will be helpful.

## Benchmark

Here is a quick benchmark I performed between IO speeds before and after I
switched to an SSD. We can clearly see a 10-fold increase.

{{< figure src="/img/sdcard-benchmark.jpg" caption="SD Card" class="center" >}}
{{< figure src="/img/ssd-benchmark.jpg" caption="NVME M.2" class="center" >}}

# References

- [DietPi Forums - Upgrade from SD card to
SSD](https://dietpi.com/phpbb/viewtopic.php?t=8190)
