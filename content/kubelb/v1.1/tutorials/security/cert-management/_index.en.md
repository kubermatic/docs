+++
title = "Certificate Management"
linkTitle = "Certificate Management"
date = 2023-10-27T10:07:15+02:00
weight = 1
enterprise = true
+++

## Setup

### Install Cert-Manager

Install [cert-manager](https://cert-manager.io) to manage certificates for your tenants.

These are minimal examples to get you started quickly. Please refer to the documentation of [cert-manager](https://cert-manager.io/docs/installation/helm/) for further details and configurations.

{{< tabs name="cert-manager" >}}
{{% tab name="Gateway API" %}}

For Gateway API, the feature gate to use Gateway APIs needs to be enabled:

```bash
helm repo add jetstack https://charts.jetstack.io --force-update
helm upgrade --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.15.2 \
  --set crds.enabled=true \
  --set config.apiVersion="controller.config.cert-manager.io/v1alpha1" \
  --set config.kind="ControllerConfiguration" \
  --set config.enableGatewayAPI=true
```

{{% /tab %}}
{{% tab name="Ingress" %}}

```bash
helm repo add jetstack https://charts.jetstack.io --force-update
helm upgrade --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.15.2 \
  --set crds.enabled=true
```

{{% /tab %}}
{{< /tabs >}}

### Configure Tenant

Certificate management can be enabled/disabled at global or tenant level. For automation purposes, you can configure allowed domains and default issuer for the certificates at the tenant level.

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
  certificates:
    # can also be configured in the `Config` resource at a global level.
    # Default issuer to use if `kubelb.k8c.io/manage-certificates` annotation is added to the cluster.
    defaultClusterIssuer: "letsencrypt-staging"
    # If not empty, only the domains specified here will have automation for Certificates. Everything else will be ignored.
    allowedDomains:
    - "*.shroud.example.com"
```

Users can then either use [cert-manager annotations](https://cert-manager.io/docs/usage/ingress/) or the annotation `kubelb.k8c.io/manage-certificates: true` on their resources to automate certificate management.

### Cluster Issuer example

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: user@example.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: example-issuer-account-key
    # Add a single challenge solver, HTTP01 using nginx
    solvers:
    - http01:
        ingress:
          ingressClassName: nginx
```

The additional validation at the tenant level allows us to use a single instance of cert-manager for multiple tenants. Multiple cert-manager installations are not recommended and it's better to have a single instance of cert-manager for all tenants but different ClusterIssuers/Issuers for different tenants, if required.

## Usage

In tenant cluster, create the following resources. Based on your requirements:

1. Use cert-manager with known issuer:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: example
  annotations:
    cert-manager.io/issuer: foo
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
      tls:
        mode: Terminate
        certificateRefs:
          - name: example-com-tls
```

2. Leave the issuer up to the management cluster:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: example
  annotations:
    kubelb.k8c.io/manage-certificates: true
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
      tls:
        mode: Terminate
        certificateRefs:
          - name: example-com-tls
```

3. Use custom certificates:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: example
  namespace: default
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
      tls:
        mode: Terminate
        certificateRefs:
          - name: custom-certificate
---
kind: SyncSecret
apiVersion: kubelb.k8c.io/v1alpha1
data:
  tls.crt: ZnJhbmtsYW1wYXJkCg==
  tls.key: ZnJhbmtsYW1wYXJkCg==
metadata:
  annotations:
  name: custom-certificate
  namespace: default
type: kubernetes.io/tls
---
```

This will then sync the secret to the management cluster in a secure way. Refer to [Bring your own Certificates]({{< relref "../secrets" >}}) for more details.

**For more use cases, view [cert-manager documentation](https://cert-manager.io/docs/usage/gateway/)**
