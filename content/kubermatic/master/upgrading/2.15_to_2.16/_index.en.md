+++
title = "Upgrading from 2.15 to 2.16"
date = 2021-02-03T11:09:15+01:00
weight = 100

+++

This document describes the major changes between KKP 2.15 and 2.16. It's recommended to read them carefully
before performing an upgrade.

## Removing the Legacy `kubermatic` Helm Chart

As announced with 2.15, this release is now the last to provide the `kubermatic` Helm chart. Users must
migrate to using either the KKP Installer, or manually install the `kubermatic-operator` chart.

### Removed ELK Logging Stack

The Helm charts for `elasticsearch`, `kibana` and `fluentbit` have been removed, as announced with KKP 2.15.
Users are encouraged to migrate to Grafana Loki, for which Helm charts are provided by Kubermatic.

## Certificate Handling

In previous releases, KKP used explicit Certificate resources to manage TLS certificates. This resulted in a
rather strong dependency on cert-manager to be installed into the cluster, plus issues handling
non-Let's Encrypt certificates.

To allow for more flexibility in providing certificates, KKP 2.16 switches to using the `cert-manager.io/issuer`
or `cert-manager.io/cluster-issuer` annotations on Ingress objects. cert-manager is still the recommended
solution for acquiring certificates (and is installed by default), but other avenues may be chosen instead.
