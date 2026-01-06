+++
title = "Architecture"
date = 2024-05-31T07:00:00+02:00
weight = 5
+++

This document describes the architecture and design principles of machine-controller.

## Overview

Machine-controller is a Kubernetes controller that implements the [Cluster API](https://cluster-api.sigs.k8s.io/) specification for managing worker nodes across multiple cloud providers. It provides a unified, declarative interface for machine lifecycle management.

## Core Components

### Controller Manager

The controller manager is the main component that runs as a Deployment in the `kube-system` namespace. It consists of several reconciliation loops:

- **MachineDeployment Controller**: Manages MachineSet objects based on MachineDeployment specifications
- **MachineSet Controller**: Ensures the desired number of Machine objects exist
- **Machine Controller**: Reconciles Machine objects with actual cloud instances

### Custom Resource Definitions (CRDs)

Machine-controller uses three primary CRDs defined by the Cluster API:

#### MachineDeployment

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
```

Provides declarative updates for Machines, similar to Kubernetes Deployments. Manages:
- Replica count
- Rolling updates
- Revision history
- Update strategies

#### MachineSet

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineSet
```

Ensures a specified number of Machines are running. Typically created and managed by MachineDeployment but can be used independently.

#### Machine

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: Machine
```

Represents a single worker node. Contains:
- Cloud provider configuration
- Operating system specification
- Kubernetes version
- Network settings
- Labels and taints

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Kubernetes API Server                    │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │
                            │ Watch/Update
                            │
┌──────────────────────────────────────────────────────────────┐
│                    Machine Controller                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │ MachineDepl. │  │  MachineSet  │  │   Machine    │       │
│  │ Controller   │─▶│  Controller  │─▶│  Controller  │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│                                              │                │
└──────────────────────────────────────────────┼───────────────┘
                                               │
                                               │ Cloud API
                                               ▼
                        ┌─────────────────────────────────────┐
                        │     Cloud Provider (AWS, Azure,     │
                        │   GCP, Hetzner, OpenStack, etc.)    │
                        └─────────────────────────────────────┘
                                               │
                                               ▼
                        ┌─────────────────────────────────────┐
                        │    Cloud Instances (Worker Nodes)   │
                        └─────────────────────────────────────┘
```

## Reconciliation Loop

The machine-controller follows the standard Kubernetes controller pattern:

1. **Watch**: Monitor Machine, MachineSet, and MachineDeployment objects
2. **Compare**: Compare desired state (spec) with actual state (status)
3. **Reconcile**: Take actions to make actual state match desired state
4. **Update Status**: Record the current state and any errors

### Machine Lifecycle

```
┌──────────┐
│  Create  │
│ Machine  │
└────┬─────┘
     │
     ▼
┌─────────────────┐
│   Validating    │ ◀─── Validate configuration
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│  Provisioning   │ ◀─── Create cloud instance
└────┬────────────┘      Generate user-data
     │                   Apply cloud-init
     ▼
┌─────────────────┐
│  Joining        │ ◀─── Configure kubelet
└────┬────────────┘      Join cluster
     │                   Register node
     ▼
┌─────────────────┐
│    Running      │ ◀─── Monitor health
└────┬────────────┘      Update status
     │
     ▼
┌─────────────────┐
│   Deleting      │ ◀─── Drain node
└────┬────────────┘      Delete cloud instance
     │                   Clean up resources
     ▼
┌─────────────────┐
│    Deleted      │
└─────────────────┘
```

## Cloud Provider Integration

Machine-controller uses a provider abstraction layer that enables support for multiple cloud platforms.

### Provider Interface

Each cloud provider implements the following interface:

```go
type Provider interface {
    // Validate validates the machine spec
    Validate(spec v1alpha1.MachineSpec) error
    
    // Create creates a new cloud instance
    Create(machine *v1alpha1.Machine, data *MachineCreateDeleteData, userdata string) (Instance, error)
    
    // Get retrieves an existing instance
    Get(machine *v1alpha1.Machine) (Instance, error)
    
    // Cleanup deletes the instance and associated resources
    Cleanup(machine *v1alpha1.Machine, data *MachineCreateDeleteData) (bool, error)
    
    // GetCloudConfig returns provider-specific cloud config
    GetCloudConfig(spec v1alpha1.MachineSpec) (config string, name string, err error)
    
    // AddDefaults adds default values to the machine spec
    AddDefaults(spec v1alpha1.MachineSpec) (v1alpha1.MachineSpec, error)
}
```

### Supported Providers

Currently implemented providers:
- AWS (Amazon Web Services)
- Azure (Microsoft Azure)
- DigitalOcean
- GCP (Google Cloud Platform)
- Hetzner Cloud
- KubeVirt
- Nutanix
- OpenStack
- Equinix Metal
- VMware Cloud Director
- VMware vSphere
- Alibaba Cloud
- Anexia

See [Cloud Providers]({{< ref "../references/cloud-providers/" >}}) for detailed configuration.

## Operating System Provisioning

Machine-controller supports multiple operating systems through a unified provisioning mechanism.

### Provisioning Flow

1. **Template Selection**: Choose base image based on OS and cloud provider
2. **User Data Generation**: Create cloud-init or ignition configuration
3. **Package Installation**: Install container runtime and Kubernetes components
4. **Configuration**: Apply kubelet configuration and join cluster
5. **Verification**: Ensure node successfully joins and reports ready

### Supported Operating Systems

- Ubuntu (20.04, 22.04, 24.04 LTS)
- Flatcar Container Linux
- RHEL (Red Hat Enterprise Linux) 8.x
- Rocky Linux 8.5+
- Amazon Linux 2

See [Operating Systems]({{< ref "../references/operating-systems/" >}}) for the support matrix.

## Security Considerations

### Credentials Management

Machine-controller supports multiple methods for cloud provider authentication:

1. **Kubernetes Secrets**: Recommended for production
2. **Environment Variables**: Useful for testing and development
3. **Instance Metadata**: For cloud instances with appropriate IAM roles

### RBAC Permissions

Machine-controller requires specific permissions:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: machine-controller
rules:
- apiGroups: ["cluster.k8s.io"]
  resources: ["machines", "machinesets", "machinedeployments"]
  verbs: ["*"]
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["*"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["events"]
  verbs: ["create", "patch"]
```

### Network Security

- Cloud instances should be created in private subnets when possible
- Security groups/firewall rules should restrict access
- API server should be accessible from worker nodes
- Worker nodes need internet access for package downloads (or use private repositories)

## High Availability

For production deployments:

1. **Multiple Replicas**: Run machine-controller with `replicas: 2` or more
2. **Leader Election**: Only one instance actively reconciles at a time
3. **Resource Requests/Limits**: Set appropriate resource constraints
4. **Pod Disruption Budget**: Ensure at least one replica is always available

Example HA configuration:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: machine-controller
  namespace: kube-system
spec:
  replicas: 2
  template:
    spec:
      containers:
      - name: machine-controller
        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: machine-controller
  namespace: kube-system
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: machine-controller
```

## Performance and Scalability

### Worker Count

The `-worker-count` flag controls concurrent reconciliation operations:

- **Small clusters** (< 50 nodes): 5-10 workers
- **Medium clusters** (50-200 nodes): 10-20 workers
- **Large clusters** (> 200 nodes): 20-50 workers

Higher worker counts increase throughput but also resource usage.

### Rate Limiting

Machine-controller respects cloud provider API rate limits:

- Implements exponential backoff for failures
- Queues requests to avoid overwhelming APIs
- Caches cloud provider responses when possible

### Resource Usage

Typical resource consumption:
- **CPU**: 50-200m per worker
- **Memory**: 256-512Mi base + ~10Mi per machine

## Metrics and Monitoring

Machine-controller exposes Prometheus metrics on port 8085:

- `machine_controller_machines_total{provider="aws"}` - Total machines by provider
- `machine_controller_errors_total{operation="create"}` - Error count by operation
- `machine_controller_workers_running` - Active worker count
- `machine_controller_machine_deployment_replicas` - Desired vs actual replicas

## Integration with Cluster Autoscaler

Machine-controller works seamlessly with [Kubernetes Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler):

1. Cluster Autoscaler monitors pod scheduling
2. When pods can't be scheduled, it scales up MachineDeployments
3. Machine-controller provisions new nodes
4. When nodes are underutilized, Cluster Autoscaler scales down
5. Machine-controller deletes the machines

## Design Principles

1. **Declarative Configuration**: All state expressed through Kubernetes resources
2. **Cloud Agnostic**: Unified interface across all providers
3. **Self-Healing**: Automatic remediation of unhealthy machines
4. **Scalability**: Efficient handling of large machine fleets
5. **Extensibility**: Easy to add new cloud providers and operating systems
6. **Security First**: Secure credential handling and minimal permissions
7. **Observable**: Comprehensive logging, metrics, and events

## References

- [Cluster API Specification](https://cluster-api.sigs.k8s.io/)
- [Kubernetes Controller Pattern](https://kubernetes.io/docs/concepts/architecture/controller/)
- [Machine-Controller GitHub](https://github.com/kubermatic/machine-controller)

