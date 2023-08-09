---
title: "Automated Testing of Restic Backups"
date: 2023-08-09
lastmod: 2023-08-09
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
would be disastrous if you tried to restore a backup snapshot to find that your
files have been unknowningly corrupted or loss during the backup process.

Which is why my paranoid self also runs automated restore testing as part of the
daily backup process.

After restic back ups any new data and prunes old snapshots, we run some
restoration tests:

- Check a subset of all data with [restic
  check](https://restic.readthedocs.io/en/stable/045_working_with_repos.html#checking-integrity-and-consistency)
  (1% in my case)
- Restore a series of test files and compare them with the original

While complete checks and restores would be more representative of the integrity
of the backups, they are also very unfeasible for obvious reasons[^1].

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
restoring a test file after the backup process.

Before every backup, a `generate-restore-test-files` script is executed to
create a test file with random contents in a specified test directory. The test
directory stores the last 5 generated test files and is included in the backup.

```bash
# generate-restore-test-files.sh
dd if=/dev/random of="$RESTORE_DIR/test-$(date +%Y-%m-%d)" count=10 >/dev/null 2>&1

# delete any files older than 5 days
cd $TEST_DIR && \
    find . -type f ! -newerct "$(date --date='-5 days' '+%Y/%m/%d %H:%M:%S')" -delete
```

After every backup, all files in the test directory are restored from the latest
backup snapshot to a separate temporary directory. These restored files are `diff`-ed
with the originals found in the test directory. The backup will fail if any of
the files are different.

```bash
# backup.sh

...

RESTORED_FILES="$(cd "$RESTORE_DIR" && find . -type f -printf '%f\n')"

for file in $RESTORED_FILES; do
    diff "$RESTORE_DIR/$file" "${TMP_DIR}${RESTORE_DIR}/$file"
done
```

The backup process is run with systemd timers. An extract of the
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

[^1]: High bandwidth costs for checks on remote backup repositories, the need
    for disk space to perform the restores to, very time-consuming depending on
    your network speeds etc.
