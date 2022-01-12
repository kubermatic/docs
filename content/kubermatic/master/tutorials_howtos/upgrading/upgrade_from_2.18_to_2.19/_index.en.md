+++
title = "Upgrading from 2.18 to 2.19"
date = 2021-01-07T08:00:39+02:00
weight = 110
+++

## Helm chart changes

With KKP release 2.19, we're moving to use upstream Helm charts for some of the components. The following list describes the changes to the components and required actions to perform an upgrade.

Note: The upstream charts will be downloaded during the deployment process when using the installer. Make sure to unpack the installer into a fresh location. If chart files from different installers get mixed up, the upgrade can lead to unexpected results. If you're installing manually, the dependencies have to be downloaded separately for each of the charts mentioned below using command `helm dependency build <chart_location>`

### cert-manager

Cert-manager is now using upstream Helm chart version 1.5.2 - [documentation](https://cert-manager.io/docs/).

The new version of the chart does not configure `clusterIssuers` for the cluster, so please refer to [cert-manager documentation](https://cert-manager.io/docs/configuration/) for details on how to configure your own. The installer will keep the Cluster Issuers installed by previous versions, but will stop tracking them via Helm. This change was made because the custom datastructure in the values.yaml was never capable of defining all possible Issuers (for example a custom CA issuer) and most admins will probably already define their own, custom issuers outside the Helm chart.

Actions required (using the installer):

1. Entries for cert-manager in `values.yaml` should now be placed under `cert-manager` key instead of `certManager`, e.g.
   ```yaml
   # before
   certManager:
     tolerations: {}

   # now
   cert-manager:
     tolerations: {}
   ```
2. `--migrate-upstream-cert-manager` flag has to be added for the installer to perform the migration. During the upgrade, the chart is uninstalled completely so there is a short time when certificates will not be renewed.

Actions required (manual installation):
1. Entries for cert-manager in `values.yaml` should now be placed under `cert-manager` key instead of `certManager`
2. The recommended way of handling the migration is to backup the old Cluster Issuers, then remove the old cert-manager installation before installing the new one.

### nginx-ingress-controller

Ingress Nginx is now using upstream Helm chart version 4.0.9 - [documentation](https://kubernetes.github.io/ingress-nginx/).

Actions required (using the installer):

1.  The following changes have to be made in the `values.yaml`:
    * entire nginx-ingresss-controller configuration is moved to a subkey in values file: `nginx.controller` - refer to [examples in upstream's values.yaml](https://github.com/kubernetes/ingress-nginx/blob/helm-chart-4.0.9/charts/ingress-nginx/values.yaml)
      ```yaml
        # before
        nginx:
          # your values

        # now
        nginx:
          controller:
            # your values
      ```
    * the option to run as a daemonset (`nginx.asDaemonSet`) is removed - use `nginx.controller.kind` instead
    * the option to schedule on master nodes removed (`nginx.ignoreMasterTaint`) and a way to reconfigure it has been added to the `values.yaml` file
2. `--migrate-upstream-nginx-ingress` flag has to be added for the installer to perform the migration.

Actions required (manual installation):
1.  The following changes have to be made in the `values.yaml`:
    * entire nginx-ingresss-controller configuration is moved to a subkey in values file: `nginx.controller` - refer to [examples in upstream's values.yaml](https://github.com/kubernetes/ingress-nginx/blob/helm-chart-4.0.9/charts/ingress-nginx/values.yaml)
    * the option to run as a daemonset (`nginx.asDaemonSet`) is removed - use `nginx.controller.kind` instead
    * the option to schedule on master nodes removed (`nginx.ignoreMasterTaint`) and a way to reconfigure it has been added to the `values.yaml` file
2. The recommended way is to remove the old chart deployment before upgrading to new version. Removing the `ingress-nginx-controller` deployment is required for the upgrade to proceed.

### logging/loki

Loki is now using upstream Helm chart version 2.8.1 - [documentation](https://artifacthub.io/packages/helm/grafana/loki/2.8.1).

Please refer to the chart's documentation linked above for information about changes to the `values.yaml` structure. No additional actions are required to perform an upgrade.

### logging/promtail

Promtail is now using upstream Helm chart version 3.8.1 - [documentation](https://artifacthub.io/packages/helm/grafana/promtail/3.8.1)

Please refer to the chart's documentation linked above for information about changes to the `values.yaml` structure. No additional actions are required to perform an upgrade.
