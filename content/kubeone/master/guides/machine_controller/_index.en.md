+++
title = "Using machine-controller"
date = 2020-04-01T12:00:00+02:00
enableToc = true
+++

[Kubermatic machine-controller][machine-controller] is an open-source
[Cluster API][cluster-api] implementation that takes care of:

* creating and managing instances for worker nodes
* joining worker nodes a cluster
* reconciling worker nodes and ensuring they are healthy

Kubermatic machine-controller allows you define all worker nodes as Kubernetes
object, more precisely, as MachineDeployments. MachineDeployments work similar
to core Deployments. You provide information needed to create instances, while
machine-controller creates underlying MachineSet and Machine objects, and
based on that, (cloud) provider instances. The (cloud) provider instances are
then provisioned and joined the cluster by machine-controller automatically.

machine-controller watches all MachineDeployment, MachineSet, and Machine
objects all the time, and if any change happens, it ensures that the actual
state matches the desired.

As all worker nodes are defined as Kubernetes objects, you can manage them
using kubectl or by interacting with the Kubernetes API directly. This is a
powerful mechanism because you can create new worker nodes, delete existing
ones, or scale them up and down, using a single kubectl command.

Kubermatic machine-controller works only with
[natively-supported][supported-providers] providers. If your provider is
natively-supported, we highly recommend using machine-controller. Otherwise,
you can use [KubeOne Static Workers][static-workers].

## Creating Initial Worker Nodes

The initial worker nodes (MachineDeployment objects) can be created on the
provisioning time by defining them in the KubeOne Configuration Manifest or in
the `output.tf` file if you're using Terraform.

If you're using the [KubeOne Terraform Integration][terraform-integration],
you can define initial MachineDeployment objects in the `output.tf` file under
the [`kubeone_workers` section][terraform-integration]. We already define
initial MachineDeployment objects in our example Terraform configs and you can
modify them by setting the appropriate variables or by modifying the
`output.tf` file.

Otherwise, if you don't use Terraform, you can define MachineDeployment objects
directly in the KubeOne Configuration Manifest, under `dynamicWorkers` key.
You can run `kubeone config print --full` for an example configuration.

## Creating Additional Worker Nodes

If you want to create additional worker nodes once the cluster is provisioned,
you need to create the appropriate MachineDeployments manifest. You can do that
by grabbing the existing MachineDeployment object from the cluster or by using
KubeOne, such as:

```bash
kubeone config machinedeployments --manifest kubeone.yaml -t tf.json
```

This command will output MachineDeployments defined in the KubeOne
Configuration Manifest and `tf.json` Terraform state file. You can use that
as a template/foundation to create your desired manifest.

## Inspecting Worker Nodes

If you already have a provisioned cluster, you can use `kubectl` to inspect
nodes in the cluster.

The following command returns all nodes, including control plane nodes,
machine-controller managed nodes, and nodes managed using any other way
(if applicable).

```bash
kubectl get nodes
```

All nodes should have status Ready. Additionally, worker nodes have `<none>`
set for roles.

If you want to filter just nodes created by machine-controller, you can utilize
the appropriate label selector.

```bash
kubectl get nodes -l "machine-controller/owned-by"
```

You can use the following command to list all MachineDeployment, MachineSet,
and Machine objects. KubeOne deploys all those objects in the `kube-system`
namespace. You can include additional details by using the `-o wide` flag.

```bash
kubectl get machinedeployments,machinesets,machines -n kube-system
```

The output includes various details, such as the number of replicas, cloud
provider name, IP addresses, and more. Adding `-o wide` would also include
information about underlying MachineDeployment, MachineSet, and Node objects.

## Editing Worker Nodes

You can easily edit existing MachineDeployment objects using the `kubectl edit`
command, for example:

```bash
kubectl edit -n kube-system machinedeployment <machinedeployment-name>
```

This will open a text editor, where you can edit various properties. If you
want to change number of replicas, you can also use the `scale` command.

{{% notice warning %}}
Make sure to also change `output.tf` or KubeOne Configuration Manifest, or
otherwise, your changes can get overwritten the next time you run KubeOne.
{{% /notice %}}

## Scaling Worker Nodes

The MachineDeployment objects can be scaled up and down (including to 0) using
the `scale` command:

```bash
# Scaling up
kubectl scale -n kube-system machinedeployment <machinedeployment-name> --replicas=5
```

```bash
# Scalding down
kubectl scale -n kube-system machinedeployment <machinedeployment-name> --replicas=2
```

Scaling down to zero is useful when you want to "temporarily" delete worker
nodes, i.e. have the ability to easily recreate them by scaling up.

```bash
# Scalding down
kubectl scale -n kube-system machinedeployment <machinedeployment-name> --replicas=0
```

{{% notice warning %}}
Make sure to also change `output.tf` or KubeOne Configuration Manifest, or
otherwise, your changes can get overwritten the next time you run KubeOne.
{{% /notice %}}

[machine-controller]: https://github.com/kubermatic/machine-controller
[cluster-api]: {{< ref ".#concepts#cluster-api" >}}
[machine-deployments]: {{< ref ".#concepts#machinedeployments" >}}
[supported-providers]: {{< ref ".#compatibility_info" >}}
[static-workers]: {{< ref ".#static_workers" >}}
[terraform-integration]: {{< ref ".#infrastructure/terraform_integration" >}}
[terraform-integration-workers]: {{< ref ".#infrastructure/terraform_integration#kubeone_workers-reference" >}}
