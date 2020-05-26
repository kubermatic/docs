+++
title = "Upgrading from 2.7 to 2.8"
date = 2018-10-23T12:07:15+02:00
weight = 20

+++

After modifying the `values.yaml` files according to the information below, you merely need to re-apply helm charts upgrade from the `release/2.8` branch.

### Changes to *values.yaml*

{{% notice note %}}
An automated `values.yaml` converter for 2.7->2.8 is available in the `release/2.8` branch of the Kubermatic Installer.
{{% /notice %}}

#### Docker Registry Credentials Merger

The docker registry credentials for Docker Hub and Quay located at `kubermatic->docker->secret` and `kubermatic->quay->secret` respectively, have been merged into a single secret at `kubermatic->imagePullSecretData`. The base64-encoded values need to be simply decoded, the resulting JSONs merged and then base64 encoded again before storing at the new location.

#### isMaster

A new boolean field `kubermatic->isMaster` has been added with the following possible values:

- `true` for the master cluster
- `false` for all other seed clusters

#### cert-manager

The following values for cert-manager have been moved from the YAML top level to the `certManager` section:

- `replicaCount`
- `image`

#### IAP

IAP proxy has been added to control access to the monitoring stack using oauth instead of static credentials. Refer to `values.example.yaml` for an example on how to configure the IAP proxy. At the same time, the following basic-auth configuration options can be removed:

- `alertmanager->auth`
- `grafana->host`
- `grafana->user`
- `grafana->password`
- `prometheus->auth`

#### kubeStateMetrics

The section `kubeStateMetrics->externalLabels` has been removed.

#### Prometheus Backups

A boolean config value `prometheus->backups` has been added to toggle the creation of metrics' backups.

#### Minio Backups

A boolean config value `minio->backups` has been added to toggle the creation of backups.

#### Misc

The following top-level values are now gone:

- `createCustomResource`
- `rbac`
