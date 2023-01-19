+++
title = "Creating a Kubernetes Cluster on Bare-metal"
date = 2021-02-10T12:00:00+02:00
weight = 2
+++

In this tutorial, we're going to show how to use Kubermatic KubeOne to create
a highly-available Kubernetes cluster on providers that are not natively-supported. The tutorial covers downloading KubeOne, and provisioning a cluster using KubeOne.
As a result, you'll get a production-ready and Kubernetes/CNCF compliant cluster.

This tutorial could be used in the following scenarios:

* Provisioning a cluster on providers that are not [natively-supported][compatibility-providers] (e.g. on bare metal or edge).
* Provisioning a cluster on a natively-supported provider, but you don't want to use Terraform.
* Creating a Raspberry Pi cluster
  
If you are able to use a provider, have a look at the [creating clusters][creating-clusters] tutorial, as this is the recommended approach.

## Prerequisites

This tutorial assumes that you're using Linux or macOS. KubeOne currently
doesn't release Windows binaries. If you're using Windows, we recommend
checking out the Windows Subsystem for Linux (WSL).

## How Kubermatic KubeOne Works

Kubermatic KubeOne is a CLI tool for managing highly-available Kubernetes
clusters in any environment (cloud, on-prem, bare metal, edge...). Clusters
created by KubeOne are production-ready and Kubernetes/CNCF compliant out of
the box. Generally, KubeOne runs the following tasks:

* install dependencies and required packages (container runtime, kubelet,
  kubeadm...)
* run Kubernetes' Kubeadm to provision a Kubernetes cluster
* deploy components such as CNI, metrics-server, and Kubermatic
  machine-controller
* create worker nodes by creating the appropriate MachineDeployment object(s)

{{% notice note %}}
Kubermatic machine-controller works only on [natively-supported providers]({{< ref "../../architecture/supported-providers/" >}}), so we can't use it for bare metal setups. Instead, we'll create worker nodes manually and use the KubeOne Static Worker Nodes feature to provision those worker nodes.
{{% /notice %}}

### Infrastructure Management

The infrastructure for the control plane and worker nodes is created by the user.

Once the infrastructure is created, the user provides information about the instances that will be used and
the load balancer that's running in the front of the control plane nodes.

To make this task easier, KubeOne integrates with Terraform by reading the
Terraform state, and provides example Terraform configs that can be used to
create the infrastructure.

The infrastructure for the worker nodes can be managed in two ways:

* automatically, by using Kubermatic machine-controller (deployed by default
  for supported providers)
* by creating the instances manually and using KubeOne to provision
  them

The first approach is recommended if your provider is
[natively-supported][compatibility-providers] (AWS, Azure, DigitalOcean, GCP,
Hetzner Cloud, Nutanix, OpenStack, Packet, and VMware vSphere), and is covered in [Creating a Kubernetes cluster tutorial][creating-clusters].

This tutorial focuses on bare metal without the usage of any provider to create the required infrastructure.
Therefore, you need to create the required infrastructure on your own.
Make sure to adhere to the requirements described in the [Infrastructure Management document][infrastructure-management].

Below, you can find a diagram that shows how KubeOne works.

{{< figure src="/img/kubeone/common/creating-clusters/architecture.png" height="577" width="750" alt="KubeOne architecture" >}}

## Default Configuration

By default, KubeOne installs the following components:

* Container Runtime: containerd for Kubernetes 1.22+ clusters, otherwise Docker
* CNI: Canal (based on Calico and Flannel)
  * Cilium, WeaveNet, and user-provided CNI are supported as an alternative
* [metrics-server][metrics-server] for collecting and exposing metrics from
  Kubelets
* [NodeLocal DNSCache][nodelocaldns] for caching DNS queries to improve the
  cluster performance
* [Kubermatic machine-controller][machine-controller], a Cluster-API based
  implementation for managing worker nodes

It's possible to configure which components are installed and how they are
configured by adjusting the KubeOne configuration manifest that we'll create
later in the Step 3 (Provisioning The Cluster). To see possible configuration
options, refer to the configuration manifest reference which can be obtained
by running `kubeone config print --full`.

## Step 1 — Downloading KubeOne

The easiest way to download KubeOne is to use our installation script.
The following command will download and run the script:

```shell
curl -sfL https://get.kubeone.io | sh
```

The script downloads the latest version of KubeOne from GitHub, and unpacks it
in the `/usr/local/bin` directory. Additionally, the script unpacks the example
Terraform configs, addons, and helper scripts in your current working
directory. At the end of the script output, you can find the path to the
unpacked files:

