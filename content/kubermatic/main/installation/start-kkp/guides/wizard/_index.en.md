+++
title = "Use the Wizard to Configure KKP"
weight = 10
+++

Start by visiting [https://start.kubermatic.com](https://start.kubermatic.com).

Introduction page will welcome you.

Start by clicking on the **Generate** button.

![Welcome Page](welcome.png?width=700px&classes=shadow,border "Welcome Page" )

## 1. Git provider selection
At this step, you will select a Git provider where the repository will be hosted.

You can pick between GitHub, GitLab and Bitbucket.

![Step 1](1.png?width=700px&classes=shadow,border "Step 1")

## 2. Cloud provider selection
At this step, you will select a cloud provider where the KKP will be deployed.

![Step 2](2.png?width=700px&classes=shadow,border "Step 2")

{{% notice info %}}
Keep in mind that after the selection of Git Provider, some cloud providers may not be available.
It is due to the limited support how the Terraform backend is implemented.
All Cloud Providers are available with GitLab.
{{% /notice %}}

## 3. Kubernetes cluster configuration
At this step, you are providing details of your Kubernetes cluster where Kubermatic Kubernetes Platform will be installed ("Master / Seed Cluster").

You can generate a _Cluster name_, provide a _Kubernetes Version_ and pick the _Container Runtime_.

Then you can configure usage of _Kubernetes Nodes Autoscaler_ by providing minimum and maximum nodes to be managed.

{{% notice warning %}}
Section with provider details is different per each cloud provider, AWS is used in the example below.
{{% /notice %}}

Keep in mind that this configuration is for the master cluster where KKP will be deployed, later on you will provision
User clusters through KKP where your workload will be deployed (and for that you will have a separate control for options like instance types, etc.).

![Step 3](3.png?width=700px&classes=shadow,border "Step 3")

## 4. KKP configuration
Here you are going to provide some high-level configuration of the KKP installation.

_Version_ is matching the KKP release tag, see [Release page on github](https://github.com/kubermatic/kubermatic/releases).

_Endpoint_ parameter represents the DNS endpoint where the KKP Dashboard will be accessible in the browser (DNS registration will be described later).

{{% notice warning %}}
Don’t specify a protocol (https://) and the trailing slash in the _Endpoint_ input.
{{% /notice %}}

_Username_ should be your email which will be used for your initial user integrated inside Dex (used as a KKP authentication provider),
this user will be also the “admin” of your KKP installation.

_Certificate Issuer Email_ should be email for receiving notifications from Let's Encrypt certificate issuer (can be different email than above).

There is optional choice of enabling the Monitoring / Logging / Alerting stack - if enabled, MLA stack for master / seed cluster will be deployed and configured on your Kubernetes cluster.

Monitoring stack includes following services installed as helm charts: _alertmanager_, _prometheus_, _karma_, _grafana_, _kube-state-metrics_, _blackbox-exporter_, _node-exporter_.

The services with the UI interface are accessible on the Ingress endpoints which are configured using OAuth2-Proxy (identity aware proxy).

Parameter _IAP Allowed Email Domain_ is used to limit access to monitoring services, see [documentation](https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/overview) for more advanced options.

![Step 4](4.png?width=700px&classes=shadow,border "Step 4")

## 5. KKP Bootstrap configuration
This is an additional step of setting up more KKP resources which are managed as the Custom Resources in your Kubernetes cluster.

_Project Name_ is used to create a project inside your KKP. Your admin user will be already bound inside this project out of the box.

_Datacenter Configuration_ is used to set up your Seed resource.

{{% notice info %}}
The Seed resource defines the Seed cluster where all control plane components for your user clusters are running.
The Seed resource also includes information about which cloud providers are supported and more.
In our architecture, we'll use the master cluster as a seed cluster, but it can also be a dedicated cluster.
In this wizard, you can setup one datacenter in AWS, you can later on update the Seed configuration to provision the clusters in any other cloud providers as well.
{{% /notice %}}

{{% notice note %}}
Keep in mind that with KKP CE version you can have only one Seed resource!
{{% /notice %}}

_Preset Configuration_ will be used for provisioning of your user cluster in your cloud provider, these credentials will be safely stored in your Git repository (values are encrypted with _SOPS_ tool).

{{% notice warning %}}
Sections with Datacenter and Preset configuration are different per each cloud provider, AWS is used in the example below.
{{% /notice %}}

![Step 5](5.png?width=700px&classes=shadow,border "Step 5")

## 6. Summary
This is a summary of all your inputs which will be used for generating the configuration for your KKP setup. You can go back to any previous step and update the values if needed.

At this moment, click the **Generate** button.

![Step 6](6.png?width=700px&classes=shadow,border "Step 6")

You will be redirected to the following page and a file named `kkp-generated-bundle.zip` will be downloaded in your browser.

![Congratulations Page](congrats.png?width=700px&classes=shadow,border "Congratulations Page")
