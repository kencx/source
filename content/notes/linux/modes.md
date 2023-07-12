---
title: "Modes"
date: 2022-12-29T19:27:19+08:00
lastmod: 2022-12-29T19:27:19+08:00
draft: false
toc: true
tags:
- linux
- permissions
---

## Permissions

Every file has a set of nine permission bits that control the read, write and
execution of the file. These bits are known as the file's mode.

```
$ ls -l /usr/bin/gzip
-rwxrwxrwx 4 root root 37432 Nov 11 2021 /usr/bin/gzip
```

The nine bits are divided into three sets which define access for the owner,
group and world (everyone else). Each set contains a:

- Read bit - file can be opened and read
- Write bit - file can be modified
- Execute bit - file can be executed or directory can be entered

>The read and execute bits together allow a directory's contents to be listed.
>The write and execute bits together allow files to be created, deleted and
>renamed within the directory.

Modes can be represented in two forms: octal and symbolic.

| Octal | Symbolic |
| ----- | -------- |
| 0 | - - - |
| 1 | - - x |
| 2 | - w - |
| 3 | - w x |
| 4 | r - - |
| 5 | r - x |
| 6 | r w - |
| 7 | r w x |


To get the mode of a file:

```bash
$ stat -c "%a %n" foo
```

### chmod
`chmod` changes the permissions of a file. Only the owner and superuser can change a file's permissions.

```bash
$ chmod 711 file         # gives rwx to owner, x to group, world
$ chmod u,g+x file       # gives x to owner, group
$ chmod ug=rw,o=r file   # gives r/w to owner, group; r to world
```

### chown, chgrp
`chown` changes a file's ownership and `chgrp` changes its group's ownership.

```bash
$ chown -R 1000:1000 directory/
```

`chown` does **not** set the default ownership of newly created files in a
directory, nor does it let files inherit its parent directory's ownerships.
Instead, files always belong to the user running the process (`touch`, `mkdir`
etc.) that created the file.

Because the default mode of directories is `0755` (on most systems), only the
owner of the directory can create new files within it, resulting in all files
belonging to the same user as the parent directory. If the directory has mode
`0777`, anyone can create files within it and the file will belong to that of
the process' user.

### umask

`umask` sets the default permissions given to files created by the user. It is
specified as a three-digit octal value that represents permissions to
**remove**. When a file is created, its permissions are set to whatever the
program requests minus whatever `umask` forbids.

For example, when given a `umask` of 0002,

```
Original  --- rw- rw- rw-
Mask      000 000 000 010
Result    --- rw- rw- r--
```

When given a `umask` of 0022

```
Original  --- rw- rw- rw-
Mask      000 000 010 010
Result    --- rw- r-- r--
```

Wherever a `1` appears in binary, the attribute is **unset**.

```bash
$ umask 0027
# 000 010 111
# rw- r-- ---
```

The default `umask` value is `022`.

## Special Permissions
We see that most permissions have a leading `0` of the 4 digits which have been largely unused so far. These are less used permission settings.

### setuid bit
The `setuid` bit has octal `4000`. When applied to an executable file, it sets the effective user ID from that of the user that executed the program to that of the program's owner.

When a regular user runs a program that is `setuid root`, the programs runs with effective privileges of root. This raises security concerns and hence, `setuid` programs should be minimized.

```bash
$ chmod 4755 program
$ chmod u+s program
# -rwsr-xr-x
```

`setuid` on directories is [ignored](https://superuser.com/questions/471844/why-is-setuid-ignored-on-directories) on most Linux systems.

### setgid bit
The `setgid` bit has octal `2000`. This set the effective group ID to that of the file owner.

Similar to `setuid`, executables that have `setgid` will be run with the effective group
ID of the executable's group.

If `setgid` is set on a directory, newly created files in the directory will be
belong to the directory's group rather than file creator's group.

```bash
$ chmod 2755 dir
$ chmod g+s dir
# drwxrwsr-x
```

This is useful in shared directories when members of a common
group need to access all files in the directory, regardless of the file owner's
primary group.


### sticky bit

The `sticky` bit has octal `1000`. When applied to a directory, it prevents
users from deleting or renaming files unless they are the owner or the
superuser.

```bash
$ chmod 1777
$ chmod +t dir
# drwxrwxrwt
```

It is used to control access to a shared directory
like `/tmp`.
