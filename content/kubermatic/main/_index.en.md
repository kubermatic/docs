+++
title = ""
date = 2019-04-27T16:06:34+02:00
+++

![Kubermatic Kubernetes Platform logo](/img/logo-kubermatic.jpg)

## What is Kubermatic Kubernetes Platform (KKP)?

Kubermatic Kubernetes Platform (KKP) is a Kubernetes management platform that helps address the operational and security challenges of enterprise customers seeking to run Kubernetes at scale. KKP automates deployment and operations of hundreds or thousands of Kubernetes clusters across hybrid-cloud, multi-cloud and edge environments while enabling DevOps teams with a self-service developer and operations portal.

KKP is directly integrated with leading cloud providers including Amazon Web Services (AWS), Google Cloud, Azure, Openstack, VMware vSphere, Open Telekom Cloud, Digital Ocean, Hetzner, Alibaba Cloud, Equinix Metal and Nutanix. For selected providers, ARM is supported as CPU architecture.

In addition to the long list of supported cloud providers, KKP allows building your own infrastructure and joining Kubernetes nodes via the popular `kubeadm` tool.

KKP is the easiest and most effective software for managing cloud native IT infrastructure and automating multi-cloud operations thanks to its unparalleled density and resilience.

## Features

#### Powerful & Intuitive Dashboard to Visualize your Kubernetes Deployment
Manage your [projects and clusters with the KKP dashboard]({{< ref "./tutorials-howtos/project-and-cluster-management/" >}}). Scale your cluster by adding and removing nodes in just a few clicks. As an admin, the dashboard also allows you to [customize the theme]({{< ref "./tutorials-howtos/dashboard-customization/" >}}) and disable theming options for other users.

#### Deploy, Scale & Update Multiple Kubernetes Clusters
Kubernetes environments must be highly distributed to meet the performance demands of modern cloud native applications. Organizations can ensure consistent operations across all environments with effective cluster management. KKP empowers you to take advantage of all the advanced features that Kubernetes has to offer and increases the speed, flexibility and scalability of your cloud deployment workflow.

At Kubermatic, we have chosen to do multi-cluster management with Kubernetes Operators. Operators (a method of packaging, deploying and managing a Kubernetes application) allow KKP to automate creation as well as the full lifecycle management of clusters. With KKP you can create a cluster for each need, fine-tune it, reuse it and continue this process hassle-free. This results in:

- Better failure resilience.
- Smaller individual clusters being more adaptable than one big cluster.
- Faster development thanks to less complex environments.

#### Kubernetes Autoscaler Integration
Autoscaling in Kubernetes refers to the ability to increase or decrease the number of nodes as the demand for service response changes. Without autoscaling, teams would manually first provision and then scale up or down resources every time conditions change. This means, either services fail at peak demand due to the unavailability of enough resources or you pay at peak capacity to ensure availability.

[The Kubernetes Autoscaler in a cluster created by KKP]({{< ref "./tutorials-howtos/kkp-autoscaler/" >}}) can automatically scale up/down when one of the following conditions is satisfied:

1. Some pods fail to run in the cluster due to insufficient resources.
2. There are nodes in the cluster that have been underutilized for an extended period (10 minutes by default) and pods running on those nodes can be rescheduled to other existing nodes.

#### Manage all KKP Users Directly from a Single Panel
The admin panel allows KKP administrators to manage the global settings that impact all KKP users directly. As an administrator, you can do the following:

- Customize the way custom links (example: Twitter, Github, Slack) are displayed in the Kubermatic dashboard.
- Control various cluster related settings that influence cluster creation, management and clean up after deletion.
- Select from a range of filters to find and control existing dynamic data centres or add new ones.
- Define Preset types in a Kubernetes Custom Resource Definition (CRD) allowing the assignment of new credential types to supported providers.
- Enable and configure etcd backups for your clusters through Backup Buckets.

#### Manage Worker Nodes via the UI or the CLI
Worker nodes can be managed [via the KKP web dashboard]({{< ref "./tutorials-howtos/manage-workers-node/via-ui/" >}}). Once you have installed kubectl, you can also manage them [via CLI]({{< ref "./tutorials-howtos/manage-workers-node/via-command-line" >}}) to automate the creation, deletion, and upgrade of nodes.

#### Monitoring, Logging & Alerting
When it comes to monitoring, no approach fits all use cases. KKP allows you to adjust things to your needs by enabling certain customizations to enable easy and tactical monitoring.
KKP provides two different levels of Monitoring, Logging, and Alerting.

1. The first targets only the management components (master, seed, CRDs) and is independent. This is the Master/Seed Cluster MLA Stack and only the KKP Admins can access this monitoring data.

2. The other component is the User Cluster MLA Stack which is a true multi-tenancy solution for all your end-users as well as a comprehensive overview for the KKP Admin. It helps to speed up individual progress but lets the Admin keep an overview of the big picture. It can be configured per seed to match the requirements of the organizational structure. All users can access monitoring data of the user clusters under the projects that they are members of.

Integrated Monitoring, Logging and Alerting functionality for applications and services in KKP user clusters are built using Prometheus, Loki, Cortex and Grafana. Furthermore, this can be enabled with a single click on the KKP UI.

#### OIDC Provider Configuration
Since Kubernetes does not provide an OpenID Connect (OIDC) Identity Provider, KKP allows the user to configure a custom OIDC. This way you can grant access and information to the right stakeholders and fulfill security requirements by managing user access in a central identity provider across your whole infrastructure.

#### Easily Upgrading Control Plane and Nodes
A specific version of Kubernetes’ control plane typically supports a specific range of kubelet versions connected to it. KKP enforces the rule “kubelet must not be newer than kube-apiserver, and maybe up to two minor versions older” on its own. KKP ensures this rule is followed by checking during each upgrade of the clusters’ control plane or node’s kubelet. Additionally, only compatible versions are listed in the UI as available for upgrades.

#### Open Policy Agent (OPA)
To enforce policies and improve governance in Kubernetes, Open Policy Agent (OPA) can be used. KKP integrates it using OPA Gatekeeper as a kubernetes-native policy engine supporting OPA policies. As an admin you can enable and enforce OPA integration during cluster creation by default via the UI.

#### Cluster Templates
Clusters can be created in a few clicks with the UI. To take the user experience one step further and make repetitive tasks redundant, cluster templates allow you to save data entered into a wizard to create multiple clusters from a single template at once. Templates can be saved to be used subsequently for new cluster creation.

#### Use Default Addons to Extend the Functionality of Kubernetes
[Addons]({{< ref "./architecture/concept/kkp-concepts/addons/" >}}) are specific services and tools extending the functionality of Kubernetes. Default addons are installed in each user cluster in KKP. The KKP Operator comes with a tool to output full default KKP configuration, serving as a starting point for adjustments. Accessible addons can be installed in each user cluster in KKP on user demand.

{{% notice tip %}}
For latest updates follow us on Twitter [@Kubermatic](https://twitter.com/Kubermatic)
{{% /notice %}}

## Further Information

See [kubermatic.com](https://www.kubermatic.com/).
