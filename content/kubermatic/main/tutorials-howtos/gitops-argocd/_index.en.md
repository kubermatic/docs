+++
title = "GitOps via ArgoCD"
date = 2024-07-30T12:00:00+02:00
weight = 56
linktitle = "GitOps via ArgoCD"
+++

{{% notice warning %}}
This is an Alpha version of Kubermatic management via GitOps which can become the default way to manage KKP in future. This article explains how you can kickstart that journey with ArgoCD right now. But this feature can also change significantly and in backward incompatible ways. **Please use this setup in production at your own risk.**
{{% /notice %}}


## Need of GitOps solution
Kubermatic Kubernetes Platform is a versatile solution to create and manage Kubernetes clusters (user-clusters) a plethora of cloud providers and on-prem virtualizaton platforms. But this flexibility also means that there is a good amount of moving parts. KKP provides various tools to manage user-clusters across various regions and cloudss.

This is why, if we utilize a GitOps solution to manage KKP and its upgrades, KKP administrators would have better peace of mind. We have now provided [an alpha release of ArgoCD based management of KKP master and seeds](https://github.com/kubermatic/kubermatic/tree/main/charts/gitops/kkp-argocd-apps).

This page outlines how to install ArgoCD and team-provided Apps to manage KKP seeds and their upgrades.

## Preparation

In order to setup and manage KKP using a GitOps solution, one must first know some basics about KKP. Following links could be useful to get that knowledge, if you are new to KKP.

1. [KKP main documentation home](../../) for general overview. This documentation is quite vast and you should glance through it but focus on specific links below.
1. [KKP Architecture, terminology and planning](../../architecture/)
1. [Hardware requirements, firewall requirements](../../architecture/requirements/cluster-requirements/), [supported cloud providers](../../architecture/supported-providers/) and [DNS requirements](../../installation/install-kkp-ce/#update-dns--tls)

We will install KKP along the way, so, we do not need a running KKP installation. But if you already have a KKP installation running, you can still make use of this guide to onboard your existing KKP installation to ArgoCD.

## Introduction

The diagram below shows the general concept of the setup. It shows how KKP installations and ArgoCD will be deployed and what KKP components will be managed by ArgoCD in each seed.
![Concept](@/images/tutorials/gitops-argocd/kkp-gitops-argocd.png "Concept - KKP GitOps using ArgoCD")

For the demonstration, 
1. We will use 2 Kubernetes clusters in AWS (created using KubeOne but they could be any Kubernetes clusters on any of the supported cloud / on-prem providers as long as they have a network path to reach each other)
1. Install KKP master on one cluster (c1) and also use this cluster as seed (master-seed combo cluster)
1. Make 2nd cluster (c2) as dedicated seed
1. ArgoCD will be installed in each of the seeds (and master/seed) to manage the respective seed's KKP components

A high-level procedure to get ArgoCD to manage the seed would be as follows:
1. Setup a Kubernetes cluster to be used as master (or master-seed combo)
1. Install ArgoCD Helm chart and KKP ArgoCD Applications Helm chart
1. Install KKP on the master seed using kubermatic-installer
1. Setup DNS records for KKP dashboard as well as ArgoCD endpoint in your DNS server (e.g. Route53 for AWS)
1. Create customized values for your setup in Git repository and create a tag in that git repo so that ArgoCD can sync (can be automated)
1. Sync the applications (can be automated)
1. Repeat the procedure for the 2nd seed (except installation of KKP on the seed)
1. Add two new yaml files in kkp master's config files in Git -  1) kkp Seed CR yaml for 2nd seed  2) seed-kubeconfig secret yaml for 2nd seed. This way KKP master takes control of seed cluster. (can be automated)
1. Commit, push and re-tag the above change so that you can add the seed to master via ArgoCD UI (can be automated)

The `Folder and File Structure` section in the [README.md of ArgoCD Apps Component](https://github.com/kubermatic/kubermatic/blob/main/charts/gitops/kkp-argocd-apps/README.md#folder-and-file-structure) explains what files should be present for each seed in what folders and how to customize the behavior of ArgoCD apps installation.

**Note:** Configuring values for all the components of KKP is a humongous task. Also - each KKP installation might like a different directory structure to manage KKP installation. This ArgoCD Apps based approach is an _opinionated attempt_ to provide a standard structure that can be used in most of the KKP installations. If you need different directory structure, refer to [README.md of ArgoCD Apps Component](https://github.com/kubermatic/kubermatic/blob/main/charts/gitops/kkp-argocd-apps/README.md) to understand how you can customize this, if needed.

### ArgoCD Apps
We will install ArgoCD on both the clusters and we will install following components on both clusters via ArgoCD. In non-GitOps scenario, some of these components are managed via kubermatic-installer and rest are left to be managed by KKP administrator in master/seed clusters by themselves. With ArgoCD, except for kubermatic-operator, everything else can be managed via ArgoCD. Choice remains with KKP Administrator to include which apps to be managed by ArgoCD.

1. Core KKP components
    1. Dex (in master)
    1. ngix-ingress-controller
    1. cert-manager
1. Backup components
    1. Velero
1. Seed monitoring tools
    1. Prometheus
    1. alertmanager
    1. Grafana
    1. kube-state-metrics
    1. node-exporter
    1. blackbox-exporter
    1. Identity aware proxy (IAP) for seed monitoring components
1. Logging components
    1. Promtail
    1. Loki
1. S3-like object storage, like Minio
1. User-cluster MLA components
    1. Minio and Minio Lifecycle Manager
    1. Grafana
    1. Consul
    1. Cortex
    1. Loki
    1. Alertmanager Proxy
    1. IAP for user-mla
    1. secrets - Grafana and Minio secrets
1. Seed Settings - Kubermatic configuration, Seed objects, Preset objects and such misc objects needed for Seed configuration
1. Seed Extras - This is a generic ArgoCD app to deploy arbitrary resources not covered by above things and as per needs of KKP Admin.

## Installation

> You can find code for this tutorial with sample values in [this git repository](https://github.com/kubermatic-labs/kkp-using-argocd). For ease of installation, a `Makefile` has been provided to just make commands easier to read. Internally, it just depends on Helm, kubectl and kubermatic-installer binaries. But you will need to look at `make` target definitions in `Makefile` to adjust DNS names. While for the demo, provided files would work, you would need to look through each file under `dev` folder and customize the values as per your need.

### Setup two Kubernetes Clusters
> This step install two Kubernetes clusters using KubeOne in AWS. You can skip this step if you already have access to two Kubernetes clusters.

Use KubeOne to create 2 clusters in DEV env - master-seed combo (c1) and regular seed (c2). The steps below are generic to any KubeOne installation. a) We create basic VMs in AWS using Terraform and then b) Use KubeOne to bootstrap the control plane on these VMs and then rollout worker node machines.

**Note:** The sample code provided here to create Kubernetes clusters uses single VM control-plane. This is NOT recommended in any way as production. Always use HA control-plane for any production grade Kubernetes installation.

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

# KubeOne needs SSH keys to communicate with machines.
# make sure to use SSH keys which do not need any passphrase

# Setup CP machines and other infra
export AWS_PROFILE=<your AWS profile>
make k1-apply-masters
make k1-apply-seed
```

This same folder structure can be further expanded to add KubeOne installations for additional environments like staging and prod.

### Note about URLs:
The [demo codebase](https://github.com/kubermatic-labs/kkp-using-argocd) assumes `argodemo.lab.kubermatic.io` as base URL for KKP. The KKP Dashboard is available at this URL. This also means that ArgoCD for master-seed, all tools like Prometheus, Grafana, etc are accessible at `*.argodemo.lab.kubermatic.io`
The seed need its own DNS prefix which is configured as `self.seed`. This prefix needs to be configured in Route53 or similar DNS provider in your setup.

Similarly, the demo creates a 2nd seed named `india-seed`. Thus, 2nd seed's ArgoCD, Prometheus, Grafana etc are accessible at `*.india.argodemo.lab.kubermatic.io`. And this seed's DNS prefix is `india.seed`.

These names would come handy to understand the references below to them and customize these values as per your setup.

### Installation of KKP Master-seed combo
1. Install ArgoCD and all the ArgoCD Apps
    ```shell
    cd <root directory of this repo>
    make deploy-argo-dev-master deploy-argo-apps-dev-master
    # get ArgoCD admin password via below command
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    ```
1. Create a git tag with right label. The `make` target creates a git tag with a pre-configured name: `dev-kkp-<kkp-version>` and pushes it to your git repository. This way, when you want to upgrade KKP version, you just need to update the KKP version at the top of Makefile and run this make target again.
    ```shell
    make push-git-tag-dev
    ```
1. ArgoCD syncs nginx ingress and cert-manager automatically
1. Manually update the DNS records so that ArgoCD is accessible. (In the demo, this step is automated via external-dns app)
    ```shell
    # Apply the DNS CNAME record below manually in AWS Route53:
    #   argodemo.lab.kubermatic.io
    #   *.argodemo.lab.kubermatic.io
    #   grafana-user.self.seed.argodemo.lab.kubermatic.io
    #   alertmanager-user.self.seed.argodemo.lab.kubermatic.io
    # You can get load balancer details from `k get svc -n nginx-ingress-controller nginx-ingress-controller`
    # After DNS setup, you can access ArgoCD at https://argocd.argodemo.lab.kubermatic.io
    ```
1. Install KKP EE without Helm charts. If you would want a complete ArgoCD setup with separate seeds, we will need Enterprise Edition of KKP. You can run the demo with master-seed combo. For this, community edition of KKP is sufficient.
    ```shell
    make install-kkp-dev
    ```
1. Add Seed CR for seed called `self`
    ```shell
    make create-long-lived-master-seed-kubeconfig
    # commit changes to git and push latest changes
    make push-git-tag-dev
    ```
1. Wait for all apps to sync in ArgoCD (depending on setup - you can choose to sync all apps manually. In the demo, all apps are configured to sync automatically.)
1. Add Seed DNS record AFTER seed has been added (needed for usercluster creation). Seed is added as part of ArgoCD apps reconciliation above (In the demo, this step is automated via external-dns app)
    ```shell
    # Apply DNS record manually in AWS Route53
    # *.self.seed.argodemo.lab.kubermatic.io
    # Loadbalancer details from `k get svc -n kubermatic nodeport-proxy`
    ```
1. Access KKP dashboard at https://argodemo.lab.kubermatic.io
1. Now you can create user-clusters on this master-seed cluster
1. (only for staging Let's Encrypt) We need to provide the staging Let's Encrypt cert so that monitoring IAP components can work. For this, one needs to save the certificate issuer for `https://argodemo.lab.kubermatic.io/dex/` from browser / openssl and insert the certificate in `dev/common/custom-ca-bundle.yaml` for the secret `letsencrypt-staging-ca-cert` under key `ca.crt` in base64 encoded format. After saving the file, commit the change to git and re-apply the tag via `make push-git-tag-dev` and sync the ArgoCD App.

### Installation of dedicated KKP seed
> **Note:** You can follow these steps only if you have a KKP EE license. With KKP CE licence, you can only work with one seed (which is master-seed combo above)

We follow similar procedure as the master-seed combo but with slightly different commands.
We execute most of the commands below, unless noted otherwise, in a 2nd shell where we have exported kubeconfig of dev-seed cluster above.

1. Install ArgoCD and all the ArgoCD Apps
    ```shell
    cd <root directory of this repo>
    make deploy-argo-dev-seed deploy-argo-apps-dev-seed
    # get ArgoCD admin password via below command
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    ```
1. Add Seed nginx-ingress DNS record (In the demo, this step is automated via external-dns app)
    ```shell
    # Apply below DNS CNAME record manually in AWS Route53
    #   *.india.argodemo.lab.kubermatic.io
    #   grafana-user.india.seed.argodemo.lab.kubermatic.io
    #   alertmanager-user.india.seed.argodemo.lab.kubermatic.io
    # You can get load balancer details from `k get svc -n nginx-ingress-controller nginx-ingress-controller`
    # After DNS setup, you can access the seed ArgoCD at https://argocd.india.argodemo.lab.kubermatic.io
    ```
1. Prepare kubeconfig with cluster-admin privileges so that it can be added as secret and then this cluster can be added as Seed in master cluster configuration
    ```shell
    make create-long-lived-seed-kubeconfig
    # commit changes to git and push latest changes in
    make push-git-tag-dev
    ```
1. Sync all apps in ArgoCD by accessing ArgoCD UI and syncing apps manually
1. Add Seed nodeport proxy DNS record
    ```shell
    # Apply DNS record manually in AWS Route53
    # *.india.seed.argodemo.lab.kubermatic.io
    # Loadbalancer details from `k get svc -n kubermatic nodeport-proxy`
    ```
1. Now we can create user-clusters on this dedicated seed cluster as well.

> NOTE: If you receive timeout errors, you should restart node-local-dns daemonset and/or coredns / cluster-autoscaler deployment to resolve these errors.

----

## Verification that this entire setup works
1. Clusters creation on both the seeds (**Note:** If your VPC does not have a NAT Gateway, then ensure that you selected public IP for worker nodes during cluster creation wizard)
1. Access All Monitoring, Logging, Alerting links - available in left nav on any project within KKP.
1. Check Minio and Velero setup
1. Check User-MLA Grafana and see you can access user-cluster metrics and logs. You must remember to enable user-cluster monitoring and logging during creation of user-cluster.
1. KKP upgrade scenario
    1. Change the KKP version in Makefile
    1. Rollout KKP installer target again
    1. Create new git tag and push this new tag
    1. rollout argo-apps again and sync all apps on both seeds.
