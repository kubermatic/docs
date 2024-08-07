+++
title = "KKP Administration using GitOps via ArgoCD"
date = 2024-07-30T12:00:00+02:00
weight = 56
linktitle = "GitOps via ArgoCD"
+++

{{% notice warning %}}
Kubermatic officially does not have native GitOps support yet. This article explains how you can kickstart that journey with ArgoCD right now. **Please use this setup in production at your own risk.**
{{% /notice %}}


## Need of GitOps solution
Kubermatic Kubernetes Platform is very versatile solution to create and manage Kubernetes clusters (user-clusters) across plethora of Cloud providers and on-prem virtualizaton platforms. But this flexibility also means that there are good amount of moving parts. Kubermatic Kubernetes Platform (KKP) provides various tools to manage user-clusters across various regions and cloud.

This is why, if we utilize a GitOps solution to manage KKP and it's upgrades, KKP administrator would have better peace of mind. While KKP installation does not come ready with a GitOps solution, we have provided [an unofficial component for ArgoCD](https://github.com/kubermatic/community-components/tree/master/ArgoCD-managed-seed) based KKP management.

This page outlines how to install ArgoCD and team provided Apps to manage KKP seeds and their upgrades.

## Preparation

In order to setup and manage KKP using a GitOps solution, one must first know some basics about KKP. Following links could be useful to get that knowledge, if you are new to KKP.

