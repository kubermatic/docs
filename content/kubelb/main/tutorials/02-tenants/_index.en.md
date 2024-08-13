+++
title = "Tenants"
linkTitle = "2. Tenants"
date = 2023-10-27T10:07:15+02:00
weight = 2
+++

## Kubermatic Kubernetes Platform (Enterprise Edition Only)

Starting with KKP v2.24, KubeLB Enterprise Edition is integrated into the Kubermatic Kubernetes Platform (KKP). KKP will automatically register the new user cluster as a tenant in the LB cluster thus the steps provided below are not required for tenants that are using KKP.

{{% notice note %}}
To use KubeLB enterprise offering, you need to have a valid license. Please [contact sales](mailto:sales@kubermatic.com) for more information.
{{% /notice %}}

## Usage

For usage outside of KKP please follow the guide along. This guide assumes that the KubeLB manager cluster has been configured by following the [installation guide](../../installation/).

### KubeLB Manager configuration

With KubeLB v1.1, the process to register a new tenant has been simplified. Instead of running scripts to register a new tenant, the user can now create a `Tenant` CRD.

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: shroud
spec:
  propagatedAnnotations:
    # Allow specific value
    service.beta.kubernetes.io/aws-load-balancer-type: "external"
    # Allow all values
    service.beta.kubernetes.io/aws-load-balancer-ip-address-type: ""
  # Propagate all annotations to the resources.
  propagateAllAnnotations: false
  loadBalancer:
    class: "metallb.universe.tf/metallb"
    disable: false
    limit: 10
  ingress:
    class: "nginx"
    disable: false
  gatewayAPI:
    class: "metallb.universe.tf/metallb"
    disable: false
    gateway:
      limits: 10
    disableHTTPRoute: false
    disableGRPCRoute: false
    disableTCPRoute: false
    disableUDPRoute: false
    disableTLSRoute: false
  dns:
    disable: false
    allowedDomains:
      - "*.example.com"
  certificates:
    disable: false
    defaultClusterIssuer: "letsencrypt-prod"
    allowedDomains:
      - "*.example.com"
  allowedDomains:
    - "*.example.com"
```

### KubeLB CCM configuration

For CCM, during installation we need to provide the `kubeconfig` that we generated in the previous step. Also, the `tenantName` field in the values.yaml should be set to the name of the tenant cluster.
