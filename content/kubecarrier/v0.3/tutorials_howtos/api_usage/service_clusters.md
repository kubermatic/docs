---
title: ServiceClusters
weight: 20
slug: clusters
date: 2020-04-24T09:00:00+02:00
---

ServiceClusters are Kubernetes clusters that run the actual application workloads managed by their operators,
which are driven by the KubeCarrier Service Hub. To allow that, they first have to be registered in the KubeCarrier 
Management Cluster.

To register a new Service Cluster in KubeCarrier, we will need another Kubernetes cluster and its Kubeconfig.

## Need another Cluster?

If you don't have another Kubernetes Cluster, just go back to [Requirements]({{< relref "../requirements" >}}) and create another cluster with Kind.
In this example we will use the name `eu-west-1` for this new cluster.

When you create another cluster with Kind, you have to work with the **internal** Kubeconfig of the cluster, see command below:

`kind get kubeconfig --internal --name eu-west-1 > /tmp/eu-west-1-kubeconfig`

This will replace the default `localhost:xxxx` address with the container's IP address, allowing KubeCarrier to talk with the other kind cluster.

{{% notice warning %}}
When creating a new cluster with `kind` your active context will be switched to the newly created cluster.
Check `kubectl config current-context` and use `kubectl config use-context` to switch back to the right cluster.
{{% /notice %}}

## Add a ServiceCluster

To add a new Service Cluster, we first have to upload its Kubeconfig as a `Secret` into our Account Namespace.

> Management Cluster
```bash
$ kubectl create secret generic eu-west-1-kubeconfig \
  -n team-a \
  --from-file=kubeconfig=/tmp/eu-west-1-kubeconfig
secret/eu-west-1-kubeconfig created
```

Now that we have the credentials and connection information, we can register the Cluster into KubeCarrier.

```yaml
apiVersion: kubecarrier.io/v1alpha1
kind: ServiceCluster
metadata:
  name: eu-west-1
spec:
  metadata:
    displayName: EU West 1
  kubeconfigSecret:
    name: eu-west-1-kubeconfig
```

You can create the above ServiceCluster CR object with:

> Management Cluster
```bash
$ kubectl apply -n team-a \
  -f https://raw.githubusercontent.com/kubermatic/kubecarrier/v0.3.0/docs/manifests/servicecluster.yaml
servicecluster.kubecarrier.io/team-a created

$ kubectl get servicecluster -n team-a
NAME        STATUS   DISPLAY NAME   KUBERNETES VERSION   AGE
eu-west-1   Ready    EU West 1      v1.17.0              8s
```

KubeCarrier will connect to the Cluster, do basic health checking and report the Kubernetes Version.
