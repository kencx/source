---
title: "Automated Testing of Restic Backups"
date: 2023-08-09
lastmod: 2024-01-22
draft: false
toc: true
tags:
  - backups
  - restic
---

My NAS server runs daily backups to an onsite USB hard drive and an offsite
[Backblaze](https://www.backblaze.com/) B2 bucket with
[restic](https://restic.net/) and [autorestic](https://autorestic.vercel.app/).
This backup plan aims to fulfil the [3,2,1
rule](https://www.backblaze.com/blog/the-3-2-1-backup-strategy/) by being
automatic, redundant and offsite.

However, a backup is only as good as its ability to be restored successfully. It
can be potentially disastrous if we tried to restore a backup after data loss
and realise that the data has been unknowningly corrupted or loss during the
backup process.

A good measure involves performing automated restoration tests as part of the
backup process. After restic backs up any new data and prunes old snapshots, it
also performs the following:

- Check a subset of all data with [restic
  check](https://restic.readthedocs.io/en/stable/045_working_with_repos.html#checking-integrity-and-consistency)
  (1% in my case)
- Restore a series of test files and compare them with the original

While complete checks and restores would be more representative of the integrity
of the backups, they are also very unfeasible[^1].

## Restic check

The `check` subcommand runs two types of checks:

- Structural consistency and integrity of the backups, e.g. snapshots, trees and
  pack files (default)
- Integrity of the actual data (enabled with `--read-data[-subset]`)

By including the `--read-data-subset` flag, restic will download a randomly
chosen subset of repository pack files, and verify their integrity:

```bash
$ restic check --read-data-subset=1%

# or with autorestic
$ autorestic exec -av -- check --read-data-subset=1%
```

## Restoring Test Files

In addition to restic's native integrity checks, we also run explicit checks by
restoring a test file after the backup process. This involves creating a test
file with random content in a specified test directory before the backup:

```bash
#!/bin/bash

# generate-restore-test-files.sh
TEST_DIR="~/restore-test"
dd if=/dev/random of="$TEST_DIR/test-$(date +%Y-%m-%d)" count=10 >/dev/null 2>&1

# delete any files older than 5 days
cd $TEST_DIR && \
    find . -type f ! -newerct "$(date --date='-5 days' '+%Y/%m/%d %H:%M:%S')" -delete
```

Any test files older than the last 5 generated files are discarded. During the
backup, we have restic restore the files in this directory to a temporary
directory.

```bash
RESTORE_DIR="~/restore-test"
TMP_DIR="$(mktemp -d)"
autorestic restore -v --include "$RESTORE_DIR" --to "$TMP_DIR"
```
These restored files are `diff`-ed with the originals found in the test
directory. The backup will fail if any of the files are different.

```bash
RESTORED_FILES="$(cd "$RESTORE_DIR" && find . -type f -printf '%f\n')"

for file in $RESTORED_FILES; do
    diff "$RESTORE_DIR/$file" "${TMP_DIR}${RESTORE_DIR}/$file"
done
```

If there are any differences, `diff` returns an exit code of `1`, causing the
script to fail. Otherwise, the backup passes and the script cleans up any
temporary directories.

## Systemd Timer

The backup process is scheduled with systemd timers. An extract of the
`backup.service` file is as follows:

```
# /etc/systemd/system/backup.service
[Service]
Type=oneshot
ExecStartPre=/usr/bin/generate-restore-test-files.sh
ExecStart=/usr/bin/backup.sh
```

{{< alert type="note" >}}
The complete scripts and files can be found
[here](https://github.com/kencx/homelab/tree/master/ansible/roles/autorestic/templates).
They are written as Jinja2 templates as they are provisioned with an Ansible
role.
{{< /alert >}}

## References
- [Preparing for the worst](https://tomm.org/2022/preparing-for-the-worst)

[^1]: Due to high bandwidth costs for checks on remote backup repositories, the
    need for disk space to perform the restores to, all of which can be very
    expensive and time-consuming.
