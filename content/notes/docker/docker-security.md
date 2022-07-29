---
title: "Security"
date: 2022-02-16
lastmod:
draft: false
toc: true
tags:
  - docker
---

## Docker Socket Ownership

Never change the permissions of `var/run/docker.sock`. By default, the socket is
owned by `root` user and `docker` group.

Instead of replacing that with your own user, add yourself to the `docker` group.

## Protecting Docker Daemon Socket

Some services require access to the docker socket (eg.
[Traefik](https://doc.traefik.io/traefik/providers/docker/#docker-api-access),
Portainer, Watchtower). Unrestricted access via the docker daemon is a [major
security
concern](https://docs.docker.com/engine/security/#docker-daemon-attack-surface).

If an attacker manages to access any container with access to the docker socket, they can obtain root access to the host machine trivially.

### SSH/HTTPS
Read [here](https://docs.docker.com/engine/security/protect-access/) for more info.

### Socket Proxy

A solution is to use a socket proxy. A socket proxy is similar to a firewall for
the docker socket. It is a container without a network connection that controls
access to the socket. Some well-known socket proxies include
[Tecnavita](https://github.com/Tecnativa/docker-socket-proxy) and
[fluencelabs](https://github.com/fluencelabs/docker-socket-proxy).

To add a socket proxy, create a separate network for the proxy (or create a network gateway and subnet):

```bash
$ sudo docker network create socket_proxy
# or
$ sudo docker network create --gateway 192.168.91.1 --subnet 192.168.91.0/24 socket_proxy
```

Add the network to your compose file.

```yaml
networks:
  socket_proxy:
    external:
	  name: socket_proxy
```

Finally, add the socket proxy container with this compose snippet

```yaml
socket-proxy:
	container_name: socket-proxy
	image: fluencelabs/docker-socket-proxy
	restart: always
	networks:
	  socket_proxy:
	    ipv4_address: 192.168.91.200 # static IP
	privileged: true
	ports:
	  - 127.0.0.1:2375:2375
	volumes:
	  - /var/run/docker.sock:/var/run/docker.sock
	environment:
	  ...
```

In the `environment` block, we control the Docker API section that we want to
open or close. Read the relevant socket-proxy image documentation for more
details.

After starting the socket proxy container, you can replace any direct access to
the Docker socket with the new socket proxy. How it is added depends on the
service.

**Related Reference**: [Docker Security Best
Practices](https://www.smarthomebeginner.com/traefik-docker-security-best-practices/#9_Use_a_Docker_Socket_Proxy)

## Running as root

By default, the root user is the default user inside a container if the user is
not explicitly specified. This is the case for most public images. Additionally,
Linux is known for starting as a root user before dropping back to a non-root
user. This is necessary to support port-binding below port 1024.

### Security Risks

Although containers are containerized, running as root poses huge security
risks, especially when an attacker manages to break out of the container. It
would allow the attacker to gain root privileges to your entire host system.

>When a container mounts a sensitive filesystem path (eg. `/etc/passwd`), it can
>overwrite the `/etc/passwd` on the host.

You can choose to run the container as a non-root user through 2 methods.

### Support with environment variables

Some images (like those from [linuxserver.io](linuxserver.io)) offer support for
`UID` and `GID` environment variables. Ideally, when writing docker images,
offer support for non-root use as well.

```yaml
environment:
  - PUID=1000
  - PGID=1000
```

### Explicitly stating the user

Docker has the CLI flag `--user` to start containers as a specific user. For
docker-compose, we have to explicitly state the container's user with the
`user:` block in the compose file.

```yaml
services:
  db:
    user: 1000:1000
```

However, if it is an existing container (with volumes), the container fails to
start as the `UID:GID` may be directly hardcoded into its image. Instead, we
must do the following:

1. Stop the already running container.
2. Manually change the ownership of the files/volumes to the `UID:GID` you want.
3. Edit the compose file with the desired `UID:GID` as above.
4. Start the container with `docker-compose up`.

**Related Reference**: [Permission Issue with Postgres Docker
Container](https://stackoverflow.com/questions/56188573/permission-issue-with-postgresql-in-docker-container)

## Privileged Mode

By default, containers run in unprivileged mode. This means containers cannot
run a docker daemon within themselves.

Some services (Socket proxy) might require privileged mode with:

```yaml
privileged: true
```

In these cases, it is helpful to add the following to limit privileges

```yaml
security_opt:
  - no-new-privileges: true
```

## Docker and IP tables

Read [ufw-docker](https://github.com/chaifeng/ufw-docker) for more information
about Docker and `ufw`. Implement the changes to `/etc/ufw/after.rules` and
ensure all public network access is blocked.

## Docker Traefik Security
TODO

# References
- [Docker Security Best Practices](https://www.smarthomebeginner.com/traefik-docker-security-best-practices)
