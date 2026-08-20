+++
title = "CIS Benchmarking"
date = 2024-03-06T12:00:00+02:00
weight = 10
+++

[CIS Benchmark for Kubernetes](https://www.cisecurity.org/benchmark/kubernetes) is a guide that consists of secure configuration guidelines and best practices developed for Kubernetes.

In this document, information how it can be run on a Kubernetes cluster created using KKP and what to expect as the result is described.

Please note: It is impossible to inspect the master nodes of managed clusters(KKP user clusters) since from within the cluster(kubeconfig) one does not have access to such nodes. So for KKP, we can only check the worker nodes.

## Tooling

[Trivy](https://github.com/aquasecurity/trivy) is the tool used to run the benchmark.

### Installation

To install trivy, follow the instructions [here](https://trivy.dev/latest/getting-started/installation/).

### Running the Benchmark

```bash
trivy k8s --compliance=k8s-cis-1.23 --report summary
```

## Table of Content

{{% children depth=5 %}}
{{% /children %}}
