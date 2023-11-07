+++
title = "Configure Dashboard Interface"
date = 2022-08-10T11:07:15+02:00
weight = 20
+++

Interface section in the Admin Panel allows you to control various UI related settings. They can be used to show/hide certain features on the dashboard.

![Interface](/img/kubermatic/{{< current_version >}}/ui/interface.png?classes=shadow,border)

- [Enable External Clusters](#enable-external-clusters)
- [Enable Kubernetes Dashboard](#enable-kubernetes-dashboard)
- [Enable OIDC Kubeconfig](#enable-oidc-kubeconfig)
- [Disable Admin Kubeconfig](#disable-admin-kubeconfig)
- [Enable Web Terminal](#enable-web-terminal)
- [Enable Share Cluster](#enable-share-cluster)

## Enable External Clusters

![Enable External Cluster](/img/kubermatic/{{< current_version >}}/ui/enable_external_clusters.png?classes=shadow,border)

External clusters feature allows you to connect third-party Kubernetes clusters in a read-only mode to your Kubermatic
project. Those clusters will not be managed by the Kubermatic Kubernetes Platform therefore the available information
will be limited. Clusters on the list will have an `External` badge to indicate their origin.

This is how it looks like on the external cluster list and details page:

![External Cluster on the Cluster List](/img/kubermatic/{{< current_version >}}/ui/external_cluster.png?classes=shadow,border)

![External Cluster Details](/img/kubermatic/{{< current_version >}}/ui/external_cluster_details.png?classes=shadow,border)

## Enable Kubernetes Dashboard

![Enable Kubernetes Dashboard](/img/kubermatic/{{< current_version >}}/ui/enable_kubernetes_dashboard.png?classes=shadow,border)

This section controls the Kubernetes Dashboard support for created user clusters. When enabled an `Open Dashboard`
button will appear on the cluster details, and the API will allow Kubernetes Dashboard proxy access through the API.

![Cluster Details](/img/kubermatic/{{< current_version >}}/ui/cluster_details.png?height=300px&classes=shadow,border)

## Enable OIDC Kubeconfig

![Enable OIDC Kubeconfig](/img/kubermatic/{{< current_version >}}/ui/enable_oidc_kubeconfig.png?classes=shadow,border)

This setting controls whether OIDC provider should be used as a proxy for the `kubeconfig`. For more details on this feature please visit
[OIDC Provider Configuration]({{< ref "../../../oidc-provider-configuration/share-clusters-via-delegated-oidc-authentication" >}}).

![Get Kubeconfig](/img/kubermatic/{{< current_version >}}/ui/get_kubeconfig.png?classes=shadow,border)

## Disable Admin Kubeconfig

![Disable Admin Kubeconfig](/img/kubermatic/{{< current_version >}}/ui/disable_admin_kubeconfig.png?classes=shadow,border)

This setting controls whether Admin kubeconfig feature should be enabled for the user clusters. When disabled, the `Admin Kubeconfig` button will
not be visible on the cluster details page and the corresponding API endpoints will be disabled.

## Enable Web Terminal

![Enable Web Terminal](/img/kubermatic/{{< current_version >}}/ui/enable_web_terminal.png?classes=shadow,border)

This setting controls whether the `Web Terminal` feature should be enabled for the user clusters. When enabling it, a button will appear on the
top right side of the user cluster page and the API will allow its usage. **Note** that `OIDC Kubeconfig` should be enabled to allow this option.

![Web Terminal](/img/kubermatic/{{< current_version >}}/ui/web_terminal_button.png?classes=shadow,border)

Please visit [Web Terminal]({{< ref "../../../project-and-cluster-management/web-terminal" >}}) for more information about this feature.

## Enable Share Cluster

![Enable Share Cluster](/img/kubermatic/{{< current_version >}}/ui/enable_share_cluster.png?classes=shadow,border)

This section controls the support for sharing access to clusters with other users. When enabled, a `Share Cluster`
option will appear in menu on the cluster details, and it can be used to share a link to download the cluster `kubeconfig`.

![Share Cluster](/img/kubermatic/{{< current_version >}}/ui/share_cluster.png?classes=shadow,border)

Please visit [Share Clusters via Delegated OIDC Authentication]({{< ref "../../../oidc-provider-configuration/share-clusters-via-delegated-oidc-authentication" >}}) for more information about this feature.
