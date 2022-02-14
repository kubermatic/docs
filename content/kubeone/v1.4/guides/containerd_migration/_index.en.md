+++
title = "Migrating to containerd"
date = 2020-06-15T15:00:00+02:00
enableToc = true
+++

Since dockershim has been deprecated and soon (as of kubernetes 1.22+) to be
removed, there is a need to migrate cluster container-runtime to some other CRI
compatible container runtime. At the moment KubeOne supports only containerd as
a second option.

The cluster is divided into 3 groups of nodes:

* control-plane nodes
* static workers
* dynamic workers

and each one needs to be migrated.

## Before migration
{{% notice warning %}}
Please be aware that this operation is quite violent on the cluster as
containers on control-plane and static-worker nodes will be stopped and
restarted!
{{% /notice %}}

## Config

All kubernetes versions prior 1.22+ (where switch will happen) have to
explicitly specify the containerd as a container runtime in the config.
For this please use `containerRuntime.containerd` field as shown below.

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster

versions:
  kubernetes: "1.21.1"

containerRuntime:
  containerd: {}
```

## Migrate control-plane and static-workers

{{% notice warning %}}
Violent changes!
{{% /notice %}}

Once the config is set to containerd:

```shell
terraform output -json > tf.json
kubeone migrate to-containerd -t tf.json
```

This step will do the following on each control-plane and static-worker node:

* reconfigure kubelet to communicate over CRI to containerd
* reconfigure containerd to enable CRI plugin
* stop ALL docker containers
* remove ALL docker containers
* restart kubelet
* wait (with 10 minutes timeout) for all containers to became ready on give node

## Migrate dynamic-workers

Once previous step is completed, machine-controller deployment will be
reconfigured with `-container-runtime=containerd` flag. But your existing
dynamic-workers still using docker. In order to get rid of docker in
dynamic-workers you need to rolling recreate dynamic-workers. To do that please
force machine-controller to recreate Machines. This can be done by patching
MachineDeployment objects at `spec.template.metadata.annotations` for example.

See more at [Rolling Restart MachineDeploments][rolling-restart]

## Outro

If you wish to, it's now safe to uninstall docker / docker-cli. Dockerd is still
running in your control-plane and static-workers nodes, it's just kubelet now
configured to not use it anymore.

{{% notice warning %}}
Do not just disable docker, but uninstall it if you wish to get rid of docker!
Simple `systemctl disable --now docker` IS NOT ENOUGH, you will have to leave
it running or uninstall completely!
{{% /notice %}}

[rolling-restart]: {{< ref "../../cheat_sheets/rollout_machinedeployment" >}}
