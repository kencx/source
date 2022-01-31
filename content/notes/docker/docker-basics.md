---
title: "Docker Basics"
date: 2021-12-10T18:00:00+08:00
draft: false
toc: false
images:
---

# tldr
```bash
$ docker images
$ docker rmi [image]
$ docker pull [image]

$ docker ps [-a]
$ docker run [image]
$ docker rm [container]
$ docker stop [container]
$ docker exec [container] [cmd]

$ docker container prune
$ docker image prune
$ docker system prune
```


# Images
Docker images are lightweight, immutable blueprints used to create containers.

They are built from a Dockerfile with `docker build .`
```docker
FROM <image>:<tag>
RUN <install some stuff>
CMD <command>
```

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


# Containers
Containers are runnable instances of images. Start a container with:

```bash
$ docker run hello-world	# run hello-world image
$ docker ps -a				# list all containers
```

For example,
```bash
$ docker run -it -d --rm --name looper ubuntu sh -c \
	'while true; do date; sleep 1; done'
```

runs a `ubuntu` container that is
- `i`- interactive
- `t` - tty
- `d` - detached
- `rm` - deleted upon exit
- `--name looper` with name looper
- `sh -c '<command>'` - with the given command

## Attaching and Detaching
Attach to a detached container
- with attach command - `docker attach looper`
- by starting a bash process - `docker exec -it looper bash`

Detach from an attached container with
- `Ctrl+c` *stops* the entire container
- `Ctrl+p, Ctrl+q` detaches with the container running in the background

## Logs
Obtain the container's output/logs with `docker logs -f looper`.

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
