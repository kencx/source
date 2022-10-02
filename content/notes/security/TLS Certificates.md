---
title: "TLS Certificates"
date: 2022-10-02T21:36:46+08:00
lastmod: 2022-10-02T21:36:46+08:00
draft: true
toc: false
tags:
  - security
  - tls
---

In secure networking, the [TLS protocol]({{< ref "/notes/security/tls.md" >}}) aims to provide privacy, integrity and
authenticity through encryption of data between communicating hosts. To send an
encrypted message, we require the other party's public key as a prerequisite. The
simplest way to obtain it would be to ask your peer to send over their public key.

However, this may constitute a risk that an attacker uses IP address spoofing to pretend
to be the peer of interest and send a fake public key. Instead, we require a way to
verify that the presented public key is owned by the party of interest.

A well known approach is to establish a third, trusted and publicly known party, a
**Certificate Authority (CA)**. The CA's role is to digitally sign the peer's public
key before presenting it to you. You would then retrieve the CA's public key and use it
to verify the signature. Your peer's digitally signed public key is known as a
**certificate**.

## Certificate

A certificate, according to the x509v3 standard consists of the following components:

- The version number of the x509 specification
- A serial number which the issuer (CA) assigns to the certificate, in hex
- A valid-from and valid-to date
- The public key that the certificate is supposed to certify, with some information on
	the underlying algorithm (eg. RSA)
- The subject (the party owning the key)
- The issuer (the party signing the certificate, the CA)
- Extensions, optional pieces of data
- A digital signature that signs all the data above

A certificate comes with a generated private key. The private key is to be kept private
and should NEVER leave the device.
