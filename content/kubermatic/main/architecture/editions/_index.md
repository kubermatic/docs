+++
title = "Community & Enterprise Editions"
linkTitle = "KKP Editions"
date = 2024-04-23T12:11:35+02:00
weight = 3

+++

## KKP Editions

Kubermatic Kubernetes Platform (KKP) is an open-source product, and both the Community Edition and the Enterprise Edition are available to download from GitHub. However, there are some extra features that are only available in the Enterprise Edition of Kubermatic Kubernetes Platform.

| Feature | Community Edition | Enterprise Edition | Description |
|---------|:-----------------:|:------------------:|-------------|
| **Cloud Providers** | | | User clusters can be provisioned on these cloud providers.
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Alibaba | ✔ | ✔ | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Anexia | ✔ | ✔ | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Amazon Web Services (AWS) | ✔ | ✔ | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Azure | ✔ | ✔ | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DigitalOcean | ✔ | ✔ | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Google Cloud Platform | ✔ | ✔ | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Hetzner (HCloud) | ✔ | ✔ | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;KubeVirt | ✔ | ✔ | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nutanix | ✔ | ✔ | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;OpenStack | ✔ | ✔ | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Equinix Metal (formerly Packet) | ✔ | ✔ | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;VMware Cloud Director | ✔ | ✔ | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;vSphere | ✔ | ✔ | |
| **Kubernetes Providers** (External Clusters) | | | Clusters using these external cluster providers can be added to KKP.
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Google Kubernetes Engine (GKE) | ✔ | ✔ | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Azure Kubernetes Service (AKS) | ✔ | ✔ | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Elastic Kubernetes Service (EKS) | ✔ | ✔ | |
| **Platform Functionality** |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Multi-user architecture | ✔ | ✔ | Multiple users can log-in to the platform and manage their resources independent from each other. |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Project Sharing | ✔ | ✔ | Projects can be shared between users. |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;User Cluster Snapshots | ✔ | ✔ | The etcd database for user clusters can be backed up and restored. |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;User Cluster Backup | – | ✔ | Backups can be done in KKP (through Velero integration) for user clusters in order to transport full clusters, and be able to restore only specific namespaces of a chosen user cluster. |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Cluster Templates | ✔ | ✔ | New user clusters can be created from preconfigured templates. |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;OIDC Integration | ✔ | ✔ | Access to the platform is authenticated via OIDC (Dex by default, but other providers can be used). |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Multiple seed clusters | – | ✔ | Independent management zones for edge, cloud and on-premise sites. |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;OPA Integration | – | ✔ | Allows users to set which image container registries are allowed, so only workloads from those registries can be deployed on user clusters. |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Metering | – | ✔ | Scheduled consumption reports for KKP admins generated automatically by datacenters and projects. |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Resource Quotas | – | ✔ | KKP admins can define consumption caps for different projects. |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Group Project bindings | – | ✔ | Projects can be bound to user groups defined in your authentication provider. |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Edge capabilities | – | ✔ | Independent operation from the control plane and workload allocation among different clusters. |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Web Terminal | ✔ | ✔ | On-demand terminal from the platform, with access to a user cluster |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Application catalog | – | ✔ | Easy solution for deploying and managing the most popular applications in your Kubernetes user clusters right from KKP. |

## How to use Enterprise Edition

If you are willing to use Enterprise Edition, you'll need to [insert a secret during the installation]({{< ref "../../installation/install-kkp-ee/" >}}). In order to own this secret, you will need to be our customer. If you are interested in being our customer, please [contact us](https://www.kubermatic.com/contact-us/) or check our AWS marketplace listing.
