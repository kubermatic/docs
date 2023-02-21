+++
title = "Changing cluster-id for existing vSphere user clusters"
date = 2022-07-06T12:00:00+02:00
weight = 40
+++

Some vSphere user clusters have the `cluster-id` value in the CSI config
set to the vSphere Compute Cluster Name. However, this value is supposed
to be a unique identifier of the cluster. If there are multiple vSphere user
clusters, those clusters might be using the same `cluster-id` value, causing
users to experience issues with volumes (e.g. the CSI driver failing to find
or mount a volume).

As a resolution, you should follow the steps described in this document to
change the `cluster-id` value to a unique value for all affected vSphere
user clusters.

## Glossary

* User cluster name (name of the user cluster): the value of the `NAME` column
  in output of `kubectl get clusters` (e.g. `s8kkpcccfq`)
* Seed cluster kubeconfig: kubeconfig file used to access the Seed cluster
* User cluster kubeconfig: kubeconfig file used to access the specific user
  cluster
* User cluster namespace (in the seed cluster): each KKP user cluster has a
  namespace in the seed cluster named `cluster-<name>`, where `<name>` is the
  user cluster name as defined above (e.g. `cluster-s8kkpcccfq`)

## Affected KKP Versions and vSphere User Clusters

The following vSphere user clusters are affected by this issue:

* Clusters created with the following KKP versions:
  * 2.18.0 - 2.18.9
  * 2.19.0 - 2.19.4
* Clusters migrated to the external CCM/CSI with the following KKP versions:
  * 2.18.0 - 2.18.9
  * 2.19.0 - 2.19.4
  * 2.20.0 - 2.20.1

You can confirm if your user cluster is affected by taking the following steps.
The following steps should be done in the **seed cluster** for each vSphere
user cluster.

<!-- Field selectors are not working here (kubectl returns an error) -->
First, get all user clusters and filter vSphere user clusters using `grep`:

```shell
kubectl --kubeconfig=<seed-cluster-kubeconfig> get clusters | grep vsphere
```

You should get output similar to the following:

```
NAME         HUMANREADABLENAME         OWNER                    VERSION   PROVIDER   DATACENTER          PHASE         PAUSED   AGE
s8kkpcccfq   focused-spence            test@kubermatic.com      1.23.8    vsphere    your-dc             Running       false    16h
```

**For each user cluster in the list**, note down the cluster name (in this case
`s8kkpcccfq`) and inspect the vSphere CSI cloud-config to check value of
the `cluster-id` field.

```shell
kubectl --kubeconfig=<seed-cluster-kubeconfig> get configmap -n cluster-<cluster-name> cloud-config-csi -o yaml
```

The following excerpt shows the most important part of the output. You need to
locate the `cluster-id` field under the `[Global]` group.

```
apiVersion: v1
data:
  config: |+
    [Global]
    user              = "username"
    ...
    cluster-id        = "gph75zqs2q"
...
```

Finally, verify value of the `cluster-id` field:
   1. If it's set to the cluster name (e.g. `s8kkpcccfq`) you're **not**
      affected by this issue and you don't need to take any action
   1. If it's set to the vSphere Compute Cluster Name, you're **affected** and
      you should follow this guide
   1. If the ConfigMap doesn't exist, you're still running the in-tree cloud
      provider, and therefore you're **not** affected. **Make sure that you 
      don't use an affected KKP version when migrating the cluster to the
      external CCM/CSI**

## Changing the `cluster-id` Value

This guide documents two different approaches to change the `cluster-id` value.

The first approach is [recommended by VMware][vmware-kb], however, it requires
pausing affected KKP user clusters **and** stopping the CSI driver for **about
one hour**. For that time, KKP will not reconcile your affected user clusters
and you'll not be able to work with vSphere volumes (attach/detach volumes,
create new volumes, delete volumes...).

The second approach assumes changing `cluster-id` without stopping the CSI
driver. This approach is **not documented** by VMware, however, it worked in 
our environment. In this case, there's no significant downtime. Since this
approach is not documented by VMware, we **heavily advise** that you:
   - follow the first approach
   - if you decide to follow this approach, make sure to extensively test it in
     a staging/testing environment before applying it in the production

### Approach 1 (recommended)

#### Introduction and Warnings

{{% notice warning %}}
This approach assumes pausing all your affected KKP user clusters at same time
and stopping the vSphere CSI driver. When the KKP user cluster is paused, KKP
controllers will **not** reconcile the cluster. You'll not be change properties
of your cluster (e.g. enable/disable features, upgrade cluster...) while the
cluster is paused. You'll be able to use kubectl to access your cluster, and
your workload will run as usual.
{{% /notice %}}

{{% notice warning %}}
Stopping the CSI driver assumes that you'll not be able to work with volumes
while it's stopped. This means that you can't attach/detach or create/delete
volumes. This also means that you'll not be able to schedule/run new pods that
are using vSphere volumes. It's **strongly recommended that you don't delete any
pods that are using vSphere volumes while this procedure is ongoing**, or
otherwise you might not be able to run new pods until the procedure is done.
{{% /notice %}}

