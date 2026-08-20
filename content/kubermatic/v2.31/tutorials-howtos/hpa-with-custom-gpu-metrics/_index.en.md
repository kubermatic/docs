+++
title = "HPA with Custom GPU Metrics"
date = 2025-10-29T00:00:00+00:00
weight = 20
+++

## Overview

The Kubernetes Horizontal Pod Autoscaler (HPA) is a fundamental component of Kubernetes that automatically adjusts the number
of pod replicas in a Deployment, ReplicaSet, or StatefulSet based on observed resource utilization or other custom metrics.

-----

## HPA Installation Guide

The Horizontal Pod Autoscaler is a built-in feature of Kubernetes, so there is no separate "installation" required for 
the controller itself. However, it relies on the **Metrics Server** to function correctly.

### Step 1: Install the Metrics Server (Prerequisite)

The Metrics Server is a crucial component that collects resource usage data (CPU, memory) from all nodes and pods, which 
the HPA then uses to make scaling decisions.

**Note:** You can install the Metrics Server and the whole MLA stack in KKP by enabling User Cluster Monitoring checkbox
in the Cluster settings. More information can be found [here](https://docs.kubermatic.com/kubermatic/v2.29/tutorials-howtos/monitoring-logging-alerting/user-cluster/user-guide/).


Once running, you can test it by checking if you can retrieve node and pod metrics:

```bash
kubectl top nodes
kubectl top pods
```

-----

### Step 2: Configure Resource Requests

The HPA scales based on a percentage of the defined **resource requests**. If your Deployment does not have CPU requests defined, the HPA will not be able to function based on CPU utilization.

Ensure your workload's YAML file (Deployment, ReplicaSet, etc.) includes a `resources: requests` block:

```yaml
# Snippet from your Deployment YAML
spec:
  template:
    spec:
      containers:
      - name: my-container
        image: k8s.gcr.io/hpa-example # A simple example image
        resources:
          requests:
            cpu: "200m"  # 200 milliCPU (0.2 CPU core)
          limits:
            cpu: "500m"  # Optional, but recommended
```

-----

### Step 3: Deploy the Horizontal Pod Autoscaler (HPA)

You can deploy the HPA using either a simple command or a declarative YAML file.

#### Option A: Using the `kubectl autoscale` Command (Quick Method)

This is the fastest way to create an HPA resource:

```bash
kubectl autoscale deployment [DEPLOYMENT_NAME] \
  --cpu-percent=50 \
  --min=2 \
  --max=10
```

* `[DEPLOYMENT_NAME]`: Replace this with the actual name of your Deployment.
* `--cpu-percent=50`: The HPA will try to maintain an average CPU utilization of **50%** across all pods.
* `--min=2`: The minimum number of replicas.
* `--max=10`: The maximum number of replicas.

-----

#### Option B: Using a Declarative YAML Manifest (Recommended Method)

For complex configurations (like scaling on memory or custom metrics), a YAML manifest is better. We recommend using the **`autoscaling/v2`** API version for the latest features.

**`hpa-config.yaml`**

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    # Target the resource that needs to be scaled
    apiVersion: apps/v1
    kind: Deployment
    name: hpa-demo-deployment # <-- REPLACE with your Deployment name
  
  minReplicas: 2
  maxReplicas: 10
  
  metrics:
  # Metric 1: Scale based on CPU utilization
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50 # Target average 50% CPU utilization
  
  # Metric 2: Scale based on Memory utilization (optional)
  - type: Resource
    resource:
      name: memory
      target:
        type: AverageValue
        averageValue: 300Mi # Target average of 300 MiB of memory usage
```

**Apply the HPA:**

```bash
kubectl apply -f hpa-config.yaml
```

-----

### Step 4: Verify the HPA Status

Check that the HPA has been created and is monitoring your application:

```bash
kubectl get hpa

# Example Output:
# NAME         REFERENCE                  TARGETS      MINPODS   MAXPODS   REPLICAS   AGE
# my-app-hpa   Deployment/hpa-demo-deployment   0%/50%       2         10        2          2m
```

The **`TARGETS`** column shows the current utilization versus the target. If it shows **`<unknown>`** or **`missing resource metric`**, double-check that your **Metrics Server** is healthy and your Deployment has **resource requests** defined.

For details on scaling decisions, check the events:

```bash
kubectl describe hpa my-app-hpa
```

This command will show the **Conditions** and **Events** sections, which explain when the HPA scaled up or down and why.

## Setting Up HPA with DCGM Metrics

Autoscaling GPU-accelerated workloads in Kubernetes involves dynamically adjusting the number of Pods based on real-time 
utilization of the GPU resources. This process is more complex than scaling based on standard CPU or memory, as it 
requires setting up a dedicated Custom Metrics Pipeline to feed GPU-specific telemetry to the Horizontal Pod Autoscaler (HPA).

Here is the rephrased paragraph in a clear Markdown format, emphasizing the key components and their roles in GPU-based autoscaling:

---

### Scaling AI/ML Workloads with GPU Metrics

To enable autoscaling for AI/ML workloads based on GPU performance, you must establish a reliable source for those specialized metrics. 
In this document, we will use a custom GPU metrics pipeline that leverages the NVIDIA GPU Device Plugin and DCGM (Data Center GPU Manager) to collect GPU-specific performance metrics.

| Component               | Role in the Pipeline                                                                                                                                                                                      |
|:------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **NVIDIA GPU Operator** | The GPU Operator is an umbrella package that automates the deployment of all necessary NVIDIA components for Kubernetes. This stack includes the NVIDIA DCGM Exporter (Data Center GPU Manager Exporter). |
| **Prometheus Server**   | Prometheus monitors applications running in the user clusters as well as system components running in the user clusters.                                                                                  |
| **Prometheus Adapter**  | The Prometheus Adapter is a crucial component in Kubernetes that allows the Horizontal Pod Autoscaler (HPA) to scale workloads using custom metrics collected by Prometheus.                              |

---

### Install NVIDIA GPU Operator

KKP offers the possibility to install the NVIDIA GPU Operator in the user cluster, by using our application catalog for enterprise customers, 
or by installing it manually in the user cluster. to install the operator via our application catalog, follow the instructions 
[here](https://docs.kubermatic.com/kubermatic/v2.29/architecture/concept/kkp-concepts/applications/default-applications-catalog/nvidia-gpu-operator/).

To install the operator manually, follow the instructions [here](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html).

### Install Prometheus
We need Prometheus for the Prometheus Adapter because the Adapter relies on Prometheus as its source of metrics data. 
The Adapter itself does not collect metrics; its sole purpose is to translate and expose the metrics that Prometheus has already collected

The adapter should be installed where the prometheus server is running as the adapter will be configured to query the prometheus server. This 
can be achieved by installing the adapter in the seed cluster where the user cluster prmetheus server is running.

Another approach can be to run a prometheus server in the user cluster directly via Kubermatic custom app definition or 
manually running it on the cluster via helm:

```console
# Add the Prometheus Community Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Update your local Helm chart repository cache
helm repo update

helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --create-namespace \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set alertmanager.enabled=false # Optional: Disable Alertmanager if you don't need alerts immediately
```

### Install Prometheus Adapter
The Prometheus Adapter is a crucial component in Kubernetes that allows the Horizontal Pod Autoscaler (HPA) to scale 
workloads using custom metrics collected by Prometheus.

Users can install the Prometheus Adapter in the user cluster by via helm by executing these commands:

For Helm2
```console
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
$ helm repo update
$ helm install --name my-release prometheus-community/prometheus-adapter
```
For Helm3 ( as name is mandatory )
```console
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
$ helm repo update
$ helm install my-release prometheus-community/prometheus-adapter
```

For more information on how to install the Prometheus Adapter, please refer to the [official documentation](https://github.com/kubernetes-sigs/prometheus-adapter).

### Setting HPA with DCGM Metrics

Here is an example of a HPA configuration that scales based on GPU utilization. Creating a Kubernetes Deployment that 
utilizes an NVIDIA GPU requires two main things: ensuring your cluster has the NVIDIA Device Plugin running (a prerequisite) 
and specifying the GPU resource in the Pod's manifest.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gpu-worker-deployment
  labels:
    app: gpu-worker
spec:
  replicas: 1 # Start with 1 replica, HPA will scale this up
  selector:
    matchLabels:
      app: gpu-worker
  template:
    metadata:
      labels:
        app: gpu-worker
    spec:
      # Node Selector (Optional but recommended)
      # This ensures the Pod is only scheduled on nodes labeled to have GPUs.
      nodeSelector:
        accelerator: nvidia
        
      containers:
      - name: cuda-container
        image: nvcr.io/nvidia/cuda:12.4.1-runtime-ubuntu22.04 # Use a robust NVIDIA image
        command: ["/bin/bash", "-c"]
        args: ["/usr/local/nvidia/bin/nvidia-smi; sleep infinity"] # Example command to keep the container running
        
        # --- GPU Resource Configuration (CRITICAL) ---
        resources:
          limits:
            # This is the line that requests a GPU resource from the cluster.
            # Replace '1' with the number of GPUs required (e.g., "0.5" if using MIG or time-slicing)
            nvidia.com/gpu: "1" 
          
          # Requests should be identical to limits for non-sharable resources like GPUs
          requests:
            nvidia.com/gpu: "1"
```

Next we will configure the HPA to scale based on the GPU utilization:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: gpu-util-autoscaler
  namespace: default # Ensure this matches your deployment's namespace
spec:
  # 1. Target the Deployment created previously
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: gpu-worker-deployment 
  
  # 2. Define scaling limits
  minReplicas: 1
  maxReplicas: 5 # Define the maximum number of GPU workers
  
  # 3. Define the custom metric
  metrics:
  - type: Pod # Metric applies to the pods managed by the Deployment
    pod:
      metric:
        # This name MUST match the metric alias defined in your 
        # Prometheus Adapter configuration (ConfigMap)
        name: dcgm_gpu_utilization_percent 
      target:
        type: AverageValue
        # Scale up if the average GPU utilization across all pods exceeds 60%
        averageValue: 60
```
