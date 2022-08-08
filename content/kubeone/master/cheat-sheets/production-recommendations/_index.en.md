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
