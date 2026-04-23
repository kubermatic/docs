+++
title = "v1alpha1 API Reference"
date = 2026-04-22T19:41:35+01:00
weight = 11
+++
## v1alpha1

* [APIEndpoint](#apiendpoint)
* [ControlPlaneConfig](#controlplaneconfig)
* [DashboardAuthConfig](#dashboardauthconfig)
* [DashboardBasicConfig](#dashboardbasicconfig)
* [DashboardConfiguration](#dashboardconfiguration)
* [DashboardOIDCConfig](#dashboardoidcconfig)
* [DeveloperConfiguration](#developerconfiguration)
* [DexConfiguration](#dexconfiguration)
* [DexConnector](#dexconnector)
* [DexStaticClient](#dexstaticclient)
* [HostConfig](#hostconfig)
* [IDPConfiguration](#idpconfiguration)
* [KubeVCluster](#kubevcluster)
* [KubevirtConfiguration](#kubevirtconfiguration)
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

### DashboardAuthConfig

DashboardAuthConfig selects the authentication mode for the dashboard.
Exactly one of None, Basic, or OIDC must be set. Default is None when unset.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| none | None disables authentication. The dashboard is accessible without login. | *[NoneSpec](#nonespec) | false |
| basic | Basic enables username/password authentication backed by a Kubernetes Secret. | *[DashboardBasicConfig](#dashboardbasicconfig) | false |
| oidc | OIDC enables OpenID Connect authentication via an external provider (e.g. Dex). | *[DashboardOIDCConfig](#dashboardoidcconfig) | false |

[Back to Group](#v1alpha1)

### DashboardBasicConfig

DashboardBasicConfig holds basic-auth settings for the dashboard.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| secretName |  | string | false |
| secretNamespace |  | string | false |
| sessionDuration |  | string | false |

[Back to Group](#v1alpha1)

### DashboardConfiguration

DashboardConfiguration configures the KubeV API server and web dashboard components.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| enabled | Enabled controls whether the API server and dashboard are deployed. Defaults to false. | bool | false |
| auth | Auth configures how users authenticate to the dashboard. Required when Enabled is true. | [DashboardAuthConfig](#dashboardauthconfig) | false |
| dashboardURL | DashboardURL is the public URL where the dashboard is reachable (e.g. \"https://kubev.example.com\"). Used as the redirect target after a successful OIDC login. | string | false |
| imagePullSecret | ImagePullSecret is the raw Docker config JSON for authenticating to the image registry. If empty, the installer checks KUBEV_USERNAME and KUBEV_PASSWORD environment variables. | string | false |

[Back to Group](#v1alpha1)

### DashboardOIDCConfig

DashboardOIDCConfig holds the OIDC provider settings for the dashboard.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| issuerURL |  | string | true |
| clientID |  | string | true |
| clientSecret |  | string | true |
| redirectURL |  | string | true |
| scopes |  | []string | false |

[Back to Group](#v1alpha1)

### DeveloperConfiguration

DeveloperConfiguration holds settings for developers working on KubeV and KubeVirt.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| featureGates | FeatureGates specifies a list of experimental feature gates to enable. Defaults to none. A feature gate must not appear in both FeatureGates and DisabledFeatureGates. | []string | false |
| useEmulation | UseEmulation can be set to true to allow fallback to software emulation in case hardware-assisted emulation is not available. Defaults to false | bool | false |

[Back to Group](#v1alpha1)

### DexConfiguration

DexConfiguration configures the Dex OIDC identity provider deployed alongside the cluster.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| issuer | Issuer is the base URL at which Dex will be reachable (e.g., \"https://dex.example.com\"). | string | true |
| connectors | Connectors is the list of identity provider connectors (OIDC, LDAP, GitHub, etc.). | [][DexConnector](#dexconnector) | false |
| staticClients | StaticClients is the list of pre-registered OAuth2 clients. | [][DexStaticClient](#dexstaticclient) | false |
| enablePasswordDB | EnablePasswordDB enables the built-in local password database connector. | bool | false |

[Back to Group](#v1alpha1)

### DexConnector

DexConnector defines a single Dex identity provider connector.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| type | Type is the connector type (e.g., \"oidc\", \"ldap\", \"github\"). | string | true |
| id | ID is a unique identifier for this connector. | string | true |
| name | Name is the human-readable display name shown on the login page. | string | true |
| config | Config holds connector-specific configuration. The structure depends on Type. | apiextensionsv1.JSON | false |

[Back to Group](#v1alpha1)

### DexStaticClient

DexStaticClient defines a statically configured OAuth2 client in Dex.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| id | ID is the OAuth2 client identifier. | string | true |
| secret | Secret is the plaintext OAuth2 client secret. | string | false |
| name | Name is the human-readable display name for this client. | string | true |
| redirectURIs | RedirectURIs is the list of allowed redirect URIs for this client. | []string | false |
| public | Public marks this as a public client (no secret required, e.g. for CLI flows). | bool | false |

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
| tunnelInterface | TunnelInterface specifies the physical NIC used for Kube-OVN overlay tunnel traffic on this node. Must be a valid Linux network interface name (max 15 characters, alphanumeric with _, ., -). | string | false |

[Back to Group](#v1alpha1)

### IDPConfiguration

IDPConfiguration selects which identity provider to deploy alongside the cluster.
Exactly one of Dex or None must be set. Default is None when unset.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| dex | Dex deploys a Dex OIDC identity provider alongside the cluster. | *[DexConfiguration](#dexconfiguration) | false |
| none | None explicitly disables any managed identity provider deployment. | *[NoneSpec](#nonespec) | false |

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
| offlineSettings | OfflineSettings configures the platform for air-gapped (offline) operation. When used, all external dependencies must be served from internal mirrors. | [OfflineSettings](#offlinesettings) | false |
| kubevirt | KubevirtConfiguration holds settings specific to the KubeVirt integration. | [KubevirtConfiguration](#kubevirtconfiguration) | false |
| idp | IDP configures an optional identity provider to deploy alongside the cluster. Exactly one option (e.g., Dex, None) must be specified. Default is None when unset. | [IDPConfiguration](#idpconfiguration) | false |
| dashboard | Dashboard configures the KubeV API server and web dashboard. | [DashboardConfiguration](#dashboardconfiguration) | false |

[Back to Group](#v1alpha1)

### KubevirtConfiguration

KubevirtConfiguration holds settings specific to the KubeVirt integration.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| developerConfiguration | DeveloperConfiguration holds settings for developers working on KubeV and KubeVirt. | *[DeveloperConfiguration](#developerconfiguration) | false |

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
| tunnelInterface | TunnelInterface specifies the physical NIC used for Kube-OVN overlay tunnel traffic. Accepts a single interface name (e.g., \"eth0\"), a comma-separated list (e.g., \"eth0,eth1\"), or a regular expression (e.g., \"^eth[0-9]+$\"). | string | false |

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
