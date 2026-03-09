+++
title = "Application Catalog Manager Guide"
linktitle = "Managing ApplicationDefinitions via ApplicationCatalog"
date =  2026-02-09T12:00:00+00:00
weight = 2
+++

# Application Catalog Manager Guide

## Overview

The Application Catalog Manager is a *new* feature that allows KKP administrators to manage application definitions dynamically through Kubernetes custom resources.
This replaces the previous approach where application definitions were embedded in the KKP binary.

{{% notice note %}}
This feature is in beta in KKP 2.30.
As it continues to evolve, you may encounter breaking changes in future releases.
{{% /notice %}}

The main key benefits of the new manager are as follows:

- Update applications without upgrading KKP
- Add custom applications from any Helm repository
- Customize default applications that are shipped with KKP



## How It Works

The Application Catalog Manager uses a custom resource called `ApplicationCatalog`.
When you create or modify an `ApplicationCatalog`, the controllers automatically create or update the corresponding `ApplicationDefinition` resources.

## Enabling the Feature

To enable the Application Catalog Manager, add the feature gate to your `KubermaticConfiguration`:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  featureGates:
    ExternalApplicationCatalogManager: true
```

When enabled, KKP automatically:
- Deploys the `application-catalog-manager` and webhook components
- Creates a default `ApplicationCatalog` named `default-catalog`
- Begins managing `ApplicationDefinition` resources
- Prevents old logic to interfere the ownership of ApplicationDefinitions

## Creating Application Catalogs

### Basic Catalog Structure

```yaml
apiVersion: applicationcatalog.k8c.io/v1alpha1
kind: ApplicationCatalog
metadata:
  name: my-catalog
spec:
  helm:
    charts:
      - chartName: "nginx-ingress"
        metadata:
          displayName: "NGINX Ingress Controller"
          description: "Ingress controller for Kubernetes"
          documentationURL: "https://kubernetes.github.io/ingress-nginx/"
          sourceURL: "https://github.com/kubernetes/ingress-nginx"
        defaultValuesBlock: |
          controller:
            service:
              type: LoadBalancer
        chartVersions:
          - chartVersion: "4.9.1"
            appVersion: "1.9.1"
          - chartVersion: "4.12.2"
            appVersion: "1.10.0"
```

### Custom Repository Configuration

You can specify a default Helm repository for all charts in a catalog:

```yaml
apiVersion: applicationcatalog.k8c.io/v1alpha1
kind: ApplicationCatalog
metadata:
  name: custom-repo-catalog
spec:
  helm:
    repositorySettings:
      baseURL: "oci://quay.io/kubermatic-mirror/helm-charts"
      credentials:
        registryConfigFile:
          secretName: helm-registry-secret
          key: .dockerconfigjson
    charts:
      - chartName: "my-app"
        chartVersions:
          - chartVersion: "1.0.0"
            appVersion: "1.0.0"
```

### Per-Chart Repository Override

Override the repository for a specific chart:

```yaml
apiVersion: applicationcatalog.k8c.io/v1alpha1
kind: ApplicationCatalog
metadata:
  name: mixed-repo-catalog
spec:
  helm:
    repositorySettings:
      baseURL: "oci://quay.io/kubermatic-mirror/helm-charts"

    charts:
      - chartName: "nginx-ingress"
        repositorySettings:
          baseURL: "https://charts.bitnami.com/bitnami"
        chartVersions:
          - chartVersion: "4.9.1"
            appVersion: "1.9.1"
```

### Per-Version Repository Override

Override the repository for a specific chart version:

```yaml
apiVersion: applicationcatalog.k8c.io/v1alpha1
kind: ApplicationCatalog
metadata:
  name: version-specific-catalog
spec:
  helm:
    charts:
      - chartName: "nginx-ingress"
        chartVersions:
          - chartVersion: "4.9.1"
            repositorySettings:
              baseURL: "oci://internal-mirror/nginx-ingress"
          - chartVersion: "4.12.2"
```

## URL Resolution Order

The system resolves Helm chart URLs in this order (first match wins):

1. Version-level: `charts[].chartVersions[].repositorySettings.baseURL`
2. Chart-level: `charts[].repositorySettings.baseURL`
3. Catalog-level: `helm.repositorySettings.baseURL`
4. Default: `oci://quay.io/kubermatic-mirror/helm-charts/{chartName}`

This allows you to use a default repository while overriding specific charts or versions to use internal mirrors.

## Authentication

This section explains how to configure credentials for accessing private Helm repositories or OCI registries.

### OCI Registry Authentication

For OCI registries (like quay.io, ghcr.io, or internal registries):

