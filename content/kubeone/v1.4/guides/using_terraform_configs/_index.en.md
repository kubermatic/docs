+++
title = "Using Example Terraform Configs"
date = 2021-02-24T12:00:00+02:00
enableToc = true
+++

KubeOne comes with example Terraform configs that can be used to create the
infrastructure needed for running a conformant, production-grade Kubernetes
cluster. The example configs are available for all natively supported
providers and can be found on the
[GitHub under the `examples/terraform`][terraform-configs-github]
directory. They are also coming along with the binaries when you download a
KubeOne release from [GitHub Releases][github-releases].

{{% notice warning %}}
The example Terraform configs are supposed to be used as a foundation for
building your own configs. The configs are optimized for ease of use and
using in E2E tests, and therefore might not be suitable for the production
usage out of the box.
{{% /notice %}}

{{% notice note %}}
Please check the
[Production Recommendations]({{< ref "../../cheat_sheets/production_recommendations" >}})
document for more details about making the example configs suitable for
the production usage.
{{% /notice %}}

## Prerequisites

Before getting started, make sure that you have:

* Downloaded KubeOne by following the [Getting KubeOne][getting-kubeone] guide
* Credentials configured. We recommend configuring environment variables by
  following the [Configuring Credentials][configuring-credentials] guide.
  You can also check the Terraform provider's documentation for other
  authentication options.

## Exploring Configs

If you downloaded KubeOne by using the installation script, downloading the
release, or you've checked out the repository, navigate to the
`./examples/terraform` directory.

If you installed KubeOne using the Arch Linux
package, the example configs are located in the
`/usr/share/doc/kubeone/examples/terraform/` directory. You should copy those
configs to some other place, as they might be removed/overwritten when
upgrading the package.

In this directory, you can find directories for each supported provider.
Navigate to the appropriate directory depending on the provider you want to
use. Each provider's directory has the following files:

| Variable       | Description                                                                                                                                                                                         |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `README.md`    | information about required and available input and output                                                                                                                                           |
| `main.tf`      | the main script defining all resources that will be created by Terraform                                                                                                                            |
| `output.tf`    | defines the format of the file generated using the `terraform output -json` command. The resulting file is used by the KubeOne Terraform Integration to source the information about infrastructure |
| `variables.tf` | available variables that can be used to configure provisioning (e.g. cluster properties, region, instances size, image to be used, and more)                                                        |
| `versions.tf`  | required Terraform and provider's plugin versions                                                                                                                                                   |

Additionally, if your desired provider doesn't provide LBaaS (Load Balancer as
a Service), `gobetween.sh` and `etc_gobetween.tpl` are used to configure the
[GoBetween Load Balancer][gobetween] to be used to access the Kubernetes API.

## Initializing Terraform

The first step you've to do before using the example configs is to initialize
the Terraform working directory and download the required plugins.
This is done by running the `init` command:

```bash
terraform init
```

{{% notice tip %}}
You have to run this command only the first time you're using the example
configs. If you already initialized the Terraform working directory and want to
upgrade plugins instead, you can run `terraform init -upgrade`.
{{% /notice %}}

## Configuring Variables

It's recommended that you familiarize yourself with the available variables and
their default values by checking the `variables.tf` file. Some of the variables
are consistent for all providers, such as the cluster name, the operating
system to be used for the worker nodes (MachineDeployments), and the SSH
information.

You should consider setting at least the following variables:

| Variable            | Required | Default Value     | Description                                              |
| ------------------- | -------- | ----------------- | -------------------------------------------------------- |
| cluster_name        | yes      |                   | cluster name and prefix for cloud resources              |
| ssh_public_key_file |          | ~/.ssh/id_rsa.pub | path to your SSH public key that's deployed on instances |

Make sure that you have configured your SSH agent with the appropriate key as
described in the [Configuring SSH][configuring-ssh] guide. If your setup
doesn't support the SSH agent, you can provide an unencrypted private key
instead by following [those steps][configuring-ssh-noagent].

The easiest way to set variables is to put them in the `terraform.tfvars` file
which is parsed by default. The file should be co-located with other Terraform
files and can look like:

```terraform
cluster_name = "example"

ssh_public_key_file = "~/.ssh/terraform_rsa.pub"
```

You may want to change other variables as well, like the region.
If you decide to change information such as the instance size, the image
to be used, or operating system, ensure that you comply with requirements
defined in the [Infrastructure Management][infrastructure-management]
and [Compatibility][compatibility] documents.

## Creating Infrastructure (applying configs)

With the variables configured, you're ready to create the infrastructure by
applying the configs.

You can see what changes will be made by running the `plan` command:

```bash
terraform plan
```

{{< tabs name="terraform-apply" >}}

{{% tab name="All providers" %}}
If you agree with the proposed changes, run the `apply` command to create
the infrastructure. You'll be asked to type `yes` to confirm your intention.
```bash
terraform apply
```
{{% /tab %}}

{{% tab name="GCE" %}}
Due to how GCP LBs work, initial `terraform apply` requires variable
`control_plane_target_pool_members_count` to be set to 1.

```bash
terraform apply -var=control_plane_target_pool_members_count=1
```

Once initial `kubeone install` or `kubeone apply` is done, the `control_plane_target_pool_members_count` should not be
used.
{{% /tab %}}

{{< /tabs >}}

It takes several minutes to provision the infrastructure and for instances to
come up.

## Exporting Terraform State

The last step regarding provisioning infrastructure is to export the Terraform
state to be parsed by the KubeOne Terraform Integration for information about
instances and worker nodes. The following information is used by KubeOne:

* the load balancer endpoint
* nodes' public and private IP addresses, and hostnames
* SSH parameters (username, port, key)
* bastion/jump host parameters if bastion is used
* information needed to generate the MachineDeployment objects which define
  worker nodes

The `output.tf` file defines the template used to generate the file and the
information to be included in a state file generated by Terraform.
The state file is generated using the `output` command. KubeOne requires the
file to be in the JSON format.

```bash
terraform output -json > tf.json
```

{{% notice note %}}
If you modify variables and/or `output.tf` file after running
`terraform apply`, you're required to run `terraform apply` and
`terraform output` commands again after changes. Note that modifying variables
may cause all resources to be recreated causing the **data loss**!
{{% /notice %}}

[terraform-configs-github]: https://github.com/kubermatic/kubeone/tree/master/examples/terraform
[github-releases]: https://github.com/kubermatic/kubeone/releases
[getting-kubeone]: {{< ref "../../getting_kubeone" >}}
[configuring-credentials]: {{< ref "../credentials" >}}
[gobetween]: http://gobetween.io/
[configuring-ssh]: {{< ref "../ssh" >}}
[configuring-ssh-noagent]: {{< ref "../ssh#option-2-specify-private-key-in-the-terraform-output" >}}
[infrastructure-management]: {{< ref "../../architecture/requirements/infrastructure_management" >}}
[compatibility]: {{< ref "../../architecture/compatibility" >}}
