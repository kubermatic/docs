+++
title = "DNS Management"
linkTitle = "DNS Management"
date = 2023-10-27T10:07:15+02:00
weight = 1
enterprise = true
+++

## Setup

Install [External-dns](https://bitnami.com/stack/external-dns/helm) to manage DNS records for the tenant clusters. DNS can be enabled/disabled at global or tenant level. For automation purposes, you can configure allowed domains for DNS per tenant.

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: shroud
spec:
  # These domains are allowed to be used for Ingress, Gateway API, DNS, and certs.
  allowedDomains:
    - "kube.example.com"
    - "*.kube.example.com"
    - "*.shroud.example.com"
  dns:
    # If not empty, only the domains specified here will have automation for DNS. Everything else will be ignored.
    allowedDomains:
    - "*.shroud.example.com"
```

Users can then either use [external-dns annotations](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/annotations/annotations.md) or the annotation `kubelb.k8c.io/manage-dns: true` on their resources to automate DNS management.

The additional validation at the tenant level allows us to use a single instance of external-dns for multiple tenants. Although, if required, external-dns can be installed per tenant as well.
