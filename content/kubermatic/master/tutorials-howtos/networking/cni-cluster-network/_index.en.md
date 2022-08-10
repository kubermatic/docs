+++
linkTitle = "CNI & Cluster Network Configuration"
title = "CNI (Container Network Interface) & Cluster Network Configuration"
date = 2021-09-07T16:06:10+02:00
weight = 10
enableToc = true
+++

This page describes various cluster networking options that can be configured for each KKP user cluster either via KKP UI
or via [KKP API](#cluster-cluster-network-configuration-in-kkp-api). Most of this configuration can be specified only
at the cluster creation time and cannot be changed in an already existing clusters.

Cluster networking can be configured in the "Network Configuration" part of the cluster creation wizard, as shown below:

![Cluster Settings - Network Configuration](/img/kubermatic/master/tutorials/networking/ui_cluster_networking.png?classes=shadow,border "Cluster Settings - Network Configuration")

## CNI Type and Version

KKP supports three types of CNI (Container Network Interface) plugin types:

- **[Canal](#canal-cni)**
- **[Cilium](#cilium-cni)**
- **[None](#none-cni)**

Apart from these, KKP also supports [Multus-CNI addon]({{< relref "../multus/" >}}). This is a CNI meta-plugin that can be installed on top of any of the supported primary CNIs.

The following table lists the versions of individual CNIs supported by KKP:

| KKP version | Canal                                                             | Cilium           |
|-------------|-------------------------------------------------------------------|------------------|
| `v2.21.x`   | `v3.23`, `v3.22`, `v3.21`, `v3.20`, (deprecated: `v3.8`, `v3.19`) | `v1.11`, `v1.12` |
| `v2.20.x`   | `v3.22`, `v3.21`, `v3.20`, `v3.19`, (deprecated: `v3.8`)          | `v1.11`          |
| `v2.19.x`   | `v3.21`, `v3.20`, `v3.19`, (deprecated: `v3.8`)                   | `v1.11`          |
| `v2.18.x`   | `v3.19` (deprecated: `v3.8`)                                      | -                |
| `v2.17.x`   | `v3.8`                                                            | -                |

**Note:** The deprecated versions cannot be used for new KKP user clusters, but are supported for backward compatibility of existing clusters.

The desired CNI type and version can be selected at the cluster creation time - on the Cluster Settings page, as shown below:

![Cluster Settings - Network Configuration](/img/kubermatic/master/tutorials/networking/ui_cluster_cni.png?classes=shadow,border "Cluster Settings - Network Configuration")

Available CNI versions depend on the KKP version. Note that CNI type cannot be changed after cluster creation, but [manual CNI migration]({{< relref "../cni-migration/" >}}) is possible when necessary.

### Canal CNI

[Canal](https://projectcalico.docs.tigera.io/getting-started/kubernetes/flannel/flannel) is a combination of Flannel CNI and Calico CNI, which sets up Flannel to manage pod networking and Calico to handle policy management. It is a CNI that works fine in most environments but may not be sufficient for some large scale use-cases.

In KKP versions below v2.19, this was the only supported CNI.

### Cilium CNI

[Cilium](https://cilium.io/) is a feature-rich CNI plugin, which leverages the revolutionary eBPF Kernel technology. It provides enhanced security and observability features, but requires more recent kernel versions on the worker nodes (see [Cilium System Requirements](https://docs.cilium.io/en/stable/operations/system_requirements/)).  
The following table lists the supported operating systems and cloud providers for cilium CNI in KKP:

{{%expand "With ebpf proxy mode" %}}
|                       | Ubuntu | CentOS | Flatcar | RHEL | Amazon Linux 2 | SLES |
| --------------------- | ------ | ------ | ------- | ---- | -------------- | ---- |
| AWS                   | ✓      | -      | ✓       | ✓    | ✓              | x    |
| Azure                 | ✓      | -      | ✓       | ✓    | -              | -    |
| Digitalocean          | ✓      | x      | -       | -    | -              | -    |
| Google Cloud Platform | ✓      | -      | -       | -    | -              | -    |
| Hetzner               | ✓      | x      | -       | -    | -              | -    |
| KubeVirt              | ✓      | x      | ✓       | ✓    | -              | -    |
| Equinix Metal         | ✓      | x      | -       | -    | -              | -    |
| Openstack             | ✓      | x      | ✓       | ✓    | -              | -    |

**NOTE:**

- A hyphen(-) denotes that the operating system is not supported for the given cloud provider.

{{% /expand%}}

{{%expand "With iptables proxy mode" %}}
|                       | Ubuntu | CentOS | Flatcar | RHEL | SLES |
| --------------------- | ------ | ------ | ------- | ---- | ---- |
| AWS                   | ✓      | x      | ✓       | ✓    | x    |
| Azure                 | ✓      | -      | ✓       | x    | -    |
| Digitalocean          | ✓      | x      | -       | -    | -    |
| Google Cloud Platform | ✓      | -      | -       | -    | -    |
| Hetzner               | ✓      | x      | -       | -    | -    |
| KubeVirt              | ✓      | x      | ✓       | ✓    | -    |
| Equinix Metal         | ✓      | x      | -       | -    | -    |
| Openstack             | ✓      | x      | ✓       | ✓    | -    |

**NOTE:**

- A hyphen(-) denotes that the operating system is not supported for the given cloud provider.
- A tilde(~) denotes a partial support

{{% /expand%}}

**NOTE:** IPVS kube-proxy mode is not recommended with Cilium CNI due to [a known issue]({{< relref "../../../architecture/known-issues/" >}}#2-connectivity-issue-in-pod-to-nodeport-service-in-cilium--ipvs-proxy-mode).

The most of the Cilium CNI features can be utilized when the `ebpf` Proxy Mode is used (Cilium `kube-proxy-replacement` is enabled). This can be done by selecting `ebpf` for `Proxy Mode` in the [Cluster Network Configuration](#other-cluster-network-configuration). Please note that this option is available only of [Konnectivity](#konnectivity) is enabled.

To provide better observability on cluster networking with Cilium CNI via a web user interface, KKP provides a Hubble Addon that can be easily installed into user clusters with Cilium CNI via the KKP UI on the cluster page, as shown below:

![Cluster Details - Addons](/img/kubermatic/master/tutorials/networking/ui_addons.png?classes=shadow,border "Cluster Details - Addons")

![Cluster Details - Addons - Install Addon](/img/kubermatic/master/tutorials/networking/ui_addon_hubble.png?classes=shadow,border "Cluster Details - Addons - Install Addon")

After the Hubble addon is installed into the cluster, the Hubble UI can be displayed by port-forwarding to it, e.g.:

```bash
kubectl port-forward -n kube-system svc/hubble-ui 12000:80
```

After the above port-forwarding is active, the Hubble UI can be shown by navigating to the URL [http://localhost:12000](http://localhost:12000).

Please note that to have the Hubble addon available, the KKP installation has to be configured with `hubble` as [an accessible addon]({{< relref "../../../architecture/concept/kkp-concepts/addons/#accessible-addons" >}}).

### None CNI

"None" CNI is a special KKP-internal CNI type, which does not install any CNI managed by KKP into the user cluster. CNI management is therefore left on the cluster admin which provides a flexible option to install any CNI with any specific configuration.

When this option is selected, the user cluster will be left without any CNI, and will not be functioning until some CNI is installed into it by the cluster admin. This can be done either manually (e.g. via helm charts), or by leveraging KKP [Addons]({{< relref "../../../architecture/concept/kkp-concepts/addons/#accessible-addons" >}}) infrastructure and creating a custom Accessible addon.
When deploying your own CNI, please make sure you pass proper pods & services CIDRs to your CNI configuration - matching with the KKP user-cluster level configuration in the [Advanced Network Configuration](#advanced-network-configuration).

### CNI Version Upgrades

If the KKP installation supports a newer version of the CNI installed in a user cluster, it is possible to upgrade to it. This will be shown in the KKP UI and the available versions will be listed in the upgrade dialog shown after clicking on the "CNI Plugin Version" box:

![Cluster Details](/img/kubermatic/master/tutorials/networking/ui_cni_upgrade_available.png?classes=shadow,border "Cluster Details")

![Cluster Details - CNI Plugin Version Dialog](/img/kubermatic/master/tutorials/networking/ui_cni_upgrade_dialog.png?classes=shadow,border "Cluster Details - CNI Plugin Version Dialog")

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

![Cluster Settings - Advanced Network Configuration](/img/kubermatic/master/tutorials/networking/ui_cluster_networking_advanced.png?classes=shadow,border "Cluster Settings - Network Configuration")

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
Konnectivity provides TCP level proxy for the control plane (seed cluster) to worker nodes (user cluster) communication. Defaults to `0.0.0.0/0` (allowed from everywhere). It is based on the upstream [apiserver-network-proxy](https://github.com/kubernetes-sigs/apiserver-network-proxy/) project and is aimed to be the replacement of the older KKP-specific solution based on OpenVPN and network address translation. Since the old solution was facing several limitations, it will be replaced with Konnectivity in future KKP releases.

#### Enabling Konnectivity in KubermaticConfiguration

To enable Konnectivity for control plane to worker nodes communication, the feature first has to be enabled in `KubermaticConfiguration` by enabling the `KonnectivityService` feature gate, e.g.:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  featureGates:
    KonnectivityService: true
```

All existing clusters started before enabling `KonnectivityService` feature gate will continue using OpenVPN.

#### Enabling Konnectivity for New Clusters

Once the `KonnectivityService` feature gate is enabled, Konnectivity can be enabled on per-user-cluster basis. When creating a new user cluster, the `Konnectivity` checkbox will become available in the Advanced Network Configuration part of the cluster in the KKP UI (and will be enabled by default):

![Cluster Settings - Network Configuration](/img/kubermatic/master/tutorials/networking/ui_cluster_konnectivity.png?classes=shadow,border "Cluster Settings - Network Configuration")

When this option is checked, Konnectivity will be used for control plane to worker nodes communication in the cluster. Otherwise, the old OpenVPN solution will be used.

#### Switching Existing Clusters to Konnectivity

Given that the `KonnectivityService` feature gate is enabled, existing user clusters that are using OpenVPN can be migrated to Konnectivity at any time via the "Edit Cluster" dialog in KKP UI:

{{% notice warning %}}

This action will cause a restart of most of the control plane components and result in temporary cluster unavailability, so it should be performed during a maintenance window.

{{% /notice %}}

![Cluster Details - Edit Cluster Dialog](/img/kubermatic/master/tutorials/networking/ui_cluster_dialog_konnectivity.png?classes=shadow,border "Cluster Details - Edit Cluster Dialog")

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
| `konnectivityEnabled`      | `false`                                                                                                      | Enables [Konnectivity](#konnectivity) for control plane to node network communication. Requires `KonnectivityService` feature gate in the `KubermaticConfiguration` to be enabled.                                                                  |
