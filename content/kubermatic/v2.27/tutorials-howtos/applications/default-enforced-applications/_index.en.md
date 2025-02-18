+++
title = "Default & Enforced Applications"
date =  2022-08-03T16:43:41+02:00
weight = 5
+++

This guide targets KKP Admins and explains how to configure default and enforced applications.

## Default Applications

Default applications are applications that are automatically installed in all new clusters. Users can disable, update, and delete the default applications, during and after cluster creation. Due to this KKP will only install the default applications in new clusters but won't update them.

```yaml
apiVersion: apps.kubermatic.k8c.io/v1
kind: ApplicationDefinition
metadata:
  name: apache
spec:
  description: Apache HTTP Server is an open-source HTTP server for modern operating systems
  method: helm
  default: true
  versions:
    - template:
        source:
          helm:
            chartName: apache
            chartVersion: 9.2.9
            url: https://charts.bitnami.com/bitnami
      version: 9.2.9
    - template:
        source:
          git:
            path: bitnami/apache
            ref:
              branch: main
            remote: https://github.com/bitnami/charts.git
      version: 2.4.55-git
```

## Enforced Applications

Enforced applications are applications that are automatically installed and updated, when the application definition is updated, for all the clusters; existing and new ones.

```yaml
apiVersion: apps.kubermatic.k8c.io/v1
kind: ApplicationDefinition
metadata:
  name: apache
spec:
  description: Apache HTTP Server is an open-source HTTP server for modern operating systems
  method: helm
  enforced: true
  versions:
    - template:
        source:
          helm:
            chartName: apache
            chartVersion: 9.2.9
            url: https://charts.bitnami.com/bitnami
      version: 9.2.9
    - template:
        source:
          git:
            path: bitnami/apache
            ref:
              branch: main
            remote: https://github.com/bitnami/charts.git
      version: 2.4.55-git
```

## Usage guidelines

### Selector

The scope of enforcement and defaulting can be configured with a selector. If the selector is not set, the application will be enforced and defaulted for all clusters.

```yaml
apiVersion: apps.kubermatic.k8c.io/v1
kind: ApplicationDefinition
metadata:
  name: apache
spec:
  description: Apache HTTP Server is an open-source HTTP server for modern operating systems
  method: helm
  enforced: true
  selector:
    datacenters:
    - datacenter-1
  versions:
    - template:
        source:
          helm:
            chartName: apache
            chartVersion: 9.2.9
            url: https://charts.bitnami.com/bitnami
      version: 9.2.9
    - template:
        source:
          git:
            path: bitnami/apache
            ref:
              branch: main
            remote: https://github.com/bitnami/charts.git
      version: 2.4.55-git
```

### Versioning

If `defaultVersion` is specified in the `ApplicationDefinition`, it will be used as the default version for the application. If it is not specified, the highest semver version will be used.

### Configuring default and enforced applications

Applications can be be marked as default and enforced from the admin panel in KKP UI as well as from the APIs directly. For more details refer to the [Applications]({{< ref "../../administration/admin-panel/applications/" >}}) section.
