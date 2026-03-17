+++
title = "Architecture"
date = 2026-03-17T10:07:15+02:00
weight = 5
+++

Conformance EE is a Ginkgo v2-based test framework that follows a three-phase pattern: **Build**, **Execute**, and **Report**. It uses combinatorial scenario generation, SHA-256 deduplication, and parallel execution to efficiently validate KKP cluster configurations.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Ginkgo Test Suite                            │
│   provider/kubevirt/provider_suite_test.go                     │
│   provider/kubevirt/provider_kubevirt_test.go                  │
└──────────────────────┬──────────────────────────────────────────┘
                       │ calls
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                  build.GetTableEntries()                        │
│   Combinatorially generates all test scenarios                  │
│   Deduplicates using SHA-256 of sanitized cluster specs         │
└──────────────────────┬──────────────────────────────────────────┘
                       │ uses
          ┌────────────┼────────────┐
          ▼            ▼            ▼
    ┌──────────┐ ┌──────────┐ ┌──────────────┐
    │settings/ │ │options/  │ │build/        │
    │cluster.go│ │options.go│ │provider/     │
    │kubevirt  │ │          │ │kubevirt.go   │
    └──────────┘ └──────────┘ └──────────────┘

                  Parallel Ginkgo nodes
          ┌─────────────────────────────────┐
          │  Node 1     Node 2  ...  Node N │
          │  cluster/   utils/              │
          │  ensure.go  provider_suite_     │
          │  update.go  utils.go            │
          └─────────────────────────────────┘

                  Reporting
          ┌─────────────────────────────────┐
          │  utils/junit_reporter.go        │
          │  utils/reports_configmap.go     │
          └─────────────────────────────────┘
```

## Three-Phase Pattern

### 1. Build Phase

The `build.GetTableEntries()` function generates the complete scenario matrix before any test spec runs:

1. **Discover Infrastructure** — Calls the provider's `DiscoverDefaultDatacenterSettings()` to enumerate VPCs, subnets, storage classes, instance types, etc. from the live infrastructure cluster.
2. **Generate Cluster Specs** — Combinatorially applies cluster modifiers (CNI, proxy mode, expose strategy, etc.) and datacenter modifiers (network, storage class).
3. **Deduplicate Cluster Specs** — Serializes each sanitized `ClusterSpec` to JSON, hashes with SHA-256, and uses a `(dcHash[:6], specHash[:6], k8sVersion)` key to identify truly distinct clusters.
4. **Generate Machine Specs** — For each unique cluster, combinatorially applies machine modifiers (CPU, memory, disk, OS distribution, image source, DNS policy, eviction strategy, etc.).
5. **Deduplicate Machine Specs** — Same SHA-256 approach applied to machine specs.

The result is a `map[string]*Scenario` where each key is a cluster dedup key and each `Scenario` contains the cluster spec plus all machines to test against it.

### 2. Execute Phase

Test scenarios are executed in parallel across Ginkgo nodes:

- **Suite Setup** (`SynchronizedBeforeSuite`): Expensive one-time operations (project creation, cluster setup) run only on the first parallel Ginkgo node. Results are shared via `[]byte` to all nodes.
- **Spec Execution**: Each Ginkgo node picks up specs from the scenario table and runs the full machine deployment lifecycle.
- **Suite Teardown** (`SynchronizedAfterSuite`): Cluster deletion and report publishing run only on the first node after all others finish.

### 3. Report Phase

- **JUnit XML**: Per-spec JUnit XML files written to the reports directory, consumable by any CI system.
- **ConfigMap Live Reporting**: After each spec, results are patched into a shared Kubernetes ConfigMap using JSON merge patches for live visibility into test progress.

## Components

### Scenario Generator (`build/`)

The scenario generator is the core engine that produces the test matrix. It uses 100 concurrent workers to parallelize cluster and machine spec generation:

```
Discover Infrastructure
    ↓ (VPCs, subnets, storage classes, instance types)
Generate Cluster Specs
    ↓ (apply 28 cluster modifiers across 17 groups)
Deduplicate Cluster Specs
    ↓ (SHA-256 hash: dcNameHash[:6] + specHash[:6] + k8sVersion)
For Each Unique Cluster:
    Generate Machine Specs
        ↓ (apply machine modifiers: CPU, memory, disk, OS, DNS, etc.)
    Deduplicate Machine Specs
        ↓ (SHA-256 hash of sanitized spec + machineName)
Return Map[clusterDedupKey]*Scenario
```

### Cluster Lifecycle Manager (`cluster/`)

Handles the full lifecycle of KKP clusters:

- **Creation**: Create cluster resource, wait for reconciliation (10 min), validate control plane health, add cleanup finalizers, run smoke tests
- **Upgrade**: Patch Kubernetes version, wait for reconciliation, re-run health checks
- **Deletion**: Delete with 25 min timeout, wait for cleanup finalizer-based PV/LB deletion

### Machine Deployment Manager (`utils/`)

Manages machine deployments within user clusters:

- **Setup**: Create `MachineDeployment`, attach OSP annotations, wait for node references, label nodes, wait for Ready state and pod readiness
- **Update**: Patch kubelet version, wait for rollout, verify new nodes

### Interactive TUI (`ui/`)

A Bubble Tea-based terminal interface that guides users through:

1. Environment selection (local or existing cluster)
2. Provider selection (currently KubeVirt)
3. Kubeconfig and credential configuration
4. Kubernetes version, distribution, datacenter, and modifier selection
5. Test execution and live monitoring

### Deployment Engine (`deploy/`)

Creates Kubernetes resources for in-cluster test execution:

- Kubernetes client setup from kubeconfig
- Namespace and RBAC (cluster-admin) creation
- ConfigMap for provider configuration
- Secret for kubeconfig credentials
- Job definition with mounted config and credentials

## Directory Structure

```
conformance-ee/
├── cmd/                    # CLI entry point
│   └── main.go
├── deploy/                 # Kubernetes deployment utilities
│   └── kubernetes.go
├── tests/                  # Core test framework
│   ├── build/              # Scenario generation engine
│   │   ├── build.go        # GetTableEntries(), worker pools
│   │   ├── scenario.go     # Entry point for scenario generation
│   │   ├── types.go        # Core types (Scenario, clusterJob)
│   │   ├── labels.go       # Ginkgo label helpers
│   │   ├── provider.go     # Provider-agnostic building
│   │   └── provider/       # Provider implementations
│   ├── cluster/            # Cluster lifecycle
│   │   ├── ensure.go       # Creation and health validation
│   │   └── update.go       # Version upgrade logic
│   ├── options/            # Configuration loading
│   │   └── options.go      # YAML config and runtime options
│   ├── settings/           # Modifier definitions
│   │   ├── types.go        # Core modifier types
│   │   ├── cluster.go      # 28 cluster modifiers
│   │   └── kubevirt.go     # KubeVirt machine/DC modifiers
│   ├── utils/              # Test utilities and reporters
│   └── provider/kubevirt/  # Ginkgo test suite
├── ui/                     # Interactive TUI
├── Dockerfile.ginkgo       # Multi-stage Docker build
└── go.mod                  # Go module dependencies
```