{{% notice note %}}
The addons and helper scripts are supposed to be used for advanced deployments
and we will not use those in this tutorial. They're not required by KubeOne, so
you're not required to keep to them.
{{% /notice %}}

```shell
...
Kubermatic KubeOne has been installed into /usr/local/bin/kubeone
Terraform example configs, addons, and helper scripts have been downloaded into the ./kubeone_1.4.0_linux_amd64 directory
```

You can confirm that KubeOne has been installed successfully by running the
`kubeone version` command. If you see an error, ensure that `/usr/local/bin` is
in your `PATH` or modify the script to install KubeOne in a different place.
You can also check the [Getting KubeOne guide][getting-kubeone] for alternative
installation methods.

## Step 2 — Creating The Infrastructure

With KubeOne installed, we're ready to create the infrastructure for our cluster.
Because we are not using any provider, it is up to you to create the necessary infrastructure.
Below you can find the infrastructure requirements and recommendations for control plane and worker nodes.

### Infrastructure For Control Plane

The following infrastructure requirements **must** be satisfied to successfully
provision a Kubernetes cluster using KubeOne:

* You need the appropriate number of instances dedicated for the control plane
  * You need **even** number of instances with a minimum of **three** instances
    for the Highly-Available control plane
  * If you decide to use a single-node control plane instead, one instance is
    enough, however, highly-available control plane is highly advised,
    especially in the production environments
* All control plane instances must satisfy the
  [system requirements for a kubeadm cluster][kubeadm-sysreq]
  * Minimum 2 vCPUs
  * Minimum 2 GB RAM
  * Operating system must be a [officially-supported by KubeOne][supported-os]
    (Ubuntu, Debian, CentOS, RHEL, Flatcar Linux)
  * Full network connectivity between all machines in the cluster
    (private network is recommended, but public is supported as well)
  * Unique hostname, MAC address, and product_uuid for every node
    * You can get the MAC address of the network interfaces using the command
      `ip link` or `ifconfig -a`
    * The product_uuid can be checked by using the command
      `sudo cat /sys/class/dmi/id/product_uuid`
  * Swap disabled. You MUST disable swap in order for the kubelet to work
    properly.
  * The following ports open: `6443`, `2379`, `2380`, `10250`, `10251`, `10252`
* For highly-available control plane, a load balancer pointing to the
  control plane instances (the Kubernetes API server) is required
  * Load balancer must include all control plane instances and distribute
    traffic to the TCP port 6443 (default port of the Kubernetes API server)
  * It's recommended to use a provider's offering for load balancers if such is
    available
  * If provider doesn't offer load balancer, you can create an instance and
    setup a solution such as HAProxy
  * Check out the [Load Balancer for Highly-Available Cluster example][ha-load-balancing]
    to learn more about possible setups
* You must have an SSH key deployed on all control plane instances and
  SSH configured as described in the [Configuring SSH][configuring-ssh] document

Depending on the environment, you may need additional objects, such as VPCs,
firewall rules, or images.

### Infrastructure For Worker Nodes

The requirements for the worker istances are similar as for the control
plane instances:

* All instances must satisfy the
  [system requirements for a kubeadm cluster][kubeadm-sysreq]
  * Minimum 2 vCPUs
  * Minimum 2 GB RAM
  * Operating system must be a [officially-supported by KubeOne][supported-os]
    (Ubuntu, Debian, CentOS, RHEL, Flatcar Linux)
  * Full network connectivity between all machines in the cluster
    (private network is recommended, but public is supported as well)
  * Unique hostname, MAC address, and product_uuid for every node
    * You can get the MAC address of the network interfaces using the command
      `ip link` or `ifconfig -a`
    * The product_uuid can be checked by using the command
      `sudo cat /sys/class/dmi/id/product_uuid`
  * Swap disabled. You MUST disable swap in order for the kubelet to work
    properly.
  * The following ports open: `10250`, and optionally `30000-32767` for
    NodePort Services
* You must have an SSH key deployed on all control plane instances and
  SSH configured as described in the [Configuring SSH][configuring-ssh] document


Usually the Kubermatic machine-controller would take care of managing the worker nodes.
However, without a provider we can not make use of it.
For the following steps, we assume that the required infrastructure is in place and SSH access is ensured.

## Step 3 — Provisioning The Cluster

Now that we have the infrastructure, we can use KubeOne to provision a Kubernetes cluster.

