---
title: "CloudFront VPC Origins and Websockets"
date: 2025-03-02
lastmod: 2025-03-02
draft: false
toc: false
---

CloudFront's [VPC
Origins](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-vpc-origins.html)
do not work with the WebSockets protocol (yet).

Although CloudFront [natively supports](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-working-with.websockets.html) WebSockets, trying to establish a WebSocket connection with an internal ALB via a VPC Origin causes a WebSockets connection error with a 502.

Taking a look at the CloudFront logs, we see an unexpected message:

```json
{
    ...
    "x-edge-detailed-result-type": "OriginDnsError",
    ...
}
```

Wait... what, a DNS error? Turns out I'm [not the only
one](https://repost.aws/questions/QU9RNe5fD_SsK7UIGGG26yOA/origindnserror-from-cloudfront-vpc-origin-when-websocket-is-used)
facing this issue.

## Are you sure?

For context, this is the architecture that I setup:

```
CloudFront --via VPC origin--> internal ALB -> App
```

To eliminate all other factors, here's what works:

```
# direct connection
Public ALB -> App

# with ALB target type in the NLB target groups
Public NLB -> internal ALB -> App

# with exact same caching and behaviour configuration as the above VPC origin
CloudFront --via custom origin--> public ALB -> App
```

## My Solution

The solution for me was to recreate the internal ALB as a public-facing one, and
switching the VPC origin for a custom origin.

Finally, to secure the now public-facing ALB so that only CloudFront can access
it, use the [AWS-managed CloudFront prefix list](https://aws.amazon.com/about-aws/whats-new/2022/02/amazon-cloudfront-managed-prefix-list/) in the ALB's security group rules.
