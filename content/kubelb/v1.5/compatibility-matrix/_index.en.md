+++
title = "Compatibility Matrix"
date = 2024-03-15T00:00:00+01:00
description = "Tested version combinations of KubeLB, KKP, Gateway API, Envoy Gateway, NGINX Ingress, and Kubernetes."
weight = 10
+++

This matrix lists the component versions that Kubermatic tests together. Listed combinations are covered by compatibility testing; versions outside the matrix may work, but Kubermatic does not make compatibility claims for them.

KubeLB supports [ingress-nginx](https://kubernetes.github.io/ingress-nginx/) for Ingress resources and [Envoy Gateway](https://gateway.envoyproxy.io/) for Gateway API resources. Other implementations may work through standard Kubernetes APIs, but they are not part of the tested compatibility matrix.

| KubeLB | Kubermatic Kubernetes Platform | Gateway API | Envoy Gateway | NGINX Ingress | Kubernetes |
|--------|-------------------------------|-------------|---------------|-------------------------|------------|
| v1.5   | v2.29, v2.30, v2.31               | v1.6.x      | v1.8.x       | v1.10.0+                  | v1.27+     |
| v1.4   | v2.29, v2.30               | v1.6.x      | v1.8.x       | v1.10.0+                  | v1.27+     |
| v1.3   | v2.27, v2.28, v2.29, v2.30               | v1.4.0+      | v1.5.0+       | v1.10.0+                  | v1.27+     |

The Kubernetes version column records the versions covered by testing. KubeLB Helm charts do not enforce a `kubeVersion` constraint.

## Support Policy

See the [KubeLB Support Policy]({{< relref "../support-policy/" >}}) for the scope of Enterprise Edition support.
