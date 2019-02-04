+++
title = "Increase the Service CIDR"
date = 2018-12-02T12:07:15+02:00
weight = 20
pre = "<b></b>"
+++

## Intro

By default each cluster created with Kubermatic gets the following network settings:
- Pod CIDR: `172.25.0.0/16`
- Service CIDR: `10.10.10.0/24`
- Cluster domain: `cluster.local`

As a cluster grows over time it might become necessary to increase the above CIDR's.

### Changing the service CIDR

{{% notice warning %}}
When creasing the CIDR, the new CIDR must include the old one - it is not possible to use a different network.
{{% /notice %}}

To change the service CIDR, edit the cluster object and specify the new CIDR:
```yaml
  clusterNetwork:
    dnsDomain: cluster.local
    pods:
      cidrBlocks:
      - 172.25.0.0/16
    services:
      cidrBlocks:
      - 10.10.10.0/24
```
becomes:
```yaml
  clusterNetwork:
    dnsDomain: cluster.local
    pods:
      cidrBlocks:
      - 172.25.0.0/16
    services:
      cidrBlocks:
      - 10.10.0.0/16
```

After the CIDR has been changed, all new services will get an IP from the new CIDR.

### Update the cluster DNS IP

{{% notice warning %}}
This might cause a downtime of the cluster DNS & communication to the API server
{{% /notice %}}

Kubermatic will always create a Service with a static ClusterIP for the DNS service(`kube-system/kube-dns`).
The ClusterIP will always be the 10th of the network.
Example:
Give the service CIDR: `10.10.10.0/24`, the Service for the DNS will have the ClusterIP `10.10.10.10`.

When the CIDR gets changed, the DNS service(`kube-system/kube-dns`) must be changed as well.
As changing the ClusterIP is not possible, the Service(`kube-system/kube-dns`) must be recreated (A backup must be created):
```bash
# Dump old service
kubectl -n kube-system get service kube-dns -o yaml > old_service.yaml
# Delete old service
kubectl -n kube-system delete service kube-dns
# Kubermatic will recreate it with the new IP

# Create old service with a different name to not break existing DNS
# For this change metadata.name inside old_service.yaml and apply it
kubectl apply -f old_service.yaml

# Delete the kubernetes service
kubectl delete service kubernetes
# Wait until it gets recreated
```
