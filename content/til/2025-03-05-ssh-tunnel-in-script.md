---
title: "Running SSH tunnel in script"
date: 2025-03-05
lastmod: 2025-03-05
draft: false
toc: false
tags:
- ssh
---

To run a SSH tunnel in a Bash script or in a CI/CD job, we can utilize the
following command:

```bash
ssh -o ExitOnForwardFailure=yes -f -L port:host:5432 user@$ip -i ~/.ssh/key.pub sleep 10
```
- `-o ExitOnForwardFailure`

    Specifies whether ssh should terminate the connection if it cannot set up all requested dynamic,
    tunnel, local, and remote port forwardings, (e.g. if either end is unable to bind and listen on a
    specified port).  Note that ExitOnForwardFailure does not apply to connections made over port
    forwardings and will not, for example, cause ssh to exit if TCP connections to the ultimate
    forwarding destination fail.

- `-f`

    Requests ssh to go to background just before command execution. ... If the
    ExitOnForwardFailure configuration option is set to “yes”, then a client
    started with -f will wait for all remote port forwards to be successfully
    established before placing itself in the background.

- `-L port:host:5432 user@$ip`

    This opens an SSH tunnel via a jumphost.

- `sleep 10`

    With `-f` and `sleep 10`, the SSH tunnel will attempt to close after 10
    seconds. However, if the forwarded ports are still in use by another
    process, even after the 10 second period, the tunnel will remain open until
    the process exits.

### Use Cases

Some examples of use cases:
- Running a long-running SQL query via an SSH tunnel in a CI/CD job


### References

- [How to run a tunnel in the background as part of a shell script](https://superuser.com/questions/1313738/how-to-run-a-tunnel-in-the-background-as-part-of-a-shell-script)
- [Auto-closing SSH tunnels](https://www.g-loaded.eu/2006/11/24/auto-closing-ssh-tunnels/)
- [Opening and closing an SSH tunnel in a shell script the smart way](https://gist.github.com/scy/6781836)
- [explainshell](https://explainshell.com/explain?cmd=ssh+-f+-o+ExitOnForwardFailure%3Dyes+-L+localhost%3A5433%3A%22%24PGHOST%22%3A%24db_port+%24ssh_user%40%22%24ssh_host%22+-i+%22%24DB_SSH_KEY%22+sleep+10)
