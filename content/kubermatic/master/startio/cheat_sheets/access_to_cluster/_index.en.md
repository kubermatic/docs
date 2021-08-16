+++
title = "Get Access to Kubernetes Cluster"
weight = 10
+++

You can either login to created EC2 instance and use the `/etc/kubernetes/admin.conf` or if you want to
have access to your Master Kubernetes cluster locally, follow these steps:

### Retrieve Terraform State
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

### Prepare SSH Agent with SSH Key
```shell
cd ../kubeone
eval ssh-agent
ssh-add ../k8s_rsa
```

### Use KubeOne to retrieve kubeconfig
```shell
kubeone kubeconfig -m kubeone.yaml -t ../terraform/output.json > kubeconfig
export KUBECONFIG=`pwd`/kubeconfig
kubectl get nodes
```