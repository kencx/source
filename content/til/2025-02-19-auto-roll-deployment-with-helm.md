---
title: "Automatically roll deployment With Helm"
date: 2025-02-19
lastmod: 2025-02-19
draft: false
toc: false
tags:
- helm
- kubernetes
---

To automatically roll a Kubernetes deployment with Helm, use the
`sha256sum` function with the `checksum/config` annotation:

```yml
kind: Deployment
spec:
  template:
    metadata:
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
[...]
```

## References
- [Helm - Charts Tips and Tricks](https://helm.sh/docs/howto/charts_tips_and_tricks/#automatically-roll-deployments)
