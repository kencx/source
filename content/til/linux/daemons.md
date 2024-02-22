---
title: "Daemons"
date: 2023-01-21T00:00:00+08:00
lastmod: 2023-01-21T00:00:00+08:00
draft: false
toc: false
tags:
- linux
- processes
---

{{< alert type="warning" >}}
This section is incomplete.
{{< /alert >}}

A daemon is a long living process. It is often started at launch and service
until OS shutdown. Daemons run in the background without a controlling terminal.
This guarantees that the process never receives terminal [signals]({{< ref
"/til/linux/signals" >}}) from the kernel (`SIGINT, SIGTSTP, SIGHUP`).

### Double Fork Technique

The traditional method of spawning daemons is with the double fork technique:

1. The first `fork()` is required:
	- to become a child of PID `1`
	- if a daemon starts manually from a  terminal, it puts itself into the background so it cannot be terminated easily
	- the child is guaranteed not to be a process group leader so a `setsid()` call starts a new session and breaks a possible connection to the existing controlling terminal
2. The second `fork()` is done to stop being the session leader. This protects a daemon from opening a new controlling terminal as only a session leader can do that.

### systemd

For systems with systemd, they rely on its features instead:
- `systemd` starts a new process session for daemon
- it can swap the standard file descriptors with regular files or sockets
  instead of manually closing them.

The following settings control where a daemon can write `stdout` and `stderr` to

```systemd
StandardOutput=
StandardError=
```

## References
- [The Linux Command Line](https://linuxcommand.org/tlcl.php)
- [GNU/Linux shell related internals - Process groups, jobs and sessions](https://biriukov.dev/docs/fd-pipe-session-terminal/3-process-groups-jobs-and-sessions/#process-groups-jobs-and-sessions)
