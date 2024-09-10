+++
linkTitle = "Manual CNI Migration"
title = "Manual CNI Migration"
date = 2022-01-12T14:30:00+02:00
weight = 150
+++

As described on the [**CNI & Cluster Network Configuration**]({{< relref "../cni_cluster_network/" >}}) page, the CNI type (e.g. Canal or CIlium) cannot be changed after cluster creation.

However, it is still possible to migrate an user cluster from one CNI to another using some manual steps. This guide will describe the process of migrating a KKP user cluster with Canal CNI to the Cilium CNI.

{{% notice warning %}}

This procedure will cause temporary outage in the user cluster, so it should be performed during a maintenance window. It is also recommended to try this procedure first on a testing cluster in the exactly same infrastructure (same cloud provider, same worker node OS images, same k8s version, etc.) before performing it on a production cluster.

{{% /notice %}}

## Migrating User Cluster with the Canal CNI to the Cilium CNI

Before starting, make sure you understand the [Cilium System Requirements](https://docs.cilium.io/en/stable/operations/system_requirements/) and migration steps. Also please note your current CNI type and version, you will need it in a later step.

#### Step 1:

In order to allow CNI migration, the cluster first needs to be labeled with the `unsafe-cni-migration` label (e.g. `unsafe-cni-migration: "true"`).

{{% notice warning %}}

By putting this label on your cluster you acknowledge that this type of upgrade is not supported by Kubermatic and the you are fully responsible for the consequences it may have. The process can be quite complex and you should be well aware of the target CNI prerequisites and upgrade path steps.

{{% /notice %}}

#### Step 2:

At this point, you are able to change the CNI type and version in the Cluster API. Change Cluster `spec.cniPlugin.type` and `spec.cniPlugin.version` to a supported CNI type and version - in our case `cilium` and `v1.11` respectively:

- either using KKP API endpoint `/api/v2/projects/{project_id}/clusters/{cluster_id}`,

- or by editing the cluster CR in the Seed Cluster (`kubectl edit cluster <cluster-name>`).

Now wait until all Cilium pods are running:

```bash
$ kubectl get pods -A

NAMESPACE              NAME                                        READY   STATUS    RESTARTS   AGE
kube-system            calico-kube-controllers-796995f576-ktrnv    1/1     Running   0          55m
kube-system            canal-45w75                                 2/2     Running   1          52m
kube-system            canal-c9mts                                 2/2     Running   0          52m
kube-system            cilium-869jp                                1/1     Running   0          2m48s
kube-system            cilium-mj7n6                                1/1     Running   0          2m48s
kube-system            cilium-operator-f8447b698-kz267             1/1     Running   0          2m48s
```

Note that at this point, both Canal and Cilium pods are running. Existing pods are still connected via Canal CNI, but Cilium will be used to connect all new pods.

#### Step 3:

Restart all already running non-host-networking pods to ensure that Cilium starts managing them:

{{% notice warning %}}

This command will restart all non-host-networking pods in the cluster.

{{% /notice %}}

```bash
$ kubectl get pods --all-namespaces -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,HOSTNETWORK:.spec.hostNetwork --no-headers=true | grep '<none>' | awk '{print "-n "$1" "$2}' | xargs -L 1 -r kubectl delete pod

pod "calico-kube-controllers-796995f576-ktrnv" deleted
pod "coredns-84968b74bb-5wbwt" deleted
pod "coredns-84968b74bb-qpv5d" deleted
pod "openvpn-client-bf7495b8b-kpqj5" deleted
pod "user-ssh-keys-agent-86bf4" deleted
pod "user-ssh-keys-agent-k75s4" deleted
pod "dashboard-metrics-scraper-dd5d7666f-mzpxp" deleted
pod "dashboard-metrics-scraper-dd5d7666f-vmqbp" deleted
```

If you have the `cilium` CLI installed, you can now verify that all pods are managed by Cilium via `cilium status` (e.g. `Cluster Pods: 8/8 managed by Cilium`):

```bash
$ cilium status

    /¯¯\
 /¯¯\__/¯¯\    Cilium:         OK
 \__/¯¯\__/    Operator:       OK
 /¯¯\__/¯¯\    Hubble:         disabled
 \__/¯¯\__/    ClusterMesh:    disabled
    \__/

DaemonSet         cilium             Desired: 2, Ready: 2/2, Available: 2/2
Deployment        cilium-operator    Desired: 1, Ready: 1/1, Available: 1/1
Containers:       cilium             Running: 2
                  cilium-operator    Running: 1
Cluster Pods:     8/8 managed by Cilium
Image versions    cilium             quay.io/cilium/cilium:v1.11.0@sha256:ea677508010800214b0b5497055f38ed3bff57963fa2399bcb1c69cf9476453a: 2
                  cilium-operator    quay.io/cilium/operator-generic:v1.11.0@sha256:b522279577d0d5f1ad7cadaacb7321d1b172d8ae8c8bc816e503c897b420cfe3: 1
```

#### Step 4:

At this point, you can delete all Canal resources from the cluster.

For instance, if you were running Canal `v3.21` before the upgrade, you can do it as follows (modify the version in the URL if it was different):

```bash
kubectl delete -f https://docs.projectcalico.org/v3.21/manifests/canal.yaml
```

At this point, your cluster should be running on Cilium CNI.

#### Step 5 (Optional):

As the last step, we recommend to perform rolling restart of machine deployments in the cluster. That will make sure your nodes do not contain any leftovers of the Canal CNI, even if they are not affecting anything.

#### Step 6:

Please verify that everything works normally in the cluster. If there are any problems, you can revert the migration procedure and go back to the previously used CNI type and version as described in the next section.

## Migrating User Cluster with the Cilium CNI to the Canal CNI

Please follow the same steps as in [Migrating User Cluster with the Canal CNI to the Cilium CNI](#migrating-user-cluster-with-the-canal-cni-to-the-cilium-cni), with the following changes:

- [(Step 2)](#step-2) Change `spec.cniPlugin.type` and `spec.cniPlugin.version` to `canal` and your desired canal version (e.g. `v3.21`).

- [(Step 3)](#step-3) Skip this step. Do not restart the non-host-networking pods in the cluster before removing Cilium (that would have no effect). Instead, do that as part of the Step 5.

- [(Step 4)](#step-4) In order to remove Cilium resources from the cluster, you can use the following command (modify the version if it was different):

```bash
helm template cilium cilium/cilium --version 1.11.0 --namespace kube-system | kubectl delete -f -
```

- [(Step 5)](#step-5-optional) Restart all already running non-host-networking pods as in the [Step 3](#step-3). We then recommend to perform rolling restart of machine deployments in the cluster as well.
