+++
title = "Production Recommendations"
date = 2020-04-01T12:00:00+02:00
weight = 4
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

### internal Loadbalancer alternative

In order to hide your Kubernetes API endpoint from the external world, it's recommended to use an internal loadbalancer. 
However due the [limitations](https://docs.microsoft.com/en-us/azure/load-balancer/components#limitations) of the 
loadbalancer, backend VM cannot call the frontend of it's loadbalancer. We recommend to use
 [GoBetween Load Balancer][gobetween] as an alternative here. You will find an example in the 
 [Terrafrom configs][terraform-configs]  