```yaml
apiVersion: applicationcatalog.k8c.io/v1alpha1
kind: ApplicationCatalog
metadata:
  name: my-catalog
spec:
  helm:
    repositorySettings:
      baseURL: "oci://quay.io/kubermatic-mirror/helm-charts"
      credentials:
        registryConfigFile:
          secretName: oci-credentials
          key: .dockerconfigjson
    charts:
      - chartName: "my-app"
        chartVersions:
          - chartVersion: "1.0.0"
            appVersion: "1.0.0"
```

Create the secret:
```bash
kubectl create secret generic oci-credentials \
  --from-file=.dockerconfigjson=path/to/config.json \
  -n kubermatic
```

### HTTP/HTTPS Repository Authentication

For traditional Helm chart repositories over HTTP/HTTPS:

```yaml
apiVersion: applicationcatalog.k8c.io/v1alpha1
kind: ApplicationCatalog
metadata:
  name: my-catalog
spec:
  helm:
    repositorySettings:
      baseURL: "https://charts.internal.example.com"
      credentials:
        username:
          secretName: helm-credentials
          key: username
        password:
          secretName: helm-credentials
          key: password
    charts:
      - chartName: "my-app"
        chartVersions:
          - chartVersion: "1.0.0"
            appVersion: "1.0.0"
```

Create the secret:
```bash
kubectl create secret generic helm-credentials \
  --from-literal username=myuser \
  --from-literal password=mypassword \
  -n kubermatic
```

## Available Applications

KKP includes the following enterprise applications by default:

| Application | Description |
|------------|-------------|
| argocd | GitOps continuous delivery tool |
| cert-manager | Certificate management |
| falco | Runtime security |
| flux2 | GitOps operator |
| k8sgpt-operator | AI-powered Kubernetes assistant |
| kube-vip | Virtual IP management |
| kubevirt | Virtualization platform |
| local-ai | Local AI inference |
| metallb | Load balancer for bare-metal |
| mcp-server-kubernetes | Model Context Protocol server |
| nvidia-gpu-operator | GPU management |
| nginx-ingress | Ingress controller |
| trivy | Vulnerability scanner |
| trivy-operator | Security scanner |
| kueue | Job queue management |

## Customizing Default Applications

In air-gapped environments or when you need to use custom Helm registries, you can override the default application definitions by modifying the `default-catalog` ApplicationCatalog.

### Adding Custom Applications to the Default Catalog

You can add custom applications alongside the default KKP applications:

```yaml
apiVersion: applicationcatalog.k8c.io/v1alpha1
kind: ApplicationCatalog
metadata:
  name: default-catalog
  namespace: kubermatic
spec:
  helm:
    includeDefaults: true
    # Add custom charts here
    charts:
      - chartName: "my-custom-app"
        metadata:
          displayName: "My Custom Application"
          description: "Internal application for our team"
        chartVersions:
          - chartVersion: "1.0.0"
            appVersion: "1.0.0"
```

When `includeDefaults: true`, the webhook merges the default KKP applications with your custom charts.

### Overriding Default Application Repositories

To use a different Helm registry for default applications (e.g., for air-gapped environments), create a custom catalog that references the same application names with different repository settings:

```yaml
apiVersion: applicationcatalog.k8c.io/v1alpha1
kind: ApplicationCatalog
metadata:
  name: air-gapped-catalog
  namespace: kubermatic
spec:
  helm:
    repositorySettings:
      baseURL: "https://internal-registry.example.com/charts"
    charts:
      - chartName: "cert-manager"
        chartVersions:
          - chartVersion: "1.13.0"
            appVersion: "1.13.0"
      - chartName: "nginx-ingress"
        chartVersions:
          - chartVersion: "4.9.1"
            appVersion: "1.9.1"
```

Alternatively, you can modify the `default-catalog` directly by adding a `repositorySettings` block:

```yaml
apiVersion: applicationcatalog.k8c.io/v1alpha1
kind: ApplicationCatalog
metadata:
  name: default-catalog
  namespace: kubermatic
spec:
  helm:
    includeDefaults: true
    repositorySettings:
      baseURL: "https://internal-registry.example.com/charts"
      credentials:
        username:
          secretName: internal-registry-creds
          key: username
        password:
          secretName: internal-registry-creds
          key: password
```

When you set `spec.helm.repositorySettings.baseURL`, that URL applies to all charts in the catalog. However, you can override this URL for specific charts or versions. For example, if most of your charts are in an internal registry but one chart needs to come from a different location:

