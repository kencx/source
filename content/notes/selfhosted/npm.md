---
title: "Nginx Proxy Manager"
date: 2021-12-31T21:58:36+08:00
draft: false
toc: false
images:
---

[Nginx Proxy Manager](https://nginxproxymanager.com/) is an nginx wrapper that
quickly sets up a [reverse proxy]({{< ref "/notes/networking/reverse-proxy.md" >}}) with free SSL certificates and a modern web GUI.

This guide assumes your applications are running on separate docker containers
and you wish to access them behind a reverse proxy **WITHOUT** port forwarding.
We require the following prerequisites:

1. docker and docker-compose
2. A docker container to be accessed behind the reverse proxy
3. (Optional) A valid domain and VPS account for the [DNS
   challenge](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge).
   This is required if you cannot or do not wish to perform port forwarding.


## Create a docker network

First, create an external docker network `proxy`.

```bash
$ docker network create proxy
```

Then, add the following to your `npm/docker-compose.yml`

```yml
version: "3"
services:
	npm:
		image: "jc21/nginx-proxy-manager:2.9.12"
		networks:
		    - proxy

networks:
	proxy:
		external: true
```

All containers that you wish to access behind the reverse proxy should be added
to the same network. Do this by adding the same lines to their existing compose
files.

Next, remove all existing published ports from the same compose files. All
upstream services should now be inaccessible with their IPs. You can then carry
on to add proxy hosts for your various services in the NPM GUI.

>One concern with this approach is that all services within the NPM proxy
>network can now communicate with one another, which might not be ideal.
>
>It is also possible to keep all containers in their separate subnets, while linking
>the NPM container to each service individually. This takes more effort at the
>expense of convenience. You can decide how you want to do it but do understand
>the tradeoffs.

## Adding Proxy Hosts

When a container is restarted, its IP address can change. Hence, it is preferred
to refer to a container with their hostname. Fortunately, this is possible when
the containers are in the same docker network. This way, we do not need to
update the proxy host address when a container is restarted.

## SSL certificates

TODO


# References

- [NPM Docs - Use a Docker network](https://nginxproxymanager.com/advanced-config/#best-practice-use-a-docker-network)
