+++
title = "Benchmark on Kubernetes 1.33 with KKP 2.28.3"
date = 2025-09-19T09:00:00+02:00
+++

This guide helps you evaluate the security of a Kubernetes cluster created using KKP against each control in the CIS Kubernetes Benchmark.

Please note: It is impossible to inspect the master nodes of managed clusters since from within the cluster(kubeconfig) one does not have access to such nodes. So for KKP, we can only check the worker nodes.

This guide corresponds to the following versions of KKP, CIS Benchmarks, and Kubernetes:

| KKP Version  | Kubernetes Version | CIS Benchmark Version |
| ---------------- | ------------------ | --------------------- |
| 2.28.3               | 1.33.5                 | CIS-1.23                    |

## Testing Methodology

### Running the Benchmark

[Trivy](https://github.com/aquasecurity/trivy) was used to run the benchmark.

```bash
trivy k8s --compliance=k8s-cis-1.23 --report summary --timeout=1h --tolerations node-role.kubernetes.io/control-plane="":NoSchedule
```

### Results

Summary Report for compliance: CIS Kubernetes Benchmarks v1.23

Each control in the CIS Kubernetes Benchmark was evaluated. These are the possible results for each control:

🟢 **Pass:** The cluster passes the audit/control outlined in the benchmark.

🔵 **Pass (Additional Configuration Required):** The cluster passes the audit/control outlined in the benchmark with some extra configuration. The documentation is provided.

🔴 **Fail:** The audit/control will be fixed in a future KKP release.

## Control Type: Worker Nodes

### 4.1. Worker Node Configuration Files

#### 4.1.1: Ensure that the kubelet service file permissions are set to 600 or more restrictive

**Severity:** HIGH

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KKP release_

---

#### 4.1.2: Ensure that the kubelet service file ownership is set to root:root

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 4.1.3: If proxy kubeconfig file exists ensure permissions are set to 600 or more restrictive

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 4.1.4: If proxy kubeconfig file exists ensure ownership is set to root:root

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 4.1.5: Ensure that the --kubeconfig kubelet.conf file permissions are set to 600 or more restrictive

**Severity:** HIGH

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KKP release_

---

#### 4.1.6: Ensure that the --kubeconfig kubelet.conf file ownership is set to root:root

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 4.1.7: Ensure that the certificate authorities file permissions are set to 600 or more restrictive

**Severity:** CRITICAL

**Result:** 🟢 Pass

---

#### 4.1.8: Ensure that the client certificate authorities file ownership is set to root:root

**Severity:** CRITICAL

**Result:** 🟢 Pass

---

#### 4.1.9: If the kubelet config.yaml configuration file is being used validate permissions set to 600 or more restrictive

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 4.1.10: If the kubelet config.yaml configuration file is being used validate file ownership is set to root:root

**Severity:** HIGH

**Result:** 🟢 Pass

---

### 4.2. Kubelet

#### 4.2.1: Ensure that the --anonymous-auth argument is set to false

**Severity:** CRITICAL

**Result:** 🟢 Pass

---

#### 4.2.2: Ensure that the --authorization-mode argument is not set to AlwaysAllow

**Severity:** CRITICAL

**Result:** 🟢 Pass

---

#### 4.2.3: Ensure that the --client-ca-file argument is set as appropriate

**Severity:** CRITICAL

**Result:** 🟢 Pass

---

#### 4.2.4: Verify that the --read-only-port argument is set to 0

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 4.2.5: Ensure that the --streaming-connection-idle-timeout argument is not set to 0

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 4.2.6: Ensure that the --protect-kernel-defaults argument is set to true

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 4.2.7: Ensure that the --make-iptables-util-chains argument is set to true

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 4.2.8: Ensure that the --hostname-override argument is not set

**Severity:** HIGH

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KKP release_

---

#### 4.2.9: Ensure that the --event-qps argument is set to 0 or a level which ensures appropriate event capture

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 4.2.10: Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate

**Severity:** CRITICAL

**Result:** 🟢 Pass

---

#### 4.2.11: Ensure that the --rotate-certificates argument is not set to false

**Severity:** CRITICAL

**Result:** 🟢 Pass

---

#### 4.2.12: Verify that the RotateKubeletServerCertificate argument is set to true

**Severity:** CRITICAL

**Result:** 🟢 Pass

---

#### 4.2.13: Ensure that the Kubelet only makes use of Strong Cryptographic Ciphers

**Severity:** CRITICAL

**Result:** 🟢 Pass

---

## Control Type: Policies

### 5.1. RBAC and Service Accounts

KKP user clusters have specific RBAC configurations that are required for cluster operation. The following controls show failures due to architectural decisions that enable multi-cloud support in the clusters.

#### 5.1.1: Ensure that the cluster-admin role is only used where required

**Severity:** HIGH

**Result:** 🔵 Expected Fail (Architectural Requirement)

The following ClusterRoleBindings to `cluster-admin` are present by design:

- `cluster-admin` - Default Kubernetes binding for `system:masters` group
- `cloud-controller-manager` - Required for cloud provider integration (multiple cloud providers).
- `<cluster-id>:cluster-admin` - KKP cluster owner access.

---

#### 5.1.2: Minimize access to secrets

**Severity:** HIGH

**Result:** 🔵 Expected Fail (Architectural Requirement)

_KKP cluster owners and editors have full access to secrets as part of their administrative role. This is by design to allow cluster management._

---

#### 5.1.3: Minimize wildcard use in Roles and ClusterRoles

**Severity:** HIGH

**Result:** 🔵 Expected Fail (Architectural Requirement)

_KKP uses wildcard permissions for cluster owners (`system:kubermatic:owners`) and editors (`system:kubermatic:editors`) ClusterRoles. This is an intentional design decision to provide full cluster management capabilities to authorized users._

---

#### 5.1.6: Ensure that Service Account Tokens are only mounted where necessary

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 5.1.8: Limit use of the Bind, Impersonate and Escalate permissions in the Kubernetes cluster

**Severity:** HIGH

**Result:** 🟢 Pass

---

### 5.2. Pod Security Standards

KKP applies Pod Security Admission (PSA) labels to user cluster namespaces to enforce security standards:

**Privileged System Namespaces:**

| Namespace | enforce | audit | warn | Description |
|-----------|---------|-------|------|-------------|
| kube-system | privileged | baseline | privileged | Kubernetes core components (CNI, CSI, node-local-dns) |
| kube-public | privileged | baseline | privileged | Kubernetes public resources |
| kube-node-lease | privileged | baseline | privileged | Node heartbeat leases |
| cloud-init-settings | privileged | baseline | privileged | KKP cloud-init configuration |

**Namespaces using baseline enforcement:**

| Namespace | enforce | audit | warn | Description |
|-----------|---------|-------|------|-------------|
| default | baseline | baseline | baseline | User workloads |
| kubernetes-dashboard | baseline | baseline | baseline | KKP dashboard service |

{{% notice note %}}
Privileged system namespaces contain components (CNI, CSI, node-local-dns) that need hostNetwork, hostPath volumes, and elevated capabilities to function. Baseline-enforced namespaces block dangerous pod configurations while allowing standard workloads.
{{% /notice %}}

To verify compliance for namespaces using baseline enforcement:

```bash
trivy k8s --include-namespaces default,kubernetes-dashboard --compliance=k8s-cis-1.23 --report summary
```

#### 5.2.2: Minimize the admission of privileged containers

**Severity:** HIGH

**Result:** 🔵 Pass (Baseline-Enforced Namespaces) / Expected Fail (Privileged System Namespaces)

_Baseline-enforced namespaces (default, kubernetes-dashboard) block privileged containers. Privileged system namespaces need it for CNI (cilium), CSI drivers, and node-local-dns._

---

#### 5.2.3: Minimize the admission of containers wishing to share the host process ID namespace

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 5.2.4: Minimize the admission of containers wishing to share the host IPC namespace

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 5.2.5: Minimize the admission of containers wishing to share the host network namespace

**Severity:** HIGH

**Result:** 🔵 Pass (Baseline-Enforced Namespaces) / Expected Fail (Privileged System Namespaces)

_Baseline-enforced namespaces block hostNetwork. Privileged system namespaces need hostNetwork for CNI (cilium) and node-local-dns._

---

#### 5.2.6: Minimize the admission of containers with allowPrivilegeEscalation

**Severity:** HIGH

**Result:** 🔵 Pass (Baseline-Enforced Namespaces) / Expected Fail (Privileged System Namespaces)

_Workloads in baseline-enforced namespaces set `allowPrivilegeEscalation: false`. Components in privileged system namespaces require privilege escalation._

---

#### 5.2.7: Minimize the admission of root containers

**Severity:** MEDIUM

**Result:** 🔵 Pass (Baseline-Enforced Namespaces) / Expected Fail (Privileged System Namespaces)

_Workloads in baseline-enforced namespaces set `runAsNonRoot: true` and run as non-root users. Components in privileged system namespaces run as root._

---

#### 5.2.8: Minimize the admission of containers with the NET_RAW capability

**Severity:** MEDIUM

**Result:** 🔵 Pass (Baseline-Enforced Namespaces) / Expected Fail (Privileged System Namespaces)

_Baseline-enforced namespaces drop NET_RAW. Components in privileged system namespaces (CNI) require this capability._

---

#### 5.2.9: Minimize the admission of containers with added capabilities

**Severity:** LOW

**Result:** 🔵 Pass (Baseline-Enforced Namespaces) / Expected Fail (Privileged System Namespaces)

_Workloads in baseline-enforced namespaces drop all capabilities with `capabilities.drop: ["ALL"]`. Components in privileged system namespaces require various capabilities._

---

#### 5.2.10: Minimize the admission of containers with capabilities assigned

**Severity:** LOW

**Result:** 🔵 Pass (Baseline-Enforced Namespaces) / Expected Fail (Privileged System Namespaces)

_Workloads in baseline-enforced namespaces drop all capabilities. Components in privileged system namespaces require various capabilities._

---

#### 5.2.11: Minimize the admission of containers with capabilities assigned

**Severity:** MEDIUM

**Result:** 🟢 Pass

---

#### 5.2.12: Minimize the admission of HostPath volumes

**Severity:** MEDIUM

**Result:** 🔵 Pass (Baseline-Enforced Namespaces) / Expected Fail (Privileged System Namespaces)

_Baseline-enforced namespaces do not use hostPath volumes. Components in privileged system namespaces (CNI, CSI) require hostPath for node-level operations._

---

#### 5.2.13: Minimize the admission of containers which use HostPorts

**Severity:** MEDIUM

**Result:** 🔵 Pass (Baseline-Enforced Namespaces) / Expected Fail (Privileged System Namespaces)

_Baseline-enforced namespaces do not use hostPorts. Components in privileged system namespaces require hostPorts._

---

### 5.3. Network Policies and CNI

#### 5.3.1: Ensure that the CNI in use supports Network Policies (Manual)

**Severity:** MEDIUM

**Result:** Manual check required

---

#### 5.3.2: Ensure that all Namespaces have Network Policies defined

**Severity:** MEDIUM

**Result:** 🟢 Pass

---

### 5.4. Secrets Management

#### 5.4.1: Prefer using secrets as files over secrets as environment variables (Manual)

**Severity:** MEDIUM

**Result:** Manual check required

---

#### 5.4.2: Consider external secret storage (Manual)

**Severity:** MEDIUM

**Result:** Manual check required

---

### 5.5. Extensible Admission Control

#### 5.5.1: Configure Image Provenance using ImagePolicyWebhook admission controller (Manual)

**Severity:** MEDIUM

**Result:** Manual check required

---

### 5.7. General Policies

#### 5.7.1: Create administrative boundaries between resources using namespaces (Manual)

**Severity:** MEDIUM

**Result:** Manual check required

---

#### 5.7.2: Ensure that the seccomp profile is set to docker/default in your pod definitions

**Severity:** MEDIUM

**Result:** 🟢 Pass

---

#### 5.7.3: Apply Security Context to Your Pods and Containers

**Severity:** HIGH

**Result:** 🔵 Pass (Baseline-Enforced Namespaces) / Expected Fail (Privileged System Namespaces)

_Workloads in baseline-enforced namespaces (default, kubernetes-dashboard) have security contexts applied with runAsNonRoot, allowPrivilegeEscalation: false, and capabilities dropped. Components in privileged system namespaces require elevated privileges._

---

#### 5.7.4: The default namespace should not be used

**Severity:** MEDIUM

**Result:** 🟢 Pass

---
