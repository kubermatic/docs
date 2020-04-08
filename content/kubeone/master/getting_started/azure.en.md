+++
title = "Azure"
date = 2020-04-01T12:00:00+02:00
weight = 8
pre = "<b></b>"
+++

## How To Install Kubernetes On Azure cloud Using KubeOne

In this quick start we're going to show how to get started with KubeOne on
Azure. We'll cover how to create the needed infrastructure using our example
Terraform scripts and then install Kubernetes. Finally, we're going to show how
to destroy the cluster along with the infrastructure.

As a result, you'll get Kubernetes High-Available (HA) clusters with
three control plane nodes and one worker node.

### Prerequisites

To follow this quick start, you'll need:

* KubeOne v0.11.1 or newer installed, which can be done by following the
Installing KubeOne section of [the README][readme]
* Terraform v0.12.0 or newer installed. Older releases are not compatible.
The binaries for Terraform can be found on the [Terraform website][terraform]

## Setting Up Credentials

{{% notice warning %}}
The provided credentials are deployed to the cluster to be used by
machine-controller for creating worker nodes. You may want to consider
providing a non-administrator credentials to increase the security.
{{% /notice %}}

In order for Terraform to successfully create the infrastructure and for
machine-controller to create worker nodes, you need to setup credentials for
your Azure cluster.

For the Terraform reference please take a look at
[Azure provider docs][terraform-azure-ref].

The following environment variables should be set:

```bash
export ARM_CLIENT_ID=<your client id>
export ARM_CLIENT_SECRET=<your client secret id>
export ARM_TENANT_ID=<your tenant id>
export ARM_SUBSCRIPTION_ID=<your subscribtion id>
```

## Creating Infrastructure

KubeOne is based on the Bring-Your-Own-Infra approach, which means that you have
to provide machines and needed resources yourself. To make this task easier we
are providing Terraform scripts that you can use to get started.
You're free to use your own scripts or any other preferred approach.

The Terraform scripts for Azure are located in the
[`./examples/terraform/azure`][terraform-azure] directory.

