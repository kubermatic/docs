+++
title = "Cilium Cluster Mesh Setup"
date = 2022-12-07T09:45:00+02:00
weight = 180
+++

This guide describes the setup for configuring Cilium Cluster Mesh between 2 KKP user clusters
running with Cilium CNI.

{{< table_of_contents >}}

## Versions
This guide was made for the following versions of KKP and Cilium:

- KKP 2.22-pre-alpha (main)
- Cilium 1.13-rc3

It will be updated once the final minor versions for both platforms are released.

## Prerequisites
Before proceeding, please review that your intended setup meets
the [Prerequisites for Cilium Cluster Mesh](https://docs.cilium.io/en/latest/network/clustermesh/clustermesh/#prerequisites).

Especially, keep in mind that nodes in all clusters must have IP connectivity between each other. The ports that need to be allowed between all nodes of all clusters are:

- UDP 8472 (VXLAN)
- TCP 4240 (HTTP health checks)

## Deployment Steps

### 1. Create 2 KKP User Clusters with non-overlapping pod CIDRs
Create 2 user clusters with Cilium CNI and `ebpf` proxy mode (necessary to have Cluster Mesh working also for cluster-ingress traffic via LoadBalancer or NodePort services). The clusters need to have non-overlapping pod CIDRs, so at least one of them needs to have the `spec.clusterNetwork.pods.cidrBlocks` set to a non-default value (e.g. `172.26.0.0/16`).

We will be referring to these clusters as `Cluster 1` and `Cluster 2` in this guide.

### 2. Enable Cluster Mesh in the Cluster 1
**In Cluster 1**, edit the Cilium ApplicationInstallation values (via UI, or `kubectl edit ApplicationInstallation cilium -n kube-system`),
and add the following snippet to it:

```yaml
cluster:
  name: cluster-1
  id: 1
clustermesh:
  useAPIServer: true
  config:
    enabled: true
  apiserver:
    tls:
      auto:
        method: cronJob
    service:
      type: LoadBalancer
```

### 3. Retrieve Cluster Mesh data from the Cluster 1
**In Cluster 1**, retrieve the information necessary for the next steps:

Retrieve CA cert & key:
```
kubectl get secret cilium-ca -n kube-system -o yaml
```

Retrieve clustermesh-apiserver external IP:
```
kubectl get svc clustermesh-apiserver -n kube-system
```

Retrieve clustermesh-apiserver remote certs:
```
kubectl get secret clustermesh-apiserver-remote-cert -n kube-system -o yaml
```

### 4. Enable Cluster Mesh in the Cluster 2
**In Cluster 2**, the Cilium ApplicationInstallation values, and add the following snippet to it
(after replacing the values below the lines with comments with the actual values retrieved in the previous step):

```yaml
cluster:
  name: cluster-2
  id: 2
clustermesh:
  useAPIServer: true
  config:
    enabled: true
    clusters:
    - name: cluster-1
      address: ""
      port: 2379
      ips:
      # external-ip of the clustermesh-apiserver svc in Cluster 1
      - <ip-address>
      tls:
        # tls.crt from clustermesh-apiserver-remote-cert secret in Cluster 1
        cert: "<base64-encoded-cert>"
        # tls.key from clustermesh-apiserver-remote-cert secret in Cluster 1
        key: "<base64-encoded-key>"
  apiserver:
    tls:
      auto:
        method: cronJob
      ca:
        # ca.crt from the cilium-ca secret in Cluster 1
        cert: "<base64-encoded-cert>"
        # ca.key from the cilium-ca secret in Cluster 1
        key: "<base64-encoded-key>"
    service:
      type: LoadBalancer
```

### 5. Retrieve Cluster Mesh data from the Cluster 2
**In Cluster 2**, retrieve the information necessary for the next steps:

Retrieve clustermesh-apiserver external IP:
```shell
kubectl get svc clustermesh-apiserver -n kube-system
```

Retrieve clustermesh-apiserver remote certs:
```shell
kubectl get secret clustermesh-apiserver-remote-cert -n kube-system -o yaml
```

### 6. Update Cluster Mesh config in the Cluster 1
**In Cluster 1**, update the Cilium ApplicationInstallation values, and add the following clustermesh config with cluster-2 details into it:

```yaml
clustermesh:
  useAPIServer: true
  config:
    enabled: true
    clusters:
    - name: cluster-2
      address: ""
      port: 2379
      ips:
      # external-ip of the clustermesh-apiserver svc in Cluster 2
      - <ip-address>
      tls:
        # tls.crt from clustermesh-apiserver-remote-cert secret in Cluster 2
        cert: "<base64-encoded-cert>"
        # tls.key from clustermesh-apiserver-remote-cert secret in Cluster 2
        key: "<base64-encoded-key>"
  apiserver:
    tls:
      auto:
        method: cronJob
      ca:
        # ca.crt from the cilium-ca secret in Cluster 1 (important - not Cluster 2)
        cert: "<base64-encoded-cert>"
        # ca.key from the cilium-ca secret in Cluster 1 (important - not Cluster 2)
        key: "<base64-encoded-key>"
    service:
      type: LoadBalancer
```

### 7. Allow traffic between worker nodes of different clusters
If any firewalling is in place between the worker nodes in different clusters, the following ports need to be allowed between them:

- UDP 8472 (VXLAN)
- TCP 4240 (HTTP health checks)

### 8. Check Cluster Mesh status
At this point, check Cilium health status in each cluster with:
```shell
kubectl exec -it cilium-<pod-id> -n kube-system -- cilium-health status
```

It should show all local and remote cluster's nodes and not show any errors. It may take a few minutes until things settle down since the last configuration.

Example output:
```
Nodes:
  cluster-1/f5m2nzcb4z-worker-p7m58g-7f44796457-wv5fq (localhost):
    Host connectivity to 10.0.0.2:
      ICMP to stack:   OK, RTT=585.908µs
      HTTP to agent:   OK, RTT=386.343µs
    Endpoint connectivity to 172.25.0.235:
      ICMP to stack:   OK, RTT=563.934µs
      HTTP to agent:   OK, RTT=684.559µs
  cluster-2/qqkp9pksmb-worker-cn24gj-5d55cc7b65-tmz9w:
    Host connectivity to 10.0.0.3:
      ICMP to stack:   OK, RTT=1.659939ms
      HTTP to agent:   OK, RTT=2.932125ms
    Endpoint connectivity to 172.26.0.240:
      ICMP to stack:   OK, RTT=1.6367ms
      HTTP to agent:   OK, RTT=4.215347ms
```

In case of errors, check again for firewall settings mentioned in the previous point. It may also help to manually restart:
- first `clustermesh-apiserver` pods in each cluster,
- then `cilium` agent pods in each cluster.


## Example Cross-Cluster Application Deployment With Failover / Migration
After Cilium Cluster Mesh has been set up, it is possible to use global services across the meshed clusters.

In this example, we will deploy a global deployment into 2 clusters, where each cluster will be acting a failover for the other. Normally, all traffic will be handled by backends in the local cluster. Only in case of no local backends, it will be handled by backends running in the other cluster. That will be true for local (pod-to-service) traffic, as well as ingress traffic provided by LoadBalancer services in each cluster.

Let's start by deploying a nginx deployment with 2 replicas in each cluster:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.16.1
        ports:
        - containerPort: 80
```

Now, in each cluster, lets create a service of type LoadBalancer with the necessary annotations:
- `io.cilium/global-service: "true"`
- `io.cilium/service-affinity: "local"`

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx-deployment
  annotations:
    io.cilium/global-service: "true"
    io.cilium/service-affinity: "local"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx
```

The list of backends for a service can be checked with:
```shell
kubectl exec -it cilium-<pod-id> -n kube-system -- cilium service list --clustermesh-affinity
```

Example output:
```
ID   Frontend                Service Type   Backend
16   10.240.27.208:80        ClusterIP      1 => 172.25.0.160:80 (active) (preferred)
                                            2 => 172.25.0.12:80 (active) (preferred)
                                            3 => 172.26.0.31:80 (active)
                                            4 => 172.26.0.196:80 (active)
```

At this point, the service should be available in both clusters, either locally or via assigned external IP of the `nginx-deployment` service.

Let's scale the number of nginx replicas in one of the clusters (let's say Cluster 1) to 0:
```shell
kubectl scale deployment nginx-deployment --replicas=0
```

The number of backends for the service has been lowered down to 2, and only lists remote backends in the `cilium service list` output:

```
ID   Frontend                Service Type   Backend
16   10.240.27.208:80        ClusterIP      1 => 172.26.0.31:80 (active)
                                            2 => 172.26.0.196:80 (active)
```

The service should still be available in the Cluster 1 (either locally via ClusterIP, or via assigned ExternalIP of the `nginx-deployment` service, or via NodePort), even if there is no local backend for it. The requests will be served by the backends running in the Cluster 2.

We can also scale up the replicas in Cluster 1 to non-zero and scale down the replicas in Cluster 2 to 0. This way the application can "migrate" between the clusters while still being available in both clusters.
