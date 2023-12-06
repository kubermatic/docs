+++
title = "Storage Requirements"
linkTitle = "Storage"
date = 2023-08-28T12:00:00+02:00
weight = 15

+++

Running KKP requires at least one persistent storage layer that can be accessed via a Kubernetes [CSI driver](https://kubernetes-csi.github.io/docs/drivers.html). The Kubermatic Installer attempts to discover pre-existing CSI drivers for known cloud providers to create a suitable _kubermatic-fast_ `StorageClass`.

In particular for setups in private datacenters, setting up a dedicated storage layer might be necessary to reach adequate performance. Make sure to configure and install the corresponding CSI driver (from the list linked above) for your storage solution onto the KKP Seed clusters before installing KKP.

## etcd

[etcd](https://etcd.io) is a key-value store and the persistence layer for the Kubernetes API. KKP runs a control plane for each user cluster including both etcd and kube-apiserver. etcd is very sensitive to disk write latency and requires fast and consistent I/O performance.

In general, etcd has certain [disk performance requirements](https://etcd.io/docs/v3.5/op-guide/hardware/#disks): At least 50 sequential IOPS, with a recommendation of 500 sequential IOPS for large clusters. It is strongly recommended to provide SSD-backed storage for etcd.

Networked storage might be suitable if performance is adequate, but inconsistent network performance might significantly impact etcd cluster stability. It is strongly recommended to have a dedicated storage area network (SAN) that cannot be impacted by general networking traffic.
