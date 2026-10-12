+++
title = "KubeLB"
date = 2023-10-27T10:07:15+02:00
weight = 15
enterprise = true
+++

KubeLB is a Kubernetes native tool, responsible for centrally managing load balancers for Kubernetes clusters across multi-cloud and on-premise environments.

## Usage

Starting with KKP v2.24, KubeLB is integrated into the Kubermatic Kubernetes Platform (KKP). This means that you can use KubeLB to provision load balancers for your KKP clusters. KKP will take care of configurations and deployments for you in the user cluster. Admins mainly need to create the KubeLB management cluster and configure KKP to use it. For KubeLB management cluster and it's configuration please refer to the [KubeLB documentation]({{< ref "/kubelb" >}})

{{% notice warning %}}
For KKP v2.26 or higher, your KubeLB management cluster must be using KubeLB v1.1 or higher for proper integration. KubeLB v1.1 introduces `Tenant` API to manage tenants which is not supported below KKP v2.26.
{{% /notice %}}

## Configuration

KubeLB can be configured in the following way:

* Generate a Kubeconfig for the KubeLB management cluster by following the instructions [here](https://docs.kubermatic.com/kubelb/latest/tutorials/kkp).
* (Optional: If you didn't create kubeconfig via the instructions above) Create a secret with the key `kubeconfig` that contains the kubeconfig for the KubeLB management cluster like this:

```yaml
apiVersion: v1
data:
  # You can use `base64 -w0 kubelb-management-kubeconfig` to encode the
  # kubeconfig properly for inserting into this Secret.
  kubeconfig: <base64 encoded kubeconfig>
kind: Secret
metadata:
  name: kubelb-management-cluster
  namespace: kubermatic
type: Opaque
```

* Configure `Seed` as follows:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Seed
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  # these two fields are only informational
  country: FR
  location: Paris

  # KubeLB configuration
  kubelb:
    # Set to true to enable KubeLB for all the datacenters belong to this seed. This will not install KubeLB for the user clusters, has to be configured at the cluster level.
    enableForAllDatacenters: false
    kubeconfig:
      name: kubelb-management-cluster
      namespace: kubermatic

  # List of datacenters where this seed cluster is allowed to create clusters.
  datacenters:
    vsphere-de:
      country: DE
      location: Hamburg
      spec:
        vsphere:
          endpoint: "https://vsphere.hamburg.example.com"
        kubelb:
          # To enable KubeLB for this datacenter. This will not install KubeLB for the user clusters, has to be configured at the cluster level.
          enabled: true
          # Enforced is used to enforce kubeLB installation for all the user clusters belonging to this datacenter. Setting enforced to false will not uninstall kubeLB from # the user clusters and it needs to be disabled manually.
          enforced: false
          # NodeAddressType is used to configure the address type from node, used for load balancing. Optional: Defaults to ExternalIP
          nodeAddressType: InternalIP
          # Kubeconfig is reference to the Kubeconfig for the kubeLB management cluster. Kubeconfig specified at the datacenter level will have precedence over the
          # kubeconfig specified at the seed level.
          kubeconfig: nil
          # UseLoadBalancerClass is used to configure the use of load balancer class `kubelb` for kubeLB. If false, kubeLB will manage all load balancers in the
          # user cluster irrespective of the load balancer class.
          useLoadBalancerClass: false
          # EnableGatewayAPI is used to configure the use of gateway API for kubeLB.
          enableGatewayAPI: false
          # DisableGatewayAPIProtection disables the protection of the Gateway API CRDs for the user clusters of this datacenter.
          # See "Gateway API CRD Protection" below.
          disableGatewayAPIProtection: false
          # EnableSecretSynchronizer is used to configure the use of secret synchronizer for kubeLB.
          enableSecretSynchronizer: false
          # DisableIngressClass is used to disable the ingress class `kubelb` filter for kubeLB.
          disableIngressClass: false

```

* Enable KubeLB for the user cluster:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Cluster
metadata:
  name: crh4xbxz5f
spec:
...
  kubelb:
    enabled: true
...
```

This can be enabled using the KKP dashboard as well.

![Enable KubeLB during cluster creation](kubelb-dashboard.png?classes=shadow,border "Enable KubeLB during cluster creation")

### Gateway API CRD Protection

When Gateway API support is enabled for a user cluster (`spec.kubelb.enableGatewayAPI: true`), the KubeLB CCM installs and manages the Gateway API CRDs in that cluster. If another component replaces these CRDs, for example by applying an upstream Gateway API release bundle, the KubeLB CCM can stop working and crashloop.

To prevent this, KKP protects the Gateway API CRDs in every user cluster where both KubeLB and Gateway API support are enabled. Protection is enabled by default and does the following:

* KKP creates a `ValidatingAdmissionPolicy` and a `ValidatingAdmissionPolicyBinding`, both named `kubermatic-kubelb-gateway-api-crds`, in the user cluster. They reject creating, updating and deleting CRDs in the `gateway.networking.k8s.io` and `gateway.networking.x-k8s.io` API groups for every identity except the KubeLB CCM. Other CRDs are not affected.
* KKP removes the upstream `safe-upgrades.gateway.networking.k8s.io` policy and its binding from the user cluster. Every upstream Gateway API release bundle ships this policy. It rejects Gateway API CRDs older than the bundle it came with, which blocks the KubeLB CCM from installing its own CRDs.
* KKP restores the policy and binding if they are deleted or modified.

A rejected request fails with the following message:

```text
Gateway API CRDs in this cluster are installed and managed by KubeLB, because Gateway API support is enabled for this cluster (spec.kubelb.enableGatewayAPI). Installing or modifying them breaks the KubeLB CCM. Set spec.kubelb.disableGatewayAPIProtection to true to manage the Gateway API CRDs yourself, or disable spec.kubelb.enableGatewayAPI to stop KubeLB from using them.
```

When KubeLB or Gateway API support is disabled for a cluster, KKP removes the policy and binding and no longer touches the Gateway API CRDs.

#### Disabling the protection

If you want to manage the Gateway API CRDs yourself, you can disable the protection. When the protection is disabled, KKP removes its policy and binding from the user cluster and leaves the upstream `safe-upgrades` policy in place.

{{% notice warning %}}
With the protection disabled, the KubeLB CCM can fail if the installed Gateway API CRDs or the `safe-upgrades` policy are incompatible with the CRD version it installs. Make sure that the Gateway API CRDs you install are compatible with the KubeLB CCM.
{{% /notice %}}

Protection can be disabled at three levels. If any level disables it, protection is off. A lower level cannot re-enable protection that a higher level disabled.

| Level | Field | Scope |
| ----- | ----- | ----- |
| `KubermaticConfiguration` | `spec.userCluster.kubelb.disableGatewayAPIProtection` | All user clusters |
| `Seed` | `spec.datacenters.<datacenter>.spec.kubelb.disableGatewayAPIProtection` | User clusters in this datacenter |
| `Cluster` | `spec.kubelb.disableGatewayAPIProtection` | This user cluster |

##### Admin level

To disable the protection for all user clusters, set the field in the `KubermaticConfiguration`:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  userCluster:
    kubelb:
      disableGatewayAPIProtection: true
```

To disable the protection for the user clusters of a single datacenter, set the field in the datacenter's KubeLB settings in the `Seed`:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Seed
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  datacenters:
    vsphere-de:
      spec:
        kubelb:
          enabled: true
          disableGatewayAPIProtection: true
```

Changing an admin-level setting restarts the user cluster controller manager of each affected user cluster.

##### Cluster level

To disable the protection for a single user cluster, set the field in the `Cluster`:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Cluster
metadata:
  name: crh4xbxz5f
spec:
...
  kubelb:
    enabled: true
    enableGatewayAPI: true
    disableGatewayAPIProtection: true
...
```

### Tenant defaulting at Project level

KubeLB Tenant Spec can be defaulted in the related `Project` as follows:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Project
metadata:
  name: 2msp2ww6gw
spec:
  defaultTenantSpec:
    # Whether all annotations should propagate to the LoadBalancer service
    propagateAllAnnotations: false
    # Specific annotations to propagate to the LoadBalancer service
    propagatedAnnotations:
      service.beta.kubernetes.io/aws-load-balancer-type: "external"
    # Default annotations set on load balancing resources if not already present
    defaultAnnotations:
      service:
        service.beta.kubernetes.io/aws-load-balancer-internal: "true"
      ingress:
        nginx.ingress.kubernetes.io/ssl-redirect: "true"
    # Restrict allowed domains across all tenant components
    allowedDomains:
      - example.com
```

The options for configuring default values for a kubelb tenant can be viewed in [kubelb tenant api specification](https://docs.kubermatic.com/kubelb/latest/references/ee/#tenantspec).

KKP applies `defaultTenantSpec` at Tenant creation and whenever the defaults change, using Server-Side Apply. KKP updates existing Tenants in place; you do not need to recreate them.

* Removing a field from `defaultTenantSpec` also removes it from the Tenants, but only if KKP set the field.
* KKP does not change fields that other components or users set, for example with `kubectl`. If a default conflicts with such a field, KKP reports an error and leaves the field unchanged.
* A conflict on a Tenant does not stop KKP from maintaining the KubeLB CCM in the affected cluster.