```yaml
apiVersion: applicationcatalog.k8c.io/v1alpha1
kind: ApplicationCatalog
metadata:
  name: default-catalog
  namespace: kubermatic
spec:
  helm:
    includeDefaults: true
    # Default repository for most charts
    repositorySettings:
      baseURL: "https://internal-registry.example.com/charts"
    charts:
      # Override repository for this specific chart
      - chartName: "cert-manager"
        repositorySettings:
          baseURL: "https://charts.jetstack.io"
        chartVersions:
          - chartVersion: "1.13.0"
            appVersion: "1.13.0"
      # This chart uses the catalog-level baseURL
      - chartName: "nginx-ingress"
        chartVersions:
          - chartVersion: "4.9.1"
            appVersion: "1.9.1"
```

### URL Resolution for Custom Registries

The system resolves Helm chart URLs in this order:

1. **Version-level**: `charts[].chartVersions[].repositorySettings.baseURL`
2. **Chart-level**: `charts[].repositorySettings.baseURL`
3. **Catalog-level**: `helm.repositorySettings.baseURL`
4. **Default**: `oci://quay.io/kubermatic-mirror/helm-charts/{chartName}`

This allows you to override specific charts or versions to point to internal mirrors while using the default registry for others.

## Multiple Catalogs

Create multiple catalogs for different purposes:

```yaml
apiVersion: applicationcatalog.k8c.io/v1alpha1
kind: ApplicationCatalog
metadata:
  name: internal-tools
  namespace: kubermatic
spec:
  helm:
    repositorySettings:
      baseURL: "https://charts.internal.example.com"
    charts:
      - chartName: "monitoring-stack"
        metadata:
          displayName: "Internal Monitoring Stack"
          description: "Company monitoring tools"
        chartVersions:
          - chartVersion: "2.0.0"
            appVersion: "2.0.0"
```

### Avoiding Duplicate Applications

When using multiple catalogs, keep these considerations in mind:

**Webhook Validation Prevents Duplicates**
- ApplicationDefinition names must be unique across the entire cluster
- The webhook REJECTS any attempt to create a catalog with duplicate application names
- If two catalogs reference the same chart name, the second catalog creation will fail with a clear error message
- The webhook detects both intra-catalog duplicates (same catalog) and inter-catalog conflicts (different catalogs)

**Error Message Example**
```
ApplicationCatalog conflicts detected:
  - ApplicationDefinition "nginx" is already managed by catalog "other-catalog"

To resolve this conflict, either:
  1. Remove the conflicting chart from this catalog
  2. Use a different appName in metadata.appName for the chart
  3. Delete the other catalog or remove the chart from it first
```

## Managed ApplicationDefinitions

ApplicationDefinitions created by the catalog manager are labeled with:
- `applicationcatalog.k8c.io/managed-by: "true"`
- `applicationcatalog.k8c.io/catalog-name: "<catalog-name>"`

These labels help track catalog ownership.

**Note** that when you remove a chart from an ApplicationCatalog or delete the catalog entirely, the controller does NOT automatically delete the corresponding ApplicationDefinition resources.
This is intentional to prevent disruption of running workloads that may be using these applications.

If you need to remove an ApplicationDefinition, you must delete it manually after removing ApplicationDefinition from the catalog or removing labels from it:

```bash
kubectl delete applicationdefinition <definition-name> -n kubermatic
```

> Before deleting an ApplicationDefinition, ensure no running workloads depend on it.

## Modifying Managed ApplicationDefinitions

You can modify certain fields on managed ApplicationDefinitions without the controller overwriting your changes.

## Configuration Options

Customize the Application Catalog Manager through `KubermaticConfiguration`:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
spec:
  applications:
    catalogManager:
      image:
        repository: quay.io/kubermatic/application-catalog-manager
        tag: v0.2.0
      managerSettings:
        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 500Mi
        logLevel: info
        reconciliationInterval: 10m
      webhookSettings:
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            cpu: 200m
            memory: 128Mi
      apps:
        - cert-manager
        - nginx
        - argocd
```

The `apps` field filters which default applications are included in the default catalog

When `apps` is empty or not set, all default applications are included.
When specified, only the listed applications are included.
This is useful when you want to provide a curated subset of default KKP applications to your users.

The `apps` field filters default applications in the default catalog.

## Disabling the Feature

To revert to the embedded catalog approach, remove the feature gate:

```bash
kubectl patch kubermaticconfiguration kubermatic -n kubermatic --type=json -p='[
  {"op": "remove", "path": "/spec/featureGates/ExternalApplicationCatalogManager"}
]'
```

KKP will automatically:
- Delete all `ApplicationCatalog` resources
- Remove the application-catalog-manager and webhook deployments
- Clean up RBAC resources
- Remove catalog ownership labels from ApplicationDefinitions

## Migration Path

When you enable the feature gate:
1. KKP automatically creates the default catalog and migrates ApplicationDefinitions
2. New `applicationcatalog.k8c.io/managed-by` labels are applied
3. Existing user applications continue to work without changes
