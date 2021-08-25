+++
title = "GitHub Workflow description"
+++

GitHub Workflow named `kkp.yaml` was created to automate all installation steps to have KKP up and running and
ready to operate with GitOps (using Flux tool).

![Pipeline Schema](pipeline.png?width=700px&classes=shadow,border "Pipeline Schema")

Automation workflows are being triggered on 2 specific events - either on your _Pull Requests_ or after push to _main_ branch.
On pull requests, only the jobs for terraform validate and plan are executed (so that you have visibility what is going to change).
All other jobs are being executed on the _main_ branch after push (in case that any files in directories _kubeone, kubermatic, terraform_ or _.github/workflows_ have changed).

## Jobs

### terraform-kkp-validate, terraform-kkp-dns-validate
Runs validation of all Terraform modules.

### terraform-backend-prepare
Prepares Terraform backend for storing Terraform state.

### terraform-plan
Prepares Terraform plan based on the stored Terraform state.

Terraform state is stored on AWS S3 bucket (created in previous job).

### terraform-apply
Applies the Terraform changes based on a Terraform state.

==> EC2 instances, network and LB for Kubernetes on AWS are prepared at this stage

Runs only after the push in `main` branch.

### kubeone-apply
Performs the cluster provisioning using the `kubeone` tool.

==> Kubernetes cluster is ready to use at this stage

Runs only after the push in `main` branch.

### kkp-deploy
Performs the Kubermatic Kubernetes Platform installation with installer.

==> KKP platform with core components is prepared at this stage

Runs only after the push in `main` branch.

### dns-update
Updates DNS records for KKP services using Terraform module.

==> services from Kubernetes for KKP are retrieved and external IPs are registered in Route53 using hosted zone

Runs only after the push in `main` branch.

### flux-bootstrap
Initiates Flux v2 using `flux bootstrap github` command.

==> monitoring stack for KKP and other KKP resources (seed, preset, project) are delivered after Flux is set up on cluster,
Flux itself is also managed by the same GitHub repository

Runs only after the push in `main` branch.
