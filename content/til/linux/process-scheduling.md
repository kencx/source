---
title: "Process Scheduling"
date: 2023-01-21T00:53:00+08:00
lastmod: 2023-01-21T00:53:00+08:00
draft: false
toc: false
tags:
- linux
- processes
---

## Niceness

The *niceness* of a process informs the kernel about how the process should be
treated relative to other processes contending for the CPU. A high niceness
means a low priority for the process, while a low (or negative) niceness means a
higher priority. In Linux, the range of niceness is between -20 and +19.

>In modern systems, it is unusual to set priorities by hand as they have more
>than adequate CPU power and the scheduler manages workloads more efficiently.

A newly created process inherits the niceness of its parent process. The process
owner may increase the niceness but cannot lower it, even to return the process
to default niceness. This restriction prevents low priority processes from
bearing high-priority children. However, the superuser can set nice values
arbitrarily.

The `nice` command is used to set a process' niceness at creation. The `renice`
is used to adjust the niceness of a running process.

```bash
# raise niceness by 5
$ nice -n 5 ~/bin/foo

# set niceness to -5
$ sudo renice -5 [PID]
# set niceness to 5
$ sudo renice 5 -u foo
```

## References
- [Unix and Linux System Administration Handbook](https://www.amazon.com/UNIX-Linux-System-Administration-Handbook/dp/0134277554)