The first step is to create a KubeOne configuration manifest that contains a list of instances that will be used, and that describes how the cluster will be provisioned, which Kubernetes version will be used,
and more. To see possible configuration options reference, you can run `kubeone config print --full`.

For clusters running on providers that are not natively-supported (e.g. bare metal), we need to set the `cloudProvider` to `none: {}`.
In order to prevent KubeOne from deploying the Kubermatic machine-controller, which requires a cloud provider, set `machineController` to `deploy: false`.
Next, we need to define our control plane and worker nodes, referenced as [staticWorkers][static-workers], in the KubeOneCluster configuration.
Furthermore, the `apiEndpoint` needs to be set to a load balancer or the first control plane node.
You can find more information about load balancing at [HA load balancing][ha-load-balancing].

Below you find an example reference about the minimum necessary information for a bare metal deployment.

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: bm-cluster
versions:
  kubernetes: '1.22.5'
cloudProvider:
  none: {}

controlPlane:
  hosts:
    - publicAddress: '1.2.3.4'
      privateAddress: '172.18.0.1'
      sshUsername: root
      sshPrivateKeyFile: '/home/me/.ssh/id_rsa'
      taints:
        - key: "node-role.kubernetes.io/master"
          effect: "NoSchedule"

staticWorkers:
  hosts:
    - publicAddress: '1.2.3.5'
      privateAddress: '172.18.0.2'
      sshUsername: root
      sshPrivateKeyFile: '/home/me/.ssh/id_rsa'

# Provide the external address of your load balancer or the public addresses of
# the first control plane nodes.
apiEndpoint:
  host: ''
  port: 6443

machineController:
  deploy: false
```

Before proceeding, make sure to select the Kubernetes version that you want
to use, add your controlPlane and staticWorkers hosts and replace the placeholder values with real values where applicable.

In the following table, you can find a list of supported Kubernetes version
for latest KubeOne versions (you can run `kubeone version` to find the version
that you're running).

| KubeOne version | 1.24  | 1.23  | 1.22  | 1.21\*  | 1.20\*\*  | 1.19\*\*   |
| --------------- | ----- | ----- | ----- | ------- | --------- | ---------- |
| v1.5            | ✓     | ✓     | ✓     | -       | -         | -          |
| v1.4            | -     | ✓     | ✓     | ✓       | ✓         | -          |
| v1.3            | -     | -     | ✓     | ✓       | ✓         | ✓          |

\* Kubernetes 1.21 is in the [maintenance mode] which means that only critical
and security issues are fixed. It's strongly recommended to upgrade to a newer
Kubernetes version as soon as possible.

\*\* Kubernetes 1.20 and 1.19 have reached End-of-Life (EOL). We strongly
recommend upgrading to a supported Kubernetes release as soon as possible.

We recommend using a Kubernetes release that's not older than one minor release
than the latest Kubernetes release. For example, with 1.24 being the latest
release, we recommend running at least Kubernetes 1.23.

Now, we're ready to provision the cluster! This is done by running the
`kubeone apply` command and providing it the configuration manifest.

```shell
kubeone apply -m kubeone.yaml
```

This command analyzes the provided instances by running a set of probes to
determine is it needed to provision a cluster or is there already a Kubernetes
cluster running. If the cluster is already there, the probes will check is the
cluster healthy and is the actual state matching the expected state defined by
the configuration manifest. This allows us to use one single command for all
operations (provision, upgrade, enable features, and more). This process is
called Cluster Reconciliation and is described with additional details in the
[Cluster Reconciliation document][cluster-reconciliation].

The output will show steps that will be taken to provision a cluster. You'll be
asked to confirm the intention to provision a cluster by typing `yes`.

```
INFO[11:37:21 CEST] Determine hostname…
INFO[11:37:28 CEST] Determine operating system…
INFO[11:37:30 CEST] Running host probes…
The following actions will be taken:
Run with --verbose flag for more information.
  + initialize control plane node "ip-172-31-220-51.eu-west-3.compute.internal" (172.31.220.51) using 1.20.4
  + join control plane node "ip-172-31-221-177.eu-west-3.compute.internal" (172.31.221.177) using 1.20.4
  + join control plane node "ip-172-31-222-48.eu-west-3.compute.internal" (172.31.222.48) using 1.20.4
  + join worker node "ip-172-31-223-103.eu-west-3.compute.internal" (172.31.223.103) using 1.20.4
  + join worker node "ip-172-31-224-178.eu-west-3.compute.internal" (172.31.224.178) using 1.20.4

