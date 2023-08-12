---
title: "cloudresumechallenge"
date: 2022-07-01T09:55:25+08:00
lastmod:
weight: 2
draft: true
repo_url: https://github.com/kencx/cloudresumechallenge
post_url:
tools:
- AWS
- Terraform
- Python
- Github Actions
---

A simple static site hosting a resume and visitor counter. It is hosted entirely
on AWS and built with AWS services, including DynamoDB, AWS Lambda and API
Gateway. All cloud services are entirely managed with Terraform. The Lambda code
is written in Python and code changes are automatically deployed with Github
Actions.

This project is inspired entirely by
[cloudresumechallenge](https://cloudresumechallenge.dev/) and was a great
learning experience for working with cloud services and DevOps concepts
including IaC and CI/CD. More details on the experience can be found in the
Github repo.
