+++
title = "Packet"
date = 2020-04-01T12:00:00+02:00
weight = 8

+++

## How To Install Kubernetes On Packet Cluster Using KubeOne

In this quick start we're going to show how to get started with KubeOne on
Packet. We'll cover how to create the needed infrastructure using our
example Terraform scripts and then install Kubernetes. Finally, we're going to
show how to destroy the cluster along with the infrastructure.

As a result, you'll get Kubernetes High-Available (HA) clusters with
three control plane nodes and one worker node (which can be easily scaled).

### Prerequisites

To follow this quick start, you'll need:

* KubeOne v0.11.1 or newer installed, which can be done by following the 
Installing KubeOne section of [the README][readme]
* Terraform v0.12.0 or newer installed. Older releases are not compatible.
The binaries for Terraform can be found on the [Terraform website][terraform]

## Setting Up Credentials

{{% notice warning %}}
The provided credentials are deployed to the cluster to be used by
machine-controller for creating worker nodes.
{{% /notice %}}

In order for Terraform to successfully create the infrastructure and for
machine-controller to create worker nodes you need an API Access Token. You
can refer to [the official documentation][packet_support_docs] for guidelines
for generating the token.

Once you have the API access token you need to set the `PACKET_AUTH_TOKEN` and
`PACKET_PROJECT_ID` environment variables:

```bash
export PACKET_AUTH_TOKEN=<api key>
export PACKET_PROJECT_ID=<project UUID>
```

## Creating Infrastructure

KubeOne is based on the Bring-Your-Own-Infra approach, which means that you have
to provide machines and needed resources yourself. To make this task easier we
are providing Terraform scripts that you can use to get started. You're free to
use your own scripts or any other preferred approach.

The Terraform scripts for Packet are located in the
[`./examples/terraform/packet`][packet_terraform] directory.

