---
title: "File Descriptors"
date: 2023-01-21T00:00:00+08:00
lastmod: 2023-01-30T00:00:00+08:00
draft: false
toc: true
tags:
- linux
- processes
---

A file descriptor (fd) is a positive integer used to identify an open file or
input/output resource (pipe, network socket etc.) in the kernel. It is bound to
a process ID, where each process has its own **file descriptor table** that
lists its opened files. All file descriptors of a process are stored in
[procfs]() at `/proc/PID/fd`.

```bash
$ ls -la /proc/123/fd
dr-x------ 2 root root  0 Apr  2 03:44 .
dr-xr-xr-x 9 root root  0 Apr  2 03:42 ..
lrwx------ 1 root root 64 Apr  2 03:44 0 -> /dev/pts/0
lrwx------ 1 root root 64 Apr  2 03:44 1 -> /dev/pts/0
lrwx------ 1 root root 64 Apr  2 03:44 2 -> /dev/pts/0
```

The most well known file descriptors are 0, 1 and 2, corresponding to `stdin,
stdout, stderr` respectively.

File descriptors are used to decouple a file path from a file object inside the
kernel. This allows developers to refer to the same file multiple times for
different purposes when working with Unix syscalls such as `read()` and
`write()`.


{{< alert type="example" >}}
A program wants to read from and write to one file in two separate
places. In this case, it opens the file twice and two new file
descriptors are created. These will refer to two different entries in the
system-wide [open file description table](#open-file-descriptor-table).
{{< /alert >}}


### File descriptor vs file description

There is a distinction between *file description* and *file descriptor*. File
description is the structure in the kernel that maintains the state of an open
file. File descriptors are used to refer to this state. See the
[POSIX](https://pubs.opengroup.org/onlinepubs/009695399/functions/open.html)
`open()`:

>The `open()` function shall establish the connection between a file and a file
>_descriptor_. It shall create an open file _description_ that refers to a file
>and a file _descriptor_ that refers to that open file _description_. The file
>descriptor is used by other I/O functions to refer to that file.

## Open File Descriptor Table

The open file description table is a system-wide kernel abstraction that stores
the file open status flags and file positions. To create a new entry in the open
file description table, we need to open a file with one of the following
syscalls:
- `open()`
- `openat()`
- `create()`
- `open2()`

These functions:
1. Add a corresponding entry in the file descriptor table **of the calling
   process**
2. Build a reference between the open file description table entry and the file
   descriptor table
3. Return the lowest positive number not currently opened by the calling process

This means that a file descriptor number can be reused during the process lifespan if it opens and closes files in an arbitrary order.

{{< figure src="/img/file-descriptors.png" caption="Source: [GNU/Linux shell related internals - File descriptor and open file description](https://biriukov.dev/docs/fd-pipe-session-terminal/1-file-descriptor-and-open-file-description/)" class="center" >}}


- The first three file descriptors in the file descriptor table are special
  `stdin, stdout, stderr`. All three point to a pseudoterminal `/dev/pts/0`.
  These files don't have positions due to their character device type.
- `stdout` of process 2 points to the file `/tmp/out.log`. This is an example of
  [shell redirection](#shell-redirection).
- Some file descriptors can have per-process flags.
- A process can have more than one file descriptor that points to the same entry
  in open file descriptions. fd `0, 2` of process 2 refer to the same pseudo
  terminal entry.
- File descriptors from different processes can point to the same entry in the
  system-wide open file description table. This is usually achieved by a `fork`
  call and [inheriting](#sharing-file-descriptors-between-parent-and-child) file
  descriptors from the parent to its child. For instance, fd `9` of process 1
  and fd `3` of process 2 point to the same file.
- Multiple open file descriptor entries can also be linked with the same file on
  disk. The kernel allows us to open a file with different flags and at various
  offset positions.

## Sharing File Descriptors between Parent and Child

{{< alert type="warning" >}}
This section can be improved.
{{< /alert >}}

After a `fork()` or `clone()` call, a child and parent have an equal set of file
descriptors, which refer to the **same** entries in the system-wide open file
description table. They share identical file positions, status flags and process
fd flags.

The primary purpose of such sharing is to protect files from being overwritten
by children and its parent process. If all relatives write to a file
simultaneously, the Linux kernel will not lose any hold because it holds the
lock and updates the offset after each write.

## Shell Redirection
Redirection uses the standard file descriptors `0, 1, 2` for `stdin, stdout, stderr`:

```bash
# stdin
$ cat < /tmp/foo

# stdout
$ echo "123" > /tmp/foo

# stderr
$  cat "123" 2> /tmp/foo

# stdout and stderr
$ cat "123" > /tmp/foo 2>&1
```

During redirection, the target file is opened with the `open()` syscall and
`dup2()` is used to overwrite the standard file descriptors with the fd of the
file.

>When redirecting both stdout and stderr with `2>&1`, `dup2()` is ran twice for
>`stdout` and `stderr`.

## References
- [What are file descriptors?](https://stackoverflow.com/questions/5256599/what-are-file-descriptors-explained-in-simple-terms)
- [Computer Science from the Bottom Up - File Descriptors](https://bottomupcs.com/ch01s03.html)
- [GNU/Linux shell related internals - File descriptor and open file description](https://biriukov.dev/docs/fd-pipe-session-terminal/1-file-descriptor-and-open-file-description/)
