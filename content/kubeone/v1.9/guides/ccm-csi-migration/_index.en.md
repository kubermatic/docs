+++
title = "CCM/CSI migration"
date = 2021-09-06T12:00:00+02:00
+++

The CCM/CSI migration is used to migrate your clusters using legacy in-tree
cloud provider (i.e. created **without** `.cloudProvider.external: true`)
to external cloud controller managers (CCMs) and CSI drivers. The CCM/CSI
migration process is currently supported **only** for the following providers:

* Azure
* GCE

This guide provides the context on:

* what are in-tree providers, external CCMs, and CSI drivers
* why and when do you need to migrate
* how to migrate your clusters
* how to troubleshoot failed migration

## Support for Cloud Providers in Kubernetes

Cloud providers that want to support advanced Kubernetes use cases can
implement Kubernetes controller(s) that would connect Kubernetes clusters
with their cloud provider platform/API.

There are three common controllers:

* **Node** controller - annotates Node objects with the information about the
  instance (e.g. instance size, region, availability zone) including IP
  addresses. It also deletes the Node object when the instance is removed
* **Route** controller - configures routes in the cloud appropriately so that
  containers on different nodes in your Kubernetes cluster can communicate with
  each other.
* **Service** controller - providers support for LoadBalancer Services backed
  by cloud provider's Load Balancing offering

In addition, cloud providers can implement controllers for volume operations
so that cloud provider's storage offerings can be used as Kubernetes volumes.

The cloud provider can choose which controllers they want to implement.
In other words, they don't need to implement all those controllers, and they
can also implement additional controllers.

### In-tree Cloud Providers

In the early days of Kubernetes, those controllers were implemented as part of
**kube-controller-manager**. Those controllers were named as **in-tree cloud
providers**, where the in-tree part was referring to the fact that the code
for those controllers was part of the main Kubernetes repository.

This approach worked in the beginning when only very few cloud providers
supported Kubernetes. However, as number of providers that support Kubernetes
increased, many problems appeared:

* Having many in-tree cloud providers integrated in kube-controller-manager
  increases the binary size, while you don't actually need all providers
* All providers had to follow the Kubernetes release cycle. If they wanted to
  change anything in controllers (e.g. they changed the API, added a new
  feature), they would have to wait for a new Kubernetes release to bring
  changes to their users
* Testing and maintaining all the controllers became very complicated

Therefore, it has been decided to **deprecate and remove** in-tree cloud
providers in favor of external cloud controller managers and CSI drivers.
The in-tree cloud providers are disabled as of Kubernetes 1.29, and
permanently removed in Kubernetes 1.30.

### External Cloud Controller Managers (CCMs) and CSI Drivers

External Cloud Controller Manager (CCM) is a set of controllers implemented
by cloud providers. Those controllers are not anymore part of the main
Kubernetes repository, instead, cloud providers can host them wherever they
want. Those controllers also have the same purpose and tasks as in-tree cloud
provider controllers. External CCMs are deployed like any other Kubernetes
workload (e.g. using Deployments or DaemonSets), however, other control plane
components must be configured properly to utilize external CCMs.

However, the controllers for volume operations are not part of the external
CCM. Instead, it has been decided to use Container Storage Interface (CSI)
for handling volume operations. CSI drivers (or also called plugins) are CSI
implementations that are handling all the volume operations, which was
originally done by kube-controller-manager. Similar to external CCMs, CSI
drivers are also deployed like any other Kubernetes workload.

## Who Should Migrate?

If you do **not** have this section in your KubeOneCluster manifest, then
you're running in-tree cloud provider and you **need** to migrate.

```yaml
...
cloudProvider:
  external: true
...
```

{{% notice note %}}
We recommend migrating as soon as possible if your provider is supported
because many in-tree providers are not maintained any longer, so new features
and improvements are only added to the external CCMs and CSI drivers.
{{% /notice %}}

## Migration Prerequisites

Make sure to familiarize yourself with requirements for external CCM and CSI
drivers. Those requirements are provided by cloud providers and you can usually
find them in the repositories for each components:

* Azure: there are no special prerequisites for Azure CCM and CSI drivers
* GCE: there are no special prerequisites for Azure CCM and CSI drivers

## Migrating Your Clusters

The migration is done in two phases as described below. Before the migration,
you need to update your KubeOneCluster manifest as appropriate.

### Phase 0 — Preparing your KubeOneCluster manifest

You must set `.cloudProvider.external` to `true`, so KubeOne can deploy
external CCM and CSI. For example:

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
versions:
  kubernetes: 1.29.4
cloudProvider:
  openstack: {}
  external: true
  cloudConfig: |
    ...
```

In addition to that, specific cloud providers might require additional
configuration.

#### Azure and GCE

In general, no addition configuration or changes are needed for Azure and
GCE, but make sure to check the documents linked in the Migration
Prerequisites section.

### Phase 1 — Deploying External CCM and CSI Plugin, with in-tree cloud provider enabled

The first phase assumes deploying the external CCM and CSI plugin, while
leaving in-tree provider enabled. Kubernetes API server and
kube-controller-manager are configured to:

* use controllers integrated in external CCM instead of in-tree cloud provider
  for all cloud-related operations
* redirect all volumes-related operations to the CSI plugin

The existing worker nodes will continue to use in-tree provider, and that's why
we still leave it enabled on API server and kube-controller-manager.
Therefore, all worker nodes managed by machine-controller must be rolled out
after phase 1 is complete.

To start the first phase of the migration, run the following command. You'll
be asked to confirm your intention by typing `yes`.

```
kubeone migrate to-ccm-csi --manifest kubeone.yaml -t tf.json
```

This command might take 5-10 minutes to finish. After it's done, you need
to roll out all your worker nodes managed by machine-controller, so they start
using external CCM and CSI.

The Rolling Restart MachineDeploments document describes possible approaches
for rotating worker nodes. You can use the following command to rotate all
worker nodes at the same time. For additional approaches, please check the
document.

```
forceRestartAnnotations="{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"forceRestart\":\"$(date +%s)\"}}}}}"
for md in $(kubectl get machinedeployments -n kube-system --no-headers | awk '{print $1}'); do
  kubectl patch machinedeployment -n kube-system $md --type=merge -p $forceRestartAnnotations
done
```

You can watch the progress by running `kubectl get nodes`. Make sure that all
worker nodes are rotated before proceeding to the next phase.

### Phase 2 — Completely disabling in-tree cloud provider

The CCM/CSI migration is completed by fully-disabling in-tree provider.
To trigger the phase 2, users first need to rotate all their worker nodes
managed by machine-controller as described in the previous phase.

After all worker nodes are rotated, you can run the following command to
complete the migration:

```
kubeone migrate to-ccm-csi --complete --manifest kubeone.yaml -t tf.json
```

This command might take up to 5 minutes to finish. After this command is done,
the CCM/CSI migration is fully-completed. Congratulations!

## Alternatives to the CCM/CSI migration

Alternative to the CCM/CSI migration is recreating the cluster from scratch
with `.cloudProvider.external` enabled from the beginning. While that approach
would give you a fresh cluster, it might be complicated because:

* you need to recreate all the resources and re-deploy the workload. This might
  cause some downtime, and it can be very complicated in case you have stateful
  workload
* you need to manually migrate existing PersistentVolumes to the new cluster

{{% notice warning %}}
Restoring from a backup in case of recreating the cluster is not an option
because that might also restore the old configuration and eventually break the
cluster.
{{% /notice %}}