{{% notice note %}}
KubeOne comes with the Terraform integration that can source information about
the infrastructure directly from the Terraform output. If you decide not to use
our Terraform scripts, but you still want to use the Terraform integration, you
must ensure that your
[Terraform output (`output.tf`)](https://github.com/kubermatic/kubeone/blob/master/examples/terraform/packet/output.tf)
is using the same format as ours. Alternatively, if you decide not to use Terraform,
you can provide needed information about the infrastructure manually in the
KubeOne configuration file.
{{% /notice %}}

{{% notice note %}}
As Packet doesn't have Load Balancers as a Service (LBaaS), the example
Terraform scripts will create an instance for a Load Balancer and setup it using
[GoBetween](https://github.com/yyyar/gobetween). This setup may not be appropriate
for the production usage, but it allows us to provide better HA experience in an
easy to consume manner.
{{% /notice %}}

First, we need to switch to the directory with Terraform scripts:

```bash
cd examples/terraform/packet
```

Before we can use Terraform to create the infrastructure for us, Terraform needs
to download the Packet plugin. This is done by running the `init` command:

```bash
terraform init
```

{{% notice tip %}}
You need to run this command only the first time before using scripts.
{{% /notice %}}

You may want to configure the provisioning process by setting variables defining
the cluster name, device type, facility and similar. The easiest way is to
create the `terraform.tfvars` file and store variables there. This file is
automatically read by Terraform.

```bash
nano terraform.tfvars
```

For the list of available settings along with their names please see the
[`variables.tf`][packet_variables] file. You should consider setting:

| Variable            | Required | Default Value     | Description                                                                                                          |
| ------------------- | -------- | ----------------- | -------------------------------------------------------------------------------------------------------------------- |
| cluster_name        | yes      |                   | cluster name and prefix for cloud resources                                                                          |
| project_id          | yes      |                   | Packet project UUID                                                                                                  |
| ssh_public_key_file |          | ~/.ssh/id_rsa.pub | path to your SSH public key that's deployed on instances                                                             |
| device_type         |          | t1.small.x86      | control plane instance type (note that you should have at least 2 GB RAM and 2 CPUs for Kubernetes to work properly) |

The `terraform.tfvars` file can look like:

```
cluster_name = "demo"

project_id = "<PROJECT-UUID>"
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

Infrastructure provisioning takes around 3 minutes.

Once the provisioning is done, you need to export the Terraform output using the
following command. This Terraform output file will be used by KubeOne to source
information about the infrastructure and worker nodes.

```bash
terraform output -json > tf.json
```

{{% notice tip %}}
The generated output is based on the [`output.tf` file](https://github.com/kubermatic/kubeone/blob/master/examples/terraform/packet/output.tf).
If you want to change any settings, such as how worker nodes are created,
you can modify the `output.tf` file. Make sure to run `terraform apply`
and `terraform output` again after modifying the file.
{{% /notice %}}

## Installing Kubernetes

Now that you have the infrastructure you can proceed with provisioning
your Kubernetes cluster using KubeOne.

Before you start, you'll need a configuration file that defines how Kubernetes
will be installed, e.g. what version will be used and what features will be
enabled. For the configuration file reference run `kubeone config print --full`.

To get started you can use the following configuration file:

```yaml
apiVersion: kubeone.io/v1alpha1
kind: KubeOneCluster

versions:
  kubernetes: "1.18.0"

cloudProvider:
  name: "packet"
  external: true

clusterNetwork:
  podSubnet: "192.168.0.0/16"
  serviceSubnet: "172.16.0.0/12"
```

{{% notice warning %}}
It's important to provide custom `clusterNetwork` settings in order to
avoid colliding with private Packet network (which is `10.0.0.0/8`).
{{% /notice %}}

This configuration manifest instructs KubeOne to provision Kubernetes 1.18.0
cluster on Packet. Other properties, including information about the infrastructure
and how to create worker nodes are sourced from the [Terraform output][packet_tf_output].
As KubeOne is using [Kubermatic `machine-controller`][machine-controller]
for creating worker nodes, see the [Packet example manifest][packet_mc_example]
for available options.

{{% notice tip %}}
The `external: true` field instructs KubeOne to configure the Kubernetes
components to work with the external Cloud Controller Manager and to deploy
the [Packet CCM](https://github.com/packethost/packet-ccm).
The Packet CCM is responsible for fetching information about nodes from
the API.
{{% /notice %}}

Finally, we're going to install Kubernetes by using the `install` command and
providing the configuration file and the Terraform output:

```bash
kubeone install -m config.yaml --tfjson <DIR-WITH-tfstate-FILE>
```

Alternatively, if the terraform state file is in the current working directory
`--tfjson .` can be used as well.

The installation process takes some time, usually 5-10 minutes. The output
should look like the following one:

```
$ kubeone install -m config.yaml -t tf.json
INFO[14:19:46 EEST] Installing prerequisites…
INFO[14:19:47 EEST] Determine operating system…                   node=147.75.80.241
INFO[14:19:47 EEST] Determine hostname…                           node=147.75.80.241
INFO[14:19:47 EEST] Creating environment file…                    node=147.75.80.241
INFO[14:19:47 EEST] Determine operating system…                   node=147.75.81.119
INFO[14:19:48 EEST] Installing kubeadm…                           node=147.75.80.241 os=ubuntu
INFO[14:19:48 EEST] Determine hostname…                           node=147.75.81.119
INFO[14:19:48 EEST] Creating environment file…                    node=147.75.81.119
INFO[14:19:48 EEST] Determine operating system…                   node=147.75.84.57
INFO[14:19:48 EEST] Installing kubeadm…                           node=147.75.81.119 os=ubuntu
INFO[14:19:49 EEST] Determine hostname…                           node=147.75.84.57
INFO[14:19:49 EEST] Creating environment file…                    node=147.75.84.57
INFO[14:19:49 EEST] Installing kubeadm…                           node=147.75.84.57 os=ubuntu
INFO[14:20:36 EEST] Deploying configuration files…                node=147.75.80.241 os=ubuntu
INFO[14:20:38 EEST] Deploying configuration files…                node=147.75.81.119 os=ubuntu
INFO[14:20:40 EEST] Deploying configuration files…                node=147.75.84.57 os=ubuntu
INFO[14:20:41 EEST] Generating kubeadm config file…
INFO[14:20:42 EEST] Configuring certs and etcd on first controller…
INFO[14:20:42 EEST] Ensuring Certificates…                        node=147.75.80.241
INFO[14:20:54 EEST] Downloading PKI files…                        node=147.75.80.241
INFO[14:20:56 EEST] Creating local backup…                        node=147.75.80.241
INFO[14:20:56 EEST] Deploying PKI…
INFO[14:20:56 EEST] Uploading files…                              node=147.75.81.119
INFO[14:20:56 EEST] Uploading files…                              node=147.75.84.57
INFO[14:21:01 EEST] Configuring certs and etcd on consecutive controller…
INFO[14:21:01 EEST] Ensuring Certificates…                        node=147.75.81.119
INFO[14:21:01 EEST] Ensuring Certificates…                        node=147.75.84.57
INFO[14:21:11 EEST] Initializing Kubernetes on leader…
INFO[14:21:11 EEST] Running kubeadm…                              node=147.75.80.241
INFO[14:22:29 EEST] Joining controlplane node…
INFO[14:22:29 EEST] Waiting 30s to ensure main control plane components are up…  node=147.75.84.57
INFO[14:24:22 EEST] Waiting 30s to ensure main control plane components are up…  node=147.75.81.119
INFO[14:26:21 EEST] Copying Kubeconfig to home directory…         node=147.75.81.119
INFO[14:26:21 EEST] Copying Kubeconfig to home directory…         node=147.75.84.57
INFO[14:26:21 EEST] Copying Kubeconfig to home directory…         node=147.75.80.241
INFO[14:26:22 EEST] Building Kubernetes clientset…
INFO[14:26:26 EEST] Creating credentials secret…
INFO[14:26:26 EEST] Ensure external CCM is up to date
INFO[14:26:27 EEST] Patching coreDNS with uninitialized toleration…
INFO[14:26:27 EEST] Applying canal CNI plugin…
INFO[14:26:31 EEST] Installing machine-controller…
INFO[14:26:35 EEST] Installing machine-controller webhooks…
INFO[14:26:37 EEST] Waiting for machine-controller to come up…
INFO[14:27:17 EEST] Creating worker machines…
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
Once it's done you can proceed and destroy the Packet infrastructure using Terraform:

```bash
terraform destroy
```

You'll be asked to enter `yes` to confirm your intention to destroy the cluster.

Congratulations! You're now running Kubernetes HA cluster with three
control plane nodes and one worker node. If you want to learn more about KubeOne and
its features, make sure to check our [documentation][docs].

[readme]: https://github.com/kubermatic/kubeone/blob/master/README.md
[terraform]: https://www.terraform.io/downloads.html
[packet_support_docs]: https://support.packet.com/kb/articles/api-integrations
[packet_terraform]: https://github.com/kubermatic/kubeone/tree/master/examples/terraform/packet
[packet_variables]: https://github.com/kubermatic/kubeone/blob/master/examples/terraform/packet/variables.tf
[packet_ccm]: https://github.com/packethost/packet-ccm
[packet_tf_output]: https://github.com/kubermatic/kubeone/blob/789509f54b3a4aed7b15cd8b27b2e5bb2a4fa6c1/examples/terraform/packet/output.tf
[machine-controller]: https://github.com/kubermatic/machine-controller
[packet_mc_example]: https://github.com/kubermatic/machine-controller/blob/master/examples/packet-machinedeployment.yaml
[docs]: https://docs.kubermatic.com/kubeone
