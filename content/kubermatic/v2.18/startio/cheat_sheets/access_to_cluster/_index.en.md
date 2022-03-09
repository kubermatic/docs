+++
title = "Get Access to Kubernetes Cluster"
description = "Do you know how to access your Kubernetes cluster? Follow these steps to access your Master Kubernetes cluster locally."
weight = 10
+++

You can either login to created EC2 instance and use the `/etc/kubernetes/admin.conf` or if you want to
have access to your Master Kubernetes cluster locally, follow these steps.

## Prerequisites
Make sure that you have following tools installed locally:
 * [kubeone]({{< ref "../../../../../kubeone/master/getting_kubeone/" >}})
 * [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
 * [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)

## 1. Retrieve Terraform State
{{% notice warning %}}
Make sure that you have environment variables for accessing AWS set (`AWS_PROFILE` or
`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`).
{{% /notice %}}
{{% notice info %}}
Value of s3 bucket name used for storing Terraform state can be found at the `secrets.md` file.
{{% /notice %}}
```shell
cd terraform
terraform init -backend-config="bucket=tf-state-kkp-<bucket-suffix>" -backend-config="region=eu-west-1"
terraform output -json > output.json
```

## 2. Prepare SSH Agent with SSH Key
KubeOne tools requires SSH access to your instances, see [documentation](https://docs.kubermatic.com/kubeone/master/guides/ssh/) for more details.
```shell
cd ../kubeone
eval ssh-agent
ssh-add ../k8s_rsa
```

## 3. Use KubeOne to retrieve kubeconfig
```shell
kubeone kubeconfig -m kubeone.yaml -t ../terraform/output.json > kubeconfig
export KUBECONFIG=`pwd`/kubeconfig
kubectl get nodes
```
Now you should see details of your control planes and worker nodes.
