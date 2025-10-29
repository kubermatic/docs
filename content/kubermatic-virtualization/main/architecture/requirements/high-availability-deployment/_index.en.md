+++
title = "High-Availability Deployment"
date = 2025-06-28T12:07:15+02:00
weight = 15
+++

## High-Availability Deployment

The hardware foundation for Kubermatic Virtualization is multi-faceted, encompassing requirements for the Kubermatic  
Virtualization (Kube-V) management layer, the KubeVirt infrastructure nodes that host virtual machines, in addition to 
various services that are running as part of the ecosystem.

### Control Plane Nodes

* Nodes: Minimum 3 control plane nodes to ensure a quorum for etcd (Kubernetes' key-value store) and prevent a single point of failure. 
These should ideally be distributed across different failure domains (e.g., availability zones, racks).
* CPU: At least 2 vCPUs per control plane node. 
* RAM: At least 4 GB RAM per control plane node. Recommended: 8-16 GB for robust performance.
* Storage: Fast, persistent storage for etcd (SSD-backed recommended) with sufficient capacity.

### Worker Nodes

* Minimum 2 worker nodes (for KubeVirt VMs): For HA, you need more than one node to run VMs. This allows for live migration 
and VM rescheduling in case of a node failure.
* CPU: A minimum of 8 CPU cores per node is suggested for testing environments. For production deployments, 16 CPU cores 
or more per node are recommended to accommodate multiple VMs and their workloads effectively. Each worker node must have 
Intel VT-x or AMD-V hardware virtualization extensions enabled in the BIOS/UEFI. 
This is a fundamental requirement for KubeVirt to leverage KVM (Kernel-based Virtual Machine) for efficient VM execution. 
Without this, KubeVirt can fall back to software emulation, but it's significantly slower and not suitable for production HA.
* RAM: At least 8 GB RAM per node. Recommended: 16-32 GB, depending on the number and memory requirements of your VMs.
* Storage: SSDs or NVMe drives are highly recommended for good VM performance in addition to sufficient storage capacity 
based on the disk images of your VMs and any data they store.

### Storage

* CSI Driver Capabilities (Crucial for HA/Live Migration): This is perhaps the most critical component for KubeVirt HA and live migration.
  You need a shared storage backend that supports ReadWriteMany (RWX) access mode or Block-mode (volumeMode: Block) volumes.
* Capacity: Sufficient storage capacity based on the disk images of your VMs and any data they store.
* Performance: SSDs or NVMe drives are highly recommended for good VM performance where high-throughput services,
  low-latency, high-IOPS storage (often block storage) is critical.
* Replication and Redundancy: To achieve HA, data must be replicated across multiple nodes or availability zones.
  If a node fails, the data should still be accessible from another.

### Networking

A well-planned and correctly configured network infrastructure is fundamental to the stability and performance of
Kubermatic Virtualization. This includes considerations for IP addressing, DNS, load balancing, and inter-component communication.

* High-bandwidth, low-latency connections: 1 Gbps NICs are a minimum; 10 Gbps or higher is recommended for performance-sensitive
workloads and efficient live migration.
* Load Balancing: External/internal load balancers for distributing traffic across control planes and worker nodes.
* Dedicated network for live migration (recommended): While not strictly minimal, a dedicated Multus network for live 
migration can significantly reduce network saturation on tenant workloads during migrations.
* Connectivity: Full and unrestricted network connectivity is paramount between all host nodes. Firewalls and security 
groups must be configured to permit all necessary Kubernetes control plane traffic, KubeVirt communication, and KubeV-specific 
inter-cluster communication.
* DNS: DNS resolution is crucial for the Kube-V environment, enabling all nodes to find each other and external services. 
A potential conflict can arise if both the KubeVirt infrastructure and guest user clusters 
use NodeLocal DNSCache with the same default IP address, leading to DNS resolution issues for guest VMs. This can be 
mitigated by adjusting the dnsConfig and dnsPolicy of the guest VMs.


|     Component      | Port(s)              | Protocol | Direction    | Purpose                                                 |
|:------------------:| :------------------: | :------: | :----------: | :-----------------------------------------------------: |
|     API Server     | 6443                 | TCP      | Inbound      | All API communication with the cluster                  |
|        etcd        | 2379-2380            | TCP      | Inbound      | etcd database communication                             |
|      Kubelet       | 10250                | TCP      | Inbound      | Kubelet API for control plane communication             |
|   Kube-Scheduler   | 10259                | TCP      | Inbound      | Kube-Scheduler component                                |
| Controller-Manager | 10257                | TCP      | Inbound      | Kube-Controller-Manager component                       |
|     Kube-Proxy     | 10256                | TCP      | Inbound      | Kube-Proxy health checks and service routing            |
| NodePort Services  | 30000-32767          | TCP/UDP  | Inbound      | Default range for exposing services on node IPs         |
|    KubeVirt API    | 8443                 | TCP      | Internal     | KubeVirt API communication                              |
|   Live Migration   | 61000-61009 (approx) | TCP      | Node-to-Node | For migrating VM state between nodes                    |
|     OVN NB DB      | 6641                 | TCP      | Internal     | OVN Northbound Database                                 |
|     OVN SB DB      | 6642                 | TCP      | Internal     | OVN Southbound Database                                 |
|     OVN Northd     | 6643                 | TCP      | Internal     | OVN Northd process                                      |
|      OVN Raft      | 6644                 | TCP      | Internal     | OVN Raft consensus (for HA OVN DBs)                     |
|   Geneve Tunnel    | 6081                 | UDP      | Node-to-Node | Default overlay network for pod communication (OVN) |
|   OVN Controller   | 10660                | TCP      | Internal     | Metrics for OVN Controller                          |
|     OVN Daemon     | 10665                | TCP      | Internal     | Metrics for OVN Daemon (on each node)               |
|    OVN Monitor     | 10661                | TCP      | Internal     | Metrics for OVN Monitor                             |

