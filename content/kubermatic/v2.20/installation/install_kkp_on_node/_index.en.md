+++
linkTitle = "Install KKP - Quick Guide"
title = "Get started with KKP - “KKP on a single node with Kubeone on AWS”"
date = 2022-02-07T12:07:15+02:00
weight = 10
enableToc = true
+++

This chapter will guide you through the KKP Master setup on a single master/worker k8s node using Kubeone. Here, we are leveraging the kubeone addons capability for quick installation of KKP.

In this **Get Started with KKP** guide, we will be using AWS Cloud as our underlying infrastructure and KKP release v2.18.4.

> For more information on the kubeone configurations for different environment, checkout the [Creating the kubernetes Cluster using Kubeone](https://docs.kubermatic.com/kubeone/master/tutorials/creating_clusters/) documentation.

## Prerequisites

1. [Terraform >v1.0.0](https://www.terraform.io/downloads)
2. [Kubeone](https://github.com/kubermatic/kubeone/releases/tag/v1.4.0)

## Download the repository

The [kubermatic/kkp-single-node](https://github.com/kubermatic/kkp-single-node) contains the required configuration to install KKP on single node k8s with kubeone. Clone or download it, so that you deploy KKP quickly as per the following instructions and get started with it!

```bash
git clone https://github.com/kubermatic/kkp-single-node.git
cd kkp-single-node
```

## Configure the Environment

```bash
export AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxxx
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxx
# Path to your private SSH key. This is only used to configure SSH agent on your local machine.
export K1_SSH_PRIVATE_KEY_PATH=~/.ssh/id_rsa
# Path to your public SSH key, copied over to the nodes for SSH access
export K1_SSH_PUBLIC_KEY_PATH=~/.ssh/id_rsa.pub
```

## Create the Infrastructure using Terraform

```bash
make k1-tf-apply PROVIDER=aws
```

**You can update the terraform.tfvars with values such as `cluster_name`, `ssh_public_key_file`, `ssh_private_key_file`. More variables can be overridden here, see variables.tf.**

> **Important**: Add `untaint` flag with value as `true` in the `output.tf` file as shown below

```bash
output "kubeone_hosts" {
  description = "Control plane endpoints to SSH to"

  value = {
    control_plane = {
      untaint              = true
```

## Prepare the KKP addon configuration

> Replace the TODO place holder in addons/kkp yaml definitions.

```bash
export KKP_DNS=xxx.xxx.xxx.xxx
export KKP_USERNAME=xxxx@xxx.xxx
export RANDOM_SECRET=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c32)
export ISSUERCOOKIEKEY=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c32)
export SERVICEACCOUNTKEY=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c32)
mkdir -p ./aws/addons
cp -r ./addons.template/kkp ./aws/addons
sed -i 's/TODO_DNS/'"$KKP_DNS"'/g' ./aws/addons/kkp/*.yaml
sed -i 's/TODO@email.com/'"$KKP_USERNAME"'/g' ./aws/addons/kkp/*.yaml
sed -i 's/TODO-A-RANDOM-SECRET/'"$RANDOM_SECRET"'/g' ./aws/addons/kkp/*.yaml
sed -i 's/TODO-KUBERMATIC-OAUTH-SECRET-FROM-VALUES.YAML/'"$RANDOM_SECRET"'/g' ./aws/addons/kkp/*.yaml
sed -i 's/TODO-A-RANDOM-ISSUERCOOKIEKEY/'"$ISSUERCOOKIEKEY"'/g' ./aws/addons/kkp/*.yaml
sed -i 's/TODO-A-RANDOM-SERVICEACCOUNTKEY/'"$SERVICEACCOUNTKEY"'/g' ./aws/addons/kkp/*.yaml
```

**KKP_DNS** specifies the domain where the kubermatic dashboard would be hosted.

## Create k8s cluster using kubeone along with KKP master as an addon

```bash
make k1-apply PROVIDER=aws
```

## Configure the Cluster access

```bash
export KUBECONFIG=$PWD/aws/<cluster_name>-kubeconfig
```

## Validate the KKP Master setup

* Get the LoadBalancer External IP by following command.

  ```bash
  kubectl get svc -n ingress-nginx
  ```

* Update DNS mapping with External IP of the nginx ingress controller service. In case of AWS, the CNAME record mapping for $TODO_DNS with External IP should be created.

* Nginx Ingress Controller Load Balancer configuration - Add the node to backend pool manually.
  > **Known Issue**: Should be supported in the future as part of Feature request[#1822](https://github.com/kubermatic/kubeone/issues/1822)

* Verify the Kubermatic resources and certificates

  ```bash
  kubectl -n kubermatic get deployments,pods
  ```

  ```bash
  kubectl get certificates -A -w
  ```

  > Wait for a while, if still kubermatic-api-xxx pods / kubermatic & dex tls certificates are not in `Ready` state, delete  and wait to get validated.

## Login to KKP Dashboard

Finally, you should be able to login to KKP dashboard!

Login to https://$TODO_DNS/
> Use username/password configured as part of Kubermatic configuration.
