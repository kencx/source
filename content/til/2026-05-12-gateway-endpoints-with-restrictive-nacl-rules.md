+++
title = "That AWS Gateway endpoints don't play nice with restrictive NACL rules"
date = "2026-05-12"
updated = 2026-05-14

[taxonomies]
tags = ["aws", "s3", "networking", "vpc-endpoint"]
+++

Gateway endpoints provide an alternative method of privately connecting to S3 and DynamoDB
without an internet gateway or NAT, free of charge.

However, if your NACL rules are somewhat restrictive, i.e. they do not contain
the following:

- ingress allow port 1024-65535 from `0.0.0.0/0`
- egress allow port 443 to `0.0.0.0/0`

then using gateway endpoints can be a pain, since NACLs don't support prefix
lists. Paired with the [default
limit](https://docs.aws.amazon.com/vpc/latest/userguide/amazon-vpc-limits.html#vpc-limits-nacls)
of 20 rules per NACL, and the possible network performance impact when this
quota is increased, it might not be worth it to add all the prefix list IPs to
the NACL.

In these cases, I find it simpler to just use an [interface VPC
endpoint](https://docs.aws.amazon.com/vpc/latest/privatelink/privatelink-access-aws-services.html)
and call it a day.

## References
- [AWS - Gateway endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html)
