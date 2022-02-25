---
title: "Basics"
date: 2021-12-10T18:00:00+08:00
draft: false
toc: false
tags:
  - docker
---

# Images
Docker images are lightweight, immutable blueprints used to create containers.

Images are pulled from [Docker Hub](https://hub.docker.com/) if not found
locally. Search for images with `docker search <image>`.

Image names consist of:
- Two name components
- An optional tag
- An optional prefix of a registry hostname

```text
registry/organization/image:tag
quay.io/nordstrom/hello-world:2.0
```

Rename image tags with `docker tag <old-image-name> <new-image-name>`.

## Building Images
Images are built with Dockerfiles.

```docker
FROM <image>:<tag>
RUN <install some stuff>
CMD <command>
```

# Volumes
Volumes are used to persist data within docker containers. There are
*two* types of volumes:
- Bind mounts
- Docker volumes

In both cases, files are synced across the host machine and container, even
after the container has been stopped. See [here]() for the differences between
bind mounts and docker volumes.

To create a simple bind mount, run the command with the following flag

```bash
$ docker run -v <host-path>:<container-path>
$ docker run -v ./data:/videos youtube-dl [url]
```

Binding a folder `./data` to the container allows us to access the downloaded
videos in `/videos` in the youtube-dl container.

# Ports
This section assumes prerequisite knowledge of [computer networking]().

Ports allows for communication between the host machine and container.
Information can be sent and received only when the container's ports are
published.

Create a port mapping by running the command with the flag `-p`
```bash
$ docker run -p <host-port>:<container-port> <image>
$ docker run -p 4567:4567 app
```

Within the container, the app has been started on `http://localhost:4567`. To
access this address on our host machine, we mapped the container's port 4567 to
the host machine's corresponding port. The container's port is thus accessible
on our host machine at `http://localhost:4567`.

Note: Leaving out the host port will let docker choose any free port.
