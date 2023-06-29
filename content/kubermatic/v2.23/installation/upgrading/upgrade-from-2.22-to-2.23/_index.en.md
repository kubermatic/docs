
+++
title = "Upgrading to KKP 2.23"
date = 2023-03-01T00:00:00+01:00
weight = 10
+++

{{% notice note %}}
Upgrading to KKP 2.23 is only supported from version 2.22. Do not attempt to upgrade from versions prior to that and apply the upgrade step by step over minor versions instead (e.g. from [2.21 to 2.22]({{< ref "../upgrade-from-2.21-to-2.22/" >}}) and then to 2.23). It is also strongly advised to be on the latest 2.22.x patch release before upgrading to 2.23.
{{% /notice %}}

This guide will walk you through upgrading Kubermatic Kubernetes Platform (KKP) to version 2.23. For the full list of changes in this release, please check out the [KKP changelog for v2.23](https://github.com/kubermatic/kubermatic/blob/main/docs/changelogs/CHANGELOG-2.23.md). Please read the full document before proceeding with the upgrade.

## Pre-Upgrade Considerations

KKP 2.23 adjusts the list of supported Kubernetes versions but does not drop any old versions in comparison to KKP 2.22. Kubernetes 1.24 continues to be the lowest support version.

### Velero 1.10

[Velero](https://velero.io/) has been upgraded from v1.9.x to 1.10.x. During this change, Velero improved backups by adding support for kopia for doing file-system level backups (in addition to the existing restic support). The KKP Helm chart continues to be configured for restic.

Please refer to the [Velero 1.10 Upgrade Notes](https://velero.io/docs/v1.10/upgrade-to-1.10/) for more information if you want to switch to kopia or have customized Velero in any other way.

### Cluster Isolation Network Policies in KubeVirt

KKP 2.23 changes the way that the `cluster-isolation` feature in the KubeVirt provider works. Previously, a `NetworkPolicy` blocking incoming traffic has been added to each cluster namespace in KubeVirt. With KKP 2.23, this changes to blocking outgoing traffic as it has been identified that blocking incoming traffic is highly problematic in e.g. load balancing scenarios.

Since the direction of blocked traffic changes, it might be necessary to provide your own custom `NetworkPolicies` that allow egress traffic. The new `cluster-isolation` policy blocks traffic to internal IP ranges (10.0.0.0/8, 172.16.0.0/12 and 192.168.0.0/16) by default and only allows traffic within the KubeVirt infrastructure cluster that is vital (e.g. DNS). Additional private IP addresses need to be allowed in separate egress-based policies, for example via the Seed level `customNetworkPolicies` (also [see the KubeVirt provider documentation]({{< ref "../../../architecture/supported-providers/kubevirt/kubevirt/#configure-kkp-with-kubevirt" >}})).

### Canal 3.22 Deprecation

Support for Canal 3.22 has been deprecated in KKP 2.23 and this version will no longer be offered for Kubernetes clusters of version 1.25 or higher. User clusters that are upgraded to Kubernetes 1.25 while running Canal 3.22 will automatically be upgraded to Canal 3.23.

## Upgrade Procedure

Before starting the upgrade, make sure your KKP Master and Seed clusters are healthy with no failing or pending Pods. If any Pod is showing problems, investigate and fix the individual problems before applying the upgrade. This includes the control plane components for user clusters, unhealthy user clusters should not be submitted to an upgrade.

### KKP Master Upgrade

Download the latest 2.23.x release archive for the correct edition (`ce` for Community Edition, `ee` for Enterprise Edition) from [the release page](https://github.com/kubermatic/kubermatic/releases) and extract it locally on your computer. Make sure you have the `values.yaml` you used to deploy KKP 2.22 available and already adjusted for any 2.23 changes (also see [Pre-Upgrade Considerations](#pre-upgrade-considerations)), as you need to pass it to the installer. The `KubermaticConfiguration` is no longer necessary (unless you are adjusting it), as the KKP operator will use its in-cluster representation. From within the extracted directory, run the installer:

```sh
$ ./kubermatic-installer deploy kubermatic-master --helm-values path/to/values.yaml

# example output for a successful upgrade
INFO[0000] 🚀 Initializing installer…                     edition="Enterprise Edition" version=v2.23.0
INFO[0000] 🚦 Validating the provided configuration…
WARN[0000]    Helm values: kubermaticOperator.imagePullSecret is empty, setting to spec.imagePullSecret from KubermaticConfiguration
INFO[0000] ✅ Provided configuration is valid.
INFO[0000] 🚦 Validating existing installation…
INFO[0001]    Checking seed cluster…                     seed=kubermatic
INFO[0001] ✅ Existing installation is valid.
INFO[0001] 🛫 Deploying KKP master stack…
INFO[0001]    💾 Deploying kubermatic-fast StorageClass…
INFO[0001]    ✅ StorageClass exists, nothing to do.
INFO[0001]    📦 Deploying nginx-ingress-controller…
INFO[0001]       Deploying Helm chart…
INFO[0002]       Updating release from 2.22.4 to 2.23.0…
INFO[0005]    ✅ Success.
INFO[0005]    📦 Deploying cert-manager…
INFO[0005]       Deploying Custom Resource Definitions…
INFO[0006]       Deploying Helm chart…
INFO[0007]       Updating release from 2.22.4 to 2.23.0…
INFO[0026]    ✅ Success.
INFO[0026]    📦 Deploying Dex…
INFO[0027]       Updating release from 2.22.4 to 2.23.0…
INFO[0030]    ✅ Success.
INFO[0030]    📦 Deploying Kubermatic Operator…
INFO[0030]       Deploying Custom Resource Definitions…
INFO[0034]       Deploying Helm chart…
INFO[0035]       Updating release from 2.22.4 to 2.23.0…
INFO[0064]    ✅ Success.
INFO[0064]    📦 Deploying Telemetry
INFO[0065]       Updating release from 2.22.4 to 2.23.0…
INFO[0066]    ✅ Success.
INFO[0066]    📡 Determining DNS settings…
INFO[0066]       The main LoadBalancer is ready.
INFO[0066]
INFO[0066]         Service             : nginx-ingress-controller / nginx-ingress-controller
INFO[0066]         Ingress via hostname: <Load Balancer>.eu-central-1.elb.amazonaws.com
INFO[0066]
INFO[0066]       Please ensure your DNS settings for "<KKP FQDN>" include the following records:
INFO[0066]
INFO[0066]          <KKP FQDN>.    IN  CNAME  <Load Balancer>.eu-central-1.elb.amazonaws.com.
INFO[0066]          *.<KKP FQDN>.  IN  CNAME  <Load Balancer>.eu-central-1.elb.amazonaws.com.
INFO[0066]
INFO[0066] 🛬 Installation completed successfully. ✌
```

Upgrading seed clusters is not necessary, unless you are running the `minio` Helm chart or User Cluster MLA as distributed by KKP on them. They will be automatically upgraded by KKP components.

You can follow the upgrade process by either supervising the Pods on master and seed clusters (by simply checking `kubectl get pods -n kubermatic` frequently) or checking status information for the `Seed` objects. A possible command to extract the current status by seed would be:

```sh
$ kubectl get seeds -A -o jsonpath="{range .items[*]}{.metadata.name} - {.status}{'\n'}{end}"
kubermatic - {"clusters":5,"conditions":{"ClusterInitialized":{"lastHeartbeatTime":"2023-02-16T10:53:34Z","message":"All KKP CRDs have been installed successfully.","reason":"CRDsUpdated","status":"True"},"KubeconfigValid":{"lastHeartbeatTime":"2023-02-14T16:50:09Z","reason":"KubeconfigValid","status":"True"},"ResourcesReconciled":{"lastHeartbeatTime":"2023-02-14T16:50:14Z","reason":"ReconcilingSuccess","status":"True"}},"phase":"Healthy","versions":{"cluster":"v1.24.10","kubermatic":"v2.23.0"}}
```

Of particular interest to the upgrade process is if the `ResourcesReconciled` condition succeeded and if the `versions.kubermatic` field is showing the target KKP version. If this is not the case yet, the upgrade is still in flight. If the upgrade is stuck, try `kubectl -n kubermatic describe seed <seed name>` to see what exactly is keeping the KKP Operator from updating the Seed cluster.

## Post-Upgrade Considerations

### AWS User Cluster Upgrades

KKP 2.23 introduces limitations to Kubernetes version upgrades for AWS user clusters when the "in-tree" cloud providers are used. This has been added due to Kubernetes removing provider-specific code from core Kubernetes, instead asking users to rely on external CCM (Cloud Controller Managers) and CSI drivers.

An additional limitation has been added in  KKP 2.23:

- **AWS** user clusters **with Kubernetes 1.26** and in-tree cloud provider usage cannot be upgraded to 1.27 or higher.

By default, new AWS user clusters in KKP get created with external cloud provider support. However, some long running user clusters might still be using the in-tree implementations. KKP supports [CCM & CSI migration]({{< ref "../../../tutorials-howtos/CCM-migration/" >}}) for those user clusters. The Kubermatic Dashboard offers information about the current status via the "External CCM/CSI" check under "Misc" in the additional cluster information section.

## Next Steps

- Check out Kubernetes 1.27, the newest minor release provided by the Kubernetes community.
- Import KubeOne clusters on DigitalOcean, Hetzner, OpenStack and vSphere.
- Use API tokens to authenticate to VMware Cloud Director as a cloud provider.
