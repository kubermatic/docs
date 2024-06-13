+++
title = "Proxy Whitelisting"
date = 2019-09-13T12:07:15+02:00
weight = 110

+++

To enable KKP behind a proxy environment, the following targets need to be reachable.

{{% notice note %}}
If you use the [KKP offline mode]({{< ref "../../../installation/offline-mode" >}}), images will get pulled from the defined private registry (e.g. `172.20.0.2:5000`) instead of the public registries. For more details see the [KKP offline mode]({{< ref "../../../installation/offline-mode" >}}) section.
{{% /notice %}}

## KKP Machine Controller

Resources pulled on machine controller nodes.

### kubelet - Binary

The machine controller is downloading via the [OperatingSystemManager](https://docs.kubermatic.com/operatingsystemmanager) all components to setup a Kubernetes worker node. For operating system dedicated details see the [default OperatingSystemProfiles](https://github.com/kubermatic/operating-system-manager/tree/main/deploy/osps/default).

```bash
# Binaries for the Kubernetes kubelet Get Downloaded From:
https://dl.k8s.io

# CNI Plugins
https://github.com/containernetworking/plugins/releases/

# CRI Tool: crictl
https://github.com/kubernetes-sigs/cri-tools/releases

```

### kubelet - Docker Images

After kubelet starts, it needs a few more images to work in a proper way:

**`registry.k8s.io`**

```bash
#Kubernetes core components
registry.k8s.io/autoscaling/addon-resizer
registry.k8s.io/coredns/coredns
registry.k8s.io/dns/k8s-dns-node-cache
registry.k8s.io/etcd
registry.k8s.io/kas-network-proxy/proxy-server
registry.k8s.io/kube-apiserver
registry.k8s.io/kube-controller-manager
registry.k8s.io/kube-proxy
registry.k8s.io/kube-scheduler
registry.k8s.io/kube-state-metrics/kube-state-metrics
registry.k8s.io/metrics-server/metrics-server
registry.k8s.io/pause

### CSI Storage
registry.k8s.io/sig-storage/csi-attacher
registry.k8s.io/sig-storage/csi-node-driver-registrar
registry.k8s.io/sig-storage/csi-provisioner
registry.k8s.io/sig-storage/csi-resizer
registry.k8s.io/sig-storage/csi-snapshotter
registry.k8s.io/sig-storage/livenessprobe
registry.k8s.io/sig-storage/snapshot-controller
registry.k8s.io/sig-storage/snapshot-validation-webhook

### CCM provider images
registry.k8s.io/provider-aws/cloud-controller-manager
registry.k8s.io/provider-os/openstack-cloud-controller-manager
registry.k8s.io/provider-os/cinder-csi-plugin
registry.k8s.io/cloud-provider-gcp/cloud-controller-manager

# Ingress
registry.k8s.io/ingress-nginx/controller
registry.k8s.io/ingress-nginx/kube-webhook-certgen
```

**`gcr.io`:**

```bash
# Helper
gcr.io/kubebuilder/kube-rbac-proxy
```

**`ghcr.io`**

```bash
# DEX OIDC Provider
ghcr.io/dexidp/dex
```

**`docker.io`:**

```bash
#DigitalOcean CCM
docker.io/digitalocean/digitalocean-cloud-controller-manager

#Helper
docker.io/d3fk/s3cmd
docker.io/envoyproxy/envoy
docker.io/envoyproxy/envoy-distroless
docker.io/fluent/fluent-bit
docker.io/library/alpine
docker.io/library/busybox
docker.io/library/memcached
docker.io/library/nginx
docker.io/nginxinc/nginx-unprivileged
docker.io/restic/restic
docker.io/velero/velero

#Canal
docker.io/flannel/flannel

#Monitoring
docker.io/grafana/grafana
docker.io/grafana/loki
docker.io/grafana/promtail
docker.io/grafana/agent
docker.io/hashicorp/consul
docker.io/jimmidyson/configmap-reload
docker.io/prom/memcached-exporter
docker.io/pryorda/vmware_exporter

#Kubernetes Dashboard
docker.io/kubernetesui/dashboard

```

**`quay.io`:**

```bash
#Kubermatic Components
quay.io/kubermatic/alertmanager-authorization-server
quay.io/kubermatic/dashboard-ee
quay.io/kubermatic/etcd-launcher
quay.io/kubermatic/grafana-plugins
quay.io/kubermatic/http-prober
quay.io/kubermatic/kubelb-ccm-ee
quay.io/kubermatic/kubermatic-ee
quay.io/kubermatic/kubevirt-cloud-controller-manager
quay.io/kubermatic/kubevirt-csi-driver
quay.io/kubermatic/machine-controller
quay.io/kubermatic/metering
quay.io/kubermatic/nodeport-proxy
quay.io/kubermatic/operating-system-manager
quay.io/kubermatic/s3-exporter
quay.io/kubermatic/telemetry-agent
quay.io/kubermatic/util
quay.io/kubermatic/vsoc-alerta
quay.io/kubermatic/user-ssh-keys-agent

#CNI Canal
quay.io/calico/kube-controllers
quay.io/calico/node
quay.io/calico/cni

#CNI Cilium
quay.io/cilium/certgen
quay.io/cilium/cilium

#Helper
quay.io/brancz/kube-rbac-proxy
quay.io/frrouting/frr
quay.io/oauth2-proxy/oauth2-proxy

#Monitoring
quay.io/cortexproject/cortex
quay.io/prometheus-operator/prometheus-config-reloader
quay.io/prometheus-operator/prometheus-operator
quay.io/prometheus/alertmanager
quay.io/prometheus/blackbox-exporter
quay.io/prometheus/node-export

#CertManager
quay.io/jetstack/cert-manager-cainjector
quay.io/jetstack/cert-manager-controller
quay.io/jetstack/cert-manager-webhook


#KubeVirt
quay.io/kubevirt/bridge-marker
quay.io/kubevirt/cdi-apiserver
quay.io/kubevirt/cdi-controller
quay.io/kubevirt/cdi-importer
quay.io/kubevirt/cdi-operator
quay.io/kubevirt/cdi-uploadproxy
quay.io/kubevirt/cluster-network-addons-operator
quay.io/kubevirt/cni-default-plugins
quay.io/kubevirt/kubemacpool
quay.io/kubevirt/macvtap-cni
quay.io/kubevirt/ovs-cni-plugin
quay.io/kubevirt/virt-api
quay.io/kubevirt/virt-controller
quay.io/kubevirt/virt-handler
quay.io/kubevirt/virt-launcher
quay.io/kubevirt/virt-operator

#MetalLB
quay.io/metallb/speaker

#Bakup
quay.io/minio/mc
quay.io/minio/minio
```

**`public.ecr.aws`**

```bash
# AWS CSI Driver
public.ecr.aws/ebs-csi-driver/aws-ebs-csi-driver
public.ecr.aws/eks-distro/kubernetes-csi/*
 public.ecr.aws/eks-distro/kubernetes-csi/external-attacher
```

**`mcr.microsoft.com`**

```bash
#Azure CCM Driver
mcr.microsoft.com/oss/kubernetes/azure-cloud-controller-manager
```

**`projects.registry.vmware.com`**

```bash
#vCloud Director CCM
projects.registry.vmware.com/vmware-cloud-director/cloud-director-named-disk-csi-driver
```

### OS Resources
Additional to the kubelet dependencies, the [OperatingSystemManager](https://docs.kubermatic.com/operatingsystemmanager) installs some operating-system-specific packages over cloud-init:

#### CentOS 7/8
Init script: [osp-centos.yaml](https://github.com/kubermatic/operating-system-manager/blob/main/deploy/osps/default/osp-centos.yaml)

- default yum repositories
- docker yum repository: `download.docker.com/linux/centos`

### Flatcar Linux
Init script: [osp-flatcar-cloud-init.yaml](https://github.com/kubermatic/operating-system-manager/blob/main/deploy/osps/default/osp-flatcar-cloud-init.yaml)

- no additional targets

### Ubuntu 20.04/22.04/24.04
Init script: [osp-ubuntu.yaml](https://github.com/kubermatic/operating-system-manager/blob/main/deploy/osps/default/osp-ubuntu.yaml)

- default apt repositories
- docker apt repository: `download.docker.com/linux/ubuntu`

### Other OS
Other supported operating system details are visible by the dedicated [default OperatingSystemProfiles](https://github.com/kubermatic/operating-system-manager/tree/main/deploy/osps/default).

# KKP Seed Cluster Setup

## Cloud Provider API Endpoints
KKP interacts with the different cloud provider directly to provision the required infrastructure to manage Kubernetes clusters:

### AWS
API endpoint documentation: [AWS service endpoints](https://docs.aws.amazon.com/general/latest/gr/rande.html)

KKP interacts in several ways with different cloud providers, e.g.:
- creating EC2 instances
- creating security groups
- access instance profiles

```bash
# e.g. For Region Eu-Central-1
iam.amazonaws.com
s3.eu-central-1.amazonaws.com
ec2.eu-central-1.amazonaws.com
```

### Azure
API endpoint documentation: [Azure API Docs - Request URI](https://docs.microsoft.com/en-us/rest/api/azure/#request-uri)
```bash
# Resource Manager API
management.azure.com
# Azure classic deployment API
management.core.windows.net
# Azure Authentication API
login.microsoftonline.com

```

### vSphere
API Endpoint URL of all targeted vCenters specified in [seed cluster `spec.datacenters.EXAMPLEDC.vsphere.endpoint`]({{< ref "../../../tutorials-howtos/project-and-cluster-management/seed-cluster" >}}), e.g. `vcenter.example.com`.


## KubeOne Seed Cluster Setup

If [KubeOne](https://github.com/kubermatic/kubeone) is used to setup the seed cluster, kubeone will use in addition to OS specific default repositories the following URIs (see [os.go](https://github.com/kubermatic/kubeone/blob/main/pkg/scripts/os.go)):

```bash
# debian / ubuntu
packages.cloud.google.com/apt
download.docker.com/linux/ubuntu
apt.kubernetes.io
## on azure VM's
azure.archive.ubuntu.com
# security packages ubuntu
security.ubuntu.com

# centos
packages.cloud.google.com/yum
download.docker.com/linux/centos

# CoreOS / Flatcar Linux
storage.googleapis.com/kubernetes-release/release
github.com/containernetworking/plugins/releases/download

# gobetween (if used, e.g. at vsphere terraform setup)
github.com/yyyar/gobetween/releases
```
**At installer host / bastion server**:
```bash
## terraform modules
registry.terraform.io
releases.hashicorp.com

## kubeone binary
https://github.com/kubermatic/kubeone/releases

## kubeone tooling container
quay.io/kubermatic-labs/kubeone-tooling
```

## cert-manager (if used)
For creating certificates with let's encrypt we need access:

```bash
https://acme-v02.api.letsencrypt.org/directory
```
