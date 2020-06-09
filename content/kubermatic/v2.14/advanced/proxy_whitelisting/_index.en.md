+++
title = "Kubermatic Proxy Whitelisting"
date = 2019-09-13T12:07:15+02:00
weight = 90

+++

To enable Kubermatic behind a proxy environment, the following targets need to be reachable.

{{% notice note %}}
If you use the [Kubermatic offline mode](https://docs.kubermatic.io/advanced/offline_mode/#kubermatic-offline-mode), images will get pulled from the defined private registry (e.g. `172.20.0.2:5000`) instead of the public registries. For more details see the [Kubermatic offline mode](https://docs.kubermatic.io/advanced/offline_mode/#kubermatic-offline-mode) section.
{{% /notice %}}

## Kubermatic Machine Controller

Resources pulled on machine controller nodes

### kubelet - Binary

The machine controller is downloading a few components to install the kubelet, see [download_binaries_script.go](https://github.com/kubermatic/machine-controller/blob/master/pkg/userdata/helper/download_binaries_script.go):

```bash
# Binaries for the Kubernetes kubelet Get Downloaded From:
https://storage.googleapis.com/kubernetes-release/release/

# CNI Plugins
https://github.com/containernetworking/plugins/releases/

# Kubermatic Health-Monitor Script
# (Placed at pkg/userdata/scripts/health-monitor.sh)
https://raw.githubusercontent.com/kubermatic/machine-controller/
```

### kubelet - Docker Images

After kubelet starts, it needs a few more images to work in a proper way:

**`gcr.io`:**

```bash
# ContainerLinux Requires the Hyperkube Image
gcr.io/google_containers/hyperkube-amd64

# DNS Node Cache
gcr.io/google_containers/k8s-dns-node-cache
```

**`k8s.gcr.io`:**

```bash
# Every kubelet Requires the Pause Container:
k8s.gcr.io/pause
```

**`docker.io`:**

```bash
# Calico Overlay
calico/node

# DNS Addon
coredns/coredns

# Log Shipper Fluent-Bit
fluent/fluent-bit
```

**`quay.io`:**

```bash
# Util Container for Debuging or Custom Controller
quay.io/kubermatic/util

# Prometheus Metrics Scraping
quay.io/prometheus/node-exporter

# Core Os Container
quay.io/coreos/flannel
quay.io/coreos/kube-rbac-proxy
quay.io/coreos/container-linux-update-operator
```

## OS Resources
Some os specific resources get installed over cloud-init:

### CentOS 7
Init script: https://github.com/kubermatic/machine-controller/tree/master/pkg/userdata/centos

- default yum repositories

### CoreOS
Init script: https://github.com/kubermatic/machine-controller/tree/master/pkg/userdata/coreos

- no additional targets

### Ubuntu 18.04
Init script: https://github.com/kubermatic/machine-controller/tree/master/pkg/userdata/ubuntu

- default apt repositories
- docker apt repository: `download.docker.com/linux/ubuntu`

# Kubermatic Seed Cluster Setup

## Cloud Provider API Endpoints
Kubermatic interacts with the different cloud provider directly to provision the required infrastructure to manage Kubernetes clusters:

### AWS
API Endpoint documentation: https://docs.aws.amazon.com/general/latest/gr/rande.html

Kubermatic interact in several ways with different cloud provider, e.g.:
- creating EC2 instances
- creating security groups
- access instance profiles

```bash
# e.g. For Region Eu-Central-1
iam.amazonaws.com
s3.eu-central-1.amazonaws.com
ec2.eu-central-1.amazonaws.com
```

## KubeOne Seed Cluster Setup

If [KubeOne](https://github.com/kubermatic/kubeone) is used to setup the seed cluster, it will use in addition:

```bash
packages.cloud.google.com
download.docker.com
apt.kubernetes.io
storage.googleapis.com
raw.githubusercontent.com

# Needed for CoreOS
github.com
```

## cert-manager (If Used)
For creating certificates with let's encrypt we need access:

```bash
https://acme-v02.api.letsencrypt.org/directory
```
