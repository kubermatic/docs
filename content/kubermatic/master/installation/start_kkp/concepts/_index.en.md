+++
title = "Concepts"
weight = 3
+++

Using this wizard will provide you with a pre-configured setup of the KKP based on your configuration inputs.

It is using a combination of various tools to handle all steps for you.

Throughout this documentation, we are going to mention many Kubermatic Kubernetese Platform
[concepts and terms]({{< ref "../../../architecture/" >}}).

## Prerequisites

### Cloud Provider
Environment that will be used for cloud resources needed to run the KKP.

Currently, following providers are supported to try KKP:
 * AWS
 * Azure
 * GCP
 * OpenStack
 * vSphere

Required configuration in wizard is different for each of these providers.

### GitHub or GitLab repository
It will be used for storing the declarative setup of all components,
can be either public or private, managed by user or organization.

### Hosted DNS domain
For setting up DNS endpoint for accessing KKP and other components.

{{% notice info %}}
If you have Route53 and willing to try KKP on AWS - records preparation can be fully automated with provided terraform module as long as the hosted zone is the same account as other cloud resources.
{{% /notice %}}

## Used Tools

* **[GitHub Actions / Workflow](https://github.com/features/actions)** - for management of complete delivery pipeline on top of your GitHub repository
* **[GitLab CI/CD](https://docs.gitlab.com/ee/ci/)** - for management of complete delivery pipeline on top of your GitLab repository
* **[Terraform](https://www.terraform.io/)** - for provisioning of cloud resources for Kubernetes master / seed cluster (the cluster that will run Kubermatic Kubernetes Platform components)
* **[KubeOne](https://www.kubermatic.com/products/kubeone/)** - for provisioning of Kubernetes master / seed cluster
* **[KKP installer](https://www.kubermatic.com/products/kubermatic/)** - for installing Kubermatic Kubernetes Platform on master cluster
* **[Flux v2](https://fluxcd.io/)** - GitOps tool for management of additional Kubernetes resources in GitOps way
* **[SOPS](https://github.com/mozilla/sops)** - for storage of sensitive values and configuration in your Git repository, using **[Age](https://github.com/FiloSottile/age)** encryption backend
