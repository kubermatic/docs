+++
title = "KubeVirt"
date = 2021-02-01T14:46:15+02:00
weight = 7

+++

## Architecture

![KubeVirt Cloud Provider Architecture](/img/kubermatic/main/architecture/supported-providers/kubevirt/architecture.png?classes=shadow,border "KubeVirt Cloud Provider Architecture")

## Installation And Configuration

### Requirements

A Kubernetes cluster (KubeVirt infrastructure cluster), which consists of nodes that **have a hardware virtualization support** with at least: 
* 2 CPUs
* 4GB of RAM
* 30GB of storage.

The cluster version must be in the scope of [supported KKP Kubernetes clusters]({{< ref "../../../tutorials-howtos/operating-system-manager/compatibility/#kubernetes-versions" >}})
and it must have the following components installed:
* KubeVirt >= 0.57 which supports the selected Kubernetes version.
* Containerized Data Importer which supports the selected KubeVirt and Kubernetes versions.

{{% notice note %}}
We recommend to install the latest stable releases of both projects.
{{% /notice %}}

The setup has been successfully tested with:
* CRI: containerd
* CNI: Canal

Other CRIs and CNIs should work too. However, they were not tested, so it is possible to discover issues.

{{% notice note %}}
To achieve the best possible performance it is recommended to run the setup on bare metal hosts with a hardware virtualization support.
Additionally, make sure that your nodes have appropriate Qemu and KVM packages installed.
{{% /notice %}}

### Kubernetes And KubeVirt Installation

We provide KubeOne, which can be used to set up a highly-available Kubernetes cluster on bare metal.  
Refer to the [KubeOne documentation]({{< ref "/kubeone/v1.5/tutorials/creating-clusters-baremetal/" >}}) for details on how to use it.

