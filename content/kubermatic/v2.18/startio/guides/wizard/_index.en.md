+++
title = "Use the Wizard to Configure KKP"
description = "From Git provider selection, cloud provider selection, Kubernetes cloud configuration, and KKP bootstrap configuration, learn how to set up Kubermatic Kubernetes Platform with our wizard start.kubermatic.io."
weight = 10
enableToc = true
+++

Start by visiting [https://start.kubermatic.io/](https://start.kubermatic.io/).

Introduction page will welcome you.

Start by clicking on the **Generate** button.

![Welcome Page](welcome.png?width=700px&classes=shadow,border "Welcome Page" )

## 1. Git Provider selection
At this step, you will select a git provider where the repository will be hosted.

![Step 1](1.png?width=700px&classes=shadow,border "Step 1")

## 1. Cloud Provider selection
At this step, you will select a cloud provider where the KKP will be deployed.

![Step 2](2.png?width=700px&classes=shadow,border "Step 2")

## 3. Kubernetes Cluster configuration
At this step, you are providing details of your Kubernetes master cluster.

You can generate a _Cluster name_, provide a Kubernetes _Master Cluster Version_.

For the AWS setup, you can select an _AWS region_ where the cluster will be provisioned and also the _AWS Worker Type_
(see the [Instance Types](https://aws.amazon.com/ec2/instance-types/), we recommend at least _t3.xlarge_ for the initial setup).
{{% notice warning %}}
Make sure to use the x86 instances, ARM instances are not supported.
{{% /notice %}}

Keep in mind that this configuration is for the master cluster where KKP will be deployed, later on you will provision
User clusters through KKP where your workload will be deployed (and for that you may use a different instance types).

![Step 3](3.png?width=700px&classes=shadow,border "Step 3")

## 4. KKP configuration
Here you are going to provide some high-level configuration of the KKP installation.

_Version_ is matching the KKP release tag, see [Release page on github](https://github.com/kubermatic/kubermatic/releases).

_Endpoint_ parameter represents the DNS endpoint where the KKP UI will be accessible in the browser (DNS registration will be described later).
{{% notice warning %}}
Don’t specify a protocol (https://) and the trailing slash in the _Endpoint_ input.
{{% /notice %}}

_Username_ should be your email which will be used for your initial user integrated inside Dex (used as a KKP authentication IdP),
this user will be also “admin” of your KKP installation.

There is optional choice of enabling the monitoring and alerting stack - if enabled, monitoring stack will be deployed on your Kubernetes master cluster.
Monitoring stack includes following services installed as helm charts: _alertmanager_, _prometheus_, _karma_, _grafana_, _kube-state-metrics_, _blackbox-exporter_, _node-exporter_.
The services with the UI interface are accessible on the Ingress endpoints which are configured using OAuth2-Proxy as the identity-aware proxy.
Parameter _IAP Allowed Email Domain_ is used to limit access to monitoring services, see [documentation](https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/overview) for more advanced options.

![Step 4](4.png?width=700px&classes=shadow,border "Step 4")

## 5. KKP Bootstrap configuration
This is an additional step of setting up more KKP entities which are managed as the Custom Resources in your Kubernetes cluster.

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

_Preset_ will be used for provisioning of your user cluster in AWS provider, these credentials will be safely stored in your GitHub repository (values are encrypted with _SOPS_ tool).

![Step 5](5.png?width=700px&classes=shadow,border "Step 5")

## 6. Summary
This is a summary of all your inputs which will be used for generating the configuration for your KKP setup. You can go back to any previous step and update the values if needed.

At this moment, click the **Generate** button.

![Step 6](6.png?width=700px&classes=shadow,border "Step 6")

You will be redirected to the following page and a file named `kkp-generated-bundle.zip` will be downloaded in your browser.

![Congratulations Page](congrats.png?width=700px&classes=shadow,border "Congratulations Page")
