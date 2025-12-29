+++
title = "That headers with underscores are ignored in Nginx by default"
date = "2025-12-30"
updated = "2025-12-30"

[taxonomies]
tags = ["nginx", "http"]
+++

Headers with underscores are dropped by Nginx by default. To prevent this
behaviour, add the following configuration:

```
server {
    underscores_in_headers on;
}
```


For ingress-nginx, the following config value is required in the controller's
configmap:

```yml
apiVersio: v1
kind: ConfigMap
data:
    enable-underscores-in-headers: "true"
metadata:
  name: ingress-nginx
  namespace: kube-system
```


## References

- [Nginx - underscores_in_headers](https://nginx.org/en/docs/http/ngx_http_core_module.html#underscores_in_headers)
- [ingress-nginx ConfigMap](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#enable-underscores-in-headers)
