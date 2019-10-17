+++
title = "Upgrading from 2.11 to 2.12"
date = 2019-08-20T11:09:15+02:00
publishDate = 2019-10-12T00:00:00+00:00
weight = 60
pre = "<b></b>"
+++

## Helm Charts

### cert-manager

Kubermatic 2.12 ships with cert-manager 0.10, which changed the api versions for its manifests. This requires
manual intervention and a short time frame where no certificates can be created when upgrading. Before upgrading,
create a backup of all cert-manager resources (certificates, issuers, ...) because their CRDs will have to be
recreated.

After creating the backup, delete the cert-manager chart, delete the CRDs and re-install the chart (which also
re-installs the CRDs):

```bash
$ helm --tiller-namespace kubermatic-installer delete --purge cert-manager
$ kubectl get crd | awk '/certmanager/ {print $1}' | xargs kubectl delete crd

$ cd kubermatic-installer/charts/cert-manager
$ helm --tiller-namespace kubermatic-installer upgrade --install --namespace cert-manager --values YOUR_VALUES_YAML_HERE cert-manager .
```

### Velero

The default backup schedules for the `monitoring`, `logging` and `minio` namespaces have been removed. In order
to continue these backups, dump the schedules and re-import them after updating the Helm chart like so:

```bash
kubectl -n velero get schedules.velero.io -o yaml > schedules.yaml
helm --tiller-namespace kubermatic-installer upgrade --install --namespace velero --values YOUR_VALUES_YAML_HERE velero config/backup/velero
kubectl apply -f schedules.yaml
```

This change does not affect user cluster etcds, which are stilled backed up regularly.
