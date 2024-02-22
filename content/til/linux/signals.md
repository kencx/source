---
title: "Signals"
date: 2023-01-21T00:01:00+08:00
lastmod: 2023-01-21T00:01:00+08:00
draft: false
toc: true
tags:
- linux
- processes
- signals
---

Signals allow for interprocess communication (IPC) that creates and sends
asynchronous notifications to running processes about specific events.

A process can handle signals in three ways:
- React with custom action - A program can specify custom behaviour for handling
  a signal
- React with default action - Every signal has a associated default action
- Ignore the signal (`SIGKILL` cannot be ignored)

## kill

To send a signal to a process, we use the `kill` shell built-in with a PID or
jobspec (`%1`). By default, `kill` sents the `SIGTERM` signal.

```bash
$ kill -[signal number] [PID|process name]

$ nvim &
[1] 25863
$ kill -9 25863
[1] + Terminated nvim
```

To kill multiple instances of a process, use `killall ...`

```bash
$ nvim &
$ nvim &
$ killall nvim   # terminates both instances
```

`pkill` can also be used to send signals to processes. It is a shortcut between
`ps`, `grep` and `kill`.

## Common Signals

A full list of signals is available with `kill -l`.

| Signal  | Default | Description                                                                                                                                                                                    |
| ------- | --------| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SIGINT  | Terminate | Used to interrupt a running process. Analogous to `Ctrl + C`.                                                                                                                |
| SIGHUP  | Terminate | Signal sent to process when its controlling terminal is closed. [Daemons]({{< ref "/til/linux/daemons" >}}) will reload their configuration files and reopen logfiles instead of exiting. `nohup` can be used to ignore this signal.                                                                                                                                      |
| SIGTERM | Terminate | Signal sent to terminate a process. It can be caught, interpreted and ignored by the process, allowing it to perform graceful shutdown with cleanup and releasing resources. SIGINT and SIGTERM are nearly identical. |
| SIGKILL | Terminate | Sent to force terminate a process immediately. This signal cannot be caught or ignored.                                                                                            |
| SIGQUIT | Quit/Dump | Sent when a user wants to exit the current process. Analogous to `Ctrl + D` and often used in terminal shells or SSH sessions.                                                    |
| SIGSTOP | Stop | Instructs the process to stop without termination. The process will wait till it is resumed or killed.                                                                           |
| SIGCONT | Continue | Instructs a stopped process to continue (restart).

## References
- [POSIX Signals](https://dsa.cs.tsinghua.edu.cn/oj/static/unix_signal.html)
