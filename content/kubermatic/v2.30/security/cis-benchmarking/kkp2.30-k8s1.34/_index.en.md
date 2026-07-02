+++
title = "Benchmark on Kubernetes 1.34.5 with KKP 2.30.0"
date = 2026-07-02T06:09:38+00:00
+++

> CIS Benchmark **cis-1.12** applies to KKP **2.30.0** / Kubernetes **1.34.5**.

This guide helps you evaluate the security of a Kubernetes cluster created using KKP against each control in the CIS Kubernetes Benchmark.

Please note: It is impossible to inspect the master nodes of managed clusters since from within the cluster (kubeconfig) one does not have access to such nodes. So for KKP, we can only check the worker nodes.

This guide corresponds to the following versions of KKP, CIS Benchmarks, and Kubernetes:

| KKP Version | Kubernetes Version | CIS Benchmark Version |
| --- | --- | --- |
| 2.30.0 | 1.34.5 | cis-1.12 |

## Testing Methodology

### Running the Benchmark

[kube-bench](https://github.com/aquasecurity/kube-bench) was used to run the benchmark.

### Results

Each control in the CIS Kubernetes Benchmark was evaluated. These are the possible results for each control:

🟢 **Pass:** The cluster passes the audit/control outlined in the benchmark.

🔵 **Pass (Additional Configuration Required):** The cluster passes the audit/control outlined in the benchmark with some extra configuration. The documentation is provided.

🔴 **Fail:** The audit/control will be fixed in a future KKP release.

## Summary

| Status | Count |
| --- | --- |
| Pass | 18 |
| Fail | 1 |
| Warn | 26 |
| ExpectedFail (matched by KKP exception) | 2 |
| PassWithConditions (matched by KKP exception) | 12 |
| Info | 0 |

Generated: 2026-07-02 · kube-bench v0.15.0

## Expected failures (matched by KKP exception baseline)

Baseline source: [`tests/cis/baseline/kkp-exceptions.yaml`](https://github.com/kubermatic/conformance-ee/blob/main/tests/cis/baseline/kkp-exceptions.yaml)

- **4.2.2** (Scanner Detection Gap) — Same root cause as 4.2.1: kube-bench cannot resolve $kubeletconf to
  /etc/kubernetes/kubelet.conf on KKP workers, so authorization.mode cannot
  be read from the config file. The kubelet is correctly configured with
  authorization mode Webhook; this is a false positive.
  Kubelet config in KKP OSPs:
    https://github.com/kubermatic/operating-system-manager/tree/main/deploy/osps/default
  See: https://github.com/aquasecurity/kube-bench/issues/852
       https://github.com/aquasecurity/kube-bench/issues/1973
- **4.2.3** (Scanner Detection Gap) — Same root cause as 4.2.1: kube-bench cannot resolve $kubeletconf to
  /etc/kubernetes/kubelet.conf on KKP workers, so authentication.x509.clientCAFile
  cannot be read from the config file. The client CA file is correctly set;
  this is a false positive.
  Kubelet config in KKP OSPs:
    https://github.com/kubermatic/operating-system-manager/tree/main/deploy/osps/default
  See: https://github.com/aquasecurity/kube-bench/issues/852
       https://github.com/aquasecurity/kube-bench/issues/1973
- **5.1.1** (KKP Operator Requirement) — cluster-admin, cloud-controller-manager, and cluster owner bindings are
  required by KKP design for cluster lifecycle management.
- **5.1.2** (KKP Operator Requirement) — KKP administrators require full secret access in kubermatic-system for
  cluster management operations.
- **5.1.3** (KKP Operator Requirement) — Owner and editor roles intentionally use wildcard permissions to support
  the full range of cluster management operations required by KKP.
- **5.1.5** (KKP Operator Requirement) — KKP operators mount default service accounts in kubermatic-system by
  design.
- **5.2.10** (System Component Requirement) — Capability assignment is restricted in baseline namespaces but system
  components require specific capabilities to function.
- **5.2.12** (System Component Requirement) — HostPath volumes are blocked in baseline namespaces but required in system
  namespaces by CNI plugins and CSI drivers.
- **5.2.2** (System Component Requirement) — Privileged containers are blocked in baseline namespaces but permitted in
  system namespaces (kube-system, kubermatic-system) where CNI and CSI
  drivers require elevated privileges.
- **5.2.5** (System Component Requirement) — Host network access is blocked in baseline namespaces but required in
  system namespaces for CNI plugins and DNS components.
- **5.2.6** (System Component Requirement) — Privilege escalation is restricted in baseline namespaces but required in
  system namespaces for certain KKP and Kubernetes system components.
- **5.2.7** (System Component Requirement) — Non-root enforcement is applied in baseline namespaces but system
  namespaces run containers as root where required by upstream components.
- **5.2.8** (System Component Requirement) — NET_RAW capability is dropped in baseline namespaces but required by CNI
  plugins running in system namespaces.
- **5.2.9** (System Component Requirement) — Added capabilities are restricted in baseline namespaces but system
  components (CNI, CSI, KKP operators) require specific capabilities.

## Control Type: Worker Nodes

### 4.1

#### 4.1.1: Ensure that the kubelet service file permissions are set to 600 or more restrictive (Automated)

**Result:** 🟢 Pass

---

#### 4.1.2: Ensure that the kubelet service file ownership is set to root:root (Automated)

**Result:** 🟢 Pass

---

#### 4.1.3: If proxy kubeconfig file exists ensure permissions are set to 600 or more restrictive (Manual)

**Result:** 🟢 Pass

---

#### 4.1.4: If proxy kubeconfig file exists ensure ownership is set to root:root (Manual)

**Result:** 🟢 Pass

---

#### 4.1.5: Ensure that the --kubeconfig kubelet.conf file permissions are set to 600 or more restrictive (Automated)

**Result:** 🟢 Pass

---

#### 4.1.6: Ensure that the --kubeconfig kubelet.conf file ownership is set to root:root (Automated)

**Result:** 🟢 Pass

---

#### 4.1.7: Ensure that the certificate authorities file permissions are set to 644 or more restrictive (Manual)

**Result:** 🟢 Pass

---

#### 4.1.8: Ensure that the client certificate authorities file ownership is set to root:root (Manual)

**Result:** 🟢 Pass

---

#### 4.1.9: If the kubelet config.yaml configuration file is being used validate permissions set to 600 or more restrictive (Automated)

**Result:** 🟢 Pass

---

#### 4.1.10: If the kubelet config.yaml configuration file is being used validate file ownership is set to root:root (Automated)

**Result:** 🟢 Pass

---

### 4.2

#### 4.2.1: Ensure that the --anonymous-auth argument is set to false (Automated)

**Result:** 🔴 Fail

---

#### 4.2.2: Ensure that the --authorization-mode argument is not set to AlwaysAllow (Automated)

**Result:** 🔵 Expected Fail (Scanner Detection Gap)

_Same root cause as 4.2.1: kube-bench cannot resolve $kubeletconf to
/etc/kubernetes/kubelet.conf on KKP workers, so authorization.mode cannot
be read from the config file. The kubelet is correctly configured with
authorization mode Webhook; this is a false positive.
Kubelet config in KKP OSPs:
  https://github.com/kubermatic/operating-system-manager/tree/main/deploy/osps/default
See: https://github.com/aquasecurity/kube-bench/issues/852
     https://github.com/aquasecurity/kube-bench/issues/1973_

---

#### 4.2.3: Ensure that the --client-ca-file argument is set as appropriate (Automated)

**Result:** 🔵 Expected Fail (Scanner Detection Gap)

_Same root cause as 4.2.1: kube-bench cannot resolve $kubeletconf to
/etc/kubernetes/kubelet.conf on KKP workers, so authentication.x509.clientCAFile
cannot be read from the config file. The client CA file is correctly set;
this is a false positive.
Kubelet config in KKP OSPs:
  https://github.com/kubermatic/operating-system-manager/tree/main/deploy/osps/default
See: https://github.com/aquasecurity/kube-bench/issues/852
     https://github.com/aquasecurity/kube-bench/issues/1973_

---

#### 4.2.4: Verify that if defined, the --read-only-port argument is set to 0 (Manual)

**Result:** 🟢 Pass

---

#### 4.2.5: Ensure that the --streaming-connection-idle-timeout argument is not set to 0 (Manual)

**Result:** 🟢 Pass

---

#### 4.2.6: Ensure that the --make-iptables-util-chains argument is set to true (Automated)

**Result:** 🟢 Pass

---

#### 4.2.7: Ensure that the --hostname-override argument is not set (Manual)

**Result:** Manual — Operator Dependent

---

#### 4.2.8: Ensure that the eventRecordQPS argument is set to a level which ensures appropriate event capture (Manual)

**Result:** 🟢 Pass

---

#### 4.2.9: Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate (Manual)

**Result:** Manual — Operator Dependent

---

#### 4.2.10: Ensure that the --rotate-certificates argument is not set to false (Automated)

**Result:** 🟢 Pass

---

#### 4.2.11: Verify that the RotateKubeletServerCertificate argument is set to true (Manual)

**Result:** 🟢 Pass

---

#### 4.2.12: Ensure that the Kubelet only makes use of Strong Cryptographic Ciphers (Manual)

**Result:** Manual — Operator Dependent

---

#### 4.2.13: Ensure that a limit is set on pod PIDs (Manual)

**Result:** Manual — Operator Dependent

---

#### 4.2.14: Ensure that the --seccomp-default parameter is set to true (Manual)

**Result:** Manual — Operator Dependent

---

### 4.3

#### 4.3.1: Ensure that the kube-proxy metrics service is bound to localhost (Automated)

**Result:** 🟢 Pass

---

## Control Type: Policies

### 5.1

#### 5.1.1: Ensure that the cluster-admin role is only used where required (Manual)

**Result:** 🔵 Pass (Additional Configuration Required) (KKP Operator Requirement)

_cluster-admin, cloud-controller-manager, and cluster owner bindings are
required by KKP design for cluster lifecycle management._

---

#### 5.1.2: Minimize access to secrets (Manual)

**Result:** 🔵 Pass (Additional Configuration Required) (KKP Operator Requirement)

_KKP administrators require full secret access in kubermatic-system for
cluster management operations._

---

#### 5.1.3: Minimize wildcard use in Roles and ClusterRoles (Manual)

**Result:** 🔵 Pass (Additional Configuration Required) (KKP Operator Requirement)

_Owner and editor roles intentionally use wildcard permissions to support
the full range of cluster management operations required by KKP._

---

#### 5.1.4: Minimize access to create pods (Manual)

**Result:** Manual — Operator Dependent

---

#### 5.1.5: Ensure that default service accounts are not actively used (Manual)

**Result:** 🔵 Pass (Additional Configuration Required) (KKP Operator Requirement)

_KKP operators mount default service accounts in kubermatic-system by
design._

---

#### 5.1.6: Ensure that Service Account Tokens are only mounted where necessary (Manual)

**Result:** Manual — Operator Dependent

---

#### 5.1.7: Avoid use of system:masters group (Manual)

**Result:** Manual — Operator Dependent

---

#### 5.1.8: Limit use of the Bind, Impersonate and Escalate permissions in the Kubernetes cluster (Manual)

**Result:** Manual — Operator Dependent

---

#### 5.1.9: Minimize access to create persistent volumes (Manual)

**Result:** Manual — Operator Dependent

---

#### 5.1.10: Minimize access to the proxy sub-resource of nodes (Manual)

**Result:** Manual — Operator Dependent

---

#### 5.1.11: Minimize access to the approval sub-resource of certificatesigningrequests objects (Manual)

**Result:** Manual — Operator Dependent

---

#### 5.1.12: Minimize access to webhook configuration objects (Manual)

**Result:** Manual — Operator Dependent

---

#### 5.1.13: Minimize access to the service account token creation (Manual)

**Result:** Manual — Operator Dependent

---

### 5.2

#### 5.2.1: Ensure that the cluster has at least one active policy control mechanism in place (Manual)

**Result:** Manual — Operator Dependent

---

#### 5.2.2: Minimize the admission of privileged containers (Manual)

**Result:** 🔵 Pass (Additional Configuration Required) (System Component Requirement)

_Privileged containers are blocked in baseline namespaces but permitted in
system namespaces (kube-system, kubermatic-system) where CNI and CSI
drivers require elevated privileges._

---

#### 5.2.3: Minimize the admission of containers wishing to share the host process ID namespace (Manual)

**Result:** Manual — Operator Dependent

---

#### 5.2.4: Minimize the admission of containers wishing to share the host IPC namespace (Manual)

**Result:** 🟢 Pass

---

#### 5.2.5: Minimize the admission of containers wishing to share the host network namespace (Manual)

**Result:** 🔵 Pass (Additional Configuration Required) (System Component Requirement)

_Host network access is blocked in baseline namespaces but required in
system namespaces for CNI plugins and DNS components._

---

#### 5.2.6: Minimize the admission of containers with allowPrivilegeEscalation (Manual)

**Result:** 🔵 Pass (Additional Configuration Required) (System Component Requirement)

_Privilege escalation is restricted in baseline namespaces but required in
system namespaces for certain KKP and Kubernetes system components._

---

#### 5.2.7: Minimize the admission of root containers (Manual)

**Result:** 🔵 Pass (Additional Configuration Required) (System Component Requirement)

_Non-root enforcement is applied in baseline namespaces but system
namespaces run containers as root where required by upstream components._

---

#### 5.2.8: Minimize the admission of containers with the NET_RAW capability (Manual)

**Result:** 🔵 Pass (Additional Configuration Required) (System Component Requirement)

_NET_RAW capability is dropped in baseline namespaces but required by CNI
plugins running in system namespaces._

---

#### 5.2.9: Minimize the admission of containers with capabilities assigned (Manual)

**Result:** 🔵 Pass (Additional Configuration Required) (System Component Requirement)

_Added capabilities are restricted in baseline namespaces but system
components (CNI, CSI, KKP operators) require specific capabilities._

---

#### 5.2.10: Minimize the admission of Windows HostProcess containers (Manual)

**Result:** 🔵 Pass (Additional Configuration Required) (System Component Requirement)

_Capability assignment is restricted in baseline namespaces but system
components require specific capabilities to function._

---

#### 5.2.11: Minimize the admission of HostPath volumes (Manual)

**Result:** Manual — Operator Dependent

---

#### 5.2.12: Minimize the admission of containers which use HostPorts (Manual)

**Result:** 🔵 Pass (Additional Configuration Required) (System Component Requirement)

_HostPath volumes are blocked in baseline namespaces but required in system
namespaces by CNI plugins and CSI drivers._

---

### 5.3

#### 5.3.1: Ensure that the CNI in use supports NetworkPolicies (Manual)

**Result:** Manual — Operator Dependent

---

#### 5.3.2: Ensure that all Namespaces have NetworkPolicies defined (Manual)

**Result:** Manual — Operator Dependent

---

### 5.4

#### 5.4.1: Prefer using Secrets as files over Secrets as environment variables (Manual)

**Result:** Manual — Operator Dependent

---

#### 5.4.2: Consider external secret storage (Manual)

**Result:** Manual — Operator Dependent

---

### 5.5

#### 5.5.1: Configure Image Provenance using ImagePolicyWebhook admission controller (Manual)

**Result:** Manual — Operator Dependent

---

### 5.6

#### 5.6.1: Create administrative boundaries between resources using namespaces (Manual)

**Result:** Manual — Operator Dependent

---

#### 5.6.2: Ensure that the seccomp profile is set to docker/default in your Pod definitions (Manual)

**Result:** Manual — Operator Dependent

---

#### 5.6.3: Apply SecurityContext to your Pods and Containers (Manual)

**Result:** Manual — Operator Dependent

---

#### 5.6.4: The default namespace should not be used (Manual)

**Result:** Manual — Operator Dependent

---
