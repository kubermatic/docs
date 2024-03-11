+++
title = "CIS Benchmarking"
date = 2024-03-06T12:00:00+02:00
+++

[CIS Benchmark for Kubernetes](https://www.cisecurity.org/benchmark/kubernetes) is a guide that consists of secure configuration guidelines and best practices developed for Kubernetes.

In this document, information how it can be run on KubeOne clusters and what to expect as the result is described.

## Tooling

[kube-bench](https://github.com/aquasecurity/kube-bench) is used to create the assesment.

### Installation
{{% notice note %}}
There are [multiple ways](https://github.com/aquasecurity/kube-bench/blob/main/docs/running.md) to run `kube-bench`. Below method describes how it's running via logging to a master and worker node to run it.
{{% /notice %}}

```bash
# make sure you run those commands as root user:
mkdir /root/kube-bench
cd /root/kube-bench
KUBE_BENCH_VERSION="0.7.2"

curl -L https://github.com/aquasecurity/kube-bench/releases/download/v${KUBE_BENCH_VERSION}/kube-bench_${KUBE_BENCH_VERSION}_linux_amd64.tar.gz \
  -o kube-bench_${KUBE_BENCH_VERSION}_linux_amd64.tar.gz
tar xvf kube-bench_${KUBE_BENCH_VERSION}_linux_amd64.tar.gz
```

### Run on controlplane node

```bash
cd /root/kube-bench
./kube-bench -D ./cfg/ run --targets=controlplane,master,etcd,node --benchmark=cis-1.8
```

### Run on a worker node

```bash
cd /root/kube-bench
./kube-bench -D ./cfg/ run --targets=node --benchmark=cis-1.8
```
