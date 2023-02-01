+++
title = "Configure Dashboard Interface"
date = 2022-08-10T11:07:15+02:00
weight = 20
+++

Interface section in the Admin Panel allows you to control various UI related settings. They can be used to show/hide certain features on the dashboard.

![Interface](/img/kubermatic/main/ui/interface.png?classes=shadow,border)

- ### [Enable External Clusters](#enable-external-clusters)

- ### [Enable Kubernetes Dashboard](#enable-kubernetes-dashboard)

- ### [Enable OIDC Kubeconfig](#enable-oidc-kubeconfig)

- ### [Enable Web Terminal](#enable-web-terminal)

## Enable External Clusters

![Enable External Cluster](/img/kubermatic/main/ui/enable_external_clusters.png?classes=shadow,border)

External clusters feature allows you to connect third-party Kubernetes clusters in a read-only mode to your Kubermatic
project. Those clusters will not be managed by the Kubermatic Kubernetes Platform therefore the available information
will be limited. Clusters on the list will have an `External` badge to indicate their origin.

### External Cluster on the Cluster List

![External Cluster on the Cluster List](/img/kubermatic/main/ui/external_cluster.png?classes=shadow,border)

#### External Cluster Details

![External Cluster Details](/img/kubermatic/main/ui/external_cluster_details.png?classes=shadow,border)

## Enable Kubernetes Dashboard

![Enable Kubernetes Dashboard](/img/kubermatic/main/ui/enable_kubernetes_dashboard.png?classes=shadow,border)

This section controls the Kubernetes Dashboard support for created user clusters. When enabled an `Open Dashboard`
button will appear on the cluster details, and the API will allow Kubernetes Dashboard proxy access through the API.

### Cluster Details

![Cluster Details](/img/kubermatic/main/ui/cluster_details.png?height=300px&classes=shadow,border)

## Enable OIDC Kubeconfig

![Enable OIDC Kubeconfig](/img/kubermatic/main/ui/enable_oidc_kubeconfig.png?classes=shadow,border)

This setting controls whether OIDC provider should be used as a proxy for the `kubeconfig`. For more details on this feature please visit
[OIDC Provider Configuration]({{< ref "../../../oidc-provider-configuration/share-clusters-via-delegated-OIDC-authentication/_index.en.md" >}}).

![Get Kubeconfig](/img/kubermatic/main/ui/get_kubeconfig.png?classes=shadow,border)

## Enable Web Terminal

![Enable Web Terminal](/img/kubermatic/main/ui/enable_web_terminal.png?classes=shadow,border)

This setting controls whether the `Web Terminal` feature should be enabled for the user clusters. When enabling it, a button will appear on the
top right side of the user cluster page and the API will allow its usage. **Note** that `OIDC Kubeconfig` should be enabled to allow this option.

![Web Terminal](/img/kubermatic/main/ui/web_terminal_button.png?classes=shadow,border)

Please visit [Web Terminal]({{< ref "../../../project-and-cluster-management/web-terminal/_index.en.md" >}}) for more information about this feature.

