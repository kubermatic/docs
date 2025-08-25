
+++
title = "Dynamic Resource Allocation (DRA)"
date = 2025-08-25T00:00:00+00:00
weight = 100
+++



## Overview

Dynamic Resource Allocation (DRA) is a Kubernetes feature that provides a flexible way to request and allocate resources to Pods. Unlike traditional resource management that uses static resource requests and limits.


## Prerequisites for DRA Features

- Kubernetes version 1.30 (Alpha) / 1.32 (Beta) or higher required for DRA features
- KKP version 2.25 or higher

## Enabling DRA in Kubernetes

### 1. Enable Feature Gate at via Kubermatic Configuration level

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  featureGates:
    DynamicResourceAllocation: true
  # ... other KKP configuration
```

Enabling the `DynamicResourceAllocation` feature gate in KKP automatically configures all required Kubernetes components, ensuring DRA is enabled wherever needed.

```yaml
# kube-apiserver
--feature-gates=DynamicResourceAllocation=true

# kube-controller-manager
--feature-gates=DynamicResourceAllocation=true

# kube-scheduler
--feature-gates=DynamicResourceAllocation=true

# kubelet
--feature-gates=DynamicResourceAllocation=true
```

2. Enable API Groups

Enable the DRA API groups in the API server:

```yaml
# kube-apiserver
--runtime-config=resource.k8s.io/v1beta1=true
```

## Verify DRA Feature Flag is Enabled

### 1. Verify DRA APIs resources are available

```bash
kubectl api-resources | grep resource

# Expected output:
# deviceclasses                         resource.k8s.io/v1beta1   false        DeviceClass
# resourceclaims                        resource.k8s.io/v1beta1   true         ResourceClaim
# resourceslices                        resource.k8s.io/v1beta1   false        ResourceSlice
```


### 2. Verify Kubernetes component configuration

KKP automatically configures all necessary Kubernetes components. Verify that the DRA feature gate is enabled on all control plane components:

```bash
# Check kube-apiserver arguments
kubectl get pod -n kube-system -l component=kube-apiserver -o yaml | grep "DynamicResourceAllocation"

# Check kube-controller-manager arguments  
kubectl get pod -n kube-system -l component=kube-controller-manager -o yaml | grep "DynamicResourceAllocation"

# Check kube-scheduler arguments
kubectl get pod -n kube-system -l component=kube-scheduler -o yaml | grep "DynamicResourceAllocation"
```


## Usages of Dynamic Resource Allocation

### Example 1: Simple Resource Verification

Create a simple test to verify DRA is working:

```yaml
# test-dra-basic.yaml
apiVersion: resource.k8s.io/v1beta1
kind: DeviceClass
metadata:
  name: test-gpu
spec:
  driverName: example.com/gpu
---
apiVersion: resource.k8s.io/v1beta1
kind: ResourceClaim
metadata:
  name: test-gpu-claim
spec:
  resourceClassName: example.com/gpu
  allocationMode: All
---
apiVersion: v1
kind: Pod
metadata:
  name: test-dra-pod
spec:
  resourceClaims:
    - name: gpu-claim
      source:
        resourceClaimName: test-gpu-claim
  containers:
    - name: test-container
      image: busybox:latest
      command: ["sh", "-c", "echo 'DRA is working!' && sleep 3600"]
      resources:
        claims:
          - name: gpu-claim
```

Apply the test configuration:

```bash
kubectl apply -f test-dra-basic.yaml

# Check pod status
kubectl get pod test-dra-pod

# Verify resources were created
kubectl get deviceclass test-gpu

# Check resource claim status
kubectl get resourceclaim test-gpu-claim

# View pod logs
kubectl logs test-dra-pod
```


### Example 2: Each Pod needs its own dedicated resource

```yaml
# Two pods, one container each
# Each container asking for 1 distinct GPU

---
apiVersion: v1
kind: Namespace
metadata:
  name: gpu-test1

---
apiVersion: resource.k8s.io/v1beta1
kind: ResourceClaimTemplate
metadata:
  namespace: gpu-test1
  name: single-gpu
spec:
  spec:
    devices:
      requests:
      - name: gpu
        deviceClassName: gpu.example.com

---
apiVersion: v1
kind: Pod
metadata:
  namespace: gpu-test1
  name: pod0
  labels:
    app: pod
spec:
  containers:
  - name: ctr0
    image: ubuntu:22.04
    command: ["bash", "-c"]
    args: ["export; trap 'exit 0' TERM; sleep 9999 & wait"]
    resources:
      claims:
      - name: gpu
  resourceClaims:
  - name: gpu
    resourceClaimTemplateName: single-gpu

---
apiVersion: v1
kind: Pod
metadata:
  namespace: gpu-test1
  name: pod1
  labels:
    app: pod
spec:
  containers:
  - name: ctr0
    image: ubuntu:22.04
    command: ["bash", "-c"]
    args: ["export; trap 'exit 0' TERM; sleep 9999 & wait"]
    resources:
      claims:
      - name: gpu
  resourceClaims:
  - name: gpu
    resourceClaimTemplateName: single-gpu

```

{{% notice note %}}
For more example, check out [this demo gpu-test{1,2,3,4,5}.yaml examples](https://github.com/kubernetes-sigs/dra-example-driver/tree/main/demo).
{{% /notice %}}


## Additional Resources

- [Kubernetes DRA Documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/)
- [Set Up DRA in a Cluster](https://kubernetes.io/docs/tasks/configure-pod-container/assign-resources/set-up-dra-cluster/)
- [KKP Documentation](https://docs.kubermatic.com/)