This approach assumes doing this procedure for each affected user cluster.
You can optionally choose one cluster and leave it with the old `cluster-id`
value, but we **strongly recommend** migrating all your affected user clusters.
This approach is based on the [official recommendation from VMware][vmware-kb].

#### Pausing User Clusters and Enabling `vsphereCSIClusterID` Feature Flag

Before starting, make sure to download kubeconfig files for each affected
user cluster.

First, pause affected user clusters by running the following command in the
**seed cluster** for **each affected** user cluster:

```shell
clusterPatch='{"spec":{"pause":true,"features":{"vsphereCSIClusterID":true}}}'
kubectl --kubeconfig=<seed-cluster> patch cluster <cluster-name-1> --type=merge -p $clusterPatch
...
kubectl --kubeconfig=<seed-cluster> patch cluster <cluster-name-n> --type=merge -p $clusterPatch
```

Once done, scale down the vSphere CSI driver deployment in **each affected user
cluster**:

```shell
kubectl --kubeconfig=<user-cluster-1> scale deployment -n kube-system vsphere-csi-controller --replicas=0
...
kubectl --kubeconfig=<user-cluster-n> scale deployment -n kube-system vsphere-csi-controller --replicas=0
```

Wait a minute or two to give time for the CSI controller pods to get scaled down
and terminated, and then proceed to change the `cluster-id` value which you need
to do in two places:

1. The `cloud-config-csi` Secret in the user cluster (in the `kube-system`
   namespace)
1. The `cloud-config-csi` ConfigMap in the user cluster namespace in the
   seed cluster

#### Changing the `cloud-config-csi` Secret in the User Cluster

{{% notice warning %}}
You should run steps in this section on one cluster at a time. In other words,
finish all steps in this section for one user cluster, and then repeat all those
steps for other user clusters.
{{% /notice %}}

{{% notice info %}}
`kubectl` commands in this section are targeting the **user cluster**.
{{% /notice %}}

In this section, you'll change the `cloud-config-csi` Secret in to set the
`cluster-id` value to the name of the user cluster. The name of the user cluster
is value of the `NAME` column in output of `kubectl get clusters` for that user
cluster. For example, it looks something like `s8kkpcccfq`.

Since the values of Secrets are base64-encoded, you need to take the config
stored in the Secret, decode it, change the `cluster-id` value, then encode the
config and update the Secret.

The following command reads the config stored in the Secret, decodes it and then
saves it to a file called `cloud-config-csi`:

```shell
kubectl --kubeconfig=<user-cluster-kubeconfig> get secret -n kube-system cloud-config-csi -o=jsonpath='{.data.config}' | base64 -d > cloud-config-csi
```

Open the `cloud-config-csi` file in some text editor:

```shell
vi cloud-config-csi
```

The following excerpt shows the most important part of the file. You need to
locate the `cluster-id` field under the `[Global]` group, and replace
`<vsphere-compute-cluster>` with the name of your user cluster (e.g.
`s8kkpcccfq`).

```
[Global]
user              = "username"
password          = "password"
...
cluster-id        = "<vsphere-compute-cluster>"

[Disk]
...
```

Save the file, exit your editor, and then encode the file:

```shell
cat cloud-config-csi | base64 -w0
```

Copy the encoded output and run the following `kubectl edit` command:

```shell
kubectl --kubeconfig=<user-cluster-kubeconfig> edit secret -n kube-system cloud-config-csi
```

This will open your default text editor and you should see a Secret such as the
following one. Replace `<base64-encoded-config>` with what you have copied, i.e.
with the new config, then save the file and close the editor.

```yaml
apiVersion: v1
data:
  config: <base64-encoded-config>
kind: Secret
metadata:
  creationTimestamp: "2022-07-06T07:39:51Z"
  name: cloud-config-csi
  namespace: kube-system
  resourceVersion: "560"
  uid: c77cf6e9-e69f-4e0d-b69f-f551e5233271
type: Opaque
```

Before proceeding to the next step, **you need to update the `cloud-config-csi`
Secret in other affected user clusters**. Once that's done, proceed to the next
section where you'll update the `cloud-config-csi` Secret in the user cluster
namespaces in the seed cluster.

#### Changing the `cloud-config-csi` ConfigMap in the User Cluster Namespaces

{{% notice warning %}}
You should run steps in this section on one cluster at a time. In other words,
finish all steps in this section for one user cluster, and then repeat all those
steps for other user clusters.
{{% /notice %}}

{{% notice info %}}
`kubectl` commands in this section are targeting the **seed cluster**.
{{% /notice %}}

The ConfigMap is changed in the same way as the Secret, i.e. you need to change
the `cluster-id` value to the name of the user cluster. Run the following
`kubectl edit` command. Replace `<cluster-name>` in the command with the name of
user cluster (e.g. `s8kkpcccfq`).

```shell
kubectl --kubeconfig=<seed-cluster-kubeconfig> edit configmap -n cluster-<cluster-name> cloud-config-csi
```

