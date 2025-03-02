---
title: "VPC endpoint cannot be used to connect to public APIGW"
date: 2025-02-19
lastmod: 2025-02-19
draft: false
toc: false
tags:
- aws
- api-gateway
- vpc-endpoint
---

When there is a `execute-api` VPC endpoint with `Private DNS Enabled` turned on,
it can lead to a `403 Forbidden` error when connecting to a public AWS API Gateway.

{{< quote source="[AWS](https://repost.aws/knowledge-center/api-gateway-vpc-connections)" >}}
The HTTP 403 Forbidden error occurs when you turn on DNS for an API Gateway interface VPC endpoint that's associated with a VPC. In this case, all requests from the VPC to API Gateway APIs resolve to that interface VPC endpoint. However, you can't use a VPC endpoint to connect to public APIs.
{{< /quote >}}

This occurs even for CNAMEs for API gateways.

## References
- [Why do I get an HTTP 403 Forbidden error when I connect to my API Gateway APIs from a VPC?](https://repost.aws/knowledge-center/api-gateway-vpc-connections)
