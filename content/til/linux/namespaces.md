---
title: Namespaces
date: 2023-01-21T02:37:16+08:00
lastmod: 2023-01-21T02:37:16+08:00
draft: false
toc: true
tags:
- linux
- namespaces
---

A namespace wraps a global system resource in an abstraction that makes it
appear to the processes within the namespace that they have their *own isolated
instance* of that resource. Changes to the global resource are visible to
processes within the same namespace, but invisible to other processes.
Effectively, this gives independent processes a unique view of the system,
isolating them from each other.

{{< alert type="note" >}}
Namespaces provide processes with an isolated environment without them
being aware of these limitations.
{{< /alert >}}

Each process belongs to exactly one instance of each namespace type. A process'
namespaces can be seen in `/proc/PID/ns`

```bash
$ ls /proc/$$/ns -la
total 0
lrwxrwxrwx 1 root root 0 Feb  9 20:47 cgroup -> 'cgroup:[4026531835]'
lrwxrwxrwx 1 root root 0 Feb  9 20:47 ipc -> 'ipc:[4026531839]'
lrwxrwxrwx 1 root root 0 Feb  9 20:47 mnt -> 'mnt:[4026531840]'
lrwxrwxrwx 1 root root 0 Feb  9 20:47 net -> 'net:[4026531992]'
lrwxrwxrwx 1 root root 0 Feb  9 20:47 pid -> 'pid:[4026531836]'
lrwxrwxrwx 1 root root 0 Feb  9 20:47 pid_for_children -> 'pid:[4026531836]'
lrwxrwxrwx 1 root root 0 Feb  9 20:47 time -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 Feb  9 20:47 time_for_children -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 Feb  9 20:47 user -> 'user:[4026531837]'
lrwxrwxrwx 1 root root 0 Feb  9 20:47 uts -> 'uts:[4026531838]'
```

Namespaces exist in the Linux kernel and are a prerequisite to run any process on the
system.

>Application containers like [Docker]({{< ref "/til/docker" >}}) utilize
>namespaces (along with cgroups, capabilities and chroot) to create
>lightweight, isolated environments.

## Types of Namespaces

There are 7 types of namespaces:
- `cgroup` - isolation of virtual cgroup filesystem of host
- `IPC` - isolation for interprocess communication utilities
- `Network` - isolation of host network stack
- `Mount` - isolation of host filesystem mount points
- `PID` - isolation of system process tree
- `User` - isolation of system user IDs
- `UTS` - isolation of hostname and domain name

## References
- [Digging into Linux
  Namespaces](https://blog.quarkslab.com/digging-into-linux-namespaces-part-1.html)
- [Digging into Linux Namespaces Part
  2](https://blog.quarkslab.com/digging-into-linux-namespaces-part-2.html)
- [Namespaces in operation](https://lwn.net/Articles/531114/)
- [Separation Anxiety: A tutorial for isolating your system with Linux
  namespaces](https://www.toptal.com/linux/separation-anxiety-isolating-your-system-with-linux-namespaces)
- [The Curious Case of PID
  namespaces](https://hackernoon.com/the-curious-case-of-pid-namespaces-1ce86b6bc900)
