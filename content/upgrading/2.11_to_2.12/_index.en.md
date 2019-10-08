+++
title = "Upgrading from 2.11 to 2.12"
date = 2019-08-20T11:09:15+02:00
publishDate = 2019-10-12T00:00:00+00:00
weight = 60
pre = "<b></b>"
+++

## Helm Charts

### cert-manager

Kubermatic 2.12 ships with cert-manager 0.9, which changed the api versions for its manifests. This requires
manual intervention and a short time frame where no certificates can be created when upgrading. Before upgrading,
create a backup of all cert-manager resources (certificates, issuers, ...) because their CRDs will have to be
recreated.

After creating the backup, delete the cert-manager chart, delete the CRDs and re-install the chart (which also
re-installs the CRDs):

```bash
helm --tiller-namespace kubermatic-installer delete --purge cert-manager
kubectl get crd | awk '/certmanager/ {print $1}' | xargs kubectl delete crd

cd kubermatic-installer/charts/cert-manager
helm --tiller-namespace kubermatic-installer upgrade --install --namespace cert-manager --values YOUR_VALUES_YAML_HERE cert-manager .
```
