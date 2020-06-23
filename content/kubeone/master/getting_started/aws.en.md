+++
title = "AWS"
date = 2020-04-01T12:00:00+02:00
weight = 8

+++

## How To Install Kubernetes On AWS Cluster Using KubeOne

In this quick start we're going to show how to get started with KubeOne on AWS.
We'll cover how to create the needed infrastructure using our example Terraform
scripts and then install Kubernetes. Finally, we're going to show how to
destroy the cluster along with the infrastructure.

As a result, you'll get Kubernetes High-Available (HA) cluster with three
control plane nodes and three worker nodes.

### Prerequisites

To follow this quick start, you'll need:

* KubeOne v0.11.1 or newer installed, which can be done by following the 
Installing KubeOne section of [the README][readme]
* Terraform v0.12.10 or newer installed. Older releases are not compatible.
The binaries for Terraform can be found on the [Terraform website][terraform]

## Setting Up Credentials

{{% notice warning %}}
The provided credentials are deployed to the cluster to be used by
machine-controller for creating worker nodes. You may want to consider
providing a non-administrator credentials to increase the security.
{{% /notice %}}

In order for Terraform to successfully create the infrastructure and for
machine-controller to create worker nodes, you need an [IAM account][aws-iam]
with the appropriate permissions.

Once you have the IAM account you need to set `AWS_ACCESS_KEY_ID` and
`AWS_SECRET_ACCESS_KEY` environment variables:

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
```

KubeOne can also read the default shared credentials file
(`~/.aws/credentials`). In order to use this approach, you need to explicitly
point the `AWS_PROFILE` environment variable to the profile you want to use:

```bash
export AWS_PROFILE="default"
```

{{% notice note %}}
The `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables have
the highest priority, so if you want to use credentials from the shared
credentials file you must ensure that those two environment variables are unset.
{{% /notice %}}

## Creating Infrastructure

KubeOne is based on the Bring-Your-Own-Infra approach, which means that you have
to provide machines and needed resources yourself. To make this task easier we
are providing Terraform scripts that you can use to get started.
You're free to use your own scripts or any other preferred approach.

The Terraform scripts for AWS are located in the
[`./examples/terraform/aws`][terraform-aws] directory.