Do you want to proceed (yes/no):
```

After confirming your intention to provision the cluster, the provisioning will
start. It usually takes 5-10 minutes for cluster to be provisioned. At the end,
you should see output such as the following one:

```
...
INFO[11:46:54 CEST] Downloading kubeconfig…
INFO[11:46:54 CEST] Restarting unhealthy API servers if needed...
INFO[11:46:54 CEST] Ensure node local DNS cache…
INFO[11:46:54 CEST] Activating additional features…
INFO[11:46:56 CEST] Applying canal CNI plugin…
INFO[11:47:10 CEST] Skipping creating credentials secret because cloud provider is none.
INFO[11:47:10 CEST] Joining worker node                           node=172.31.223.103
INFO[11:47:17 CEST] Joining worker node                           node=172.31.224.178
```


At this point, your cluster is fully provisioned.

## Step 4 — Configuring The Cluster Access

KubeOne automatically downloads the Kubeconfig file for the cluster. It's named
as **\<cluster_name>-kubeconfig**. You can use it with kubectl such as:

```shell
kubectl --kubeconfig=<cluster_name>-kubeconfig
```

or export the `KUBECONFIG` environment variable:

```shell
export KUBECONFIG=$PWD/<cluster_name>-kubeconfig
```

If you want to learn more about kubeconfig and managing access to your
clusters, you can check the
[Configure Access To Multiple Clusters][access-clusters] document.

You can try to list all nodes in the cluster to confirm that you can access
the cluster:

```shell
kubectl get nodes
```

You should see output such as the following one.

```
NAME                                           STATUS   ROLES    AGE   VERSION
ip-172-31-220-51.eu-west-3.compute.internal    Ready    master   43m   v1.20.4
ip-172-31-221-177.eu-west-3.compute.internal   Ready    master   42m   v1.20.4
ip-172-31-222-48.eu-west-3.compute.internal    Ready    master   41m   v1.20.4
ip-172-31-223-103.eu-west-3.compute.internal   Ready    <none>   38m   v1.20.4
ip-172-31-224-178.eu-west-3.compute.internal   Ready    <none>   38m   v1.20.4
```

## Conclusion

Congratulations!!! You have successfully provisioned a Kubernetes cluster using
Kubermatic KubeOne. You're now ready to run your workload on this cluster.
We recommend checking the following learn more section for additional resources
and recommendations.

## Learn More

* Learn how to upgrade your cluster by following the
  [Upgrading Clusters][upgrading-clusters] tutorial
* If you don't need your cluster anymore, you can check the
  [Unprovisioning Clusters][unprovisioning-clusters] tutorial to find out
  how to unprovision the cluster and remove the infrastructure
* You can find additional production recommendations in the
  [Production Recommendations document][production-recommendations]
* Learn how to use KubeOne to set up a cluster with OIDC Authentication and
  Audit Logging in [the following tutorial][create-cluster-oidc]
* Learn more about Kubermatic machine-controller and how we use it to create
  worker nodes in [the following guide][machine-controller]

[compatibility-providers]: {{< ref "../../architecture/supported-providers/" >}}
[static-workers]: {{< ref "../../guides/static-workers" >}}
[creating-clusters]: {{< ref "../creating-clusters" >}}
[infrastructure-management]: {{< ref "../../architecture/requirements/infrastructure-management" >}}
[metrics-server]: https://github.com/kubernetes-sigs/metrics-server
[nodelocaldns]: https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns/
[machine-controller]: {{< ref "../../guides/machine-controller" >}}
[getting-kubeone]: {{< ref "../../getting-kubeone" >}}
[cluster-reconciliation]: {{< ref "../../architecture/cluster-reconciliation" >}}
[access-clusters]: https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/
[upgrading-clusters]: {{< ref "../upgrading-clusters" >}}
[unprovisioning-clusters]: {{< ref "../unprovisioning-clusters" >}}
[production-recommendations]: {{< ref "../../cheat-sheets/production-recommendations" >}}
[create-cluster-oidc]: {{< ref "../creating-clusters-oidc" >}}
[configuring-ssh]: {{< ref "../../guides/ssh" >}}
[ha-load-balancing]: {{< ref "../../examples/ha-load-balancing" >}}
[supported-os]: {{< ref "../../architecture/compatibility/os-support-matrix/" >}}
[kubeadm-sysreq]: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#before-you-begin
[maintenance mode]: https://kubernetes.io/releases/patch-releases/#support-period
