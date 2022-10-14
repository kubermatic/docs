+++
title = "Concepts"
date = 2021-02-10T12:00:00+02:00
weight = 1
enableToc = true
+++

## Infrastructure Management

All required infrastructure for the cluster along with instances needed for
control plane nodes are **managed by the user**. It can be done manually or by
integrating with tools such as Terraform.

Instances for worker nodes can be managed in two ways:

* using [Kubermatic machine-controller][machine-controller], which creates and
  provisions instances, and joins them a cluster, automatically
* using KubeOne Static Workers, by using the preferred tooling to create
  instances and then provision them using KubeOne

Using Kubermatic machine-controller is highly advised if your provider is
[officially supported][supported-providers]. Otherwise, KubeOne Static Workers
are recommended instead.

Additional information about the infrastructure management, such as what are
the infrastructure requirements and how to use the Terraform integration, can
be found in the [Infrastructure Management document][infrastructure-management].

### Example Terraform Scripts

To make it easier to get started, we provide example Terraform scripts that
you can use to create the needed infrastructure and instances. The example
Terraform scripts are available for all
[officially supported][supported-providers] providers and can be found on
[GitHub][terraform-scripts].

{{% notice warning %}}
The example Terraform scripts are supposed to be used as a foundation for
building your own scripts. The scripts are optimized for ease of use and
using in E2E tests, and therefore might not be suitable for the production
usage out of the box.
{{% /notice %}}

{{% notice note %}}
Please check the
[Production Recommendations][production_recommendations]
document for more details about making the example configs suitable for
the production usage.

[production_recommendations]: {{< ref "../../cheat-sheets/production-recommendations" >}}
{{% /notice %}}

### KubeOne Terraform Integration

KubeOne integrates with Terraform by reading the Terraform state for the
information about the cluster including:

* the load balancer endpoint
* nodes' public and private IP addresses, and hostnames
* SSH parameters (username, port, key)
* bastion/jump host parameters if bastion is used
* information needed to generate the MachineDeployment objects which define
  worker nodes

All you need to do to utilize the integration is to ensure that you have
the appropriate `output.tf` file along with your other Terraform files. It's
required that your `output.tf` file follows the template used by KubeOne, which
can be found along with the example Terraform scripts
([an example for AWS][aws-output-tf]).

## Cluster Provisioning and Management

KubeOne takes care of the full cluster lifecycle including: provisioning,
upgrading, repairing, and unprovisioning the clusters. KubeOne utilizes
[Kubernetes' kubeadm][kubeadm] for handling provisioning and upgrading
tasks. Kubeadm allows us to follow the best practices and create conformant
and production-ready clusters.

Most of the tasks are carried out by running commands over SSH, therefore
the SSH access to control plane nodes is required. Such tasks include
installing and upgrading binaries, generating and distributing configuration
files and certificates, running kubeadm, and more. Manifests are mostly applied
programmatically using client-go and controller-runtime libraries.

This approach allows us to manage clusters on any infrastructure, is it
cloud, on-prem, baremetal, Edge, or IoT.

### KubeOne Configuration Manifest

Clusters are defined declaratively using the KubeOne Configuration Manifest.
The configuration manifest is a YAML file that defines properties of a cluster
such as:

* The Kubernetes version to be deployed
* Provider-specific information if applicable
* Cluster network configuring
* Cluster features to enable

You can grab the KubeOne Configuration Manifest reference by running the
following command:

```
kubeone config print --full
```

## Kubermatic machine-controller

[Kubermatic machine-controller][machine-controller] is an open-source
[Cluster API][cluster-api] implementation that takes care of:

* creating and managing instances for worker nodes
* joining worker nodes a cluster
* reconciling worker nodes and ensuring they are healthy

You can find more details about machine-controller in the
[Managing Worker Nodes Using Kubermatic machine-controller document][using-machine-controller].

## Kubermatic operating-system-manager

[Kubermatic operating-system-manager][operating-system-manager] is used to create and manage worker node
configurations in a kubernetes cluster. It works in liaison with [machine-controller][machine-controller]
and provides the required user-data to machine-controller that is used to provision the worker nodes.

### Cluster API

Cluster API is a Kubernetes sub-project focused on providing declarative APIs
and tooling to simplify provisioning, upgrading, and operating multiple
Kubernetes clusters. You can learn more about the Cluster API by checking out
the [Cluster API repository][cluster-api] and
the [Cluster API documentation website][cluster-api-book].

We use Cluster API for managing worker nodes, while control plane nodes are
managed as described in the
[Cluster Provisioning and Management][cluster-provisioning] section.

The Cluster API controller (e.g. Kubermatic machine-controller) is responsible
for acting on Cluster API objects — Machines, MachineSets, and
MachineDeployments. The controller takes care of reconciling the desired state
and ensuring that the requested machines exist and are part of the cluster.

#### Machines

Machines (`machines.cluster.k8s.io`) define a single machine and node in the
cluster. In our case, a worker node is requested by creating a Machine
object which contains all the needed information to create the instance
(e.g. region, instance size, security groups...). Machines are often compared
to Pods, i.e. Machine is a atomic unit representing a single node.

#### MachineSets

MachineSets (`machinesets.cluster.k8s.io`) have a purpose to maintain a stable
set of Machines running at any given time. It's often used to guarantee the
availability of a specified number of Machines. As such, MachineSets work
similar as ReplicaSets.

#### MachineDeployments

MachineDeployments (`machinedeployments.cluster.k8s.io`) are similar to the
Deployments. They are used to provide declarative updates for
MachineSets/Machines and allow advanced use cases such as rolling updates.

[machine-controller]: https://github.com/kubermatic/machine-controller
[supported-providers]: {{< ref "../compatibility" >}}
[infrastructure-management]: {{< ref "../requirements/infrastructure-management" >}}
[terraform-scripts]: https://github.com/kubermatic/kubeone/tree/mai/examples/terraform
[aws-output-tf]: https://github.com/kubermatic/kubeone/blob/main/examples/terraform/aws/output.tf
[kubeadm]: https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm/
[using-machine-controller]: {{< ref "../../guides/machine-controller" >}}
[cluster-api]: https://github.com/kubernetes-sigs/cluster-api
[cluster-api-book]: https://cluster-api.sigs.k8s.io/
[cluster-provisioning]: {{< ref "#cluster-provisioning-and-management" >}}
[operating-system-manager]: https://github.com/kubermatic/operating-system-manager