This will open the default text editor. You should see a ConfigMap like the
following one. Replace `<vsphere-compute-cluster>` with the name of your user
cluster (e.g. `s8kkpcccfq`), then save the file and exit your editor.

```yaml
apiVersion: v1
data:
  config: |+
    [Global]
    user              = "username"
    password          = "password"
    ...
    cluster-id        = "<vsphere-compute-cluster>"

    [Disk]
    ...
```

Before proceeding to the next step, **you need to update the `cloud-config-csi`
ConfigMap for other affected user clusters**. Once that's done, proceed to the
next section where you'll finalize the procedure.

#### Finalizing the Procedure

Before proceeding with this section, you **MUST WAIT FOR AN HOUR** to give time
to vSphere to de-register all volumes.

**After an hour**, patch **each affected** Cluster object to unpause the
cluster. The `vsphereCSIClusterID` feature flag enabled at the beginning ensures
that your `cluster-id` changes are persisted once the clusters are unpaused.

```shell
clusterPatch='{"spec":{"pause":false}}'
kubectl patch cluster <cluster-name-1> --type=merge -p $clusterPatch
...
kubectl patch cluster <cluster-name-n> --type=merge -p $clusterPatch
```

Wait for a few minutes for KKP to reconcile all unpaused user clusters. The
vSphere CSI controller deployment should get scaled up in all user clusters
after a few minutes (up to 5 minutes). Make sure the vSphere CSI controller pods
are running and that volume operations are working (e.g. you can try creating a
pod that uses a vSphere volume).

{{% notice warning %}}
Manually changing Secret and ConfigMap might be skipped since enabling the
feature flag is going to do that automatically without users' interaction.
However, this can trigger a race condition in a way that the CSI deployment is
scaled up before KKP updates Secret in the user cluster. In that case, the
vSphere CSI is going to use the old and incorrect `cluster-id` value, making
this procedure worthless. **Therefore, we heavily advise NOT skipping steps 5
and 6.**
{{% /notice %}}

### Approach 2

#### Introduction and Warnings

{{% notice warning %}}
**This approach is not documented by VMware, so take it on your own risk.** If
you choose this approach, make sure that you properly test it in an appropriate
testing/staging production before applying it to the production.
{{% /notice %}}

This approach assumes changing `cluster-id` without stopping the CSI driver.
This approach also assumes doing this procedure for each affected user cluster
like the first approach. You can optionally choose one cluster and leave it with
the old `cluster-id` value, but we **strongly recommend** migrating all your
affected user clusters.

#### Enabling `vsphereCSIClusterID` Feature Flag

Before starting, make sure to download kubeconfig files for each affected user
cluster.

Start with patching the Cluster object for **each affected** user clusters to
enable the `vsphereCSIClusterID` feature flag. Enabling this feature flag
automatically changes the `cluster-id` value to the cluster name.

```shell
clusterPatch='{"spec":{"features":{"vsphereCSIClusterID":true}}}'
kubectl patch cluster <cluster-name-1> --type=merge -p $clusterPatch
...
kubectl patch cluster <cluster-name-n> --type=merge -p $clusterPatch
```

Wait for a minute or two to give time to KKP to reconcile and apply changes on
all user clusters.

#### Verifying that ConfigMaps and Secrets are Updated

{{% notice warning %}}
You should run steps in this section on one cluster at a time. In other words,
finish all steps in this section for one user cluster, and then repeat all those
steps for other user clusters.
{{% /notice %}}

Ensure that the `cloud-config-csi` ConfigMap in the user cluster namespace in
the seed cluster **AND** the `cloud-config-csi` Secret in the user cluster
(`kube-system` namespace) are updated. The first command reads the config from
the ConfigMap in the user cluster namespace in seed cluster, and the second
commands reads the config from the Secret in the user cluster.

```shell
kubectl --kubeconfig=<seed-cluster-kubeconfig> get configmap -n cluster-<cluster-name> cloud-config-csi
kubectl --kubeconfig=<user-cluster-kubeconfig> get secret -n kube-system cloud-config-csi -o jsonpath='{.data.config}' | base64 -d
```

Both the Secret and the ConfigMap should have config with `cluster-id` set to
the user cluster name (e.g. `s8kkpcccfq`).

```
[Global]
user              = "username"
password          = "password"
...
cluster-id        = "<vsphere-compute-cluster>"

[Disk]
...
```

**Repeat steps in this section for each affected user cluster** and then proceed
to the next section.

#### Restarting the CSI Controller Pods

Finally, restart the vSphere CSI controller pods in the **each affected user
cluster** to put those changes in the effect:

```shell
kubectl --kubeconfig=<user-cluster-kubeconfig-1> delete pods -n kube-system -l app=vsphere-csi-controller
...
kubectl --kubeconfig=<user-cluster-kubeconfig-n> delete pods -n kube-system -l app=vsphere-csi-controller
```

Wait for the new vSphere CSI controller pods to get healthy. Once pods are
healthy, make sure that volume operations are working (e.g. you can try creating
a pod that uses a vSphere volume).

[vmware-kb]: https://kb.vmware.com/s/article/84446
