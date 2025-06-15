---
title: "That empty headers result in 400 error in Nginx"
date: 2025-02-19
lastmod: 2025-02-19
draft: false
toc: false
tags:
- http
- nginx
---

When a request is sent with empty headers, (specifically `User-Agent`, `Accept`
and `Host`) it causes a `400 Bad Request` error from Nginx.

```bash
$ curl -H 'User-Agent:' -H 'Accept:' -H 'Host:' https://example.com
```

{{< quote source="[RFC 9112](https://datatracker.ietf.org/doc/html/rfc9112#name-request-target)" >}}
A server MUST respond with a 400 (Bad Request) status code to any HTTP/1.1 request message that lacks a Host header field and to any request message that contains more than one Host header field line or a Host header field with an invalid field value.
{{< /quote >}}

This behaviour can lead to some problems when dealing with healthchecks from
custom load balancers that do not send any `Host` headers in their request.
