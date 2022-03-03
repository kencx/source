---
title: "Reading Logs"
date: 2022-03-03T17:55:26+08:00
lastmod: 2022-03-03T17:55:26+08:00
draft: false
toc: false
---

#### Get entries between two specific datetimes

```bash
$ sed -n '/2021-20-22 09:00/,/2021-20-23 09:00/p' server.log | less
```

Refer to
[this](https://stackoverflow.com/questions/7706095/filter-log-file-entries-based-on-date-range)
for method with awk.

#### Get entries between two specific line numbers (N to M)

With `head` and `tail`,

```bash
# cat [file] | tail -n +N | head -n (M-N+1)

# Get lines 100-110 in server.log
$ cat server.log | tail -n +100 | head -n 10
```

Or with `sed`,

```bash
# sed -n 'N,Mp' server.log

$ sed -n '100,110p' server.log
```

#### Get lines that match a pattern and its surrounding lines

```bash
$ grep -A 10 "pattern" server.log		# 10 lines after
$ grep -B 10 "pattern" server.log		# 10 lines before
$ grep -C 10 "pattern" server.log		# 10 lines around
```

#### View compressed log files (log.gz)

Pipe the output to the above commands to filter for datetime or line numbers.

```bash
$ zcat server.log.gz | [condition] | less
```
