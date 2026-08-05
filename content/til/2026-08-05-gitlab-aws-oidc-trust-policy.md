+++
title = "How to limit authorization via OIDC condition context keys in AWS IAM trust policies"
date = "2026-08-05"
updated = "2026-08-05"

[taxonomies]
tags = [
    "aws",
    "ci/cd",
    "gitlab",
    "iam",
    "oidc",
]
+++

When assuming AWS IAM roles from a GitLab CI/CD job using OIDC, it is possible
limit authorization to a specific group, project, branch or tag using additional
condition context keys in the role's trust policy.

{% alert(type="Note") %}
This assumes you have setup GitLab as an IAM OIDC identity provider in AWS.
{% end %}

On GitLab.com, AWS supports [many different condition
keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_iam-condition-keys.html#condition-keys-wif)
that can be used to restrict the role to jobs in specific pipeline sources and
environments. However, on a self-managed GitLab instance (which I use), AWS only
supports `sub`, which can only limit the group, project and branch name.

For example, on a self-managed GitLab instance, the following condition supports
CI/CD jobs in all branches, including merge request pipelines.

```json
"Condition": {
  "StringEquals": {
    "<hostname>:aud": "https://<hostname>"
  },
  "StringLike": {
    "<hostname>:sub": "project_path:<group>/<project>:ref_type:branch:ref:*"
  }
}
```

## References
- [GitLab - Configure OpenID Connect in AWS to retrieve temporary credentials](https://docs.gitlab.com/ci/cloud_services/aws/)
