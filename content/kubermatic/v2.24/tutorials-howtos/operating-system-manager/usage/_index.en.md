+++
title = "Using Operating System Manager"
date = 2022-01-18T10:07:15+02:00
weight = 2
+++

Starting with KKP 2.21, OSM will be enabled by default for all the new user clusters. It is highly recommended to use OSM instead of user-data from machine-controller, which is consideread deprecated and will be removed in the near future.

OSM can be configured using the dashboard or CLI.

## Via UI

### Enable OSM

Create a new cluster from the dashboard and toggle **Operating System Manager** feature on.

![Enable OSM during cluster creation](/img/kubermatic/v2.24/tutorials/operating_system_manager/osm_dashboard.png?classes=shadow,border "Enable OSM during cluster creation")

{{% notice note %}}
OSM cannot be disabled after cluster creation.
{{% /notice %}}

### Selecting OperatingSystemProfile

![Select OperatingSystemProfile](/img/kubermatic/v2.24/tutorials/operating_system_manager/osm_select.png?classes=shadow,border "Select OperatingSystemProfile")

## Via CLI

On cluster creation, set the following values in `Cluster` resource:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Cluster
metadata:
  name: crh4xbxz5f
spec:
...
  enableOperatingSystemManager: true
...
```

## Custom OperatingSystemProfiles

To use custom OperatingSystemProfiles, users can do the following:

1. Create their `CustomOperatingSystemProfile` resource in the seed namespace(kubermatic). These resources will be automatically synced to the `kube-system` namespace of the user-clusters.

```yaml
apiVersion: operatingsystemmanager.k8c.io/v1alpha1
kind: CustomOperatingSystemProfile
metadata:
  name: osp-install-curl
  namespace: kube-system
spec:
  osName: "ubuntu"
  osVersion: "20.04"
  version: "v1.0.0"
  provisioningUtility: "cloud-init"
  supportedCloudProviders:
    - name: "aws"
  bootstrapConfig:
    files:
      - path: /opt/bin/bootstrap
        permissions: 755
        content:
          inline:
            encoding: b64
            data: |
              #!/bin/bash

              apt update && apt install -y curl jq

      - path: /etc/systemd/system/bootstrap.service
        permissions: 644
        content:
          inline:
            encoding: b64
            data: |
              [Install]
              WantedBy=multi-user.target

              [Unit]
              Requires=network-online.target
              After=network-online.target
              [Service]
              Type=oneshot
              RemainAfterExit=true
              ExecStart=/opt/bin/bootstrap

    modules:
      runcmd:
        - systemctl restart bootstrap.service

  provisioningConfig:
    files:
      - path: /opt/hello-world
        permissions: 644
        content:
          inline:
            encoding: b64
            data: echo "hello world"
```

2. Create `OperatingSystemProfile` resources in the `kube-system` namespace of the user cluster, after cluster creation.

{{% notice note %}}
OSM uses a dedicated resource CustomOperatingSystemProfile in seed cluster. These CustomOperatingSystemProfiles are converted to OperatingSystemProfiles and then propagated to the user clusters.
{{% /notice %}}


## Updating existing OperatingSystemProfiles

OSPs are immutable by design and any modifications to an existing OSP requires a version bump in `.spec.version`. Users can create custom OSPs in the seed namespace or in the user cluster and manage them.

KKP ships default OSPs for different operating systems and it is not recommended to update default OSPs. Since KKP manages those resources and will revert any changes made on them.

## Migrating existing clusters

For migrating existing clusters, user can enable OSM using either the CLI or UI. That would enable OSM on the user cluster level. Although the machines will not be rotated automatically. To perform this rotation for existing MachineDeployments please follow the guide at [Rolling Restart MachineDeploments][rolling-restart].

[rolling-restart]: {{< ref "../../../cheat-sheets/rollout-machinedeployment" >}}
