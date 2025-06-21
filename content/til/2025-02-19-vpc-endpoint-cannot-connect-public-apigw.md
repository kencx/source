+++
title = "That VPC endpoints cannot connect to public APIGWs"
date = "2025-02-19"
updated = "2025-06-11"

[taxonomies]
tags = ["aws", "api-gateway", "vpc-endpoint"]
+++

A `execute-api` VPC endpoint with `Private DNS Enabled` turned on will intercept all
requests to AWS API Gateways in its VPC. This behaviour can lead to a `403
Forbidden` error when attempting to connect to a public AWS API Gateway in the
VPC.

{% quote(source="[AWS](https://repost.aws/knowledge-center/api-gateway-vpc-connections)") %}
The HTTP 403 Forbidden error occurs when you turn on DNS for an API Gateway interface VPC endpoint that's associated with a VPC. In this case, all requests from the VPC to API Gateway APIs resolve to that interface VPC endpoint. However, you can't use a VPC endpoint to connect to public APIs.
{% end %}

This occurs even for CNAMEs of public API Gateways.

## References
- [Why do I get an HTTP 403 Forbidden error when I connect to my API Gateway APIs from a VPC?](https://repost.aws/knowledge-center/api-gateway-vpc-connections)
