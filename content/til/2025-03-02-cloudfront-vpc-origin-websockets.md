---
title: "CloudFront VPC Origins and Websockets"
date: 2025-03-02
lastmod: 2025-06-11
draft: false
toc: false
tags:
- aws
- alb
- cloudfront
- websockets
---

As of Mar 2025, CloudFront's new [VPC
Origins](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-vpc-origins.html)
does not work with the WebSockets protocol.

Although AWS claims that CloudFront [natively
supports](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-working-with.websockets.html)
WebSockets, trying to establish a WebSocket connection with an internal ALB via
a VPC Origin causes a WebSockets connection error with a 502 status code.

```text
# the architecture in question
CloudFront --via VPC origin--> internal ALB -> App
```

Taking a look at the CloudFront logs, we see an unexpected message:

```json
{
    "x-edge-detailed-result-type": "OriginDnsError"
}
```

Wait... what, a DNS error? That can't be right... right? Well, it turns out that
[this issue has already been
reported](https://repost.aws/questions/QU9RNe5fD_SsK7UIGGG26yOA/origindnserror-from-cloudfront-vpc-origin-when-websocket-is-used).

## Are you sure?

To eliminate potential issues with the application, I also tested other setups.
These are working as expected:

```text
# direct connection
Public ALB -> App

# with ALB target type in the NLB target groups
Public NLB -> internal ALB -> App

# with exact same caching and behaviour configuration as the above VPC origin
CloudFront --via custom origin--> public ALB -> App
```

## Why is this happening?

I have no idea as I don't have any understanding on how VPC origins work with
the WebSockets protocol.

## The workaround

The workaround is to switch back to a custom origin and a public-facing ALB:
```text

CloudFront --via custom origin--> public ALB -> App
```

To secure the public ALB, AWS also recommends using its [managed CloudFront
prefix
list](https://aws.amazon.com/about-aws/whats-new/2022/02/amazon-cloudfront-managed-prefix-list/).
