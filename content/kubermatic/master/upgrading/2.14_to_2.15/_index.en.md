+++
title = "Upgrading from 2.14 to 2.15"
date = 2020-06-09T11:09:15+02:00
weight = 90

+++

## Helm Charts

### Promtail

The labelling for the Promtail DaemonSet has changed, requiring administrators to re-install the Helm chart. As a clean
upgrade is not possible, we advise to delete and re-install the chart.

```bash
helm --tiller-namespace kubermatic delete promtail
helm --tiller-namespace kubermatic upgrade --install --values YOUR_VALUES_YAML_HERE --namespace logging promtail charts/logging/promtail/
```

Promtail pods are stateless, so no data is lost during this migration.

### Removed Default Credentials

To prevent insecure misconfigurations, the default credentials for Grafana and Minio have been removed. They must be
set explicitly when installing the charts. Additionally, the base64 encoding for Grafana credentials has been removed,
so the plaintext values are put into the Helm `values.yaml`.

When upgrading the charts, make sure your `values.yaml` contains at least these keys:

```yaml
grafana:
  # Remember to un-base64-encode the username if you have set a custom value.
  user: admin

  # generate random password, keep it plaintext as well
  password: ExamplePassword

minio:
  credentials:
    accessKey: # generate a random, alphanumeric 32 byte secret
    secretKey: # generate a random, alphanumeric 64 byte secret
```
