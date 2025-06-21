+++
title = "How to redirect uppercase paths to lowercase in Nginx"
date = "2025-06-15"
updated = "2025-06-15"
[taxonomies]
tags = ["nginx", "kubernetes"]
+++

For a generic redirect for all paths:

```text
location ~ [A-Z] {
    rewrite_by_lua_block {
        ngx.redirect(string.lower(ngx.var.uri), 301);
    }
}
```

For a specific path:

```text
location ~* ^/FOO(.*) {
    return 301 /foo$1;
}
```

For a specific path with query parameters:

```text
location ~* ^/FOO(.*) {
    return 301 /foo$1$is_args$args;
}
```

For a specific path with query parameters and any request method:

```text
location ~* ^/FOO(.*) {
    return 308 /foo$1$is_args$args;
}
```

## Ingress-Nginx

There is no native annotation for uppercase redirection in ingress-nginx so we
must also use the `server-snippet` annotation:

```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/server-snippet: |
      location ~* ^/FOO(.*) {
        return 308 /foo$1$is_args$args;
      }
```


Note that the `server-snippet` annotation can only be used **once per host**.
Using the annotation more than once per host, even when the ingresses are in
different namespaces, will cause `server-snippet` to be ignored by ingress-nginx.

## References
- [ingress-nginx - Annotations](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#server-snippet)