{{% notice note %}}
KubeOne comes with the Terraform integration that can source information about
the infrastructure directly from the Terraform output. If you decide not to use
our Terraform scripts, but you still want to use the Terraform integration, you
must ensure that your
[Terraform output (`output.tf`)](https://github.com/kubermatic/kubeone/blob/master/examples/terraform/azure/output.tf)
is using the same format as ours. Alternatively, if you decide not to use Terraform,
you can provide needed information about the infrastructure manually in the
KubeOne configuration file.
{{% /notice %}}

First, we need to switch to the directory with Terraform scripts:

```bash
cd ./examples/terraform/azure
```

Before we can use Terraform to create the infrastructure for us, Terraform needs
to download the Azure plugin. This is done by running the `init` command:

```bash
terraform init
```

{{% notice tip %}}
You need to run this command only the first time before using scripts.
{{% /notice %}}

You may want to configure the provisioning process by setting variables defining
the cluster name, image to be used, instance size and similar. The easiest way
is to create the `terraform.tfvars` file and store variables there. This file is
automatically read by Terraform.

```bash
nano terraform.tfvars
```

For the list of available settings along with their names please see the
[`variables.tf`][terraform-variables] file. You should consider setting:

| Variable              | Required | Default Value     | Description                                                                                                          |
| --------------------- | -------- | ----------------- | -------------------------------------------------------------------------------------------------------------------- |
| cluster_name          | yes      |                   | cluster name and prefix for cloud resources                                                                          |
| location              |          | westeurope        | Azure datacenter resources                                                                                           |
| ssh_public_key_file   |          | ~/.ssh/id_rsa.pub | path to your SSH public key that's deployed on instances                                                             |
| control_plane_vm_size |          | Standard_B2s      | control plane instance size (note that you should have at least 2 GB RAM and 2 CPUs for Kubernetes to work properly) |

The `terraform.tfvars` file can look like:

```
cluster_name = "demo"

location = "westeurope"
```

Now that you configured Terraform you can use the `plan` command to see what
changes will be made:

```bash
terraform plan
```

Finally, if you agree with changes you can proceed and provision the
infrastructure:

```bash
terraform apply
```

Shortly after you'll be asked to enter `yes` to confirm your intention to
provision the infrastructure.

Infrastructure provisioning takes around 5-10 minutes.

To obtain IP addresses (which are a bit delayed) of the VMs, it's
required to run:

```bash
terraform refresh
```

Once the provisioning is done, you need to export the Terraform output using the
following command. This Terraform output file will be used by KubeOne to source
information about the infrastructure and worker nodes.

```bash
terraform output -json > tf.json
```

{{% notice tip %}}
The generated output is based on the [`output.tf` file](https://github.com/kubermatic/kubeone/blob/master/examples/terraform/azure/output.tf).
If you want to change any settings, such as how worker nodes are created,
you can modify the `output.tf` file. Make sure to run `terraform apply`
and `terraform output` again after modifying the file.
{{% /notice %}}

## Installing Kubernetes

Now that you have infrastructure you can proceed with installing Kubernetes
using KubeOne.

Before you start you'll need a configuration file that defines how Kubernetes
will be installed, e.g. what version will be used and what features will be
enabled. For the configuration file reference run `kubeone config print --full`.

To get started you can use the following configuration file:

```yaml
apiVersion: kubeone.io/v1alpha1
kind: KubeOneCluster
versions:
  kubernetes: '1.18.0'
cloudProvider:
  name: 'azure'
  cloudConfig: |
    {
      "tenantId": "<AZURE TENANT ID>",
      "subscriptionId": "<AZURE SUBSCIBTION ID>",
      "aadClientId": "<AZURE CLIENT ID>",
      "aadClientSecret": "<AZURE CLIENT SECRET>",
      "resourceGroup": "<SOME RESOURCE GROUP>",
      "location": "westeurope",
      "subnetName": "<SOME SUBNET NAME>",
      "routeTableName": "",
      "securityGroupName": "<SOME SECURITY GROUP>",
      "vnetName": "<SOME VIRTUAL NETWORK>",
      "primaryAvailabilitySetName": "<SOME AVAILABILITY SET NAME>",
      "useInstanceMetadata": true,
      "useManagedIdentityExtension": false,
      "userAssignedIdentityID": ""
    }
```

This configuration manifest instructs KubeOne to provision Kubernetes 1.18.0
cluster on Azure. Other properties, including information about the infrastructure
and how to create worker nodes are sourced from the [Terraform output][terraform-output].
As KubeOne is using [Kubermatic `machine-controller`][machine-controller]
for creating worker nodes, see the [Azure example manifest][machine-controller-azure]
for available options.

{{% notice note %}}
The `cloud-config` file is required for Azure, so the Azure Cloud Controller
Manager works as expected. Make sure to replace the sample values with the real
values.
{{% /notice %}}

Finally, we're going to install Kubernetes by running the following `install`
command and providing the configuration file and the Terraform output:

```bash
kubeone install config.yaml --tfjson <DIR-WITH-tfstate-FILE>
```

Alternatively, if the Terraform state file is in the current working directory
`--tfjson .` can be used as well.

The installation process takes some time, usually 5-10 minutes.
The output should look like the following one:

```
INFO[13:15:31 EEST] Installing prerequisites…
INFO[13:15:32 EEST] Determine operating system…                   node=192.168.11.142
INFO[13:15:33 EEST] Determine operating system…                   node=192.168.11.139
INFO[13:15:34 EEST] Determine hostname…                           node=192.168.11.142
INFO[13:15:34 EEST] Creating environment file…                    node=192.168.11.142
INFO[13:15:34 EEST] Installing kubeadm…                           node=192.168.11.142 os=ubuntu
INFO[13:15:34 EEST] Determine operating system…                   node=192.168.11.140
INFO[13:15:36 EEST] Determine hostname…                           node=192.168.11.139
INFO[13:15:36 EEST] Creating environment file…                    node=192.168.11.139
INFO[13:15:36 EEST] Installing kubeadm…                           node=192.168.11.139 os=ubuntu
INFO[13:15:36 EEST] Determine hostname…                           node=192.168.11.140
INFO[13:15:36 EEST] Creating environment file…                    node=192.168.11.140
INFO[13:15:37 EEST] Installing kubeadm…                           node=192.168.11.140 os=ubuntu
INFO[13:16:45 EEST] Deploying configuration files…                node=192.168.11.139 os=ubuntu
INFO[13:16:45 EEST] Deploying configuration files…                node=192.168.11.140 os=ubuntu
INFO[13:17:03 EEST] Deploying configuration files…                node=192.168.11.142 os=ubuntu
INFO[13:17:04 EEST] Generating kubeadm config file…
INFO[13:17:06 EEST] Configuring certs and etcd on first controller…
INFO[13:17:06 EEST] Ensuring Certificates…                        node=192.168.11.139
INFO[13:17:14 EEST] Downloading PKI files…                        node=192.168.11.139
INFO[13:17:16 EEST] Creating local backup…                        node=192.168.11.139
INFO[13:17:16 EEST] Deploying PKI…
INFO[13:17:16 EEST] Uploading files…                              node=192.168.11.142
INFO[13:17:16 EEST] Uploading files…                              node=192.168.11.140
INFO[13:17:21 EEST] Configuring certs and etcd on consecutive controller…
INFO[13:17:21 EEST] Ensuring Certificates…                        node=192.168.11.142
INFO[13:17:21 EEST] Ensuring Certificates…                        node=192.168.11.140
INFO[13:17:27 EEST] Initializing Kubernetes on leader…
INFO[13:17:27 EEST] Running kubeadm…                              node=192.168.11.139
INFO[13:18:45 EEST] Joining controlplane node…
INFO[13:18:45 EEST] Waiting 30s to ensure main control plane components are up…  node=192.168.11.140
INFO[13:20:27 EEST] Waiting 30s to ensure main control plane components are up…  node=192.168.11.142
INFO[13:22:03 EEST] Copying Kubeconfig to home directory…         node=192.168.11.140
INFO[13:22:03 EEST] Copying Kubeconfig to home directory…         node=192.168.11.139
INFO[13:22:03 EEST] Copying Kubeconfig to home directory…         node=192.168.11.142
INFO[13:22:10 EEST] Building Kubernetes clientset…
INFO[13:22:16 EEST] Creating credentials secret…
INFO[13:22:16 EEST] Applying canal CNI plugin…
INFO[13:22:21 EEST] Installing machine-controller…
INFO[13:22:27 EEST] Installing machine-controller webhooks…
INFO[13:22:30 EEST] Waiting for machine-controller to come up…
INFO[13:23:15 EEST] Creating worker machines…
```

KubeOne automatically downloads the Kubeconfig file for the cluster. It's named
as **\<cluster_name>-kubeconfig**, where **\<cluster_name>** is the name
provided in the `terraform.tfvars` file. You can use it with kubectl such as:

```bash
kubectl --kubeconfig=<cluster_name>-kubeconfig
```

or export the `KUBECONFIG` environment variable:

```bash
export KUBECONFIG=$PWD/<cluster_name>-kubeconfig
```

You can check the [Configure Access To Multiple Clusters][access-clusters]
document to learn more about managing access to your clusters.

## Scaling Worker Nodes

Worker nodes are managed by the machine-controller. By default, it creates
one MachineDeployment object. That object can be scaled up and down
(including to 0) using the Kubernetes API. To do so you first got
to retrieve the `machinedeployments` by running:

```bash
kubectl get machinedeployments -n kube-system
```

The names of the `machinedeployments` are generated. You can scale the workers
in those using:

```bash
kubectl --namespace kube-system scale machinedeployment/<MACHINE-DEPLOYMENT-NAME> --replicas=3
```

{{% notice note %}}
The `kubectl scale` command is not working as expected with kubectl v1.15.
If you want to use the scale command, please upgrade to kubectl v1.16 or newer.
{{% /notice %}}

## Deleting The Cluster

Before deleting a cluster you should clean up all MachineDeployments,
so all worker nodes are deleted. You can do it with the `kubeone reset`
command:

```bash
kubeone reset config.yaml --tfjson <DIR-WITH-tfstate-FILE>
```

This command will wait for all worker nodes to be gone.
Once it's done you can proceed and destroy the Azure infrastructure using Terraform:

```bash
terraform destroy
```

You'll be asked to enter `yes` to confirm your intention to destroy the cluster.

Congratulations! You're now running Kubernetes HA cluster with three
control plane nodes and one worker node. If you want to learn more about KubeOne and
its features, make sure to check our [documentation][docs].

[readme]: https://github.com/kubermatic/kubeone/blob/master/README.md
[terraform]: https://www.terraform.io/downloads.html
[terraform-azure-ref]: https://www.terraform.io/docs/providers/azurerm/index.html#argument-reference
[terraform-azure]: https://github.com/kubermatic/kubeone/tree/master/examples/terraform/azure
[terraform-output]: https://github.com/kubermatic/kubeone/blob/master/examples/terraform/azure/output.tf
[terraform-variables]: https://github.com/kubermatic/kubeone/blob/master/examples/terraform/azure/variables.tf
[machine-controller]: https://github.com/kubermatic/machine-controller
[machine-controller-azure]: https://github.com/kubermatic/machine-controller/blob/master/examples/azure-machinedeployment.yaml
[access-clusters]: https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/
[docs]: https://docs.loodse.com/kubeone
