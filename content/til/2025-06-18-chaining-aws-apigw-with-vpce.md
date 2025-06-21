+++
title = "How to chain private APIGWs and VPC endpoints"
date = "2025-06-19"
updated = "2025-06-19"
draft = true

[taxonomies]
tags = ["aws", "api-gateway", "vpc-endpoint"]
+++

At $WORK, I had the joy/pain of implementing the following architecture:

```text
VPC endpoint A -> Private APIGW A -> NLB A -> EKS A -> VPC endpoint B -> Private APIGW B ->
NLB B -> EKS B
```

Requests come in on VPCE A and flow through a private REST APIGW to a microservice[^1]
hosted in VPC A. The service processes the request and forwards it to
a different microservice hosted in VPC B.

The creation of resources was straightforward with Terraform and requests were
being correctly routed to the first microservice. However, I found that requests
to the second downstream microservice were throwing 5XX errors when they arrive at APIGW B.

Naturally, I tried calling microservice B directly from a temporary pod in EKS
A. This worked fine and see could see the requests being logged in microservice
B, which ruled out any networking or AWS configuration issues between EKS A and EKS B.

## The solution

When requests enter a VPC endpoint and AWS API gateway, AWS adds various `amz-*`
and `x-apigw-*` headers to it. These headers contain metadata that API Gateway
uses to process the request. When we chain multiple API gateways in a request
flow, the headers that already exist from the upstream resources causes errors
in the downstream resources.

Its difficult to know which of these AWS headers are important as I couldn't
find any documentation on them. Our solution was to strip any `amz-*` headers
when microservice A forwards the request to microservice B. This allowed AWS to
properly add its custom headers and API gateway was able to process all
downstream requests successfully.

[^1]: via [NLB private integration](https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-nlb-for-vpclink-using-console.html)
