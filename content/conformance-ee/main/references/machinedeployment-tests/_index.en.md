+++
title = "MachineDeployment Tests"
date = 2026-04-01T10:00:00+02:00
weight = 25
+++

After cluster creation and MachineDeployment provisioning, Conformance EE runs a suite of **smoke tests** against every MachineDeployment scenario. Each test targets nodes belonging to a specific MachineDeployment via a `nodeSelector` label, ensuring that the infrastructure provisioned by the machine-controller is functional end-to-end.

## Test Lifecycle

For every MachineDeployment scenario the following lifecycle is executed:

1. **MachineDeployment Setup / Update** — Create or update the MachineDeployment, apply per-distro OSP annotations, and wait for machines to obtain node references.
2. **Node Readiness** — Wait for all nodes to reach `Ready` status and for all system pods on those nodes to become ready.
3. **Node Labeling** — Label nodes with a `cluster.k8s.io/machine-set-name` label so that smoke tests can target them via `nodeSelector`.
4. **Smoke Tests** — Run all enabled smoke tests (see below) against the labeled nodes.

In **update mode**, step 1 patches the existing MachineDeployment's kubelet version to match the cluster's current Kubernetes version and waits for the rolling update to complete before running the smoke tests again.

## Smoke Tests

All smoke tests are implemented in `tests/kubermatic/` and are executed sequentially per MachineDeployment. Each test creates its own namespace and cleans up after itself. Currently, **KubeVirt** is the only supported provider for all smoke tests.

### Storage (PersistentVolume)

**Source:** `tests/kubermatic/storage.go` · **Test flag:** `storage`

Validates that the CSI driver and storage provisioner work correctly on the provisioned nodes.

| Step | Description |
|------|-------------|
| 1 | Create a dedicated namespace |
| 2 | Create a StatefulSet with a PVC (`1Gi`, `ReadWriteOnce`) — for KubeVirt clusters the storage class is resolved from `cluster.Spec.Cloud.Kubevirt.StorageClasses` |
| 3 | Wait for the StatefulSet to become ready (pod writes `alive` to the PV) |
| 4 | Scale the StatefulSet to 0 replicas and wait for scale-down |
| 5 | Scale back to 1 replica and verify the pod recovers with the persisted data |

**What it validates:**
- Dynamic PVC provisioning via the cloud-provider CSI driver
- Volume attach/detach lifecycle
- Data persistence across pod restarts
- Storage class propagation from datacenter to user cluster (KubeVirt `kubevirt-<name>` prefixed classes)

---

### LoadBalancer

**Source:** `tests/kubermatic/loadbalancer.go` · **Test flag:** `lb`

Validates that `Service` resources of type `LoadBalancer` are correctly provisioned and reachable.

| Step | Description |
|------|-------------|
| 1 | Create a dedicated namespace |
| 2 | Create a `LoadBalancer` Service (with provider-specific annotations, e.g. `metallb.io/ip-allocated-from-pool` for KubeVirt) |
| 3 | Create a server pod (`hello-app:2.0`) with a readiness probe and wait for it to become ready |
| 4 | Poll the Service until an external IP/hostname appears in `.status.loadBalancer.ingress` |
| 5 | Verify the LoadBalancer is reachable from the test runner via HTTP (`Hello, world!` response) |
| 6 | Create an **in-cluster curl pod** on the same node and verify connectivity from within the cluster — this covers air-gapped environments where the test runner cannot reach the LB IP directly |

**What it validates:**
- Cloud controller manager integration for LoadBalancer provisioning
- External IP assignment
- End-to-end traffic routing from external and in-cluster clients through the LoadBalancer to the backing pod

---

### Connectivity (Networking)

**Source:** `tests/kubermatic/networking.go` · **Test flag:** `network`

Validates core pod networking, DNS resolution, and CNI overlay connectivity.

