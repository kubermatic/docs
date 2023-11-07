+++
title = "KubeLB"
date = 2023-10-27T10:07:15+02:00
weight = 15
+++

KubeLB is a Kubernetes native tool, responsible for centrally managing load balancers for Kubernetes clusters across multi-cloud and on-premise environments.

## Usage

Starting with KKP v2.24, KubeLB is integrated into the Kubermatic Kubernetes Platform (KKP). This means that you can use KubeLB to provision load balancers for your KKP clusters. KKP will take care of configurations and deployments for you in the user cluster. Admins mainly need to create the KubeLB management cluster and configure KKP to use it. For KubeLB management cluster and it's configuration please refer to the [KubeLB documentation]({{< ref "/kubelb" >}})

KubeLB can be configured in the following way:

* Create a secret with the key `kubeconfig` that contains the kubeconfig for the KubeLB management cluster.
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

![Enable KubeLB during cluster creation](/img/kubermatic/v2.24/tutorials/kubelb/kubelb_dashboard.png?classes=shadow,border "Enable KubeLB during cluster creation")