1. [KKP main documentation home](../../) For general overview. This documentation is quite vast and I would suggest you glance through this but focus on specific links below.
1. [KKP Architecture, terminology and planning](../../architecture/)
1. [Hardware requirements, firewall requirements](../../architecture/requirements/cluster-requirements/) and [supported cloud providers](../../architecture/supported-providers/) and [DNS requirements](../../installation/install-kkp-ce/#update-dns--tls)

We will install KKP along the way so, we do not need a running KKP installation. But if you already have KKP installation running, you can still make use of this guide to onboard your existing KKP installation to ArgoCD. This might involve in directory re-organization though.

## Introduction
For the demonstration, 
1. we will use 2 kubernetes clusters in AWS (created using Kubeone but they could be any Kubernetes clusters as long as they have a network path to reach each other)
1. install KKP master on one cluster (c1) and also use this cluster as seed (master-seed combo cluster)
1. Make 2nd cluster (c2) as dedicated seed

Folder and File Structure section in the [README.md of ArgoCD Apps Component](https://github.com/kubermatic/community-components/blob/master/ArgoCD-managed-seed/README.md) explains what files should be present for each seed in what folders and how to customize behavior of ArgoCD apps installation.

**Note:** Configuring values for all the components of KKP is a humongous task. Also - each customer might like a different directory structure to manage KKP installation. This ArgoCD Apps based approach is an opinionated attempt to provide a standard structure that can be used in most of the customer installations. If you need different directory structure, refer to [README.md of ArgoCD Apps Component](https://github.com/kubermatic/community-components/blob/master/ArgoCD-managed-seed/README.md) to understand how you can customize this, if needed.

### ArgoCD Apps
We will install ArgoCD on both the clusters and we will install following components on both clusters via ArgoCD. In non-GitOps scenario, some  of these components are managed via kubermatic-installer and rest are left to be managed by KKP administrator in master/seed clusters by themselves.

1. Core KKP components
    1. DEX (in master)
    1. ngix-ingress-controller
    1. certManager
1. Backup components
    1. Velero
1. Seed monitoring tools
    1. Prometheus
    1. AlertManager
    1. Grafana
    1. KubeStateMetrics
    1. NodeExporter
    1. BlackboxExporter
    1. Identity aware proxy (IAP) for seed monitoring  components
1. Logging components
    1. Promtail
    1. Loki
1. S3 like object storage - minio
1. User-cluster mla components
    1. Minio and Minio Lifecycle Manager
    1. Grafana
    1. Consul
    1. Cortex
    1. LokiDistributed
    1. AlertmanagerProxy
    1. iap for user-mla
    1. secrets - grafana and minio secrets
1. Seed Settings - Kubermatic configuration, Seed objects, preset objects and such misc objects needed for Seed configuration
1. Seed Extras - This is a generic ArgoCD app to deploy arbitrary resources not covered by above things and as per needs of KKP Admin.

## Installation

### Setup two Kubernetes Clusters
> This step install two Kubernetes clusters using Kubeone in AWS. You can skip this step, if you already have access to two kubernetes clusters.

Use kubeone to create 2 clusters in DEV env - master-seed combo (c1) and regular seed (c2). Steps below are generic to any kubeone installation. a) We create basic VMs in AWS using terraform and then b) Use kubeone to bootstrap the control plane on these VMs and then rollout worker node machines.

**Note:** The sample code provided here to create kubernetes clusters uses single VM control-plane. This is NOT recommended in any way as production. Always use HA control-plane for any production grade kubernetes installation.

You should be looking at `terraform.tfvars` and `kubeone.yaml` files to customize these folder as per your needs.

```shell
# directory structure
kubeone-install
├── dev-master
│   ├── kubeone.yaml
│   ├── main.tf
│   ├── output.tf
│   ├── terraform.tfvars
│   ├── variables.tf
│   ├── versions.tf
├── dev-seed
│   ├── kubeone.yaml
│   ├── main.tf
│   ├── output.tf
│   ├── terraform.tfvars
│   ├── variables.tf
│   ├── versions.tf
└── kubeone

# Kubeone needs ssh-keys to communicate with machines.
# make sure to use ssh-keys which do not need any passphrase 

# Setup CP machines and other infra
export AWS_PROFILE=<your AWS profile>
cd kubeone-install/dev-master
terraform init && terraform plan
terraform apply -auto-approve
terraform output -json > tf.json
cd ../dev-seed
terraform init && terraform plan
terraform apply -auto-approve
terraform output -json > tf.json

# Apply kubeone and download kubeconfigs
cd ../dev-master
../kubeone apply -t . -m ./kubeone.yaml --verbose
export KUBECONFIG=$PWD/argodemo-dev-master-kubeconfig # adjust as per cluster name

# in another shell
cd ../dev-seed
../kubeone apply -t . -m ./kubeone.yaml --verbose
export KUBECONFIG=$PWD/argodemo-dev-seed-kubeconfig  # adjust as per cluster name
```

This same folder structure can be further expanded to add kubeone installations for additional environments like staging and prod.

### Installation of KKP with Argo Installation Steps
For ease of installation, I have prepared a `Makefile` to just make commands easier to read. Internally, it just depends on helm, kubectl and kubermatic-installer binaries. But you will need to look at `make` target definitions in `Makefile` to adjust DNS names.

While for my demo, provided files would work, you would need to look through each file under `dev` folder and customize the values as per your need.

### Note about URLs:
This demo codebase assumes `argodemo.lab.kubermatic.io` as base URL for KKP. KKP Dashboard is available at this URL. So master argocd, all master tools like prometheus, grafana, etc are accessible at `*.argodemo.lab.kubermatic.io`
The seed need it's own DNS prefix which configured as `self.seed`. This prefix needs to be configured in Route53.

Similarly, this demo creates 2nd seed named `india-seed`. Thus, 2nd seed's argocd, prometheus, grafana etc are accessible at `*.india.argodemo.lab.kubermatic.io`. And this seed's DNS prefix is `india.seed`.

These names would come handy to understand below references to them and customize these values as per your setup.

### Installation of KKP Master-seed combo
1. Install ArgoCD and all the ArgoCD Apps
    ```shell
    cd <root directory of this repo>
    make deploy-argo-dev-master deploy-argo-apps-dev-master
    # get argocd admin password via below command
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    ```
1. Tag the git with right label. The make target creates a git tag with a pre-configured name: `dev-kkp-<kkp-version>` and pushes it to your git repository. This way, when you want to upgrade KKP version, you just need to update the KKP version at the top of Makefile and run this make target again.
    ```shell
    make push-git-tag-dev
    ```
1. ArgoCD syncs nginx ingress and cert-manager automatically
1. Manually update the DNS records so that ArgoCD is accessible.
    ```shell
    # Apply DNS record manually in AWS Route53
    # load balancer details from k get svc -n nginx-ingress-controller nginx-ingress-controller
    # argodemo.lab.kubermatic.io and *.argodemo.lab.kubermatic.io
    # now you can access ArgoCD at https://argocd.argodemo.lab.kubermatic.io
    ```
1. Install KKP EE without helm-charts. If we want to finish the demo with separate seed, we will need Enterprise Edition KKP. You can run the demo with master-seed combo, you can use community edition of KKP.
    ```shell
    make install-kkp-dev
    ```
1. Apply ClusterIssuer. Note: During the demo, we are using staging letsencrypt certificate provider. In real world, you should use production lets-encrypt certificate issuer. Just need to change the url in below.
    ```shell
    kubectl apply -f dev/clusterIssuer.yaml
    ```
1. Add seed for self (need manual update of kubeconfig in seed.yaml)
    ```shell
    make create-long-lived-master-seed-kubeconfig
    # above target creates a file seed-ready-kube-config with base64 encoded kubeconfig
    # Manually update the content of seed-ready-kube-config in the seed-kubeconfig-secret-self.yaml
    kubectl apply -f dev/demo-master/seed-kubeconfig-secret-self.yaml
    # commit changes to git and push latest changes in
    make push-git-tag-dev
    ```
1. Sync all apps in ArgoCD by accessing ArgoCD UI and syncing apps manually
1. Seed DNS record AFTER seed has been added (needed for usercluster creation). Seed is added as part of ArgoCD apps reconciliation above
    ```shell
    # Apply DNS record manually in AWS Route53
    # Loadbalancer details from k get svc -n kubermatic nodeport-proxy
    # *.self.seed.argodemo.lab.kubermatic.io
    ```
1. Now we can create user-clusters on this master-seed cluster
1. (only for staging letsencrypt) We need to provide the staging letsencrypt cert so that monitoring IAP components can work. For this, one needs to save the certificate issuer for `https://argodemo.lab.kubermatic.io/dex/` from browser / openssl and insert the certificate in `dev/common/custom-ca-bundle.yaml` for the secret `letsencrypt-staging-ca-cert` under key `ca.crt` in base64 encoded format. Post saving the file, commit the change to git and re-apply the tag via `make push-git-tag-dev` and sync the ArgoCD App .

### Installation of dedicated KKP seed
> **Note:** You can follow these steps only if you have a KKP EE license with you. With KKP CE licence, you can only work with one seed (which is master-seed combo above)

We follow similar procedure as master-seed combo but with slightly different commands.
We execute most of the below commands, unless noted otherwise, in 2nd shell where we have exported kubeconfig of dev-seed cluster above.

1. Install ArgoCD and all the ArgoCD Apps
    ```shell
    cd <root directory of this repo>
    make deploy-argo-dev-seed deploy-argo-apps-dev-seed
    # get argocd admin password via below command
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    ```
1. Apply ClusterIssuer. Note: During the demo, we are using staging letsencrypt certificate provider. In real world, you should use production lets-encrypt certificate issuer. Just need to change the url in below.
    ```shell
    kubectl apply -f dev/clusterIssuer.yaml
    ```
1. Add Seed nginx-ingress DNS record
    ```shell
    # Apply DNS record manually in AWS Route53
    # india.argodemo.lab.kubermatic.io and *.india.argodemo.lab.kubermatic.io
    # now you can access ArgoCD at https://argocd.india.argodemo.lab.kubermatic.io
    ```
1. Prepare kubeconfig of cluster-admin privileges so that it can be added as secret and then this cluster can be added as Seed in master cluster configuration
    ```shell
    make create-long-lived-seed-kubeconfig

    # NOTE: export master kubeconfig for below operation
    kubectl apply -f dev/demo-master/seed-kubeconfig-secret-india.yaml
    ```
1. Sync all apps in ArgoCD by accessing ArgoCD UI and syncing apps manually
1. Add Seed nodeport proxy DNS record
    ```shell
    # Apply DNS record manually in AWS Route53
    # *.india.seed.argodemo.lab.kubermatic.io
    ```
1. Now we can create user-clusters on this dedicated seed cluster as well.


> NOTE: Sometimes, we get weird errors about timeouts. We need to restart node-local-dns daemonset and/or coredns / cluster-autoscaler deployment to resolve these errors.

----

## Verification that this entire setup works
1. Clusters creation on both the seeds (**Note:** If your VPC does not have a NAT Gateway, then ensure that you selected public IP for worker nodes during cluster creation wizard)
1. Access All Monitoring, Logging, Alerting links - available in left nav on any project within KKP.
1. Check minio and velero setup
1. Check User-mla grafana and see you can access user-cluster metrics and logs. You must remember to enable user-cluster monitoring and logging during creation of user-cluster.
1. KKP upgrade scenario
    1. Change the KKP version in Makefile
    1. Rollout KKP installer target again
    1. Create new git tag and push this new tag
    1. rollout argo-apps again and sync all apps on both seeds.


## Further improvements which still to be done
1. Use Secrets folder (e.g. with git-crypt)
1. Sync Presets
1. Thanos Application
1. Can we look at moving Argo App templates to ApplicationSet / App of Apps?
1. Optional External-DNS app so that DNS entries can be done separately.
1. Can we run make targets via Github actions?
