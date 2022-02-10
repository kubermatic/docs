+++
title = "Production Recommendations"
date = 2021-02-10T12:00:00+02:00
weight = 1
enableToc = true
+++

## AWS

### ami_id

{{% notice warning %}}
It's very important to set this Terraform variable to avoid future Terraform attempts to recreate your control plane
instance.
{{% /notice %}}

This can be set **after** initial `terraform apply`, and you can find its initial discovered values in your Terraform state by
using:

```bash
terraform state show data.aws_ami.ami
```

Example output:
```terraform
# data.aws_ami.ami:
data "aws_ami" "ami" {
    ...
    id                    = "ami-00f6fb16625871821"
    ...
```

This this example AMI ID is `"ami-00f6fb16625871821"`, in your case it may be different.

In the terraform.tfvars file:
```terraform
ami_id = "ami-00f6fb16625871821"
```

### internal_api_lb

In order to hide your Kubernetes API endpoint from the external world, it's recommended to use `internal_api_lb` which
will cause ELB to be created in "internal" mode (accessible only from inside of your VPC).

```terraform
internal_api_lb = true
```

In order to access your cluster later from outside, there is built-in HTTPS proxy tunnel in KubeOne.

```bash
kubeone proxy -t .
```

Now having this, point your kubectl to this proxy:
```bash
export HTTPS_PROXY=http://127.0.0.1:8888
kubectl get nodes
```

### Resulted terraform.tfvars
The resulting `terraform.tfvars` will now include the following variables:

```terraform
cluster_name    = "my-cool-cluster"
ami_id          = "ami-00f6fb16625871821"
internal_api_lb = true
```

## Azure

### Load Balancers

Due to Azure limitations, you can have only one Basic SKU Load Balancer per
Availability Set. Since we already create a Basic SKU load balancer for the API
server in the Availability Set used by control plane nodes, you can't create
other load balancers in the same set. This also means that you can't create
Kubernetes Load Balancer Services because the creation would fail due to the
mentioned limit.

To mitigate this, our Terraform configs will create a dedicated Availability
Set to be used for worker nodes and Kubernetes Load Balancer Services. With
that setup, all pods exposed via a Kubernetes Load Balancer Service must be
scheduled on worker nodes. Scheduling pods on control plane nodes would make
Azure CCM fail to find underlying instances and add them to the appropriate
Azure load balancer because the newly-created load balancer and control plane
nodes are in different availability sets.

While the Basic SKU Load Balancers might be good for the testing purposes, they
might not be suitable for the production usage. If you're running in
production, you should consider using Standard SKU Load Balancers instead.
Those load balancers are more scalable, have more features, but there are also
more expensive. A more detailed SKU comparison can be found in the
[Azure docs][azure-lb-skus]

To use the Standard SKU load balancer for the API server load balancer, you
need to change the [`lb` object in `main.tf`][azure-lb] to add the `sku` field,
such as:

```terraform
resource "azurerm_lb" "lb" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = "kubernetes"
  location            = var.location
  sku                 = "Standard"
...
```

[azure-lb-skus]: https://docs.microsoft.com/en-us/azure/load-balancer/skus
[azure-lb]: https://github.com/kubermatic/kubeone/blob/c3121b7482f910327ef15b187735e79de0bc9572/examples/terraform/azure/main.tf#L143-L157

## Hetzner

### Kubernetes API Server Endpoint

{{% notice warning %}}
**This can be applied only when creating the cluster for the first time.
Doing this on an existing cluster will effectively break the cluster!**
{{% /notice %}}

By default, the provided Terraform configs for Hetzner use Load Balancer's
public IP for the Kubernetes API server endpoint. This ensures that the
Kubernetes API is reachable via the Internet (e.g. from you local machine using
`kubectl`), however, this causes the traffic between Kubernetes Services to go
via the public interface (i.e. via the Internet).

On Hetzner, there's no option to disable the public IP/interface. The only way
to enforce the traffic between Service to be routed via the private interface
is to use the private interface for the Kubernetes API server endpoint.
This can be done by providing the Load Balancer's private IP (instead of the
public IP) as the Kubernetes API server endpoint.

Doing this will effectively disable accessing the Kubernetes API via the
Internet, but that can be solved by creating an SSH tunnel to one of the
instances. KubeOne provides `kubeone proxy` command which can do that for you.

If you're using our Terraform configs, you only need to change value in the
[`kubeone_api` section of `output.tf`][hz-output-tf] to
`hcloud_load_balancer.load_balancer.network_ip`.

{{% notice note %}}
When creating a new cluster, Terraform will not fetch the private IP of the
Load Balancer on the first run. You need to wait a minute or two after
running `terraform apply` for the first time, and then run it again, so
Terraform can fetch the Load Balancer's private IP and refresh the Terraform
output and state. You can verify this is done by checking the value of
`kubeone_api` in the output of `terraform apply` (there should be a private IP
address set).
{{% /notice %}}

If you don't use Terraform at all, the API endpoint can be set in the
KubeOneCluster manifest via `.apiEndpoint.host` field (see output of
`kubeone config print --full` for more details).

Once you create a new cluster using KubeOne, you can create the SSH tunnel
using the following command:

```
kubeone proxy -m kubeone.yaml -t tf.json
```

KubeOne will print a command that you need to run in a new terminal,
for example:

```
export HTTPS_PROXY=http://127.0.0.1:8888
```

With that done, you can access your cluster using the kubeconfig downloaded by
KubeOne.

{{% notice note %}}
You need to run `kubeone proxy` and `export` commands each time you want to
access your Kubernetes cluster via the Internet.
{{% /notice %}}

[hz-output-tf]: https://github.com/kubermatic/kubeone/blob/5f11decd23b06d9915af412be5f17fb0d3955467/examples/terraform/hetzner/output.tf#L21
