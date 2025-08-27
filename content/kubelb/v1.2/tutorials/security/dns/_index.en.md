+++
title = "DNS Management"
linkTitle = "DNS Management"
date = 2023-10-27T10:07:15+02:00
weight = 1
enterprise = true
+++

## Setup

### Install External-dns

We leverage [External-dns](https://bitnami.com/stack/external-dns/helm) to manage DNS records for the tenant clusters.

**This is just an example to give you a headstart. For more details on setting up external-dns for different providers, visit [Official Documentation](https://kubernetes-sigs.github.io/external-dns).**

Update the values.yaml for KubeLB manager chart to enable the external-dns addon.

```yaml
kubelb-addons:
  enabled: true

  external-dns:
    enabled: true
    domainFilters:
      - example.com
    extraVolumes:
      - name: credentials
        secret:
          secretName: route53-credentials
    extraVolumeMounts:
      - name: credentials
        mountPath: /.aws
        readOnly: true
    env:
      - name: AWS_SHARED_CREDENTIALS_FILE
        value: /.aws/credentials
    txtOwnerId: kubelb-example-aws
    registry: txt
    provider: aws
    policy: sync
    sources:
      - service
      - ingress
      # Comment out the below resources if you are not using Gateway API.
      - gateway-httproute
      - gateway-grpcroute
      - gateway-tlsroute
      - gateway-tcproute
      - gateway-udproute
```

#### Credentials secret

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: external-dns
---
apiVersion: v1
data:
  credentials: W2RlZmF1bHRdCmF3c19hY2Nlc3Nfa2V5X2lkID0gTk9UVEhBVERVTUIKYXdzX3NlY3JldF9hY2Nlc3Nfa2V5ID0gTUFZQkVJVFNBU0VDUkVU
kind: Secret
metadata:
  name: route53-credentials
  namespace: external-dns
type: Opaque
```

### Enable DNS automation

DNS can be enabled/disabled at global or tenant level. For automation purposes, you can configure allowed domains for DNS per tenant.

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
    # The wildcard domain to use for auto-generated hostnames for Load balancers
    # In EE Edition, this is also use to generated dynamic hostnames for tunnels.
    wildcardDomain: "*.apps.example.com"
    # Allow tenants to specify explicit hostnames for Load balancers and tunnels(in EE Edition)
    allowExplicitHostnames: false
```

Users can then either use [external-dns annotations](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/annotations/annotations.md) or the annotation `kubelb.k8c.io/manage-dns: true` on their resources to automate DNS management.

The additional validation at the tenant level allows us to use a single instance of external-dns for multiple tenants. Although, if required, external-dns can be installed per tenant as well.

## Usage

1. Using external-dns annotations:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: example
  annotations:
    external-dns.alpha.kubernetes.io/hostname: example.com
spec:
  gatewayClassName: kubelb
  listeners:
    - name: http
      hostname: example.com
      port: 443
      protocol: HTTPS
      allowedRoutes:
        namespaces:
          from: All
```

2. Delegate DNS management to KubeLB:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: example
  annotations:
    kubelb.k8c.io/manage-dns: true
spec:
  gatewayClassName: kubelb
  listeners:
    - name: http
      hostname: example.com
      port: 443
      protocol: HTTPS
      allowedRoutes:
        namespaces:
          from: All
```

3. Services can also be annotated to manage DNS:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend
  annotations:
    external-dns.alpha.kubernetes.io/hostname: backend.example.com
spec:
  ports:
    - name: http
      port: 3000
      targetPort: 3000
  selector:
    app: backend
  type: LoadBalancer
```
