+++
title = "Running Your First Test"
date = 2026-03-17T10:07:15+02:00
weight = 10
+++

This guide walks you through running your first conformance test using Conformance EE.

## Prerequisites

Before starting, ensure you have:

- A running KKP installation with at least one KubeVirt datacenter configured
- A kubeconfig with access to the KKP seed cluster
- The Conformance EE container image pulled or built locally

## Step 1: Create a Minimal Configuration

Create a `config.yaml` with a minimal test matrix:

```yaml
providers:
  - kubevirt

releases:
  - "1.31"

enableDistributions:
  - ubuntu

resources:
  cpu: [2]
  memory: ["4Gi"]
  diskSize: ["20Gi"]

imageSources:
  ubuntu:
    "22.04": "docker://quay.io/kubermatic-virt-disks/ubuntu:22.04"

controlPlaneReadyWaitTimeout: 10m
nodeReadyTimeout: 20m
nodeCount: 1
reportsRoot: /reports
```

{{% notice tip %}}
Start with a minimal configuration to verify your setup works before expanding the test matrix.
{{% /notice %}}

## Step 2: Launch the Interactive TUI

Run the Conformance EE container with the TUI entrypoint. The TUI will walk you through selecting your environment, providing credentials, and choosing which tests to run.

## Step 3: Monitor Test Progress

### Via ConfigMap

```bash
kubectl get configmap -n conformance-tests -w
```

### Via Job Logs

```bash
kubectl logs -n conformance-tests job/conformance-tests -f
```

## Step 4: Review Results

After tests complete, JUnit XML reports are available in the reports directory:

```
reports/
├── junit.with_kubernetes_1.31.1_and_ubuntu_22.04_and_canal.xml
└── ...
```

These files can be imported into any CI system that supports JUnit XML format.

## Troubleshooting

### Cluster Creation Timeout

If cluster creation exceeds the 10 minute timeout:

- Verify the KKP API is accessible from the test pod
- Check KKP controller logs for provisioning errors
- Ensure the cloud provider has sufficient quota

### Node Not Ready

If worker nodes fail to reach Ready state:

- Check machine controller logs in the user cluster
- Verify the OS image is accessible from the KubeVirt infrastructure
- Ensure the storage class exists and has available capacity
