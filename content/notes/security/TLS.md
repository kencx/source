---
title: "TLS"
date: 2022-10-02T21:36:46+08:00
lastmod: 2022-10-02T21:36:46+08:00
draft: true
toc: true
tags:
  - security
  - tls
---

The Transport Layer Security (TLS) protocol is a cryptographic protocol designed
to provide secure, encrypted communication between two sockets. An encrypted
channel is set up with a [TLS handshake](#tls-handshake) using [certificates]({{< ref
"/notes/security/tls certificates.md" >}}).

>TLS builds on the now-deprecated SSL specifications. We use SSL and TLS
>interchangeably.

## TLS Handshake

1. The client connects to the server and requests for a secure connection. In a
	 HTTP(s) connection, this is most simply done by connecting to the server on
	 port 443. At the same time, the client also presents a list of supported
	 cipher suites.
2. The server responds with its certificate which contains the server name,
	 public key and trusted CA. It also picks from the list of supported cipher
	 suites and notifies the client of its choice.
3. The client verifies the validity of the server certificate with the trusted
	 CA certificate, usually available on the OS or browser.
4. If the server is configured for client authentication (in a secure API
	 request for example), the client must also sends its client certificate to
	 the server for validation. The server will then verify their validity before
	 proceeding.
5. On verification of one or both parties, the client generates a random
	 symmetric key and encrypts it using the chosen algorithm in step 2 and the
	 server's public key. The encrypted key is sent to the server who decrypts it
	 using its private key.
6. Both parties now agree to use this symmetric session key for encrypting and
	 decrypting data until the connection closes.

The TLS connection is secure because a symmetric-key algorithm is used for
encryption. These keys are uniquely generated for each connection and are based
on a shared secret that was negotiated in step 1 and 2.

## Why use an asymmetric system to share a symmetric key?

- Asymmetrical encryption is *very* expensive compared to symmetric encryption.
- A new symmetric key can be generated for each session. This is highly
	favourable compared to using the same symmetric key across multiple sessions,
	which will be highly prone to attacks should it be leaked.
