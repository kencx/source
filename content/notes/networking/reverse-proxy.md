---
title: "Reverse Proxy"
date: 2021-12-31T21:58:36+08:00
lastmod: 2022-02-27T21:28:51+08:00
draft: true
toc: false
---

The purpose of a reverse proxy is to intercept and direct requests bound for
upstream services. In doing so, a reverse proxy can provide protection from
attacks and help to perform TLS encryption. As such, we want our upstream
services to:

- Be accessible **only** through the reverse proxy and not from their `{IP}:{port}`.
- Be configured with TLS encryption.

In home networking or selfhosting, reverse proxies are usually set up in Docker
containers with docker networks. This is the case of [Nginx Proxy
Manager]({{< ref "/notes/selfhosted/npm.md" >}}) and
Traefik.

#### docker networks

In a docker network, all containers within the network can communicate with one
another via their hostnames due to [automatic DNS
resolution](https://docs.docker.com/network/bridge/#differences-between-user-defined-bridges-and-the-default-bridge).

In order to prevent direct access to container services, we place them in the
same network as the reverse proxy container **AND** close their published ports.

If the ports are published, the port can still be directly access with the
container's IP. However, if the ports are merely exposed (usually in the Docker
image), they are inaccessible from outside the network.

This way, users are forced to access the services through the reverse proxy.

# References

- [Docker Docs - Bridge networks](https://docs.docker.com/network/bridge/)
