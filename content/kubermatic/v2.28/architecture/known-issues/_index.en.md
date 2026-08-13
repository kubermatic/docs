+++
title = "Known Issues"
date = 2022-07-22T12:22:15+02:00
weight = 25

+++

## Overview

This page documents the list of known issues and possible workarounds/solutions.

## Oidc refresh tokens are invalidated when the same user/client id pair is authenticated multiple times

### Problem

For oidc authentication to user cluster there is always the same issuer used. This leads to invalidation of refresh tokens when a new authentication happens with the same user because existing refresh tokens for the same user/client pair are invalidated when a new one is requested.

### Root Cause

By default it is only possible to have one refresh token per user/client pair in dex for security reasons. There is an open issue regarding this in the [upstream repository](https://github.com/dexidp/dex/issues/981). The refresh token has by default also no expiration set. This is useful to stay logged in over a longer time because the id_token can be refreshed unless the refresh token is invalidated.

One example would be to download a kubeconfig of one cluster and then of another with the same user. You should only be able to use the first kubeconfig until the id_token expires because the refresh token was already invalidated by the download of the second one.

### Solution

You can either change this in dex configuration by setting `userIDKey` to `jti` in the connector section or you could configure an other oidc provider which supports multiple refresh tokens per user-client pair like keycloak does by default.

#### Dex

The following yaml snippet is an example how to configure an oidc connector to keep the refresh tokens.

```yaml
    connectors:
      - id: oidc
        name: OIDC
        type: Google
        config:
          clientID: <client_id>
          clientSecret: <client_secret>
          redirectURI: https://kkp.example.com/dex/callback
          scopes:
            - openid
            - profile
            - email
            - offline_access
          # Workaround to support multiple user_id/client_id pairs concurrently
          # Configurable key for user ID look up
          # Default: id
          userIDKey: <<userIDValue>>
          # Optional: Configurable key for user name look up
          # Default: user_name
          userNameKey: <<userNameValue>>
```

#### External provider

For an explanation how to configure an other oidc provider than dex take a look at [oidc-provider-configuration]({{< ref "../../tutorials-howtos/oidc-provider-configuration" >}}).

### Security implications regarding dex solution

For dex this has some implications. With this configuration a token is generated for each user session. The number of objects stored in kubernetes regarding refresh tokens has no limit anymore. The principle that one refresh belongs to one user/client pair is a security consideration which would be ignored in that case. The only way to revoke a refresh token is then to do it via grpc api which is not exposed by default or by manually deleting the related refreshtoken resource in the kubernetes cluster.

## API server Overload Leading to Instability in Seed due to Konnectivity

Issue: <https://github.com/kubermatic/kubermatic/issues/13321>

Status: Fixed

An issue has been identified where the overloaded API server of a user cluster managed by a Seed can impact the stability of API servers in all other user clusters managed by the same Seed.
This resulted in various control plane components and applications failing to communicate with the apiserver due to timeouts and context cancellation errors.
Moreover, Konnectivity Server container in API server pod emits "Receive channel from agent is full" logs.

> Upstream issue can be found [here](https://github.com/kubernetes-sigs/apiserver-network-proxy/issues/586).

### Solution

The newly introduced `args` field in KKP v2.28.0 for configuring Konnectivity deployments (both Agent and Server) allows users to set any flags, including `--xfr-channel-size`.

**Important Note:** The `--xfr-channel-size` flag in Konnectivity is available starting from Kubernetes v1.31.0. Ensure that the Kubernetes cluster version is compatible to use this new flag.

#### Updating Konnectivity Server

To update the Konnectivity Server configuration, the Seed's `defaultComponentSettings` must be updated.
The new `args` field is available under `spec.defaultComponentSettings.konnectivityProxy`. 
An example configuration is shown below:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Seed
metadata:
  name: <<exampleseed>>
  namespace: kubermatic
spec:
  defaultComponentSettings:
    konnectivityProxy:
      # Args configures arguments (flags) for the Konnectivity deployments.
      args: ["--xfr-channel-size=20"]
```

This sets `--xfr-channel-size=20` flag for Konnectivity Server, which runs as a sidecar to the Kubernetes API server.

#### Updating Konnectivity Agent

To update the Konnectivity Agent configuration, the Cluster's `componentsOverride` must be updated.
The new `args` field is available under `spec.componentsOverride.konnectivityProxy`. 
An example configuration is shown below:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Cluster
metadata:
  name: <<examplecluster>>
  namespace: kubermatic
spec:
  componentsOverride:
    konnectivityProxy:
      # Args configures arguments (flags) for the Konnectivity deployments.
      args: ["--xfr-channel-size=300"]
```

This sets `--xfr-channel-size=300` flag for Konnectivity Agent, which runs on the user cluster.

## Workaround for the Bitnami registry changes if upgrade is not possible

Customers who are completely unable to upgrade to KKP patch version 2.28.2 or above, may use a workaround.
This should be treated as a last resort method and comes with downsides on future upgrades. Specifically, with the patch releases, we are also moving to mirrored helm-charts to ensure stability and independence going forward. This workaround will not migrate to the mirrored charts, it will only switch images.

Workaround in detail:

1. Add the following to your mla values.yaml at the top level:

  ```yaml
  cortex:
    memcached-blocks-index:
      image:
        registry: quay.io
        repository: kubermatic-mirror/images/memcached
      metrics:
        image:
          registry: quay.io
          repository: kubermatic-mirror/images/memcached-exporter
    memcached-blocks:
      image:
        registry: quay.io
        repository: kubermatic-mirror/images/memcached
      metrics:
        image:
          registry: quay.io
          repository: kubermatic-mirror/images/memcached-exporter
    memcached-blocks-metadata:
      image:
        registry: quay.io
        repository: kubermatic-mirror/images/memcached
      metrics:
        image:
          registry: quay.io
          repository: kubermatic-mirror/images/memcached-exporter
  ```

2. Re-run the mla installation process in accordance with the [official documentation](../../tutorials-howtos//monitoring-logging-alerting//user-cluster/admin-guide/#installing-mla-stack-in-a-seed-cluster) with a kubermatic installer matching your current KKP version.

## Flatcar worker nodes fail to bootstrap on KubeVirt infrastructure (Ignition not applied)

_**Affected Components**_: Machine Controller, KubeVirt provider (Kubermatic Virtualization)

_**Affected OS Image**_: Flatcar Linux worker nodes provisioned on KubeVirt v1.6.4 and newer (shipped with Kubermatic Virtualization v1.2.0). Ubuntu and other cloud-init based operating systems are **not** affected.

Issue: [kubevirt/kubevirt#16901](https://github.com/kubevirt/kubevirt/issues/16901)

### Problem

Flatcar-based user-cluster worker VMs start and receive an IP address, but they never receive their Ignition configuration. As a result the node never joins the user cluster. Ubuntu worker pools on the same infrastructure provision normally.

### Root Cause

Flatcar receives its provisioning config through a QEMU firmware-config argument (`-fw_cfg name=opt/com.coreos/config`) in the `qemu:commandline` section of the VM's libvirt domain. Starting with KubeVirt v1.6.4, the PCIe-hotplug port reservation rewrites the libvirt domain a second time; that XML round-trip drops the `qemu:commandline` block, and with it the `-fw_cfg` argument that carries Flatcar's Ignition payload. This is an upstream KubeVirt defect, not a Kubermatic or machine-controller bug — the Ignition data itself is generated correctly.

### Workaround

Set the KubeVirt annotation `kubevirt.io/placePCIDevicesOnRootComplex: "true"` on the Flatcar worker pool. machine-controller sets it automatically for Flatcar machines as of [kubermatic/machine-controller#2057](https://github.com/kubermatic/machine-controller/pull/2057), released in machine-controller v1.66.1 and backported to v1.65.5. Neither release is part of the machine-controller v1.62.x line that KKP v2.28.x bundles, and pinning `spec.userCluster.machineController.imageTag` to a different machine-controller minor than your KKP release ships is not tested. On v2.28.x, set the annotation manually on the Flatcar worker pool's `MachineDeployment` under `spec.template.metadata.annotations` (namespace `kube-system`) and recreate the nodes. The annotation only takes effect on newly created machines. See the [Kubermatic Virtualization known issues](https://docs.kubermatic.com/kubermatic-virtualization/main/known-issues/) page for the full steps, the patch command, and trade-offs.

To have machine-controller set the annotation for you, upgrade to KKP v2.30.6 or newer, which bundles machine-controller v1.65.5.

### Planned resolution

Tracked upstream in [kubevirt/kubevirt#18460](https://github.com/kubevirt/kubevirt/pull/18460). The workaround can be removed once the fix ships in the KubeVirt version bundled with Kubermatic Virtualization.
