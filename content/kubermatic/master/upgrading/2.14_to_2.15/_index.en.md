+++
title = "Upgrading from 2.14 to 2.15"
date = 2020-06-09T11:09:15+02:00
weight = 90

+++

## Helm Charts

### CRD Handling in cert-manager, Velero

In previous Kubermatic releases, Helm was responsible for installing the CRDs for cert-manager and Velero. While this
made the deployment rather simple, it lead to problems in keeping the CRDs up-to-date (as Helm never updates or deletes
CRDs).

For this reason the CRD handling in Kubermatic 2.15 was changed to require users to always manually install CRDs before
installing/updating a Helm chart. This provides much greater control over the CRD lifecycle and eases integration with
other deployment mechanisms.

Upgrading existing Helm releases in a cluster is simple, as Helm does not delete CRDs. To update cert-manager, simply
install the CRDs and then run Helm as usual:

```bash
kubectl apply -f charts/cert-manager/crd/
helm --tiller-namespace kubermatic upgrade --install --values YOUR_VALUES_YAML_HERE --namespace cert-manager cert-manager charts/cert-manager/
```

{{% notice note %}}
Older versions of `kubectl` can potentially have issues applying the CRD manifests. If you encounter problems, please update
your `kubectl` to the latest stable version and refer to the
[cert-manager documentation](https://cert-manager.io/docs/installation/upgrading/upgrading-0.15-0.16/#issue-with-older-versions-of-kubectl)
for more information.
{{% /notice %}}

Note that on the first `kubectl apply` you will receive warnings because now "kubectl takes control over previously
Helm-owned resources", which can be safely ignored.

Perform the same steps for Velero:

```bash
kubectl apply -f charts/backup/velero/crd/
helm --tiller-namespace kubermatic upgrade --install --values YOUR_VALUES_YAML_HERE --namespace velero velero charts/backup/velero/
```

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
