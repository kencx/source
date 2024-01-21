---
title: "Monitoring Backups With Prometheus"
date: 2023-08-10
lastmod: 2024-01-22
draft: false
toc: true
tags:
  - backups
  - restic
  - prometheus
---

I previously wrote about [running automated restore tests]({{< ref
"automated-testing-of-restic-backups.md" >}}) when performing daily restic
backups. If the backup script fails, it should send out an alert or
notification. Some possible methods of alerting include:

- systemd's `OnFailure` key to run a script on failure
- webhooks (eg. with [uptime-kuma](https://github.com/louislam/uptime-kuma) or
  Gotify)
- Prometheus and AlertManager

I decided to go with the last option because I've never written a Prometheus
exporter before and wanted to try it out. It would also provide some backup
metrics that might be useful.

## Prometheus Exporter

My Prometheus exporter is a Python
[script](https://github.com/kencx/homelab/blob/master/ansible/roles/autorestic/files/backup-exporter)
that generates text metrics which are then consumed by [Node exporter's
textfile-collector](https://github.com/prometheus/node_exporter#textfile-collector).
These metrics are exposed to Prometheus, where they are then consumed by Grafana
and AlertManager.

Because restic does not output any metrics or logs in a machine-readable format
(AKA `json`), the script reads and parses the log output of restic directly:

```bash
# autorestic.log
Files:           0 new,     0 changed, 11621 unmodified
Dirs:            0 new,     2 changed,  1338 unmodified
Added to the repository: 724 B (862 B stored)
processed 11621 files, 14.647 GiB in 0:02
```
```python
files = re.compile(r"Files:.*?(\d+) new.*?(\d+) changed.*?(\d+) unmodified")
dirs = re.compile(r"Dirs:.*?(\d+) new.*?(\d+) changed.*?(\d+) unmodified")
added = re.compile(r"Added to the repository: (\d+(\.\d*)?|\.\d+) ([G|T|M|K]?i?B)")
total = re.compile(r"processed (\d+) files, (\d+(\.\d*)?|\.\d+) ([G|T|M|K]?i?B) in ((\d+:)?\d+:\d+)")
```

It generates the raw metrics:

```
restic_repo_files{location="archives",backend="remote",state="new"} 0
restic_repo_files{location="archives",backend="remote",state="changed"} 0
restic_repo_files{location="archives",backend="remote",state="unmodified"} 11621
restic_repo_dirs{location="archives",backend="remote",state="new"} 0
restic_repo_dirs{location="archives",backend="remote",state="changed"} 0
restic_repo_dirs{location="archives",backend="remote",state="unmodified"} 1340
restic_repo_bytes_added{location="archives",backend="remote"} 0.0
restic_repo_bytes_total{location="archives",backend="remote"} 15727096496.128
restic_repo_total_files{location="archives",backend="remote"} 11621
restic_repo_duration_seconds{location="archives",backend="remote"} 355
```

These generated metrics are repeated for each separate autorestic location and
backend. With these repository specific metrics, there are also two general
metrics that indicate if the backup passed and when the backup was last ran:

```python
def add_general_metrics(success):
    num = 0 if success else 1
    m = """
restic_backup_success {num}
restic_backup_latest_datetime {timestamp}
    """.format(num=num, timestamp=datetime.datetime.now().timestamp())
    return m.strip()
```

```
restic_backup_success 0
restic_backup_latest_datetime 1691533984.343583
```

Should a backup fail without any logs/stats to parse, the script will only
generate the general metrics.

## Systemd

This custom script is run after a backup by extending `backup.service` to
include `ExecStartPost`

```
# /etc/systemd/system/backup.service
[Service]
Type=oneshot
ExecStartPre=/usr/bin/generate-restore-test-files.sh
ExecStart=/usr/bin/autorestic-backup.sh
ExecStartPost=/usr/bin/backup-exporter -l /var/log/autorestic.log -e restic.prom
```

## Grafana Dashboard

{{< figure src="/posts/images/backup-grafana-dashboard.png" caption="Grafana dashboard for backups" class="center" >}}

## AlertManager

Finally, we configure AlertManager to send a Telegram notification if:

- A backup fails
- A backup has not been successfully completed in the past 26 hours (i.e. timestamp
  metric is too old).

```yml
# prometheus/rules.yml
groups:
  - name: Backup
    rules:
      - alert: backup_failed
        expr: restic_backup_success == 0 or restic_backup_latest_datetime < time() - 60*60*26
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: 'Backup failed at {{ with query "restic_backup_latest_datetime" }}{{ . | first | value | humanizeTimestamp }}{{ end }}'
```

A 2 hour grace period is given to account for a scenario where a backup might
take longer than the previous day, resulting in a false-negative.

## References

- [Restic backups with systemd and prometheus
  exporter](https://blog.cubieserver.de/2021/restic-backups-with-systemd-and-prometheus-exporter/)
