+++
title = "That APIGW can intercept Authorization header values"
date = "2025-06-18"
updated = "2025-06-18"

[taxonomies]
tags = ["aws", "api-gateway", "vpc-endpoint"]
+++

VPC endpoint policies can be used to restrict access to a private API gateway.
When a VPC endpoint policy is configured, API gateway intercepts the
`Authorization` header value to evaluate the identity of the request's invoker.

This can cause errors when your applications behind the API gateway expect to
receive the same `Authorization` header. Any requests to the API gateway via the
VPC endpoint will return a `403 IncompleteSignatureException` or `403
InvalidSignatureException` error as API gateway thinks it received an invalid
`Authorization` header value, even when no custom authorizer is configured.

## Debugging the Error

When I first encountered this error, I assumed it was an issue with the [APIGW
resource
policy](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-resource-policies-examples.html). So I set the resource policy to the default allow `*`. That didn't work. Next, googling the error message landed me on [this troubleshooting
page](https://repost.aws/knowledge-center/api-gateway-troubleshoot-403-forbidden), which was not very useful.

According to the page's table, the two errors I encountered either means the
request's auth token expired or the request's signature is invalid, which is
baffling since I didn't configure any form of authorization on the APIGW.

## The solution

Annoyingly, the solution is found in the [VPC endpoint policy
section](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-vpc-endpoint-policies.html).
With a non-default VPC endpoint policy, APIGW will always evaluate the
`Authorization` header, even when there's no custom authorizer configured to
process it.

There are two cases where the header is NOT evaluated by APIGW:

1. `NONE` authorizationType with a default full access (VPC endpoint) policy
2. `CUSTOM` (Lambda authorizer) or `COGNITO_USER_POOLS` authorizationType

Alternatively, another solution would be to use a different header for
authorization in your application, something less universal, so it won't be
evaluated by APIGW.

## References

- [AWS - Use VPC endpoint policies for private APIs in API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-vpc-endpoint-policies.html)
