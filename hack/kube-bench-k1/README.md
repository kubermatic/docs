# How to create CIS Benchmark Results

## Running kube-bench

kube-bench is deployed on the master node, and run this way:

```bash
# make sure you run those commands as root user:
mkdir /root/kube-bench
cd /root/kube-bench
VERSION="0.7.3"

curl -L https://github.com/aquasecurity/kube-bench/releases/download/v${VERSION}/kube-bench_${VERSION}_linux_amd64.tar.gz \
  -o kube-bench_${VERSION}_linux_amd64.tar.gz
tar xvf kube-bench_${VERSION}_linux_amd64.tar.gz

cd /root/kube-bench
./kube-bench -D ./cfg/ run --targets=controlplane,master,etcd,node --benchmark=cis-1.8 --json --outputfile master.json
```

It outputs the example [master.json](./master.json) file.

## Running the script

The python script does not require any additional libraries. 

Before you start, you need to check these 2 files:

> In case you use a different version than cis-1.8, you need to create those files, and  pay attention to the control/audit numbers.

- [configurable_controls_cis-${VERSION}.json](./configurable_controls_cis-1.8.json): This file contains some details about some features that are not enabled by a default installation, but KubeOne supports them. e.g. audit logging, oidc, ...
- [additional_details_cis-${VERSION}.json](./additional_details_cis-1.8.json): This file contains some explanation for controls that are in `Warn` or `Fail` state in the benchmark output file. 

When you are sure that this configuration is correct, just run the script:

```bash
# python create_md.py <KUBEONE_VERSION> <KUBERNETES_VERSION>
python create_md.py 1.7.3 1.27.10 > /path/to/_index.en.md
```
