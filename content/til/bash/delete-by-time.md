---
title: "Delete Files by Time"
date: 2023-07-07
lastmod: 2023-07-07
draft: false
toc: false
tags:
- bash
- find
- snippets
---

### GNU find

GNU `find` has a `--newerXY` flag that can filter files by different timestamps.
`X` and `Y` represent placeholders for different letters:

- `a` - Access time
- `B` - Birth time. Not supported on some systems.
- `c` - Inode status change time
- `m` - Modification time
- `t` - Reference is interpreted directly as time. `X` cannot be `t`.

```bash
# example expr
$ find . type -f -newerXY '01/01/2001 00:00:00'

# delete all files created or had permission changed before 01/01/2011 4pm
$ find . -type f ! -newerct '01/01/2011 16:00:00' -delete

# list files modified between 17:30 and 22:00 on Nov 6 2017
$ find . -type f -newermt '06/11/2017 17:30' ! -newermt '06/11/2017 22:00' -ls
```

### GNU date
Reference datetimes can be easily entered with GNU `date`:

```bash
# get date of 5 days ago
$ date --date='-5 days' '%Y-%m-%d'
```

Combining the two:

```bash
# delete all files created or had permission changed more than 5 days ago
$ find . -type f ! -newerct "$(date --date='-5 days' '%Y-%m-%d')" -delete
```

## References

- [mankier - find](https://www.mankier.com/1/find#-newerXY)
- [mankier - date](https://www.mankier.com/1/date#--date)
- [How to remove files created before a specific date and
  time](https://askubuntu.com/questions/1029799/how-to-remove-only-files-created-before-a-specific-date-and-time)
