+++
title = "How to manually mount the Kubernetes service account token"
date = "2025-08-30"
updated = "2025-08-30"

[taxonomies]
tags = ["helm", "kubernetes"]
+++

By default, Kubernetes automatically injects credentials for the `default`
ServiceAccount into the pod. This token is used by applications running in the
pods to authenticate to the Kubernetes API server.

To disable this behaviour, set the following in the
pod spec:

```yml
apiVersion: v1
kind: Pod
metadata:
  name: foo-pod
spec:
  serviceAccountName: foo-sa
  automountServiceAccountToken: false
```

or in the specific serviceaccount manifest:

```yml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: foo-sa
automountServiceAccountToken: false
```

If the application requires access to the API server, we can choose to manually
(and safely) mount the token as read-only with [token volume
projection](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#serviceaccount-token-volume-projection):

```yml
apiVersion: v1
kind: Pod
metadata:
  name: foo-pod
spec:
  containers:
    - name: foo
      ...
      volumeMounts:
        - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
          name: serviceaccount-token
          readOnly: true
  volumes:
    - name: serviceaccount-token
    projected:
      defaultMode: 0444
      sources:
        - serviceAccountToken:
            expirationSeconds: 3607
            path: token
        - configMap:
            name: kube-root-ca.crt
            items:
              - key: ca.crt
                path: ca.crt
        - downwardAPI:
            items:
              - path: namespace
                fieldRef:
                apiVersion: v1
                fieldPath: metadata.namespace
```

## References
- [Kubernetes - Service Accounts](https://kubernetes.io/docs/concepts/security/service-accounts/#get-a-token)
- [Kubernetes clusters should disable automounting API credentials](https://github.com/kubernetes/ingress-nginx/issues/9735)
- [Restrict Auto-Mount of Service Account Tokens](https://cert-manager.io/docs/installation/best-practice/#restrict-auto-mount-of-service-account-tokens)
