---
title: "Cheatsheet"
date: 2023-02-03
lastmod: 2023-02-03
draft: false
toc: false
tags:
- pki
- openssl
---

```bash
# check private key
$ openssl rsa -in /path/to/key -check

# check CSR
$ openssl rsa -text -noout -verify -in /path/to/csr

# check certificate
$ openssl x509 -text -noout -in /path/to/cert

# check ca chain
$ openssl storeutl -noout -text -certs /path/to/ca-chain

# verify full ca chain on signed certificate
$ openssl verify -CAfile /root/cert -untrusted /intermediate/cert /path/to/cert
```
