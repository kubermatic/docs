+++
title = "Architecture"
date = 2026-03-17T10:07:15+02:00
weight = 5
+++

Conformance EE is a Ginkgo v2-based test framework that follows a three-phase pattern: **Build**, **Execute**, and **Report**. It uses combinatorial scenario generation, SHA-256 deduplication, and parallel execution to efficiently validate KKP cluster configurations.

## High-Level Architecture

<div style="text-align: center">
<pre>
┌───────────────────────────────────┐
│         Ginkgo Test Suite         │
└─────────────────┬─────────────────┘
      │ calls
▼
┌───────────────────────────────────┐
│       Scenario Generator          │
│  Combinatorially generates all    │
│  test scenarios & deduplicates    │
│  using SHA-256                    │
└──────┬──────────┬──────────┬──────┘
│          │          │
▼          ▼          ▼
 ┌──────────┐ ┌────────┐ ┌──────────┐
 │ Settings │ │ Config │ │ Provider │
 │& Modifi- │ │        │ │Discovery │
 │  ers     │ │        │ │          │
 └────┬─────┘ └───┬────┘ └────┬─────┘
│           │           │
└───────────┼───────────┘
▼
┌───────────────────────────────────┐
│      Parallel Ginkgo Nodes        │
│  Node 1    Node 2    ...  Node N  │
└─────────────────┬─────────────────┘
│
▼
┌───────────────────────────────────┐
│           Reporting               │
│  JUnit XML  │  ConfigMap Live     │
│  Reports    │  Reports            │
└───────────────────────────────────┘
</pre>
</div>

## Three-Phase Pattern

### 1. Build Phase

The scenario generator produces the complete test matrix before any test spec runs:

1. **Discover Infrastructure** — Queries the cloud provider to enumerate VPCs, subnets, storage classes, instance types, etc. from the live infrastructure cluster.
2. **Generate Cluster Specs** — Combinatorially applies cluster modifiers (CNI, proxy mode, expose strategy, etc.) and datacenter modifiers (network, storage class).
3. **Deduplicate Cluster Specs** — Serializes each sanitized cluster spec, hashes with SHA-256, and uses a composite key to identify truly distinct clusters.
4. **Generate Machine Specs** — For each unique cluster, combinatorially applies machine modifiers (CPU, memory, disk, OS distribution, image source, DNS policy, eviction strategy, etc.).
5. **Deduplicate Machine Specs** — Same SHA-256 approach applied to machine specs.

The result is a deduplicated map of scenarios where each entry contains the cluster spec plus all machines to test against it.

### 2. Execute Phase

Test scenarios are executed in parallel across Ginkgo nodes:

- **Suite Setup**: Expensive one-time operations (project creation, cluster setup) run only on the first parallel Ginkgo node. Results are shared to all nodes.
- **Spec Execution**: Each Ginkgo node picks up specs from the scenario table and runs the full machine deployment lifecycle.
- **Suite Teardown**: Cluster deletion and report publishing run only on the first node after all others finish.

### 3. Report Phase

- **JUnit XML**: Per-spec JUnit XML files written to the reports directory, consumable by any CI system.
- **ConfigMap Live Reporting**: After each spec, results are patched into a shared Kubernetes ConfigMap using JSON merge patches for live visibility into test progress.

## Components

### Scenario Generator

The scenario generator is the core engine that produces the test matrix. It uses concurrent workers to parallelize cluster and machine spec generation:

<div style="text-align: center">
<pre>
┌─────────────────────────────────────┐
│     Discover Infrastructure         │
│  (VPCs, subnets, storage classes)   │
└──────────────────┬──────────────────┘
│
▼
┌─────────────────────────────────────┐
│     Generate Cluster Specs          │
│  (28 modifiers across 17 groups)    │
└──────────────────┬──────────────────┘
│
▼
┌─────────────────────────────────────┐
│     Deduplicate Cluster Specs       │
│  (SHA-256 hash)                     │
└──────────────────┬──────────────────┘
│
▼
For Each Unique Cluster
│
┌────────────┴────────────┐
│                         │
▼                         ▼
┌───────────────────┐  ┌────────────────────┐
│  Generate Machine │  │ Deduplicate Machine│
│  Specs            │─▶│ Specs              │
│  (CPU, memory,    │  │ (SHA-256 hash)     │
│   disk, OS, DNS)  │  │                    │
└───────────────────┘  └──────────┬─────────┘
                        │
                        ▼
                        ┌─────────────────────┐
                        │ Return Scenario Map │
                        └─────────────────────┘
</pre>
</div>

### Cluster Lifecycle Manager

Handles the full lifecycle of KKP clusters:

- **Creation**: Create cluster resource, wait for reconciliation (10 min), validate control plane health, add cleanup finalizers, run smoke tests
- **Upgrade**: Patch Kubernetes version, wait for reconciliation, re-run health checks
- **Deletion**: Delete with 25 min timeout, wait for cleanup finalizer-based PV/LB deletion

### Machine Deployment Manager

Manages machine deployments within user clusters:

- **Setup**: Create MachineDeployment, attach OSP annotations, wait for node references, label nodes, wait for Ready state and pod readiness
- **Update**: Patch kubelet version, wait for rollout, verify new nodes

### Interactive TUI

A Bubble Tea-based terminal interface that guides users through:

1. Environment selection (local or existing cluster)
2. Provider selection (currently KubeVirt)
3. Kubeconfig and credential configuration
4. Kubernetes version, distribution, datacenter, and modifier selection
5. Test execution and live monitoring

### Deployment Engine

Creates Kubernetes resources for in-cluster test execution:

- Kubernetes client setup from kubeconfig
- Namespace and RBAC (cluster-admin) creation
- ConfigMap for provider configuration
- Secret for kubeconfig credentials
- Job definition with mounted config and credentials
