+++
title = "Compatibility Matrix"
date = 2024-03-15T00:00:00+01:00
description = "Tested version combinations of KubeLB, KKP, Gateway API, Envoy Gateway, NGINX Ingress, and Kubernetes."
weight = 10
+++

Currently, we don't have any hard dependencies on certain components and their versions. This matrix is here to reflect any changes in the compatibility matrix of the components we are using.

We are only testing our software with specific versions of the components, we are not enforcing these versions but these are the ones tested. It should work with other versions of Kubernetes, Gateway API, and Envoy Gateway as well, but we can't guarantee it.

**KubeLB support [ingress-nginx](https://kubernetes.github.io/ingress-nginx/) for Ingress resources. [Envoy Gateway](https://gateway.envoyproxy.io/) is supported for Gateway API resources. While other products might work for Ingress and Gateway API resources, we are not testing them and can't guarantee the compatibility.**

| KubeLB | Kubermatic Kubernetes Platform | Gateway API | Envoy Gateway | NGINX Ingress | Kubernetes |
|--------|-------------------------------|-------------|---------------|-------------------------|------------|
| v1.4   | v2.29, v2.30               | v1.6.x      | v1.8.x       | v1.10.0+                  | v1.27+     |
| v1.3   | v2.27, v2.28, v2.29, v2.30               | v1.4.0+      | v1.5.0+       | v1.10.0+                  | v1.27+     |
| v1.2   | v2.27, v2.28, v2.29                | v1.3.0      | v1.3.0+       | v1.10.0+                  | v1.27+     |

The Kubernetes version requirement is informational; the KubeLB Helm charts do not enforce a `kubeVersion` constraint.

## Support Policy

For the support policy, see the [KubeLB Support Policy](../support-policy/)
