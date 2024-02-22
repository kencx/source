---
title: "Environment Variables in Docker Compose"
date: 2022-02-17T18:33:14+08:00
lastmod:
draft: false
toc: true
tags:
  - docker
  - docker-compose
---

There are 2 types of environment variables in docker-compose:
1. Variable substitution in compose files
2. Container env variables

Both have different functions and are configured differently.

{{< alert type="note" >}}
For debugging env variables, use `docker-compose config`.
{{< /alert >}}

## Variable Substitution
These environment variables are passed into compose files with variable
substitution

```yaml
# docker-compose.yml
services:
  portainer:
    image: portainer:latest
    volumes:
        - "${PORTAINER_DATA_DIR}:./data"
    ports:
        - "${PORTAINER_PORT:-9443}:9443"
```

A default value are provided with `:-[VALUE]` while mandatory values are provided
with `${VAR:?err}`.

These env variables are automatically passed with an `.env` file in the
project's directory.

```bash
portainer
  |
  |- docker-compose.yml
  |- .env

$ docker-compose up -d
```

To specify a *different* `.env` file, use the `--env-file` flag.

```bash
portainer
  |
  |- docker-compose.yml
  |- .env
  |- .env.prod

$ docker-compose --env-file .env.prod up -d
```

### Precedence
1. Compose file
2. Shell environment variables
3. Environment file `.env` or `--env-file`
4. Dockerfile
5. Not defined

## Container Environment Variables

These are passed into the container for use *within the container*. These cannot
be used for variable substitution directly.

```yaml
# docker-compose.yml
services:
  portainer:
    image: portainer:latest
	environment:
	  - "INTERNAL=INTERNAL"
```

```bash
$ docker exec -it portainer bash

# inside container
root@server# env
INTERNAL=INTERNAL
```

To pass a (or multiple) file(s) of env variables, use the `env_file:` directive.

```yaml
portainer
  |
  |- docker-compose.yml
  |- portainer.env

# docker-compose.yml
services:
  portainer:
    image: portainer:latest
	env_file: "portainer.env"
	environment:
	  - "INTERNAL=INTERNAL"
```

If multiple env files are passed in `env_file`, the **last file** in the list
takes precedence.

When both `environment:` and `env_file:` directives are set, the `environment:`
directive takes
[precedence](https://github.com/docker/docker.github.io/pull/4177) for any
common variables. This is true even when the values are empty or undefined. To
prevent confusion and conflict, always set default values in the `env_file`.


```yaml
# docker-compose.yml
services:
  portainer:
    image: portainer:latest
	env_file: "portainer.env"
	environment:
	  - EDITOR=nano
	ports:
	  - "${PORTAINER_PORT:-9443}:9443"
```

```bash
# portainer.env
PORTAINER_PORT=9222
EDITOR=vim
FILE_ONLY=true

$ docker exec -it portainer bash

# inside container
root@server# env
PORTAINER_PORT=9222
EDITOR=nano
FILE_ONLY=true
```

We observe that
- `PORTAINER_PORT` in `portainer.env` is not used for variable substitution.
  Instead, it is defined in the container. It is however, useless in the
  container.
- The value of `EDITOR=vim` in `portainer.env` is overwritten by the `EDITOR=nano`.
- `FILE_ONLY` is defined and not overwritten.

## References
- [Compose - Environment Variables](https://docs.docker.com/compose/environment-variables/#substitute-environment-variables-in-compose-files)
- [Compose - env_file](https://docs.docker.com/compose/compose-file/compose-file-v3/#env_file)
- [Multiple env files in monorepo](https://github.com/docker/compose/issues/6392)
