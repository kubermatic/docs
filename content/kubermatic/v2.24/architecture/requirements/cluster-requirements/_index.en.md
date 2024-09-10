+++
title = "Cluster Requirements"
date = 2018-04-28T12:07:15+02:00
weight = 15

+++

## Master Cluster

The Master Cluster hosts the KKP components and might also act as a seed cluster and host the master components of user clusters (see [Architecture]({{< ref "../../../architecture/">}})). Therefore, it should run in a highly-available setup with at least 3 master nodes and 3 worker nodes.

**Minimal Requirements:**

* Six or more machines running one of:
  * Ubuntu 20.04+
  * Debian 10
  * Flatcar
  * RHEL 7
  * Flatcar
* 4 GB or more of RAM per machine (any less will leave little room for your apps)
* 2 CPUs or more

## User Cluster

The User Cluster is a Kubernetes cluster created and managed by KKP. The exact requirements may depend on the type of workloads that will be running in the user cluster.

**Minimal Requirements:**

* One or more machines running one of:
  * Flatcar
  * Debian 10
  * CentOS 7
  * RHEL 7
  * Flatcar
* 2 GB or more of RAM per machine (any less will leave little room for your apps)
* 2 CPUs or more
* Full network connectivity between all machines in the cluster (public or private network is fine)
* Unique hostname, MAC address, and product\_uuid for every node. See more details in the next [**topic**](#Verify-the-MAC-Address-and-product-uuid-Are-Unique-for-Every-Node).
* Certain ports are open on your machines. See below for more details.
* Swap disabled. You **MUST** disable swap in order for the kubelet to work properly.

## Verify Node Uniqueness

You will need to verify that MAC address and `product_uuid` are unique on every node. This should usually be the case but might not be, especially for on-premise providers.

* You can get the MAC address of the network interfaces using the command `ip link` or `ifconfig -a`
* The product\_uuid can be checked by using the command `sudo cat /sys/class/dmi/id/product_uuid`

It is very likely that hardware devices will have unique addresses, although some virtual machines may have identical values. Kubernetes uses these values to uniquely identify the nodes in the cluster. If these values are not unique to each node, the installation process may [fail](https://github.com/kubernetes/kubeadm/issues/31).

## Check Network Adapters

If you have more than one network adapter, and your Kubernetes components are not reachable on the default route, we recommend you add IP route(s) so Kubernetes cluster addresses go via the appropriate adapter.

## Check Required Ports

Please ensure that all nodes in a user cluster can communicate without restriction to ensure functionality of CNI/CSI and Kubernetes itself.
In addition, user cluster nodes must be able to connect to the Seed cluster's nodeport-proxy. This depends on the [expose strategy]({{< ref "../../../tutorials-howtos/networking/expose-strategies" >}}.

It is recommended to make yourself familiar with the [concept of networking]({{< ref "../../../architecture/concept/kkp-concepts/networking" >}}) in KKP.

{{< include file="../../../data/ports.md" >}}

Any port numbers marked with * are overridable, so you will need to ensure any custom ports you provide are also open.
** Default port range for [NodePort Services](https://kubernetes.io/docs/concepts/services-networking/service/).
All ports listed are using TCP.
