+++
title = "That CNs are not used for hostname validation in TLS certificates (anymore)"
date = "2025-11-19"
updated = "2025-11-19"

[taxonomies]
tags = ["tls", "ssl", "pki"]
+++

A TLS certificate requires the hostname to be in the Subject Alternative Names
(SAN) for hostname validation. It is not sufficient to just have the hostname in
the certificate's Common Name (CN).

{% quote(source="[RFC 9525](https://www.rfc-editor.org/rfc/rfc9525)") %}
Only check DNS domain names via the subjectAltName extension designed for that purpose:
dNSName.
{% end %}


## References
- [RFC 9525](https://www.rfc-editor.org/rfc/rfc9525)
