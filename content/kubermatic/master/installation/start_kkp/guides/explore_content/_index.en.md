+++
title = "Explore the Generated Bundle"
weight = 20
+++

As you have finished the [steps in the Wizard]({{< ref "../../guides/wizard/" >}}), you have the `kkp-generated-bundle.zip`
file available on your file system.

Let’s unzip it and take a look at the structure.

```text
.
├── .gitignore
├── .github                  # if GitHub was used as Git provider
│   └── workflows
│       └── kkp.yaml
├── .gitlab-ci.yml           # if GitLab was used as Git provider
├── README-local-github.md   # if GitHub was used as Git provider
├── README-local-gitlab.md   # if GitLab was used as Git provider
├── README.md
├── flux
│   └── clusters
│       ├── master
│       │   ├── iap
│       │   │   └── iap.yaml
│       │   ├── kube-system
│       │   │   └── s3-exporter.yaml
│       │   ├── kubermatic
│       │   │   ├── kubermatic-git-source.yaml
│       │   │   ├── kubermatic-setting.yaml
│       │   │   ├── project.yaml
│       │   │   ├── seed.yaml
│       │   │   ├── sops-kustomization.yaml
│       │   │   ├── user.yaml
│       │   │   └── userprojectbinding.yaml
│       │   ├── minio
│       │   │   └── minio.yaml
│       │   └── monitoring
│       │       ├── alertmanager.yaml
│       │       ├── blackbox-exporter.yaml
│       │       ├── grafana.yaml
│       │       ├── karma.yaml
│       │       ├── kube-state-metrics.yaml
│       │       ├── node-exporter.yaml
│       │       └── prometheus.yaml
│       └── master-sops
│           └── kubermatic
│               └── preset.yaml
├── kubeone
│   ├── addons
│   │   ├── 00_kubermatic-ns.yaml
│   │   └── 01_kubermatic-sc.yaml
│   └── kubeone.yaml
├── kubermatic
│   ├── cluster-issuer.yaml
│   ├── kubermatic-configuration.yaml
│   └── values.yaml
├── secrets.md
└── terraform
    └── aws                  # if AWS was used as Cloud provider, other providers are omitted from structure
        ├── README.md
        ├── dns
        │   ├── main.tf
        │   ├── terraform.tfvars
        │   ├── variables.tf
        │   └── versions.tf
        ├── main.tf
        ├── output.tf
        ├── setup_terraform_backend.sh
        ├── terraform.tfvars
        ├── variables.tf
        └── versions.tf
```

There are following directories and files:

* _.github/workflows_ - includes CI/CD jobs for automatic provisioning of cluster and KKP installation (if GitHub was selected as the Git provider).
* _.gitlab-ci.yml_ - includes CI/CD jobs for automatic provisioning of cluster and KKP installation (if GitLab was selected as the Git provider).
* _flux_ - includes Kubernetes resources organized by namespaces which are delivered to your Kubernetes cluster by the Flux GitOps tool.
  There are 2 subdirectories _master_ and _master-sops_. First one includes plain Kubernetes resources and second one
  the Kubernetes resources with some encrypted values (they are treated in special way using decryption provider with Flux).
* _kubeone_ - includes _kubeone.yaml_ definition and addons (k8s resources created in your cluster after provisioning).
  In the addons directory, you will find namespaces and storage class for Kubermatic components (used in next steps).
* _kubermatic_ - includes Kubermatic configuration and values file for Helm chart configuration.
  Keep in mind that Kubernetes Secret with these values is also created in your Kubernetes cluster as we later on use
  it for installation of additional charts with GitOps tool.
* _terraform_ - includes Terraform modules for provisioning of your cloud provider resources to bootstrap a Kubernetes cluster (with KubeOne).
* _secrets.md_ - includes sensitive information about Age secret key which was used for encryption of all sensitive values,
  generated password of your user and other details which should not be EVER committed to your Git repository (it’s defined in _.gitignore_).
  These values will only need to be set in your pipeline secrets / variables according to the next steps (see the example content below)
* _README.md_ - includes high-level information about the structure, tools and steps to follow
* _README-local-(github|gitlab).md_ - includes the step-by-step instructions if you would like to validate the whole installation
  manually instead of using the automated delivery pipeline by GitHub or GitLab

![Example content of secrets.md file](example-secrets.png?width=700px&classes=shadow,border "Example content of secrets.md file")
