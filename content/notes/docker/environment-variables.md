---
title: "Compose - Environment Variables"
date: 2022-02-17T18:33:14+08:00
lastmod:
draft: true
toc: false
tags:
  - docker
---

There are 2 types of environment variables in docker-compose:
1. Compose specific env variables
2. Container env variables

Both have different functions and are configured differently.

>For debugging env variables, use `docker-compose config`.

## Compose Specific Environment Variables
These environment variables are passed into compose files as such

```yaml
services:
  portainer:
    image: portainer:latest
	volumes:
	  - "${PORTAINER_DATA_DIR}:./data"
	ports:
	  - "${PORTAINER_PORT:-9443}:9443"
```

A default value can be provided with `:-[VALUE]` as seen in `ports` above.
Otherwise, if a value is not set, it defaults to an empty string.

>Provide a mandatory environment variable with `${VAR:?err}`

Compose specific env variables are automatically passed with an `.env` in the
project's directory. No extra arguments need to be passed when running
`docker-compose up`

```bash
portainer
  |
  |- docker-compose.yml
  |- .env

$ docker-compose up -d
```

To specify a *different* `.env` file, use the `--env-file` flag. If a `.env` is
present, it is ignored.

```bash
portainer
  |
  |- docker-compose.yml
  |- .env
  |- .env.prod

$ docker-compose --env-file .env.prod up -d
```

#### Precedence
When the same env variable is given, compose follows the following precedence:
1. Compose file
2. Shell environment variables
3. Environment file `.env` or `--env-file`
4. Dockerfile
5. Not defined

## Container Environment Variables

These environment variables are passed into the *container* for use by the container. They are not read by the compose file at all.

These env variables are passed with the `environment:` directive.

```yaml
services:
  portainer:
    image: portainer:latest
	environment:
	  - "INTERNAL=INTERNAL"
	  - "TEST=${TEST_VARIABLE}"
```

If they require variable substitution in the compose file (like `TEST_VARIABLE`
above), the variable must be passed from **`.env`**. Any variables in the
`env_file:` directive are not seen.

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
	  - "TEST=${TEST_VARIABLE}"
```

If multiple env files are passed in `env_file`, the **final file** in the list
takes precedence.

>Environment variables passed into `env_file:` directive are NOT read by the
>compose file. Do not specify any compose file variables in them.

When both `environment:` and `env_file:` are set, the `environment:` directive
takes [precedence](https://github.com/docker/docker.github.io/pull/4177) for any
common variables between them. This is true even when the values are empty or
undefined. To prevent confusion and conflict, always set default values in the
`env_file`.

# References
- [Compose - Environment Variables](https://docs.docker.com/compose/environment-variables/#substitute-environment-variables-in-compose-files)
- [Compose - env_file](https://docs.docker.com/compose/compose-file/compose-file-v3/#env_file)
- [Multiple env files in monorepo](https://github.com/docker/compose/issues/6392)
