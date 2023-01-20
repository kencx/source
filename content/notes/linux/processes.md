---
title: "Processes"
date: 2023-01-21T00:00:00+08:00
lastmod: 2023-01-21T00:00:00+08:00
draft: false
toc: true
tags:
- linux
- processes
---

The Linux kernel manages the execution of programs with processes. Each process
is assigned an integer process ID (PID) and their data is stored in a
subdirectory in the virtual filesystem `/proc/PID/`.

A process has a parent process, and is associated with a process group which are
in turn, associated with a session.

## Process Components

A process consists of the following components:
- Virtual address space: stored randomly in physical memory and tracked by
  kernel's page tables
- Current [process state]({{< ref "/notes/linux/process-states" >}})
- Execution [priority]({{< ref "/notes/linux/process-scheduling" >}}) of process
- Process' resource usage
- [File Descriptors]({{< ref "/notes/linux/file-descriptors.md" >}}) and network
  ports used by process
- Process' signal mask (a record of which [signals]({{< ref "/notes/linux/signals.md" >}}) are blocked)
- Process owner - UID and effective UID (set with [setuid]({{< ref
  "/notes/linux/modes#setuid-bit" >}}))
- At least one thread of execution that operates within the
  process' address space

Processes are also separated from hardware - they cannot interact directly with
the screen, disk or network. Instead, it calls the operating system to perform
system calls.

## Process Initialization

When the system boots, the kernel launches the init [daemon]({{< ref
"/notes/linux/daemons" >}}) process
of PID 1. The init process then starts all other system services as child
processes. This is performed in the kernel space.

>There are multiple `init` systems, including systemd, runit and upstart.

## References
- [The Linux Command Line](https://linuxcommand.org/tlcl.php)
- [Unix and Linux System Administration Handbook](https://www.amazon.com/UNIX-Linux-System-Administration-Handbook/dp/0134277554)
- [GNU/Linux shell related internals - Process groups, jobs and
  sessions](https://biriukov.dev/docs/fd-pipe-session-terminal/3-process-groups-jobs-and-sessions/#process-groups-jobs-and-sessions)
