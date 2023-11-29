+++
title = "Install Kubermatic Kubernetes Platform (KKP) EE"
linkTitle = "Install Enterprise Edition"
date = 2018-04-28T12:07:15+02:00
description = "Learn the installation procedure of KKP Enterprise Edition (EE) into a pre-existing Kubernetes cluster"
weight = 20
enterprise = true
+++

This chapter explains the installation procedure of KKP Enterprise Edition (EE) into a pre-existing
Kubernetes cluster.

{{% notice note %}}
At the moment you need to be invited to get access to Kubermatic's EE Docker repository before you can try it out.
Please [contact sales](mailto:sales@kubermatic.com) to receive your credentials.
{{% /notice %}}

## Installation

The installation procedure is identical to the [installation process for the Community Edition]({{< ref "../install-kkp-CE" >}}),
with the exception that a different installer needs to be downloaded and that the Docker credentials need to be configured.

When downloading the installer, make sure to choose the `-ee-` variant on GitHub. Extract it like documented in the CE install
guide.

During configuration, it's required to set the Docker Pull Secret, which allows the local Docker daemons to pull the KKP
images from the private Docker repository. The Docker Pull Secret is a tiny JSON snippet and needs to be configured in the
KubermaticConfiguration (e.g. in the `kubermatic.yaml`):

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  # skipping everything else in this file
  # for demonstration purposes

  # This is where the JSON snippet needs to be configured. It does not need to be
  # a multiline JSON string.
  imagePullSecret: |
    {
      "auths": {
        "quay.io": {....}
      }
    }
```

Follow the CE install guide as normal, the remaining steps apply equally to the Enterprise Edition.


### Pre-Defined Application Catalog

The Enterprise Edition(EE) of KKP offers the capability to deploy an Application Catalog consisting of [well-known Kubernetes applications](https://github.com/kubermatic/kubermatic/tree/main/pkg/ee/default-application-catalog/applicationdefinitions).
The catalog provides an easy solution to make use of upstream helm charts after the installation to get your organization up and running quickly. Applications are integrated into the KKP cluster lifecycle and can be directly managed via the UI, GitOps or KKP Cluster Templates. Afterwards, the initial catalog can be extended and adjusted to your preferences. For more details, please refer to the [Applications documentation]({{< ref "../../architecture/concept/kkp-concepts/applications/" >}}).

![Example of the default Application Catalog](/img/kubermatic/common/applications/default-application-catalogue.png "Example of the default Application Catalog")

In order to deploy pre-defined Application Catalog, add the `--deploy-default-app-catalog` when running the kubermatic installer.

{{% notice info %}}
In order to maintain upgrade compatibility, deploying the default-app-catalog will overwrite any prior [default ApplicationDefinitions](https://github.com/kubermatic/kubermatic/tree/main/pkg/ee/default-application-catalog/applicationdefinitions).
{{% /notice %}}

### Next Steps

* [Add a Seed cluster]({{< ref "./add-seed-cluster-ee" >}}) to start creating user clusters.
* Install the [Master / Seed Monitoring, Logging & Alerting Stack]({{< ref "../../tutorials-howtos/monitoring-logging-alerting/master-seed/installation" >}}) to collect cluster-wide metrics in a central place.
