+++
title = ""
date = 2019-04-27T16:06:34+02:00
+++


![Kubermatic Kubernetes Platform logo](/img/KubermaticKubernetesPlatform-logo.jpg)


## What is Kubermatic Kubernetes Platform (KKP)?

Kubermatic Kubernetes Platform (KKP) is a Kubernetes management platform that helps address the operational and security challenges of enterprise customers seeking to run Kubernetes at scale. KKP automates deployment and operations of hundreds or thousands of Kubernetes clusters across hybrid-cloud, multi-cloud and edge environments while enabling DevOps teams with a self-service developer and operations portal.


KKP is directly integrated with leading cloud providers such as [Amazon Web Services](https://docs.kubermatic.com/content/kubermatic/master/architecture/supported_providers/AWS/aws/), [Azure](https://docs.kubermatic.com/kubermatic/master/architecture/supported_providers/azure/azure/), DigitalOcean, [Google Compute Engine](https://docs.kubermatic.com/kubermatic/master/architecture/supported_providers/google_cloud/gcp/), Hetzner, OpenStack, Packet and [VMware vSphere](https://docs.kubermatic.com/kubermatic/master/architecture/supported_providers/vSphere/vSphere/) as well as any provider offering Ubuntu 16.04 or greater, even in your own datacenter.

## Features

#### Powerful & intuitive dashboard to visualize your Kubernetes deployment
Manage your projects and clusters with the KKP dashboard. Scale your cluster by adding and removing nodes in just a few clicks. As an Admin, the dashboard also allows you to customize the theme and disable theming options for other users.

#### Deploy, scale & update multiple Kubernetes clusters
Kubernetes environments must be highly distributed to meet the performance demands of modern cloud native applications. Organizations can ensure consistent operations across all environments with effective cluster management. KKP empowers you to take advantage of all the advanced features that Kubernetes has to offer and increases the speed, flexibility and scalability of your cloud deployment workflow.

At Kubermatic, we have chosen to do multi-cluster management with Kubernetes Operators. Operators (a method of packaging, deploying and managing a Kubernetes application) allow KKP to automate creation as well as the full lifecycle management of clusters. With KKP you can create a cluster for each need, fine-tune it, reuse it and continue this process hassle-free. This results in:
- Better failure resilience
- Smaller individual clusters being more adaptable than one big cluster
- Faster development thanks to less complex environments

#### Kubernetes Autoscaler Integration
Autoscaling in Kubernetes refers to the ability to increase or decrease the number of nodes as the demand for service response changes. Without autoscaling, teams would manually first provision and then scale up or down resources every time conditions change. This means, either services fail at peak demand due to the unavailability of enough resources or you pay at peak capacity to ensure availability.

The Kubernetes Autoscaler in the KKP Cluster automatically scales up/down when one of the following conditions is satisfied:
1. Some pods fail to run in the cluster due to insufficient resources.
2. There are nodes in the cluster that have been underutilized for an extended period (10 minutes by default) and pods running on those nodes can be rescheduled to other existing nodes.

#### Manage all KKP users directly from a single panel
The Admin panel allows KKP administrators to manage the global settings that impact all KKP users directly. Here as an administrator, you can do the following:

- Customize the way custom links (example: Twitter, Github, Slack) are displayed in the Kubermatic dashboard
- Control various cluster related settings that influence cluster creation, management and clean up after deletion
- Select from a range of filters to find and control existing dynamic data centres or add new ones
- Define Preset types in a Kubernetes Custom Resource Definition (CRD) allowing the assignment of new credential types to supported providers
- Enable and configure etcd backups for your clusters through Backup Buckets

#### Manage worker nodes via the UI or the CLI
Worker nodes can be managed via the KKP web dashboard. Once you have installed kubectl, you can also manage them via CLI to automate the creation, deletion, and upgrade of nodes.

#### Monitoring, Logging & Alerting
When it comes to monitoring, no approach fits all use cases. KKP allows you to adjust things to your needs by enabling certain customizations to enable easy and tactical monitoring.
KKP provides two different levels of Monitoring, Logging, and Alerting.

1. The first targets only the management components (master, seed, CRDs) and is independent. This is the Master/Seed Cluster MLA Stack and only the KKP Admins can access this monitoring data.

2. The other component is the User Cluster MLA Stack which is a true multi-tenancy solution for all your end-users as well as a comprehensive overview for the KKP Admin. It helps to speed up individual progress but lets the Admin keep an overview of the big picture. It can be configured per seed to match the requirements of the organizational structure. All users can access monitoring data of the user clusters under the projects that they are members of.

Integrated Monitoring, Logging and Alerting functionality for applications and services in KKP user clusters are built using Prometheus, Loki, Cortex and Grafana. Furthermore, this can be enabled with a single click on the KKP UI.

#### OIDC Provider Configuration
Since Kubernetes does not provide an OpenID Connect (OIDC) Identity Provider, KKP allows the user to configure a custom OIDC. This way you can grant access and information to the right stakeholders.

#### Upgrading Control Plane and the kubelets
A specific version of Kubernetes’ control plane typically supports a specific range of kubelet versions connected to it. KKP enforces the rule “kubelet must not be newer than kube-apiserver, and maybe up to two minor versions older” on its own. KKP ensures this rule is followed by checking during each upgrade of the clusters’ control plane or node’s kubelet. Additionally, only compatible versions are listed in the UI as available for upgrades.

#### OPA
To enforce policies and improve governance in Kubernetes, the Open Policy Agent (OPA) can be used. KKP integrates it using Gatekeeper which is an OPA’s Kubernetes native policy engine. As an Admin you can enable and enforce OPA integration during cluster creation by default via the UI.

#### Cluster Templates
Clusters can be created in a few clicks with the UI. To take the user experience one step further and make repetitive tasks redundant, cluster templates allow you to save data entered into a wizard to create multiple clusters from a single template at once. The templates can be saved to be used subsequently for new cluster creation.

#### Use default Addons to extend the functionality of Kubernetes
Addons are specific services and tools extending the functionality of Kubernetes. Default addons are installed in each user cluster in KKP. The KKP Operator comes with a tool to output full default KKP configuration, serving as a starting point for adjustments. Accessible addons can be installed in each user cluster in KKP on user demand.

{{% notice tip %}}
For latest updates follow us on Twitter [@Kubermatic](https://twitter.com/Kubermatic)
{{% /notice %}}


## Further Information

See [Kubermatic.com](https://www.kubermatic.com/).