| Step | Description |
|------|-------------|
| 1 | Create a dedicated namespace |
| 2 | Enumerate ready nodes matching the MachineDeployment's `nodeSelector` |
| 3 | **DNS test** — Run a pod that performs `nslookup kubernetes.default.svc.cluster.local` |
| 4 | **Pod-to-pod same-node** — Deploy a server pod and a client pod on the same node; client reaches the server via a ClusterIP Service |
| 5 | **Pod-to-pod cross-node** *(≥ 2 nodes)* — Server on node A, client on node B, connected via a ClusterIP Service — exercises the CNI overlay |
| 6 | **Host-to-host** *(≥ 2 nodes)* — Two `hostNetwork` pods on different nodes communicate via node internal IPs |
| 7 | **Host-to-pod** *(≥ 2 nodes)* — A `hostNetwork` client on node B reaches a regular pod on node A via the pod's IP |

**What it validates:**
- Cluster DNS resolution (CoreDNS / node-local-dns)
- Pod-to-pod connectivity within the same node
- Pod-to-pod connectivity across nodes (CNI overlay / routing)
- Host-network to pod-network communication
- Host-network to host-network communication
- ClusterIP Service forwarding (kube-proxy / eBPF)

---

### NetworkPolicy

**Source:** `tests/kubermatic/networkpolicy.go` · **Test flag:** `network-policy`

Validates that the CNI plugin correctly enforces Kubernetes `NetworkPolicy` resources.

| Step | Description |
|------|-------------|
| 1 | Create a dedicated namespace and a server pod |
| 2 | **Baseline check** — Verify an unlabeled client pod can reach the server (no policies in place) |
| 3 | **Deny-all ingress** — Apply a `NetworkPolicy` with an empty `podSelector` and `PolicyType: Ingress` (deny all) |
| 4 | **Block verification** — Run a client pod that succeeds only if `wget` *fails* (traffic is blocked) |
| 5 | **Targeted allow** — Apply a second `NetworkPolicy` that allows ingress from pods with `netpol-role: client` |
| 6 | **Allow verification** — Run a labeled client pod and confirm it can reach the server |

**What it validates:**
- Deny-all NetworkPolicy enforcement
- Label-based ingress allow rules
- CNI plugin NetworkPolicy implementation (Canal / Cilium)

---

### NodePort

**Source:** `tests/kubermatic/nodeport.go` · **Test flag:** `nodeport`

Validates that `Service` resources of type `NodePort` correctly forward traffic.

| Step | Description |
|------|-------------|
| 1 | Create a dedicated namespace |
| 2 | Create a server pod on one node and a `NodePort` Service targeting it |
| 3 | Resolve the server node's internal IP and the auto-assigned node port |
| 4 | Create a client pod on a **different node** (when available) that sends a request to `<nodeIP>:<nodePort>` |
| 5 | Verify the response contains `OK` |

**What it validates:**
- NodePort Service allocation and port assignment
- Cross-node kube-proxy / eBPF NodePort forwarding
- Traffic routing from a node port to the backing pod

---

## Node Targeting

All smoke tests receive a `nodeSelector` map derived from the MachineDeployment name:

```yaml
cluster.k8s.io/machine-set-name: "<clusterName>-<scenarioName>"
```

This label is applied to nodes during the MachineDeployment setup phase, ensuring that test pods (servers, clients, and workloads) are scheduled exclusively on nodes provisioned by the specific MachineDeployment under test. This isolation prevents interference between MachineDeployment scenarios running in parallel.

## Enabling / Disabling Tests

Individual test suites can be toggled via the `--tests` and `--exclude-tests` flags:

| Flag Value       | Test Suite         |
|------------------|--------------------|
| `storage`        | PersistentVolume   |
| `lb`             | LoadBalancer       |
| `network`        | Connectivity       |
| `network-policy` | NetworkPolicy      |
| `nodeport`       | NodePort           |

When a test is disabled, it is skipped with an informational log message.