{{% notice note %}}
KubeOne comes with the Terraform integration that can source information about
the infrastructure directly from the Terraform output. If you decide not to use
our Terraform scripts, but you still want to use the Terraform integration, you
must ensure that your
[Terraform output (`output.tf`)](https://github.com/kubermatic/kubeone/blob/master/examples/terraform/aws/output.tf)
is using the same format as ours. Alternatively, if you decide not to use Terraform,
you can provide needed information about the infrastructure manually in the
KubeOne configuration file.
{{% /notice %}}

First, we need to switch to the directory with Terraform scripts:

```bash
cd ./examples/terraform/aws
```

Before we can use Terraform to create the infrastructure for us, Terraform needs
to download the AWS plugin. This is done by running the `init` command:

```bash
terraform init
```

{{% notice tip %}}
You need to run this command only the first time before using scripts.
{{% /notice %}}

You may want to configure the provisioning process by setting variables defining
the cluster name, AWS region, instances size and similar. The easiest way is to
create the `terraform.tfvars` file and store variables there. This file is
automatically read by Terraform.

```bash
nano terraform.tfvars
```

For the list of available settings along with their names, please see the
[`variables.tf`][terraform-variables] file. You should consider setting:

| Variable            | Required | Default Value     | Description                                                                                                          |
| ------------------- | -------- | ----------------- | -------------------------------------------------------------------------------------------------------------------- |
| cluster_name        | yes      |                   | cluster name and prefix for cloud resources                                                                          |
| aws_region          |          | eu-west-3         | aws region to use for all resources                                                                                  |
| ssh_public_key_file |          | ~/.ssh/id_rsa.pub | path to your SSH public key that's deployed on instances                                                             |
| control_plane_type  |          | t3.medium         | control plane instance type (note that you should have at least 2 GB RAM and 2 CPUs for Kubernetes to work properly) |


The `terraform.tfvars` file can look like:

```
cluster_name = "demo"

aws_region = "us-east-1"
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

Infrastructure provisioning takes around 2-3 minutes.

Once the provisioning is done, you need to export the Terraform output using the
following command. This Terraform output file will be used by KubeOne to source
information about the infrastructure and worker nodes.

```bash
terraform output -json > tf.json
```

{{% notice tip %}}
The generated output is based on the [`output.tf` file](https://github.com/kubermatic/kubeone/blob/master/examples/terraform/aws/output.tf).
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

```
apiVersion: kubeone.io/v1alpha1
kind: KubeOneCluster
versions:
  kubernetes: '1.18.0'
cloudProvider:
  name: 'aws'
```

This configuration manifest instructs KubeOne to provision Kubernetes 1.18.0
cluster on AWS. Other properties, including information about the infrastructure
and how to create worker nodes are sourced from the [Terraform output][terraform-output].
As KubeOne is using [Kubermatic `machine-controller`][machine-controller]
for creating worker nodes, see the [AWS example manifest][machine-controller-aws]
for available options.

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
time="11:59:19 UTC" level=info msg="Installing prerequisites…"
time="11:59:20 UTC" level=info msg="Determine operating system…" node=157.230.114.40
time="11:59:20 UTC" level=info msg="Determine operating system…" node=157.230.114.39
time="11:59:20 UTC" level=info msg="Determine operating system…" node=157.230.114.42
time="11:59:21 UTC" level=info msg="Determine hostname…" node=157.230.114.40
time="11:59:21 UTC" level=info msg="Creating environment file…" node=157.230.114.40
time="11:59:21 UTC" level=info msg="Installing kubeadm…" node=157.230.114.40 os=ubuntu
time="11:59:21 UTC" level=info msg="Determine hostname…" node=157.230.114.39
time="11:59:21 UTC" level=info msg="Creating environment file…" node=157.230.114.39
time="11:59:21 UTC" level=info msg="Installing kubeadm…" node=157.230.114.39 os=ubuntu
time="11:59:22 UTC" level=info msg="Determine hostname…" node=157.230.114.42
time="11:59:22 UTC" level=info msg="Creating environment file…" node=157.230.114.42
time="11:59:22 UTC" level=info msg="Installing kubeadm…" node=157.230.114.42 os=ubuntu
time="11:59:59 UTC" level=info msg="Deploying configuration files…" node=157.230.114.39 os=ubuntu
time="12:00:03 UTC" level=info msg="Deploying configuration files…" node=157.230.114.42 os=ubuntu
time="12:00:04 UTC" level=info msg="Deploying configuration files…" node=157.230.114.40 os=ubuntu
time="12:00:05 UTC" level=info msg="Generating kubeadm config file…"
time="12:00:06 UTC" level=info msg="Configuring certs and etcd on first controller…"
time="12:00:06 UTC" level=info msg="Ensuring Certificates…" node=157.230.114.39
time="12:00:09 UTC" level=info msg="Generating PKI…"
time="12:00:09 UTC" level=info msg="Running kubeadm…" node=157.230.114.39
time="12:00:09 UTC" level=info msg="Downloading PKI files…" node=157.230.114.39
time="12:00:10 UTC" level=info msg="Creating local backup…" node=157.230.114.39
time="12:00:10 UTC" level=info msg="Deploying PKI…"
time="12:00:10 UTC" level=info msg="Uploading files…" node=157.230.114.42
time="12:00:10 UTC" level=info msg="Uploading files…" node=157.230.114.40
time="12:00:13 UTC" level=info msg="Configuring certs and etcd on consecutive controller…"
time="12:00:13 UTC" level=info msg="Ensuring Certificates…" node=157.230.114.40
time="12:00:13 UTC" level=info msg="Ensuring Certificates…" node=157.230.114.42
time="12:00:15 UTC" level=info msg="Initializing Kubernetes on leader…"
time="12:00:15 UTC" level=info msg="Running kubeadm…" node=157.230.114.39
time="12:01:47 UTC" level=info msg="Joining controlplane node…"
time="12:03:01 UTC" level=info msg="Copying Kubeconfig to home directory…" node=157.230.114.39
time="12:03:01 UTC" level=info msg="Copying Kubeconfig to home directory…" node=157.230.114.40
time="12:03:01 UTC" level=info msg="Copying Kubeconfig to home directory…" node=157.230.114.42
time="12:03:03 UTC" level=info msg="Building Kubernetes clientset…"
time="12:03:04 UTC" level=info msg="Applying canal CNI plugin…"
time="12:03:06 UTC" level=info msg="Installing machine-controller…"
time="12:03:28 UTC" level=info msg="Installing machine-controller webhooks…"
time="12:03:28 UTC" level=info msg="Waiting for machine-controller to come up…"
time="12:04:08 UTC" level=info msg="Creating worker machines…"
time="12:04:10 UTC" level=info msg="Skipping Ark deployment because no backup provider was configured."
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

Worker nodes are managed by the machine-controller. It creates initially one
MachineDeployment object per availability zone. Those can be scaled up and
down (including to 0) using the Kubernetes API. To do so you first got to
retrieve the `machinedeployments` by running:

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
Once it's done you can proceed and destroy the AWS infrastructure using Terraform:

```bash
terraform destroy
```

You'll be asked to enter `yes` to confirm your intention to destroy the cluster.

Congratulations! You're now running Kubernetes HA cluster with three control
plane nodes and three worker nodes. If you want to learn more about KubeOne and
its features, make sure to check our [documentation][docs].

[readme]: https://github.com/kubermatic/kubeone/blob/master/README.md
[terraform]: https://www.terraform.io/downloads.html
[aws-iam]: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html
[terraform-aws]: https://github.com/kubermatic/kubeone/tree/master/examples/terraform/aws
[terraform-output]: https://github.com/kubermatic/kubeone/blob/master/examples/terraform/aws/output.tf
[terraform-variables]: https://github.com/kubermatic/kubeone/blob/master/examples/terraform/aws/variables.tf
[machine-controller]: https://github.com/kubermatic/machine-controller
[machine-controller-aws]: https://github.com/kubermatic/machine-controller/blob/master/examples/aws-machinedeployment.yaml
[access-clusters]: https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/
[docs]: https://docs.kubermatic.com/kubeone
