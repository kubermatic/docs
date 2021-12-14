+++
title = "Concepts"
weight = 3
+++

Using this wizard will provide you with a pre-configured setup of the KKP based on your configuration inputs.

It is using a combination of various tools to handle all steps for you.

Throughout this documentation, we are going to mention many Kubermatic Kubernetese Platform
[concepts and terms]({{< ref "../../architecture/" >}}).

## Prerequisites

### AWS account or vSphere deployment
Environment that will be used for cloud resources needed to run the KKP.
You'll need static credentials for the CLI tools in case of AWS.

### GitHub or GitLab repository
It will be used for storing the declarative setup of all components,
can be either public or private, managed by user or organization.

### Hosted DNS domain
For setting up DNS endpoint for accessing KKP and other components
(if you have Route53 - records preparation can be fully automated as long as the hosted zone is the same account as other AWS resources).

## Used Tools

* **[GitHub Actions / Workflow](https://github.com/features/actions)** - for management of complete delivery pipeline on top of your GitHub repository
* **[GitLab CI/CD](https://docs.gitlab.com/ee/ci/)** - for management of complete delivery pipeline on top of your GitLab repository
* **[Terraform](https://www.terraform.io/)** - for provisioning of AWS resources for Kubernetes master cluster (the cluster that will run Kubermatic Kubernetes Platform components)
* **[KubeOne](https://www.kubermatic.com/products/kubeone/)** - for provisioning of Kubernetes master / seed cluster
* **[KKP installer](https://www.kubermatic.com/products/kubermatic/)** - for installing Kubermatic Kubernetes Platform on master cluster
* **[Flux v2](https://fluxcd.io/)** - GitOps tool for management of all Kubernetes resources in GitOps way
* **[SOPS](https://github.com/mozilla/sops)** - for storage of sensitive values and configuration in your GitHub repository, using **[Age](https://github.com/FiloSottile/age)** encryption backend