Follow [KubeVirt](https://kubevirt.io/user-guide/operations/installation/#installation) and [Containerized Data Importer](https://kubevirt.io/user-guide/operations/containerized_data_importer/#install-cdi)
documentation to find out how to install them and learn about their requirements.

We require the following KubeVirt configuration:
```yaml
apiVersion: kubevirt.io/v1
kind: KubeVirt
metadata:
  name: kubevirt
  namespace: kubevirt
spec:
  configuration:
    developerConfiguration:
      featureGates:
      - ExperimentalIgnitionSupport
      - DataVolumes
      - LiveMigration
      - CPUManager
      - CPUNodeDiscovery
      - Sidecar
      - Snapshot
      - HotplugVolumes
```

It is not required to have any specific Containerized Data Importer configuration as long the main storage is **not** local disks.
Otherwise, CDI must be configured with `HonorWaitForFirstConsumer` feature gate.

```yaml
apiVersion: cdi.kubevirt.io/v1beta1
kind: CDI
metadata:
  name: cdi
spec:
  config:
    featureGates:
    - HonorWaitForFirstConsumer
```

{{% notice note %}}
Refer to this [document](https://github.com/kubevirt/kubevirt/blob/main/docs/localstorage-disks.md)
to learn more about how KubeVirt handles local disks storage.
{{% /notice %}}

{{% notice warning %}}
Currently, it is not recommended to use local or any topology constrained storage due to [the issue with kubevirt csi driver](https://github.com/kubevirt/csi-driver/issues/66)
{{% /notice %}}

### Configure KKP With KubeVirt

Once you have Kubernetes with all needed components, the last thing is to configure KubeVirt datacenter on seed.

We allow to configure:
* `customNetworkPolicies` - Network policies that are deployed on the infrastructure cluster (where VMs run).
  * Check [Network Policy documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/#networkpolicy-resource) to see available options in the spec.
  * Also check a [common services connectivity issue](#i-created-a-load-balancer-service-on-a-user-cluster-but-services-outside-cannot-reach-it) that can be solved by a custom network policy.
* `dnsConfig` and `dnsPolicy` - DNS config and policy which are set up on a guest. Defaults to `ClusterFirst`.
  * You should set those fields when you suffer from DNS loop or collision issue. [Refer to this section for more details.](#i-discovered-a-dns-collision-on-my-cluster-why-does-it-happen) 
* `images` - Images for Virtual Machines that are selectable from KKP dashboard.
  * Set this field according to [supported operating systems]({{< ref "../../compatibility/os-support-matrix/" >}}) to make sure that users can select operating systems for their VMs.
* `infraStorageClasses` - Storage classes that are initialized on user clusters that end users can work with.
  * Pass names of KubeVirt storage classes that can be used from user clusters.

Refer to this [document](https://github.com/kubermatic/kubermatic/blob/main/docs/zz_generated.seed.ce.yaml#L115)
for more details and configuration example.

{{% notice warning %}}
By default, each user cluster is deployed with the **cluster-isolation** Network Policy that allows network communication
only inside the cluster. You should use `customNetworkPolicies` to customize the network rules to your needs.
**Remember that new rules will affect all user clusters.**
{{% /notice %}}

### Setup Monitoring

Install [prometheus-operator](https://github.com/prometheus-operator/prometheus-operator) on the KubeVirt cluster.
Then update `KubeVirt` configuration with the following spec:
```yaml
apiVersion: kubevirt.io/v1
kind: KubeVirt
metadata:
  name: kubevirt
  namespace: kubevirt
spec:
  monitorNamespace: "<<PROMETHEUS_NAMESPACE>>"
  monitorAccount: "<<PROMETHEUS_SERVICE_ACCOUNT_NAME>>"
```

For more details please refer to this [document](https://kubevirt.io/user-guide/operations/component_monitoring/).

After completing the above setup, you can import the [KubeVirt Dasboard](https://github.com/kubevirt/monitoring/tree/main/dashboards/grafana) to Grafana.  
Follow the official [Grafana documentation](https://grafana.com/docs/grafana/latest/dashboards/manage-dashboards/#export-and-import-dashboards
) to learn how to import the dashboard. 

## Advanced Settings

### Virtual Machine Templating

We provide a Virtual Machine templating functionality over [Instance Types and Preferences](https://kubevirt.io/user-guide/virtual_machines/instancetypes/).

![Instance Types and Preferences](/img/kubermatic/main/architecture/supported-providers/kubevirt/instance-type.png?classes=shadow,border "Instance Types and Preferences")

You can use our standard

Instance Types:
* standard-2 - 2 CPUs, 8Gi RAM
* standard-4 - 4 CPUs, 16Gi RAM
* standard-8 - 8 CPUs, 32Gi RAM

and Preferences (which are optional):
* sockets-advantage - cpu guest topology where number of cpus is equal to number of sockets

or you can just simply adjust the amount of CPUs and RAM of our default template according to your needs.

Additionally, if our templates will not fulfill your requirements then a KubeVirt cluster admin can create customized
instance types and preferences that users can select later. [Read how to add new Instance Types and Preferences.](#how-can-i-add-a-new-virtual-machine-template)

### Virtual Machine Scheduling

Each Virtual Machine you create has default [topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) applied:

```yaml
maxSkew: 1
topologyKey: kubernetes.io/hostname
whenUnsatisfiable: ScheduleAnyway
```

this allows us to spread Virtual Machine equally across a cluster.

However, it is possible to change the default behaviour and create your own topology combined with Node Affinity Presets.  
You can do it by expanding *ADVANCED SCHEDULING SETTINGS* on the initial nodes dashboard page.

![Instance Types and Preferences](/img/kubermatic/main/architecture/supported-providers/kubevirt/scheduling-form.png?classes=shadow,border "Advanced Scheduling Settings")

It gives you a possibility to create your own unique scheduling options that override ours.  
For instance, you could avoid creation of Virtual Machines on database nodes etc.

## Frequently Asked Questions

### How can I add a new Virtual Machine template?

You can do it by simply creating a new `VirtualMachineClusterInstancetype` and `VirtualMachineClusterPreference` on the KubeVirt infrastructure cluster.  
Those resources are cluster scoped meaning all users will see them.

Refer to the [InstanceTypes and Preferences](https://kubevirt.io/user-guide/virtual_machines/instancetypes/#virtualmachineinstancetype) guide for details on how to use it.

### How can I safely drain a bare metal node?

You can do it as with every standard k8s cluster, over `kubectl drain` command.

We implemented a mechanism that will allow you to safely drain a bare-metal node without losing the VM workload.  
After running a drain command the VMs running on the node along with their workload will be evicted to different nodes.

{{% notice note %}}
More details on the eviction implementation can be found [here](https://github.com/kubermatic/kubermatic/blob/main/docs/proposals/kubevirt-workload-eviction.md).
{{% /notice %}}

{{% notice warning %}}
Remember, the responsibility of making sure that the workload can be evicted lies on you.  
Invalid `PodDisruptionBudget` configuration may block the eviction.  
{{% /notice %}}

{{% notice warning %}}
Additionally consider [skipEvictionAfter](https://github.com/kubermatic/machine-controller/blob/main/cmd/machine-controller/main.go#L125-L126)
parameter of Machine Controller that sets the timeout for workload eviction.  
**Once exceeded, the VMs will simply be deleted.** 
{{% /notice %}}

### I discovered a DNS collision on my cluster. Why does it happen?

Usually it happens when both infrastructure and user clusters points to the same address of NodeLocal DNS Cache servers, even if they have separate server instances running.  

Let us imagine that: 
* On the infrastructure cluster there is a running NodeLocal DNS Cache under 169.254.20.10 address.  
* Then we create a new user cluster, start a few Virtual Machines that finally gives a fully functional k8s cluster that runs on another k8s cluster.  
* Next we observe that on the user cluster there is another NodeLocal DNS Cache that has the same 169.254.20.10 address.  
* Since Virtual Machine can have access to subnets on the infra and user clusters (depends on your network policy rules) having the same address of DNS cache leads to conflict.  

One way to prevent that situation is to set a `dnsPolicy` and `dnsConfig` rules that Virtual Machines do not copy DNS configuration from their pods and points to different addresses.

Follow [Configure KKP With KubeVirt](#configure-kkp-with-kubevirt) to learn how set DNS config correctly.

### I created a load balancer service on a user cluster but services outside cannot reach it.

In most cases it is due to `cluster-isolation` network policy that is deployed as default on each user cluster.  
It only allows in-cluster communication. You should adjust network rules to your needs by adding [customNetworkPolicies configuration]({{< ref "../../../tutorials-howtos/project-and-cluster-management/seed-cluster/" >}})).

For instance, if you need to allow all ingress traffic from `10.200.10.0/24` CIDR to each user cluster then you would have to set:

```yaml
customNetworkPolicies:
  - name: allow-external-traffic
    spec:
      policyTypes:
        - Ingress
      ingress:
        - from:
          - ipBlock:
            cidr: 10.200.10.0/24
```

## Known issues

### Support of block volume mode

Currently, the KubeVirt CSI driver does not support volumes with block mode therefore you should avoid using this option to mount a PVC to a user cluster.

### Topology constrained storage

Due to [the issue](https://github.com/kubevirt/csi-driver/issues/66), it is not recommended to use local or any storage that is constrained by some topology.  
You can find more details in the linked issue.
