---
title: "Signal Handling in Docker Containers"
date: 2023-02-19
lastmod: 2023-02-19
draft: false
toc: true
tags:
- docker
- processes
- signals
---

The very first process that runs inside a Docker container is the root
process, assigned PID 1. The root process is special because of three features:

1. It does not automatically get default signal handlers. A signal is ignored
   unless the root process registers a signal handler for that signal.
2. Any orphaned process is adopted by PID 1.
3. If the root process dies, every other process in the same namespace will be
   forcibly terminated and the namespace will be cleaned up.

In Docker containers, PID 1 is most commonly defined with the ENTRYPOINT instruction. This can be the
application binary or an entrypoint script:

```Dockerfile
ENTRYPOINT ["./foo-example"]
# or
ENTRYPOINT ["/entrypoint.sh"]
```

While this is usually fine, two issues may arise that may lead to some
unexpected problems:

1. The application is not suited to be a root process (for example, it does not
   handle [zombie processes](#zombie-processes)).
2. Signals are not being passed to the root process properly.

Hence, we discuss some common pitfalls when handling signals in Docker
containers and some solutions.

{{< alert type="info" >}}
If you're unsure if your container is handling signals appropriately, run
`docker stop` on it and observe if it always takes more than 10 seconds to
shutdown.
{{< /alert >}}

## Mistakes

### No Signal Handling

When we run `docker stop` on a running container, the root process receives a
`SIGTERM`. If the signal is not handled by the process' signal handlers, Docker
will wait for a grace period of 10 seconds before forcibly killing the container
with `SIGKILL`.

### Improper Entrypoint Script

Oftentimes, the container's program implements proper signal handling. However,
the shutdown signals are not being passed on from Docker to the running program
due to an inappropriate ENTRYPOINT script:

```bash
#!/bin/bash
# simple entrypoint.sh that runs the application
foo-example
```

While the script *should* work, it starts the container by forking a child
process of the `foo-example` program.

```bash
# inside container
$ ps
PID TIME     CMD
1   00:00:00 /bin/bash /entrypoint.sh
7   00:00:00 foo-example
```

We see that the desired program is not running as PID 1. When Docker receives a
`SIGTERM`, it will be sent to the `entrypoint.sh` (root) process, instead of the
application. This signal will also never be passed from the parent to the child
process.

### Improper Entrypoint Instruction

If the `ENTRYPOINT` does start the program as PID 1, the problem may lie in the
`ENTRYPOINT` instruction within the Dockerfile instead. `ENTRYPOINT` can be
defined in two forms: shell and exec.

When using shell form, the specified command is run within a subshell `sh -c
"command"` which creates a separate process:

```Dockerfile
ENTRYPOINT "/entrypoint.sh"
```

```bash
# inside container
$ ps
PID TIME     CMD
1   00:00:00 /bin/sh -c /entrypoint.sh
7   00:00:00 foo-example
```

### Zombie Processes

{{< alert type="warning" >}}
This section can be improved.
{{< /alert >}}

If the root process forks a child and dies before any grandchildren exit, zombie
processes can accumulate in the container. This becomes a problem if the
container's root process is not meant to be run as PID 1.

## Solution
### init flag

We can specify an init process with the `--init`
[flag](https://docs.docker.com/engine/reference/run/#specify-an-init-process).
This creates a container with an init process as PID 1. The init process will
then ensure the usual responsibilities of an init system, such as reaping zombie
processes and passing signals to the appropriate processes.

```bash
$ docker run --init -d --rm ubuntu sh
```

For `docker compose`, the equivalent is:

```yaml
version: "3.6"
services:
  web:
    image: alpine:latest
    init: true
```

The default init process is the first `docker-init` executable found in the
system path of the Docker daemon process. By default,
[tini](https://github.com/krallin/tini) is used.

{{< alert type="info" >}}
For more information about tini, see
[this](https://github.com/krallin/tini/issues/8#issuecomment-146135930)
incredibly informative comment by its author.
{{< /alert >}}

### Passing Signals to Entrypoint Scripts

Another solution to ensure that the entrypoint script runs `foo-example` as PID 1 is
to prepend `exec` to it

```bash
#!/bin/bash
exec foo-example
```

`exec` replaces the parent process with the new process, making it run as PID 1.

{{< alert type="note" >}}
Even when running exec, take care to not start the program in a
subshell with piping.
{{< /alert >}}

We must then use `ENTRYPOINT` with exec form in the Dockerfile:

```Dockerfile
ENTRYPOINT ["/entrypoint.sh"]
```

## References
- [Docker compose specification - init](https://docs.docker.com/compose/compose-file/#init)
- [Shutdown Signals with Docker Entrypoint Scripts](https://madflojo.medium.com/shutdown-signals-with-docker-entry-point-scripts-5e560f4e2d45)
- [Why your Dockerized Application isn't receiving signals](https://hynek.me/articles/docker-signals/)
