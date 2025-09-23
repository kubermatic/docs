+++
title = "Benchmark on Kubernetes 1.33 with KKP 2.28.3"
date = 2025-09-23T13:22:14+02:00
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

#### 5.1.1: Ensure that the cluster-admin role is only used where required

**Severity:** HIGH

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KKP release_

---

#### 5.1.2: Minimize access to secrets

**Severity:** HIGH

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KKP release_

---

#### 5.1.3: Minimize wildcard use in Roles and ClusterRoles

**Severity:** HIGH

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KKP release_

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

#### 5.2.2: Minimize the admission of privileged containers

**Severity:** HIGH

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KKP release_

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

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KKP release_

---

#### 5.2.6: Minimize the admission of containers with allowPrivilegeEscalation

**Severity:** HIGH

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KKP release_

---

#### 5.2.7: Minimize the admission of root containers

**Severity:** MEDIUM

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KKP release_

---

#### 5.2.8: Minimize the admission of containers with the NET_RAW capability

**Severity:** MEDIUM

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KKP release_

---

#### 5.2.9: Minimize the admission of containers with added capabilities

**Severity:** LOW

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KKP release_

---

#### 5.2.10: Minimize the admission of containers with capabilities assigned

**Severity:** LOW

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KKP release_

---

#### 5.2.11: Minimize the admission of containers with capabilities assigned

**Severity:** MEDIUM

**Result:** 🟢 Pass

---

#### 5.2.12: Minimize the admission of HostPath volumes

**Severity:** MEDIUM

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KKP release_

---

#### 5.2.13: Minimize the admission of containers which use HostPorts

**Severity:** MEDIUM

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KKP release_

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

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KKP release_

---

#### 5.7.4: The default namespace should not be used

**Severity:** MEDIUM

**Result:** 🟢 Pass

---
