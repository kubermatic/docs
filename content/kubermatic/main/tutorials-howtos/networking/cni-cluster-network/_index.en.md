+++
linkTitle = "CNI & Cluster Network Configuration"
title = "CNI (Container Network Interface) & Cluster Network Configuration"
date = 2021-09-07T16:06:10+02:00
weight = 10
+++

This page describes various cluster networking options that can be configured for each KKP user cluster either via KKP UI
or via [KKP API](#cluster-cluster-network-configuration-in-kkp-api). Most of this configuration can be specified only
at the cluster creation time and cannot be changed in an already existing clusters.

Cluster networking can be configured in the "Network Configuration" part of the cluster creation wizard, as shown below:

![Cluster Settings - Network Configuration](/img/kubermatic/main/tutorials/networking/ui_cluster_networking.png?classes=shadow,border "Cluster Settings - Network Configuration")

## CNI Type and Version

KKP supports three types of CNI (Container Network Interface) plugin types:

- **[Canal](#canal-cni)**
- **[Cilium](#cilium-cni)**
- **[None](#none-cni)**

Apart from these, KKP also supports [Multus-CNI addon]({{< relref "../multus/" >}}). This is a CNI meta-plugin that can be installed on top of any of the supported primary CNIs.

The following table lists the versions of individual CNIs supported by KKP:

| KKP version | Canal                              | Cilium                      |
|-------------|------------------------------------|-----------------------------|
| `v2.22.x`   | `v3.24`, `v3.23`, `v3.22`          | `v1.13.x`, `v1.12`, `v1.11` |
| `v2.21.x`   | `v3.23`, `v3.22`, `v3.21`, `v3.20` | `v1.12`, `v1.11`            |
| `v2.20.x`   | `v3.22`, `v3.21`, `v3.20`, `v3.19` | `v1.11`                     |

The desired CNI type and version can be selected at the cluster creation time - on the Cluster Settings page, as shown below:

![Cluster Settings - Network Configuration](/img/kubermatic/main/tutorials/networking/ui_cluster_cni.png?classes=shadow,border "Cluster Settings - Network Configuration")

Available CNI versions depend on the KKP version. Note that CNI type cannot be changed after cluster creation, but [manual CNI migration]({{< relref "../cni-migration/" >}}) is possible when necessary.

### Canal CNI

[Canal](https://projectcalico.docs.tigera.io/getting-started/kubernetes/flannel/flannel) is a combination of Flannel CNI and Calico CNI, which sets up Flannel to manage pod networking and Calico to handle policy management. It is a CNI that works fine in most environments but may not be sufficient for some large scale use-cases.

In KKP versions below v2.19, this was the only supported CNI.

### Cilium CNI

[Cilium](https://cilium.io/) is a feature-rich CNI plugin, which leverages the revolutionary eBPF Kernel technology. It provides enhanced security and observability features, but requires more recent kernel versions on the worker nodes (see [Cilium System Requirements](https://docs.cilium.io/en/stable/operations/system_requirements/)).

As of Cilium version `1.13.0`, Cilium in KKP is deployed [as a System Application](#deploying-cni-as-a-system-application), which provides KKP cluster administrators full flexibility of Cilium feature usage and configuration. See [Deploying CNI as a System Application](#deploying-cni-as-a-system-application) for more details.

Before opting for Cilium CNI, please verify that your worker nodes' Linux distributions is known to work well with Cilium based on the [Linux Distribution Compatibility List](https://docs.cilium.io/en/stable/operations/system_requirements/#linux-distribution-compatibility-considerations).

The most of the Cilium CNI features can be utilized when the `ebpf` Proxy Mode is used (Cilium `kube-proxy-replacement` is enabled). This can be done by selecting `ebpf` for `Proxy Mode` in the [Cluster Network Configuration](#other-cluster-network-configuration). Please note that this option is available only if [Konnectivity](#konnectivity) is enabled.

**NOTE:** IPVS kube-proxy mode is not recommended with Cilium CNI due to [a known issue]({{< relref "../../../architecture/known-issues/" >}}#2-connectivity-issue-in-pod-to-nodeport-service-in-cilium--ipvs-proxy-mode).

To allow better observability and troubleshooting of cluster networking with Cilium CNI, Cilium is by default deployed with the [Hubble user interface](https://github.com/cilium/hubble-ui). To access Hubble UI, you can use port-forwarding, e.g.:

```bash
kubectl port-forward -n kube-system svc/hubble-ui 12000:80
```

After the above port-forwarding is active, the Hubble UI can be shown by navigating to the URL [http://localhost:12000](http://localhost:12000).

Please note that for Cilium versions below `1.13.0`, Hubble had to be installed as a KKP Addon. As of Cilium `1.13.0` it is enabled by default, but can be disabled if necessary. See [Deploying CNI as a System Application](#deploying-cni-as-a-system-application) for more details.

### None CNI

"None" CNI is a special KKP-internal CNI type, which does not install any CNI managed by KKP into the user cluster. CNI management is therefore left on the cluster admin which provides a flexible option to install any CNI with any specific configuration.

When this option is selected, the user cluster will be left without any CNI, and will not be functioning until some CNI is installed into it by the cluster admin. This can be done either manually (e.g. via helm charts), or by leveraging the KKP [Accessible Addons]({{< relref "../../../architecture/concept/kkp-concepts/addons/#accessible-addons" >}}) infrastructure or the [Applications]({{< relref "../../applications" >}}) feature.
When deploying your own CNI, please make sure you pass proper pods & services CIDRs to your CNI configuration - matching with the KKP user-cluster level configuration in the [Advanced Network Configuration](#advanced-network-configuration).

### Deploying CNI as a System Application
As of Cilium version `1.13.0`, Cilium CNI is deployed as a "System Application" instead of KKP Addon (as it is the case for older Cilium versions and all Canal CNI versions).
Apart from internally relying on KKP's [Applications]({{< relref "../../applications" >}}) infrastructure rather than [Addons]({{< relref "../../../architecture/concept/kkp-concepts/addons" >}}) infrastructure, it provides the users with full flexibility of CNI feature usage and configuration.

#### Editing the CNI Configuration During Cluster Creation
When creating a new user cluster via KKP UI, it is possible to specify Helm values used to deploy the CNI via the "Edit CNI Values" button at the bottom of the "Advanced Network Configuration" section on the step 2 of the cluster creation wizard:

![Edit CNI Values](/img/kubermatic/main/tutorials/networking/edit-cni-app-values.png?classes=shadow,border "Edit CNI Values")

This can be used e.g. to turn specific CNI features on or off, or modify arbitrary CNI configuration. If no initial values are provided, the default values configured for the CNI `ApplicationDefinition` will be used (see [Changing the Default CNI Configuration](#changing-the-default-cni-configuration)).
Please note that the final Helm values applied in the user cluster will be automatically extended/overridden by the KKP controllers with the configuration necessary to provision the cluster, such as pod CIDR etc.

This option is also available when creating cluster templates and the CNI configuration saved in the cluster template is automatically applied to all clusters created from the template.

#### Editing the CNI Configuration in Existing Cluster
In an existing cluster, the CNI configuration can be edited in two ways: via KKP UI, or by editing CNI `ApplicationInstallation` in the user cluster.

For editing CNI configuration via KKP UI, navigate to the "Applications" tab on the cluster details page, switch the "Show System Applications" toggle, and click on the "Edit Application" button of the CNI. After that a new dialog window with currently applied CNI Helm values will be open and allow their modification.

![Edit CNI Application](/img/kubermatic/main/tutorials/networking/edit-cni-app.png?classes=shadow,border "Edit CNI Application")

The other option is to edit the CNI `ApplicationInstallation` in the user cluster directly, e.g. like this for the Cilium CNI:
```bash
kubectl edit ApplicationInstallation cilium -n kube-system
```
and edit the configuration in ApplicationInstallation's `spec.values`.

This approach can be used e.g. to turn specific CNI features on or off, or modify arbitrary CNI configuration. Please note that some parts of the CNI configuration (e.g. pod CIDR etc.) is managed by KKP, and its change will not be allowed, or may be overwritten upon next reconciliation of the ApplicationInstallation.

#### Changing the Default CNI Configuration
The default CNI configuration that will be used to deploy CNI in new KKP user clusters can be defined at two places:
 - in a cluster template, if the cluster is being created from a template (which takes precedence over the next option),
 - in the CNI ApplicationDefinition's `spec.defaultValues` in the KKP master cluster (editable e.g. via `kubectl edit ApplicationDefinition cilium`).

#### CNI Helm Chart Source
The Helm charts used to deploy CNI are hosted in a Kubermatic OCI registry (`oci://quay.io/kubermatic/helm-charts`). This registry needs to be accessible from the KKP Seed cluster to allow successful CNI deployment. In setups with restricted Internet connectivity, a different (e.g. private) OCI registry source for the CNI charts can be configured in `KubermaticConfiguration` (`spec.systemApplications.helmRepository` and `spec.systemApplications.helmRegistryConfigFile`).

To mirror a Helm chart into a private OCI repository, you can use the helm CLI, e.g.:
```bash
CHART_VERSION=1.13.0
helm pull oci://quay.io/kubermatic/helm-charts/cilium --version ${CHART_VERSION}
helm push cilium-${CHART_VERSION}.tgz oci://<registry>/<repository>/
```

#### Upgrading Cilium CNI to Cilium 1.13.0 / Downgrading
For user clusters originally created with the Cilium CNI version lower than `1.13.0` (which was managed by the Addons mechanism rather than Applications), the migration to the management via Applications infra happens automatically during the CNI version upgrade to `1.13.0`.

During the upgrade, if the Hubble Addon was installed in the cluster before, the Addon will be automatically removed, as Hubble is now enabled by default.
If there are such clusters in your KKP installation, it is important to preserve the following part of the configuration in the [default configuration](#changing-the-default-cni-configuration) of the ApplicationInstallation:
```bash
  hubble:
    tls:
      auto:
        method: cronJob
```

In the rare case of downgrading the Cilium CNI from the `1.13.0` to a lower version, it is necessary to manually delete the CNI `ApplicationInstallation` from the user cluster, e.g.: `kubectl delete ApplicationInstallation cilium -n kube-system`.

### CNI Version Upgrades

If the KKP installation supports a newer version of the CNI installed in a user cluster, it is possible to upgrade to it. This will be shown in the KKP UI and the available versions will be listed in the upgrade dialog shown after clicking on the "CNI Plugin Version" box:

![Cluster Details](/img/kubermatic/main/tutorials/networking/ui_cni_upgrade_available.png?classes=shadow,border "Cluster Details")

![Cluster Details - CNI Plugin Version Dialog](/img/kubermatic/main/tutorials/networking/ui_cni_upgrade_dialog.png?classes=shadow,border "Cluster Details - CNI Plugin Version Dialog")

Once a newer version is selected, the CNI upgrade in the user cluster can be triggered by clicking on the "Change CNI Version" button. Please note that this action may cause network connectivity drops in the cluster, so it should be performed during a maintenance window.

Generally, only one minor version difference is allowed for each CNI upgrade. There are two exceptions to this rule:

- If the cluster is labeled with the `unsafe-cni-upgrade` label (e.g. `unsafe-cni-upgrade: "true"`), any CNI version change is allowed. In this case, users are fully responsible for the consequences that this upgrade may cause and KKP is not putting any guarantees on the upgrade process.
- When upgrading from an already deprecated version, the upgrade is allowed to any higher version. Please double-check that everything is working fine in the user cluster after such upgrade. Also please note that it is not a good practice to keep the clusters on an old CNI version and try to upgrade as soon as new CNI version is available next time.

#### Forced CNI Upgrade

Some newer Kubernetes versions may not be compatible with already deprecated CNI versions. In such case, CNI may be forcefully upgraded together with Kubernetes version upgrade of the user cluster. The following table summarizes the cases when this will happen:

| Kubernetes Version | CNI   | Old CNI Version | Version After K8s Upgrade      |
|--------------------| ----- |-----------------|--------------------------------|
| `>= 1.22`          | Canal | `v3.8`          | latest supported Canal version |
| `>= 1.23`          | Canal | `< v3.22`       | `v3.22`                        |

Again, please note that it is not a good practice to keep the clusters on an old CNI version and try to upgrade as soon as new CNI version is available next time.

## IPv4 / IPv4 + IPv6 (Dual Stack)
This option allows for switching between IPv4-only and IPv4+IPv6 (dual-stack) networking in the user cluster.
This feature is described in detail on an individual page: [Dual-Stack Networking]({{< relref "../dual-stack/" >}}).

## Advanced Network Configuration
After Clicking on the "Advanced Networking Configuration" button in the cluster creation wizard, several more network
configuration options are shown to the user:

![Cluster Settings - Advanced Network Configuration](/img/kubermatic/main/tutorials/networking/ui_cluster_networking_advanced.png?classes=shadow,border "Cluster Settings - Network Configuration")

### Proxy Mode
Configures kube-proxy mode for k8s services. Can be set to `ipvs`, `iptables` or `ebpf` (`ebpf` is available only if Cilium CNI is selected and [Konnectivity](#konnectivity) is enabled).
Defaults to `ipvs` for Canal CNI clusters and `ebpf` / `iptables` (based on whether Konnectivity is enabled or not) for Cilium CNI clusters.
Note that IPVS kube-proxy mode is not recommended with Cilium CNI due to [a known issue]({{< relref "../../../architecture/known-issues/" >}}#2-connectivity-issue-in-pod-to-nodeport-service-in-cilium--ipvs-proxy-mode).

### Pods CIDR
The network range from which POD networks are allocated. Defaults to `[172.25.0.0/16]` (or `[172.26.0.0/16]` for Kubevirt clusters, `[172.25.0.0/16, fd01::/48]` for `IPv4+IPv6` ipFamily).

### Services CIDR
The network range from which service VIPs are allocated. Defaults to `[10.240.16.0/20]` (or `[10.241.0.0/20]` for Kubevirt clusters, `[10.240.16.0/20, fd02::/120]` for `IPv4+IPv6` ipFamily).

### Node CIDR Mask Size
The mask size (prefix length) used to allocate a node-specific pod subnet within the provided Pods CIDR. It has to be larger than the provided Pods CIDR prefix length.

### Allowed IP Range for NodePorts
IP range from which NodePort access to the worker nodes will be allowed. Defaults to `0.0.0.0/0` (allowed from anywhere). This option is available only for some cloud providers that support it.

### Node Local DNS Cache
Enables NodeLocal DNS Cache - caching DNS server running on each worker node in the cluster.

### Konnectivity
Konnectivity provides TCP level proxy for the control plane (seed cluster) to worker nodes (user cluster) communication. It is based on the upstream [apiserver-network-proxy](https://github.com/kubernetes-sigs/apiserver-network-proxy/) project and is aimed to be the replacement of the older KKP-specific solution based on OpenVPN and network address translation. Since the old solution was facing several limitations, it has been replaced with Konnectivity and will be removed in future KKP releases.

#### Enabling Konnectivity for New Clusters

Konnectivity can be enabled on per-user-cluster basis. When creating a new user cluster, the `Konnectivity` checkbox will become available in the Advanced Network Configuration part of the cluster in the KKP UI (and will be enabled by default):

![Cluster Settings - Network Configuration](/img/kubermatic/main/tutorials/networking/ui_cluster_konnectivity.png?classes=shadow,border "Cluster Settings - Network Configuration")

When this option is checked (which it is by default), Konnectivity will be used for control plane to worker nodes communication in the cluster. Otherwise, the old OpenVPN solution will be used.

#### Switching Existing Clusters to Konnectivity

Existing user clusters that are using OpenVPN can be migrated to Konnectivity at any time via the "Edit Cluster" dialog in KKP UI:

{{% notice warning %}}

This action will cause a restart of most of the control plane components and result in temporary cluster unavailability, so it should be performed during a maintenance window.

{{% /notice %}}

![Cluster Details - Edit Cluster Dialog](/img/kubermatic/main/tutorials/networking/ui_cluster_dialog_konnectivity.png?classes=shadow,border "Cluster Details - Edit Cluster Dialog")

After switching to Konnectivity, give the control plane components in Seed enough time to redeploy (may take several minutes). Once this redeployment is done, you should see two `konnectivity-agent` replicas running in the user cluster instead of the `openvpn-client` pod. Apart from it, you should also see new `metrics-server` pods running in the user cluster:

```bash
$ kubectl get pods -n kube-system

NAMESPACE              NAME                                        READY   STATUS    RESTARTS   AGE
kube-system            konnectivity-agent-c5f76c89f-8mxvt          1/1     Running   0          6m35s
kube-system            konnectivity-agent-c5f76c89f-hhdmq          1/1     Running   0          6m35s
kube-system            metrics-server-59566cbd5c-crtln             1/1     Running   0          6m35s
kube-system            metrics-server-59566cbd5c-lw75t             1/1     Running   0          6m35s
```

This action can be also reverted and an existing user cluster using Konnectivity can be switched back to the OpenVPN-based solution if necessary.

## Cluster Network Configuration in KKP API

All of the settings described in the previous sections (plus some more) can be also configured via KKP API endpoint for managing clusters:

`/api/v2/projects/{project_id}/clusters/{cluster_id}`

The CNI type and version can be configured in `spec.cniPlugin.type` and `spec.cniPlugin.version`.

The other networking parameters are configurable in `spec.clusterNetwork`.

When no explicit value for a setting is provided, the default value is applied. The following table summarizes the parameters configurable via the KKP UI / `spec.clusterNetwork` in the cluster API with their default values,
as described in the [Default Cluster Networking Configuration](#default-cluster-network-configuration) section.

## Default Cluster Network Configuration

The following table describes the cluster networking configuration options along with their default values, that are in
use if not explicitly specified:

| Parameter                  | Default Value                                                                                                | Description                                                                                                                                                                                                                                         |
|----------------------------|--------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ipFamily`                 | `IPv4`                                                                                                       | IP family used for cluster networking. Supported values are empty, `IPv4` or `IPv4+IPv6`. Can be omitted (empty) if pods and services CIDR ranges are specified. See [Dual-Stack Networking]({{< relref "../dual-stack/" >}}) for more information. |
| `pods.cidrBlocks`          | `[172.25.0.0/16]` (`[172.26.0.0/16]` for Kubevirt, `[172.25.0.0/16, fd01::/48]` for `IPv4+IPv6` ipFamily)    | The network ranges from which POD networks are allocated.                                                                                                                                                                                           |
| `services.cidrBlocks`      | `[10.240.16.0/20]` (`[10.241.0.0/20]` for Kubevirt, `[10.240.16.0/20, fd02::/120]` for `IPv4+IPv6` ipFamily) | The network ranges from which service VIPs are allocated.                                                                                                                                                                                           |
| `nodeCidrMaskSizeIPv4`     | `24`                                                                                                         | The mask size (prefix length) used to allocate a node-specific pod subnet within the provided IPv4 Pods CIDR. It has to be larger than the provided IPv4 Pods CIDR prefix length.                                                                   |
| `nodeCidrMaskSizeIPv6`     | `64`                                                                                                         | The mask size (prefix length) used to allocate a node-specific pod subnet within the provided IPv6 Pods CIDR. It has to be larger than the provided IPv6 Pods CIDR prefix length.                                                                   |
| `proxyMode`                | `ipvs`                                                                                                       | kube-proxy mode (`ipvs`/ `iptables` / `ebpf`). `ebpf` is allowed only if Cilium CNI is selected and [Konnectivity](#konnectivity) is enabled).                                                                                                      |
| `dnsDomain`                | `cluster.local`                                                                                              | Domain name for k8s services.                                                                                                                                                                                                                       |
| `ipvs.strictArp`           | `true` for `ipvs` proxyMode, `false` otherwise                                                               | If enabled, configures `arp_ignore` and `arp_announce` kernel parameters to avoid answering ARP queries from `kube-ipvs0` interface.                                                                                                                |
| `nodeLocalDNSCacheEnabled` | `true`                                                                                                       | Enables NodeLocal DNS Cache - caching DNS server running on each worker node in the cluster.                                                                                                                                                        |
| `konnectivityEnabled`      | `false`                                                                                                      | Enables [Konnectivity](#konnectivity) for control plane to node network communication.                                                                                                                                                              |
