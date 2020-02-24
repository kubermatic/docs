+++
title = "Share Clusters via Delegated OIDC Authentication"
date = 2018-11-23T12:01:35+02:00
weight = 70

+++

The purpose of this feature is to allow using an OIDC provider like [Dex](https://github.com/dexidp/dex) to
authenticate to a Kubernetes cluster managed by Kubermatic. This feature can be used to share access to a
cluster with other users.

{{% notice note %}}
**Note:** This feature is **experimental** and not enabled by default. See the [prerequisites](#prerequisites)
section for instruction on how to enable this for your installation.
{{% /notice %}}

### How Does It Work

This section will demonstrate how to obtain and use the `kubeconfig` to connect to a cluster owned by a
different user. Note that the user to which the `kubeconfig` is shared will not have any permissions inside
that shared cluster unless explicitly granted by creating appropriate
[RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac) bindings.

In order to demonstrate the feature we are going to need a working cluster. If you don't have one please
check the [how to create a cluster](../../getting_started/create_cluster/) section. If the feature was
enabled on your installation you should see a "Share cluster" button after navigating to "Cluster details"
page.

![Share cluster button](/img/kubermatic/master/advanced/oidc-auth/share-cluster.png)

Right after clicking on the button you will see a modal window where you can copy the generated link to your
clipboard.

![Share cluster dialog](/img/kubermatic/master/advanced/oidc-auth/share-cluster-modal.png)

You can now share this link with anyone that can access the Kubermatic UI. After login, that person will
get a download link for a `kubeconfig`.

In order for the shared `kubeconfig` to be of any use, we must grant that other user some permissions. To do
so, configure `kubectl` to point to the cluster and create a `rolebinding` or `clusterrolebinding`, using the
email address of the user the `kubeconfig` was shared to as value for the `user` property.

The following example command grants read-only access to the cluster to `user@example.com`:

```bash
kubectl create clusterrolebinding exampleviewer --clusterrole=view --user=user@example.com
```

Now it's time to let the user the cluster was shared to use the config and list some resources for example
`pods`. Even though there might be no `pods` running at the moment the command will not report any authorization
related issues.

```bash
kubectl get pods
#No resources found.
```

If the `exampleviewer` binding gets deleted or something else goes wrong, the following output is displayed instead:

```bash
kubectl get pods
#Error from server (Forbidden): pods is forbidden: User "user@example.com" cannot list pods in the namespace "default"
```

### Prerequisites

In order to enable the feature the necessary flags must be enabled in the
[KubermaticConfiguration]({{< ref "../../concepts/kubermaticconfiguration" >}}). The list of flags is set in
`spec.featureFlags` with a slight unintuitive format. To enable a feature, add a new element to the feature flags
that is a non-empty object (the exact structure is not important). You also need to provide additional information
in the `spec.auth` section and update the UI configuration.

```yaml
spec:
  featureFlags:
    OIDCKubeCfgEndpoint:
      # "enabled" has no special meaning here, nor does its value
      enabled: true

  auth:
    # Client-ID to use for Dex, defaults to "<spec.auth.clientID>Issuer"
    issuerClientID: kubermaticIssuer

    # shared key between Kubermatic and Dex
    issuerClientSecret: "<copy client secret from Dex>"

    # key to encrypt cookies with, e.g. `cat /dev/urandom | tr -dc A-Za-z0-9 | head -c32`
    issuerCookieKey: "<generate random secret here>"

  ui:
    # enable the feature in the UI
    config: |-
      {
        "share_kubeconfig": true
      }
```

{{% notice note %}}
To *disable* a feature, do not set `enabled` to `false`. Instead, remove the entire flag from the `featureFlags` list.
{{% /notice %}}

Apply the changed KubermaticConfiguration and the Kubermatic Operator will reconcile your installation. After a
few moments your changes will take effect.

### Role-Based Access Control Predefined Roles

Kubermatic provides predefined roles and cluster roles to help implement granular permissions for specific resources and
to simplify access control across the user cluster. All of the default roles and cluster roles are labeled with `component=userClusterRole`.

| Default ClusterRole | Description                                                                                                                                                                                                                                       |
|---------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| admin               | Allows admin access. allows read/write access to most resources in a namespace, including the ability to create roles and role bindings within the namespace. This role does not allow write access to resource quota or to the namespace itself. |
| edit                | Allows read/write access to most objects in a namespace. This role does not allow viewing or modifying roles or role bindings. However, this role allows accessing secrets and running pods as any service account in the namespace               |
| view                | Allows read-only access to see most objects in a namespace. It does not allow viewing roles or role bindings.                                                                                                                                     |


| Default Role     | Description                                                                                                                                         |
|------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| namespace-admin  | Allows admin access. Allows read/write access to most resources in a namespace.                                                                     |
| namespace-editor | Allows read/write access to most objects in a namespace. This role allows accessing secrets and running pods as any service account in the namespace|
| namespace-viewer | Allows read-only access to see most objects in a namespace.                                                                                         |

The cluster owner is automatically connected to the `admin` cluster role.

![Kubermatic cluster owner RBAC link](/img/kubermatic/master/advanced/oidc-auth/cluster-owner-rbac.png)

The project user with owner and editor privileges can add and remove bindings to existing roles and cluster roles.

![Kubermatic add binding RBAC link](/img/kubermatic/master/advanced/oidc-auth/add-binding-rbac.png)
