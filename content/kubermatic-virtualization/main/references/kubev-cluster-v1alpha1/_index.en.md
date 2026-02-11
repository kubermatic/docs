+++
title = "v1alpha1 API Reference"
date = 2025-12-18T23:08:43+01:00
weight = 11
+++
## v1alpha1

* [APIEndpoint](#apiendpoint)
* [ControlPlaneConfig](#controlplaneconfig)
* [HostConfig](#hostconfig)
* [KubeVCluster](#kubevcluster)
* [LoadBalancerSpec](#loadbalancerspec)
* [Longhorn](#longhorn)
* [MetalLBSpec](#metallbspec)
* [NetworkConfiguration](#networkconfiguration)
* [NoneSpec](#nonespec)
* [OCIConfiguration](#ociconfiguration)
* [OfflineSettings](#offlinesettings)
* [StaticWorkersConfig](#staticworkersconfig)
* [StorageConfiguration](#storageconfiguration)

### APIEndpoint

APIEndpoint is the endpoint used to communicate with the Kubernetes API.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| host | Host is the hostname or IP on which API is running. | string | true |
| alternativeNames | AlternativeNames is a list of Subject Alternative Names for the API Server signing cert. | []string | false |

[Back to Group](#v1alpha1)

### ControlPlaneConfig

ControlPlaneConfig defines control plane nodes.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| hosts | Hosts array of all control plane hosts. | [][HostConfig](#hostconfig) | true |

[Back to Group](#v1alpha1)

### HostConfig

HostConfig describes a single control plane or worker node.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| address | Address is internal RFC-1918 IP address. | string | true |
| sshUsername | SSHUsername is system login name. Default value is \"root\". | string | false |
| sshPrivateKeyFile | SSHPrivateKeyFile is path to the file with PRIVATE AND CLEANTEXT ssh key. Default value is \"\". | string | false |
| labels | Labels to be used to apply (or remove, with minus symbol suffix, see more kubectl help label) labels to/from node | map[string]string | false |
| annotations | Annotations to be used to apply (or remove, with minus symbol suffix, see more kubectl help annotate) annotations to/from node | map[string]string | false |

[Back to Group](#v1alpha1)

### KubeVCluster

KubeVCluster is Kubermatic Virtualization Cluster API Schema.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| controlPlane | ControlPlane describes the control plane nodes and how to access them. | [ControlPlaneConfig](#controlplaneconfig) | true |
| staticWorkers | StaticWorkers describes the worker nodes that are managed by KubeV/kubeadm. | [StaticWorkersConfig](#staticworkersconfig) | false |
| networkConfiguration | NetworkConfiguration holds the network settings for the Kubermatic Virtualization Platform. | [NetworkConfiguration](#networkconfiguration) | false |
| apiEndpoint | APIEndpoint are pairs of address and port used to communicate with the Kubernetes API. | [APIEndpoint](#apiendpoint) | true |
| loadBalancer | LoadBalancer configures the platform's external load balancing. Exactly one implementation (e.g., MetalLB, None) must be specified. | [LoadBalancerSpec](#loadbalancerspec) | false |
| storage | Storage configures the persistent storage solution for the cluster. Exactly one option (e.g., Longhorn, None) must be specified. | [StorageConfiguration](#storageconfiguration) | false |
| offlineSettings |  | [OfflineSettings](#offlinesettings) | false |

[Back to Group](#v1alpha1)

### LoadBalancerSpec

LoadBalancerSpec configures the platform's load balancing.
Exactly one of the following fields must be set: None, MetalLB.
(KubeLB will be supported in the future.)
If no load balancer is desired, set None: {}.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| none | None explicitly disables external L4 load balancing. Use this when LoadBalancer-type services should not be exposed externally. | *[NoneSpec](#nonespec) | false |
| metallb | MetalLB configures MetalLB to allocate external IPs for LoadBalancer services. | *[MetalLBSpec](#metallbspec) | false |

[Back to Group](#v1alpha1)

### Longhorn

Longhorn defines Longhorn-specific settings.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |

[Back to Group](#v1alpha1)

### MetalLBSpec

MetalLBSpec defines MetalLB-specific settings.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| ipRange | IPRange is the IP address range used to allocate external IPs for LoadBalancer services. Acceptable formats: CIDR (e.g., \"192.168.10.0/24\") or inclusive range (e.g., \"192.168.10.50-192.168.10.100\"). | string | true |

[Back to Group](#v1alpha1)

### NetworkConfiguration



| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| networkCIDR | NetworkCIDR specifies the IP address range used to assign network addresses to all managed workloads, including containers and virtual machines. This CIDR block serves as the default pool for internal IP allocation across the platform. | string | false |
| dnsServerIP | DNSServerIP is the IP address of the DNS server used by the entire platform. This field is required. In offline deployments, this address will be configured as the DNS resolver for all nodes and services within the Kubermatic Virtualization Platform. | string | true |
| gatewayIP | GatewayIP specifies the IP address of the network gateway for the default NetworkCIDR. This gateway facilitates external network access for workloads within the Kubermatic Virtualization Platform. | string | false |
| serviceCIDR | ServiceCIDR specifies the IP address range reserved for internal platform services. This CIDR block is used to allocate virtual IPs for services, ensuring they are reachable within the platform. | string | false |

[Back to Group](#v1alpha1)

### NoneSpec

NoneSpec is a marker type used to explicitly disable LB/CSI integration.
It carries no configuration.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |

[Back to Group](#v1alpha1)

### OCIConfiguration

OCIConfiguration defines how to connect to an OCI-compatible container registry.
This is used for pulling container images and Helm charts in offline environments.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| address | Address is the registry hostname and optional port (e.g., \"http://registry.example.com:5000\"). | string | true |
| username | Username is the basic-auth username for registry authentication. Required if the registry requires authentication. | string | false |
| password | Password is the basic-auth password for registry authentication. | string | false |
| insecure | Insecure, when true, disables TLS verification and may allow HTTP connections. Use only for internal, trusted registries. Not recommended for production. | bool | false |

[Back to Group](#v1alpha1)

### OfflineSettings

OfflineSettings configures the platform for air-gapped (offline) operation.
When used, all external dependencies must be served from internal mirrors.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| enabled | Enabled indicates whether the platform is operating in offline (air-gapped) mode. When true, all container images, Helm charts, and software packages must be sourced from the internal endpoints specified below. | bool | true |
| containerRegistry | ContainerRegistry specifies the internal OCI registry that hosts all container images required by the platform and workloads. This registry must be pre-populated before deployment. | [OCIConfiguration](#ociconfiguration) | true |
| helmRegistry | HelmRegistry specifies the internal OCI registry or HTTP server that hosts Helm charts used by the platform. Charts must be available at this location in offline mode. | [OCIConfiguration](#ociconfiguration) | true |
| packageRepository | PackageRepository is the URL or local path to the internal repository serving platform-related OS or software packages (e.g., RPMs, DEBs, or binaries). This is used during node provisioning and upgrades in offline environments. | string | true |

[Back to Group](#v1alpha1)

### StaticWorkersConfig

StaticWorkersConfig defines static worker nodes provisioned by KubeOne and kubeadm.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| hosts | Hosts | [][HostConfig](#hostconfig) | false |

[Back to Group](#v1alpha1)

### StorageConfiguration

StorageConfiguration configures the platform's persistent storage solution.
Exactly one of the following fields must be set: None, Longhorn.
(Additional storage providers may be supported in the future.)
If no managed storage is desired, set None: {}.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| none | None explicitly disables managed storage integration. Users must provide their own StorageClass or provision volumes manually. | *[NoneSpec](#nonespec) | false |
| longhorn | Longhorn configures Longhorn as the default distributed block storage system. | *[Longhorn](#longhorn) | false |

[Back to Group](#v1alpha1)
