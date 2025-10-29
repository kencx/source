+++
title = "About scanning Windows EC2 instances with AWS Inspector"
date = "2025-10-28"
updated = "2025-10-28"

[taxonomies]
tags = ["aws", "inspector", "windows", "ec2"]
+++

Inspector scans on Windows instances will fail if the instance does not have
access to the S3 bucket `inspector2-oval-prod-<aws-region>`.

The S3 bucket can be accessed via Regional S3 endpoints or a S3 Gateway endpoint
in air-gapped VPCs. Additionally, the instance's security group must allow
outgoing access on port 443.

## References

- [Why isn't Amazon Inspector scanning my Amazon EC2 instances](https://repost.aws/knowledge-center/amazon-inspector-ec2-scanning)
- [Scanning Windows EC2 instances with Amazon Inspector](https://docs.aws.amazon.com/inspector/latest/user/windows-scanning.html)
