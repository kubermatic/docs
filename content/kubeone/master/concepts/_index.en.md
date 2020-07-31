+++
title = "Concepts"
date = 2020-07-30T12:00:00+02:00
weight = 3
enableToc = true
+++

## Control Plane

The **control plane** is a set of components and services that serve the
Kubernetes API, manage worker nodes, and continuously reconcile desired
state using control loops. The control plane components are usually placed on
dedicated node(s) which are often referred to as **control plane nodes**.

## Highly-Available Control Plane

It's recommended to run multiple replicas of control plane components to
ensure the fault tolerance and resilience. If one of control plane nodes fail,
other nodes will continue serving user's requests and ensure that the workload
is up and running. Running multiple replicas of the control plane components is
called **Highly-Available Control Plane**.

Replicas are run on different control plane nodes. It's advised to have an odd
number of nodes (e.g. 3 or 5) and a minimum of 3 control plane nodes. For more
details, check the [etcd documentation][etcd-quorum] on how quorum works.

## Infrastructure Management

All required infrastructure for the cluster along with instances needed for
control plane nodes are **managed by the user**. It can be done manually or by
integrating with tools such as Terraform.

Instances for worker nodes can be managed in two ways:

* using [Kubermatic machine-controller][machine-controller], which creates and
  provisions instances, and joins them a cluster, automatically
* manually, by using the preferred tooling to create instances for worker nodes
  and then provision them using KubeOne

Using Kubermatic machine-controller is highly advised if your provider is
[natively supported][supported-providers].

## Example Terraform Scripts

To make it easier to get started, we provide example Terraform scripts that
you can use to create the needed infrastructure and instances. The example
Terraform scripts are available for all
[natively supported][supported-providers] providers and can be found on
[GitHub][terraform-scripts].

<!-- TODO(xmudrii): link to the production practices once the document is ready -->

{{% notice warning %}}
The example Terraform scripts are supposed to be used as a foundation for
building your own scripts. The scripts are optimized for ease of use and
using in E2E tests, and therefore might not be suitable for the production
usage out of the box.
{{% /notice %}}

## KubeOne Terraform Intergration

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

## Kubermatic machine-controller

[Kubermatic machine-controller][machine-controller] is an open-source
[Cluster API][cluster-api] implementation that takes care of:

* creating and managing instances for worker nodes
* joining worker nodes a cluster
* reconciling worker nodes and ensuring they are healthy

## Cluster API

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

### Machines

Machines (`machines.cluster.k8s.io`) define a single machine and node in the
cluster. In our case, a worker node is requested by creating a Machine
object which contains all the needed information to create the instance
(e.g. region, instance size, security groups...). Machines are often compared
to Pods, i.e. Machine is a atomic unit representing a single node.

### MachineSets

MachineSets (`machinesets.cluster.k8s.io`) have a purpose to maintain a stable
set of Machines running at any given time. It's often used to guarantee the
availability of a specified number of Machines. As such, MachineSets work
similar as ReplicaSets.

### MachineDeployments

MachineDeployments (`machinedeployments.cluster.k8s.io`) are similar to the
Deployments. They are used to provide declarative updates for
MachineSets/Machines and allow advanced use cases such as rolling updates.

[etcd-quorum]: https://etcd.io/docs/v3.3.12/faq
[machine-controller]: https://github.com/kubermatic/machine-controller
[supported-providers]: {{< ref "../compatibility_info" >}}
[terraform-scripts]: https://github.com/kubermatic/kubeone/tree/master/examples/terraform
[aws-output-tf]: https://github.com/kubermatic/kubeone/blob/master/examples/terraform/aws/output.tf
[kubeadm]: https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm/
[cluster-api]: https://github.com/kubernetes-sigs/cluster-api
[cluster-api-book]: https://cluster-api.sigs.k8s.io/
[cluster-provisioning]: {{< ref "#cluster-provisioning-and-management" >}}
