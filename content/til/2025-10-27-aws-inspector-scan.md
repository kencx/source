+++
title = "How to initiate an on-demand AWS Inspector scan"
date = "2025-10-27"
updated = "2025-10-27"

[taxonomies]
tags = ["aws", "inspector", "ec2"]
+++

Inspector scans run every 6 hours by default. We can also choose to initiate an
Inspector scan on-demand:

1. Navigate to State Manager.
2. Look for the association `InvokeInspectorLinuxSsmPlugin-do-not-delete`. This
   association should have been automatically created by Inspector.
3. Re-apply the association to initiate a new scan.

## References

- [Scanning Amazon EC2 instances with Amazon Inspector](https://docs.aws.amazon.com/inspector/latest/user/scanning-ec2.html)
- [Why isn't Amazon Inspector scanning my Amazon EC2 instances](https://repost.aws/knowledge-center/amazon-inspector-ec2-scanning)
- [Scanning Windows EC2 instances with Amazon Inspector](https://docs.aws.amazon.com/inspector/latest/user/windows-scanning.html)
