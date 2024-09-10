+++
title = "Cluster Requirements"
date = 2018-04-28T12:07:15+02:00
weight = 15

+++

## Requirements

### Master Cluster
The Master Cluster hosts the KKP components and might also act as a seed cluster and host the master components of user clusters (see [Architecture]({{< ref "../../../architecture/">}})). Therefore, it should run in [Highly Available setup]({{< relref "../../../installation/install_ha_kubernetes/">}}) with at least 3 master nodes and 3 worker nodes.

**Minimal Requirements:**
* Six or more machines running one of:
  * Ubuntu 16.04+
  * Debian 9
  * CentOS 7
  * RHEL 7
  * Flatcar
* 4 GB or more of RAM per machine (any less will leave little room for your apps)
* 2 CPUs or more

### User Cluster
The User Cluster is a Kubernetes cluster created and managed by KKP. The exact requirements may depend on the type of workloads that will be running in the user cluster.

**Minimal Requirements:**
* One or more machines running one of:
  * Ubuntu 16.04+
  * Debian 9
  * CentOS 7
  * RHEL 7
  * Flatcar
* 2 GB or more of RAM per machine (any less will leave little room for your apps)
* 2 CPUs or more
* Full network connectivity between all machines in the cluster (public or private network is fine)
* Unique hostname, MAC address, and product_uuid for every node. See more details in the next [**topic**](#Verify-the-MAC-Address-and-product-uuid-Are-Unique-for-Every-Node).
* Certain ports are open on your machines. See below for more details.
* Swap disabled. You **MUST** disable swap in order for the kubelet to work properly.

### Verify the MAC Address and `product_uuid` Are Unique for Every Node

* You can get the MAC address of the network interfaces using the command `ip link` or `ifconfig -a`
* The product_uuid can be checked by using the command `sudo cat /sys/class/dmi/id/product_uuid`

It is very likely that hardware devices will have unique addresses, although some virtual machines may have identical values. Kubernetes uses these values to uniquely identify the nodes in the cluster. If these values are not unique to each node, the installation process may [fail](https://github.com/kubernetes/kubeadm/issues/31).

### Check Network Adapters

If you have more than one network adapter, and your Kubernetes components are not reachable on the default route, we recommend you add IP route(s) so Kubernetes cluster addresses go via the appropriate adapter.

### Check Required Ports

#### Master Cluster Master Node(s)

| Protocol | Direction | Port Range | Purpose                 |
|----------|-----------|------------|-------------------------|
| TCP      | Inbound   | 6443*      | Kubernetes API server   |
| TCP      | Inbound   | 2379-2380  | etcd server client API  |
| TCP      | Inbound   | 10250      | kubelet API             |
| TCP      | Inbound   | 10251      | kube-scheduler          |
| TCP      | Inbound   | 10252      | kube-controller-manager |
| TCP      | Inbound   | 10255      | Read-only kubelet API   |

#### Worker Node(s)& User Cluster Worker Nodes

| Protocol | Direction | Port Range  | Purpose               |
|----------|-----------|-------------|-----------------------|
| TCP      | Inbound   | 10250       | kubelet API           |
| TCP      | Inbound   | 10255       | Read-only kubelet API |
| TCP      | Inbound   | 30000-32767 | NodePort Services**   |

** Default port range for [NodePort Services](https://kubernetes.io/docs/concepts/services-networking/service/).

Any port numbers marked with * are overridable, so you will need to ensure any custom ports you provide are also open.
