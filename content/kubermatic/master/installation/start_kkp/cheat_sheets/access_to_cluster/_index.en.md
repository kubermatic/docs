+++
title = "Get Access to Kubernetes Cluster"
weight = 10
+++

You can either SSH to one of the created control plane instance(s) and use the `/etc/kubernetes/admin.conf` or if you want to
have access to your Kubernetes cluster locally, follow these steps.

## Prerequisites
Make sure that you have following tools installed locally:
 * [KubeOne]({{< ref "../../../../../../kubeone/master/getting_kubeone/" >}})
 * [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
 * [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)

## 1. Retrieve Terraform State
{{% notice warning %}}
Make sure that you have environment variables set for accessing your cloud provider API.
{{% /notice %}}

{{< tabs name="Get Terraform state" >}}
{{% tab name="GitHub" %}}
Terraform state is stored at remote s3 compatible location (S3 / GCS), and all required configuration is provided via `backend.tf`.

```bash
cd terraform/<provider>
terraform init
terraform output -json > output.json
cd ../..
```
{{% /tab %}}
{{% tab name="GitLab" %}}
Terraform state is stored at GitLab repository, and it's necessary to provide a couple of configuration variables for `terraform init`.

```bash
cd terraform/<provider>
export GITLAB_PROJECT_ID=<GITLAB_PROJECT_ID> # get project ID from GitLab UI or API
export GITLAB_USERNAME=<GITLAB_USERNAME>     # your GitLab user associated with GITLAB_TOKEN
export GITLAB_TOKEN=<GITLAB_TOKEN>           # user access token to talk to GitLab API
export GITLAB_TF_STATE_NAME=kkp              # name of the Gitlab Terraform state
terraform init \
  -backend-config="address=https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${GITLAB_TF_STATE_NAME}" \
  -backend-config="lock_address=https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${GITLAB_TF_STATE_NAME}/lock" \
  -backend-config="unlock_address=https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${GITLAB_TF_STATE_NAME}/lock" \
  -backend-config="username=${GITLAB_USERNAME}" \
  -backend-config="password=${GITLAB_TOKEN}" \
  -backend-config="lock_method=POST" \
  -backend-config="unlock_method=DELETE" \
  -backend-config="retry_wait_min=5"
terraform output -json > output.json
cd ../..
```
{{% /tab %}}
{{% /tabs %}}

## 2. Prepare SSH Agent with SSH Key
KubeOne requires SSH access to your instances, see [documentation](https://docs.kubermatic.com/kubeone/master/guides/ssh/) for more details.
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
