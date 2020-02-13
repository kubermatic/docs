+++
title = "Upgrading from 2.12 to 2.13"
date = 2020-02-13T11:09:15+02:00
weight = 70
pre = "<b></b>"
+++

## Helm Charts

### cert-manager

Kubermatic 2.13 ships with cert-manager 0.12, which changed the API group for its CRDs from `certmanager.k8s.io` to
`cert-manager.io`. This requires manual intervention and a short time frame where no certificates can be created when
upgrading. Before upgrading, create a backup of all cert-manager resources (certificates, issuers, ...) because their
CRDs will have to be recreated.

After creating the backup, delete the cert-manager chart, delete the CRDs and re-install the chart (which also
re-installs the CRDs):

```bash
helm --tiller-namespace kubermatic-installer delete --purge cert-manager
kubectl get crd | awk '/certmanager/ {print $1}' | xargs kubectl delete crd

cd kubermatic-installer/charts/cert-manager
helm --tiller-namespace kubermatic-installer upgrade --install --namespace cert-manager --values YOUR_VALUES_YAML_HERE cert-manager .
```
