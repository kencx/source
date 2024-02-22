---
title: "Traefik"
date: 2022-02-20T01:51:59+08:00
lastmod: 2022-04-19
draft: false
toc: true
tags:
- selfhosted
---

This page describes my notes for setup and configuration of a Traefik reverse
proxy on Docker and docker-compose.

Traefik is a docker-focused reverse proxy and load balancer that can dynamically
perform service discovery.

## Setup
1. Ensure the following files and directories are created
- `acme/acme.json` with `0600` permissions - SSL certificates from DNS challenge
- `traefik.log` - access log file
- `traefik.env` - Environment variables
- `traefik.yml` - [Static](#static) configuration file

2. Create the external Docker networks

```bash
$ docker network create proxy
$ docker network create socket-proxy
```

3. We will be using [Let's Encrypt's DNS
   challenge](https://letsencrypt.org/docs/challenge-types/) to generate SSL
   certificates. We will be using the digitalocean
   [provider](https://doc.traefik.io/traefik/https/acme/#providers).

{{< alert type="note" >}}
A certificate file is required for every different domain. This includes second
level domains, eg. `dev.example.com` and `sit.example.com`. Ensure that the
second level domains are also added as entries to the provider.
{{< /alert >}}

Set the necessary environment variables for your provider in `traefik.env`:

```bash
DO_AUTH_TOKEN=
```

Also set the domain name, acme email and CA server variables:

```bash
TRAEFIK_CERTIFICATESRESOLVERS_LETSENCRYPT_ACME_EMAIL=user@example.com
TRAEFIK_CERTIFICATESRESOLVERS_LETSENCRYPT_ACME_CASERVER=https://acme-v02.api.letsencrypt.org/directory
DOMAIN_NAME=example.com
```

{{< alert type="note" >}}
`ACME_EMAIL` and `ACME_CASERVER` can be set in the static configuration file as
well under `certificateResolvers`. We chose to set them here as we want to pass
down the env variables from the global `.env` to Traefik.
{{< /alert >}}

4. Ensure the line in `docker-compose.yml` is **uncommented**:

```bash
labels:
	- "traefik.http.routers.traefik-router.tls.certResolver=dns-dgo"
```

This line should only be included for the first time setup to generate the SSL
certificates. It is not required after.

5. Start the containers and wait for the certificates to generate.

```bash
$ docker-compose up -d
$ docker logs -f traefik
```

Check in `acme.json` as well.

6. Comment out the line in step 4 and recreate the container.

```bash
$ docker-compose up -d --force-recreate
```

All other containers with the applied labels should now be discovered.

## Configuration
Traefik uses static and dynamic configuration.

### Static
There are three mediums to define Traefik's static configuration: `yaml`, `toml` and `CLI`. `CLI` is the most common for [simple setups](https://doc.traefik.io/traefik/user-guides/docker-compose/basic-example/). We will be using `yaml` in `traefik.yml` instead.

```yaml
api:
  insecure: false
  dashboard: true   # includes dashboard

entrypoints:
  http:
    address: :80    # take note of the : before the port number
  https:
    address: :443

providers:
  docker:
    network: "proxy" # external docker network
    endpoint: "tcp://socket-proxy:2375" # socket proxy
    ...

  file:
    directory: "/rules"
...
```

{{< alert type="note" >}}
Go templating {{ env 'VAR'}} cannot be used in static configuration files. To
pass environment variables, use Traefik's own [Environment
Variables](https://doc.traefik.io/traefik/reference/static-configuration/env/).
{{< /alert >}}

### Dynamic

We are using the file provider for Traefik's dynamic configuration to include
middleware and services. These are located in `/rules`

`chain-authelia` is used to include Authelia as an authentication server for
2FA and SSO. Comment out the relevant line in all docker-compose files if not
set or required.

## Labels

Because we specified `exposedByDefault=false`, we need to include this label for
all traefik services

```yaml
- "traefik.enable=true"
```

Next, we define `routers` for redirecting http to https

```yaml
# HTTP-to-HTTPS Redirect
- "traefik.http.routers.http-catchall.entrypoints=http"
- "traefik.http.routers.http-catchall.rule=HostRegexp(`{host:.+}`)"
- "traefik.http.routers.http-catchall.middlewares=redirect-to-https"
- "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
```

Finally, we define additional routers for cert resolving, domain info and entrypoints

```yaml
# HTTP Routers
- "traefik.http.routers.traefik-rtr.entrypoints=https"
- "traefik.http.routers.traefik-rtr.rule=Host(`traefik.$DOMAINNAME`)"
- "traefik.http.routers.traefik-rtr.tls=true"
# Comment out this line after first run of traefik to force the use of wildcard certs
- "traefik.http.routers.traefik-rtr.tls.certresolver=dns-dgo"
- "traefik.http.routers.traefik-rtr.tls.domains[0].main=$DOMAINNAME"
- "traefik.http.routers.traefik-rtr.tls.domains[0].sans=*.$DOMAINNAME"

# Services - API
- "traefik.http.routers.traefik-rtr.service=api@internal"
```

## Socket Proxy

Refer to [Docker Security]({{< ref
"/til/docker/docker-security.md#socket-proxy" >}}) for details on how to
create the socket proxy container and link services to it.

## Adding Services

Finally, we want to start adding services or containers to our reverse proxy. We
use Portainer as our example here.

```yaml
services:
	portainer:
		image: portainer/portainer:latest
		container_name: portainer
		restart: unless-stopped
		networks:
		  - proxy
		ports:
		  - 9334:9334
		volumes:
		  - /var/run/docker.sock:/var/run/docker.sock:ro
		  - ./data:/data
		labels:
		  - "traefik.enable=true"
		  - "traefik.http.routers.portainer-proxy.entrypoints=https"
		  - "traefik.http.routers.portainer-proxy.rule=Host(`portainer.$DOMAINNAME`)"
		  - "traefik.http.routers.portainer-proxy.tls=true"
		  - "traefik.http.routers.portainer-proxy.service=portainer-service"
		  - "traefik.http.services.portainer-service.loadbalancer.server.port=9334"

networks:
  proxy:
    external: true
```

The appropriate `labels` are added as shown above.

## References
- [traefik docs](https://doc.traefik.io/traefik/user-guides/docker-compose/acme-dns/)
- [traefik docker tutorial](https://www.smarthomebeginner.com/traefik-2-docker-tutorial/)
- [Docker Security Best Practices](https://www.smarthomebeginner.com/traefik-docker-security-best-practices/#9_Use_a_Docker_Socket_Proxy)
