---
title: "Nginx Proxy Manager"
date: 2021-12-31T21:58:36+08:00
draft: false
toc: false
images:
---

[Nginx Proxy Manager](https://nginxproxymanager.com/) is a nginx wrapper that allows for a quick and fuss-free setup of a reverse proxy with free SSL certificates and a modern web GUI.

This guide assumes your applications are run on separate docker containers and you wish to access them behind a reverse proxy **WITHOUT** port forwarding. We require the following prerequisites:
1. docker and docker-compose
2. An existing docker container to be accessed behind your reverse proxy
3. (Optional) A valid domain and VPS account for DNS challenge. This is required if you cannot or do not wish to perform port forwarding.

## Installation

TODO

## Usage

The purpose of a reverse proxy is to intercept and direct requests bound for upstream services. In doing so, a reverse proxy can provide protection from attacks and help to perform TLS encryption. As such, we want our upstream services to:

- Be accessible **only** through the reverse proxy and not from their `{IP}:{port}`.
- Be configured with TLS encryption.

The following steps help to ensure the above is achieved.

### Restricting direct access

Before setting up a reverse proxy, we performed port mapping to access containers directly from their `{IP}:{port}`. Now, to restrict external access, we can start by binding the host port to `127.0.0.1` so that the container is only accessible from within the host machine.

```yml
ports:
  - 127.0.0.1:8080:8080
```

However, we still want our services to be accessed through the reverse proxy.
The most straightforward to do this is to provide NPM with the container's IP
address. Its also very tedious and prone to error.

When a container is restarted, its given a different IP (unless otherwise
defined), which means we have to update NPM every single time a container is
restarted. Ideally, we want to refer to the container's by their hostname.

#### docker networks

We can do this with *docker networks*. In a docker network, all containers within the network can communicate with one another, and they can communicate via their hostnames due to [automatic DNS resolution](https://docs.docker.com/network/bridge/#differences-between-user-defined-bridges-and-the-default-bridge).

[docker network image here]

By placing all upstream services in the same network as the NPM container **AND** closing their published ports, we isolate these containers from direct access.

The second step is important. If the ports are published, we can still acess the port directly with the container's IP. However, if the ports are merely exposed (usually in the Docker image), they are inaccessible from outside the network.

With both done, we only way to access the service is through the TLS-encrypted (we'll get to this in the next section) reverse proxy, which is exactly what we want!

#### Creating a docker network

First, we want to create an external docker network `reverseproxy`

```bash
$ docker network create reverseproxy
```

Then, add the following to your `npm/docker-compose.yml`

```yml
version: "3"
services:
	npm:
		image: "jc21/nginx-proxy-manager:2.9.12"
		networks:
		    - reverseproxy

networks:
	reverseproxy:
		external: true
```

These lines adds the `npm` container to the network. All containers that you wish to access behind the reverse proxy should be added to the same network. Do this by adding the same lines to their existing compose files.

Finally, remove all existing published ports from the same compose files. All upstream services should now be inaccessible with their IPs. You can then carry on to add proxy hosts for your various services.

>One concern with this approach is that all services within the NPM reverseproxy
>network can now communicate with one another, which might not be ideal.
>
>It is also possible to keep all containers in their separate subnets, while linking
>the NPM container to each service individually. This takes more effort at the
>expense of convenience. You can decide how you want to do it but do understand
>the tradeoffs.

### SSL certificates

TODO


# References

- [NPM Docs - Use a Docker network](https://nginxproxymanager.com/advanced-config/#best-practice-use-a-docker-network)
- [Docker Docs - Bridge networks](https://docs.docker.com/network/bridge/)
