+++
title = " Kubernetes Platform(KKP) Proxy Whitelisting"
date = 2019-09-13T12:07:15+02:00
weight = 7

+++

To enable KKP behind a proxy environment, the following targets need to be reachable.

{{% notice note %}}
If you use the [KKP offline mode](https://docs.kubermatic.io/advanced/offline_mode/#kubermatic-offline-mode), images will get pulled from the defined private registry (e.g. `172.20.0.2:5000`) instead of the public registries. For more details see the [KKP offline mode](https://docs.kubermatic.io/advanced/offline_mode/#kubermatic-offline-mode) section.
{{% /notice %}}

## KKP Machine Controller

Resources pulled on machine controller nodes

### kubelet - Binary

The machine controller is downloading a few components to install the kubelet, see [download_binaries_script.go](https://github.com/kubermatic/machine-controller/blob/master/pkg/userdata/helper/download_binaries_script.go):

```bash
# Binaries for the Kubernetes kubelet get downloaded from:
https://storage.googleapis.com/kubernetes-release/release/

# CNI plugins
https://github.com/containernetworking/plugins/releases/

# KKP health-monitor script
# (placed at pkg/userdata/scripts/health-monitor.sh)
https://raw.githubusercontent.com/kubermatic/machine-controller/
```

### kubelet - Docker Images

After kubelet starts, it needs a few more images to work in a proper way:

**`gcr.io`:**

```bash
# ContainerLinux requires the hyperkube image
gcr.io/google_containers/hyperkube-amd64

# DNS node cache
gcr.io/google_containers/k8s-dns-node-cache
```

**`k8s.gcr.io`:**

```bash
# Every Kubelet requires the pause container:
k8s.gcr.io/pause
```

**`docker.io`:**

```bash
# calico overlay
calico/node

# DNS addon
coredns/coredns

# log shipper fluent-bit
fluent/fluent-bit
```

**`quay.io`:**

```bash
# util container for debuging or custom controller
quay.io/kubermatic/util

# prometheus metrics scraping
quay.io/prometheus/node-exporter

# core os container
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

# KKP Seed Cluster Setup

## Cloud Provider API Endpoints
KKP interacts with the different cloud provider directly to provision the required infrastructure to manage Kubernetes clusters:

### AWS
API Endpoint documentation: https://docs.aws.amazon.com/general/latest/gr/rande.html

KKP interact in several ways with different cloud provider, e.g.:
- creating EC2 instances
- creating security groups
- access instance profiles

```bash
# e.g. for region eu-central-1
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

# needed for coreos
github.com
```

## cert-manager (If Used)
For creating certificates with let's encrypt we need access:

```bash
https://acme-v02.api.letsencrypt.org/directory
```
