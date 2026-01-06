+++
title = "Installation"
date = 2024-05-31T07:00:00+02:00
weight = 15
+++

This chapter provides guidance on how to install and configure machine-controller in your Kubernetes cluster.

{{% notice tip %}}
It is recommended to first familiarize yourself with the [architecture documentation]({{< ref "../architecture/" >}}).
{{% /notice %}}

## Prerequisites

Before installing machine-controller, ensure you have:

- A running Kubernetes cluster (version 1.31 or later)
- `kubectl` configured to access your cluster
- Cluster admin permissions
- [cert-manager](https://cert-manager.io/) installed (for webhook certificates)
- [Operating System Manager](https://docs.kubermatic.com/operatingsystemmanager) installed

## Quick Installation

### 1. Install cert-manager

machine-controller uses webhooks that require TLS certificates. Install cert-manager to automatically manage these certificates:

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.2/cert-manager.yaml
```

Wait for cert-manager to be ready:

```bash
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager -n cert-manager
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-webhook -n cert-manager
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-cainjector -n cert-manager
```

### 2. Install Operating System Manager

The Operating System Manager is responsible for managing user data and operating system configurations for worker nodes:

```bash
kubectl apply -f https://github.com/kubermatic/machine-controller/raw/main/examples/operating-system-manager.yaml
```

### 3. Install machine-controller

Deploy the machine-controller to your cluster:

```bash
kubectl apply -f https://github.com/kubermatic/machine-controller/raw/main/examples/machine-controller.yaml
```

### 4. Verify Installation

Check that machine-controller is running:

```bash
kubectl get pods -n kube-system | grep machine-controller
```

You should see the machine-controller pod in a `Running` state.

## Configuration

machine-controller can be configured through command-line flags or environment variables. The most common configurations include:

### Cluster API Server Configuration

By default, machine-controller looks for a `cluster-info` ConfigMap in the `kube-public` namespace. This ConfigMap should contain the cluster CA certificate and API server endpoint.

If you're using kubeadm, this ConfigMap is created automatically. Otherwise, you may need to create it manually.

### Cloud Provider Credentials

Cloud provider credentials can be provided through:

- Kubernetes Secrets (recommended)
- Environment variables
- Configuration files

Refer to the specific [cloud provider documentation]({{< ref "../references/cloud-providers/" >}}) for detailed credential configuration.

## Next Steps

After installation:

1. [Configure your cloud provider credentials]({{< ref "../references/cloud-providers/" >}})
2. [Create your first MachineDeployment]({{< ref "../tutorials/creating-machines/" >}})
3. [Learn about operating system support]({{< ref "../references/operating-systems/" >}})

## Table of Content

{{% children depth=5 %}}
{{% /children %}}

