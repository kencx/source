---
title: "Process States"
date: 2023-01-21T00:00:45+08:00
lastmod: 2023-01-21T00:00:45+08:00
draft: false
toc: false
tags:
- linux
- processes
---

A process can be in one of the following states throughout its lifecycle:

| State | Name                  | Description                                                                                                                           |
| ----- | --------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| R     | Running/Runnable      | A running process is actively running and allocated to a CPU. A runnable processes is queued up as the CPU might be over-provisioned. |
| D     | Uninterruptible sleep | The process is waiting for some resource to be available (eg. I/O). Interrupting the process can cause major issues.                  |
| S     | Interruptible sleep   | The process is waiting for data (eg. user input or network packet). The process can be easily terminated.                             |
| T     | Stopped               | The process is stopped by `SIGSTOP` signal. It is waiting to be resumed or killed.                                                    |
| Z     | Zombie                | This is a terminated child process that has not been cleaned up by its parent.                                                        |

- Interactive shells and daemons spend most of their lifecycle in interruptible
  sleep.
- Uninterruptible sleep can be caused when an NFS filesystem mounted with the
  `hard` option encounters errors.

## Process Lifecycle

{{< figure src="/img/process-lifecycle.png" caption="Source: [cs.uic.edu](https://www.cs.uic.edu/~jbell/CourseNotes/OperatingSystems/3_Processes.html)" class="center" width="550px" >}}


1. The process is born or forked (new)
2. The process transitions to a runnable state (ready)
3. The process is running in user or kernel space (running)
4. The process becomes blocked in an interruptible or uninterruptible sleep
   state (waiting)
5. The process exits (terminated)
6. (Not pictured) The process can also be stopped and resumed or killed.

## References
- [cs.uic.edu - Processes](https://www.cs.uic.edu/~jbell/CourseNotes/OperatingSystems/3_Processes.html)
- [Unix and Linux System Administration Handbook](https://www.amazon.com/UNIX-Linux-System-Administration-Handbook/dp/0134277554)
