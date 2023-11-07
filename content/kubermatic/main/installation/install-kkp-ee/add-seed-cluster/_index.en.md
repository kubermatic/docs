+++
title = "Add Seed Cluster to Kubermatic Kubernetes Platform (KKP) EE"
linkTitle = "Add Seed Cluster to EE"
date = 2018-08-09T12:07:15+02:00
description = "Learn to add a new seed cluster to an existing KKP master cluster (Enterprise Edition)"
weight = 50
enterprise = true
+++

This document describes how a new seed cluster can be added to an existing KKP Enterprise Edition master cluster.

{{% notice note %}}
At the moment you need to be invited to get access to Kubermatic's EE Docker repository before you can try it out.
Please [contact sales](mailto:sales@kubermatic.com) to receive your credentials.
{{% /notice %}}

## Terminology

In this chapter, you will find the following KKP-specific terms:

* **Master Cluster** -- A Kubernetes cluster which is responsible for storing central information about users, projects and SSH keys. It hosts the KKP master components and might also act as a seed cluster.
* **Seed Cluster** -- A Kubernetes cluster which is responsible for hosting the control plane components (kube-apiserver, kube-scheduler, kube-controller-manager, etcd and more) of a User Cluster.
* **User Cluster** -- A Kubernetes cluster created and managed by KKP, hosting applications managed by users.

It is also recommended to make yourself familiar with our [architecture documentation]({{< ref "../../../architecture/" >}}).

## Installation

The installation procedure is almost identical to the [seed setup process for the Community Edition]({{< ref "../../install-kkp-ce/add-seed-cluster" >}}),
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

### Multiple Seeds

The Enterprise Edition (EE) supports running multiple seeds with arbitrary names, lifting the single seed (called `kubermatic`) limitation of the Community Edition (CE).
As such, the seed setup process linked above can be repeated multiple times with different seed clusters. Ignore the `kubermatic` name limitation given
in various places of the seed installation documentation if you are using the Enterprise Edition.

## Next Steps

Once you have set up a seed in your KKP environment, check out some EE-only features you can configure and use on your setup:

- Set up [Metering]({{< ref "../../../tutorials-howtos/metering/" >}}) to measure and report resource consumption across your KKP installation.
- Configure [Resource Quotas]({{< ref "../../../architecture/concept/kkp-concepts/resource-quotas/" >}}) to limit resource consumption in KKP projects.
- Assign [roles to OIDC groups]({{< ref "../../../architecture/iam-role-based-access-control/groups-support/" >}}) to manage authorization for large amount of users.
