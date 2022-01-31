---
title: "Docker - Entrypoint and CMD"
date: 2021-12-11T23:37:40+08:00
draft: true
toc: false
images:
---

| ENTRYPOINT                     | CMD                      |
| ------------------------------ | ------------------------ |
| Dedicated command for image    | General purpose command  |
| Use container as an executable | Arguments for ENTRYPOINT |

## Examples
```
FROM debian:wheezy
ENTRYPOINT ["/bin/ping"]
CMD ["localhost"]
```
Running the above image without arguments will ping `localhost`
```
docker run -it test
PING localhost (127.0.0.1): 48 data bytes
```
Running the image with an argument will ping the argument.
```
docker run -it test google.com
PING google.com: 48 data bytes
```

Alternatively, without `ENTRYPOINT`,
```
FROM debian:wheezy
CMD ["/bin/ping", "localhost"]
```
Running the above image without arguments will ping `localhost`
```
docker run -it test
PING localhost (127.0.0.1): 48 data bytes
```
Running the image with an argument will override `CMD`
```
docker run -it test bash
root /#
```

## References
https://stackoverflow.com/questions/21553353/what-is-the-difference-between-cmd-and-entrypoint-in-a-dockerfile
