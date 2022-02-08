+++
title = "Get Access to Kubernetes Cluster"
weight = 10
+++

You can either SSH to created control plane instance(s) and use the `/etc/kubernetes/admin.conf` or if you want to
have access to your Kubernetes cluster locally, follow these steps.

## Prerequisites
Make sure that you have following tools installed locally:
 * [KubeOne]({{< ref "../../../../../../kubeone/master/guides/getting_kubeone/" >}})
 * [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
 * [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)

## 1. Retrieve Terraform State
{{% notice warning %}}
Make sure that you have environment variables set for accessing your cloud provider API.
{{% /notice %}}

```bash
cd terraform/<provider>
terraform init
terraform output -json > output.json
cd ../..
```

## 2. Prepare SSH Agent with SSH Key
KubeOne tools requires SSH access to your instances, see [documentation](https://docs.kubermatic.com/kubeone/master/guides/ssh/) for more details.
```bash
cd kubeone
eval `ssh-agent`
ssh-add ~/.ssh/k8s_rsa
```

## 3. Use KubeOne to retrieve kubeconfig
```bash
kubeone kubeconfig -m kubeone.yaml -t ../terraform/<provider>/output.json > kubeconfig
export KUBECONFIG=`pwd`/kubeconfig
kubectl get nodes
```
Now you should see details of your control plane and worker nodes.
