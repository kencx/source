---
title: "Entrypoint and CMD"
date: 2022-02-16T18:30:40+08:00
lastmod:
draft: false
toc: true
tags:
  - docker
---

## ENTRYPOINT

By default, Docker provides a **default entrypoint `/bin/sh -c`**. If we pass `bash` as an argument when starting a Ubuntu container, the process that is executed would be `/bin/sh -c bash`.

```bash
$ docker run -it ubuntu bash
# /bin/sh -c bash
```

`ENTRYPOINT` thus, allows the container to run as an *executable*.

To set a custom `ENTRYPOINT`, we can define it with `ENTRYPOINT` in the `Dockerfile` or by passing it with the `--entrypoint` flag.

## CMD

On the other hand, `CMD` is the **argument** that is passed to `ENTRYPOINT`. In the above example, `bash` is the command. In fact, `CMD ["bash"]` is the default `CMD` specified in the Ubuntu image, so we can just run

```bash
$ docker run -it ubuntu
# /bin/sh -c bash
```

Changing `bash` to `ping google.com` would execute `/bin/sh -c ping google.com` instead as the provided argument overwrites the specified `CMD`.

```bash
$ docker run -it ubuntu ping google.com
# /bin/sh -c ping google.com
```

## Which one to use?
Use `ENTRYPOINT` in your `Dockerfile` if you want to create an executable that users can pass arguments to. Combine `ENTRYPOINT` and `CMD` if you want the executable to have a default argument.

Otherwise, use `CMD` if you just wish for your container to start a running process.

For example, running this image *without arguments* will ping `localhost`

```Dockerfile
FROM debian:wheezy
ENTRYPOINT ["/bin/ping"]
CMD ["localhost"]
```

while running the image with a given argument will ping the argument.

```bash
$ docker run -it ping-test google.com
PING google.com: 48 data bytes
```

Alternatively, if `ENTRYPOINT` is not defined, we have to add `/bin/ping` to `CMD`

```Dockerfile
FROM debian:wheezy
CMD ["/bin/ping", "localhost"]
```

and the container will run `/bin/sh -c /bin/ping localhost` when started.

```bash
$ docker run -it ping-test
PING localhost (127.0.0.1): 48 data bytes
```

If we define a custom argument, the defined `CMD` will be overwritten

```bash
$ docker run -it ping-test bash
root /#
# /bin/sh -c bash
```

## Summary

`ENTRYPOINT` and `CMD` defines the process that starts running when a container is started.

| ENTRYPOINT                     | CMD                      |
| ------------------------------ | ------------------------ |
| Dedicated command for image    | Arguments for ENTRYPOINT |
| Use container as an executable | Default argument for executable container |

## Shell & Exec Form
To make things more confusing, there are 2 different ways to define `ENTRYPOINT` and `CMD` - shell and exec form.

So far, we have been using exec form in all the examples.

```Dockerfile
ENTRYPOINT ["/bin/ping"]
CMD ["localhost"]
```

exec form does not invoke the command shell; it cannot evaluate environment variables (eg. `$HOME`) unless the shell is included with `["/bin/sh", "-c", ...]`.

In shell form, all commands are wrapped with `/bin/sh -c` by default. Hence, it can evaluate environment variables.

## Summary
|   Form     | Dockerfile                       | Command                    |
| :--------: | -------------------------------- | -------------------------- |
| shell form | ENTRYPOINT /bin/ping -c 3        | /bin/sh -c 'bin/ping -c 3' |
| shell form | CMD localhost                    | /bin/sh -c localhost       |
| exec form  | ENTRYPOINT ["/bin/ping", "-c 3"] | /bin/ping -c 3             |
| exec form  | CMD ["localhost"]                | localhost                  |

# References
- [DevOpswithDocker - Defining Start Conditions](https://devopswithdocker.com/part-1/4-defining-start-conditions)
- [Difference between CMD and Entrypoint](https://stackoverflow.com/questions/21553353/what-is-the-difference-between-cmd-and-entrypoint-in-a-dockerfile)
