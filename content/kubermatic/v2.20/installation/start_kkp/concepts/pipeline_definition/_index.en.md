+++
title = "Delivery Pipeline description"
+++

Automated pipeline was created in GitHub, GitLab or Bitbucket to automate all installation steps to have KKP up and running and
ready to operate with GitOps (using Flux tool).

![Pipeline Schema](pipeline.png?width=700px&classes=shadow,border "Pipeline Schema")

Jobs are being triggered on 2 specific events - either on your _Pull (Merge) Requests_ or after push to _main_ branch.

On pull requests, only the jobs for terraform validate and plan are executed (so that you have visibility what is going to change).

All other jobs are being executed on the _main_ branch after push (in case that any files in directories _kubeone_, _kubermatic_, _terraform_ or _.github_ (_.gitlab-ci.yml_ / _bitbucket-pipelines.yml_) have changed).

## Jobs

### terraform-kkp-validate, terraform-kkp-dns-validate
Runs validation of Terraform module(s).

### terraform-backend-prepare
Prepares Terraform backend for storing Terraform state.

{{% notice info %}}
This is performed only with [ GitHub / Bitbucket ] and [ AWS / GCP ]. If you are using GitLab, terraform state is stored in GitLab directly.
{{% /notice %}}

### terraform-plan
Prepares Terraform plan based on the stored Terraform state.

### terraform-apply
Applies the Terraform changes based on a Terraform state.

==> VM instances, LB for Kubernetes and other resources are prepared at this stage.

Runs only after the push in `main` branch.

### kubeone-apply
Performs the cluster provisioning using the `kubeone` tool.

==> Kubernetes cluster is ready to use at this stage.

Runs only after the push in `main` branch.

### kkp-deploy
Performs the Kubermatic Kubernetes Platform installation with installer.

==> KKP platform with core components is prepared at this stage.

Runs only after the push in `main` branch.

### dns-update
Updates DNS records for KKP services using Terraform module.

{{% notice info %}}
Optional step for AWS only.
{{% /notice %}}

==> Services from Kubernetes for KKP are retrieved and external IPs are registered in Route53 using hosted zone.

Runs only after the push in `main` branch.

### flux-bootstrap
Initiates Flux v2 using `flux bootstrap github` (or `flux bootstrap gitlab` / `flux bootstrap git`) command.

==> KKP resources (Seed, Preset, Project) and optionally components of Monitoring/Logging/Alerting stack are delivered after Flux is initiated on the cluster,
Flux itself is also managed by the same repository.

Runs only after the push in `main` branch.
