+++
title = "Disable CSI driver addon on user clusters"
date = 2023-10-30T14:43:42+05:30
weight = 10

+++

KKP installs the CSI drivers on user clusters that have the external CCM enabled, the CSI driver is installed as an [addon](https://github.com/kubermatic/kubermatic/tree/main/addons/csi) in the user cluster. However, in some cases, the cluster admin might want to use some other storage driver in their data center/cluster. For this purpose, KKP provides an option to disable the CSI driver installation for the data center or specific clusters in the data center, if this option is enabled then KKP/Cluster admin is responsible for deploying & managing the storage solution on their own.

### Disable CSI driver installation at the data center level

To disable the CSI driver installation for all user clusters in a data center the admin needs to set ` disableCsiDriver: true` in the data center spec in the seed resource.

```
apiVersion: kubermatic.k8c.io/v1
kind: Seed
metadata:
  name: usa
  namespace: kubermatic
spec:
  country: US
  datacenters:
    usa-east:
      country: US
      location: NV
      spec:
        # disable csi driver installation for all user clusters in this dc
        disableCsiDriver: true
        aws:
          region: us-east-1
```

User cluster created after enabling this option will not have the CSI addon installed & the cluster admins won't be able to over-ride and enable it in the cluster spec.

This will not impact the clusters which were created prior to enabling this option & if desired it needs to be updated on the cluster spec.

### Disable CSI driver installation at the user cluster level

To disable the CSI driver installation for a user cluster, admin needs to set `disableCsiDriver: true` in the cluster spec, this is possible only if it is not disabled at the data center.

```
apiVersion: kubermatic.k8c.io/v1
kind: Cluster
metadata:
  name: clustername
spec:
  # disable csi driver installation for this cluster only
  disableCsiDriver: true
```

User clusters that already have the CSI driver addon installed can also be updated to disable the CSI driver addon using the `disableCsiDriver: true` option. However, before doing this the cluster admin must ensure that none of the PVCs & PVs that belong to the storage class that has the CSI driver as the provisioner are in use, if there is any PVC that belongs to a storage class that uses the CSI driver KKP will not disable it. If for any reason the admin removes the storage class even if it has PVs that are in use & then disables the CSI driver, it will have an undesired impact on the cluster. Hence, it is expected that the admin is careful while making this change & does not remove the storage class before disabling the CSI driver.