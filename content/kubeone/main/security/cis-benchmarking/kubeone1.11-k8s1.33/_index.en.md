+++
title = "Benchmark on Kubernetes 1.33 with KubeOne 1.11.2"
date = 2025-09-19T16:39:34+02:00
+++

This guide helps you evaluate the security of a Kubernetes cluster created using KubeOne against each control in the CIS Kubernetes Benchmark.

This guide corresponds to the following versions of KubeOne, CIS Benchmarks, and Kubernetes:

| KubeOne Version  | Kubernetes Version | CIS Benchmark Version |
| ---------------- | ------------------ | --------------------- |
| 1.11.2               | 1.33.4                 | CIS-1.23                    |

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

🔴 **Fail:** The audit/control will be fixed in a future KubeOne release.

## Control Type: Control Plane Components

### 1.1. Control Plane Node Configuration Files

#### 1.1.1: Ensure that the API server pod specification file permissions are set to 600 or more restrictive

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.1.2: Ensure that the API server pod specification file ownership is set to root:root

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.1.3: Ensure that the controller manager pod specification file permissions are set to 600 or more restrictive

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.1.4: Ensure that the controller manager pod specification file ownership is set to root:root

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.1.5: Ensure that the scheduler pod specification file permissions are set to 600 or more restrictive

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.1.6: Ensure that the scheduler pod specification file ownership is set to root:root

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.1.7: Ensure that the etcd pod specification file permissions are set to 600 or more restrictive

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.1.8: Ensure that the etcd pod specification file ownership is set to root:root

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.1.9: Ensure that the Container Network Interface file permissions are set to 600 or more restrictive

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.1.10: Ensure that the Container Network Interface file ownership is set to root:root

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.1.11: Ensure that the etcd data directory permissions are set to 700 or more restrictive

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.1.12: Ensure that the etcd data directory ownership is set to etcd:etcd

**Severity:** LOW

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 1.1.13: Ensure that the admin.conf file permissions are set to 600

**Severity:** CRITICAL

**Result:** 🟢 Pass

---

#### 1.1.14: Ensure that the admin.conf file ownership is set to root:root

**Severity:** CRITICAL

**Result:** 🟢 Pass

---

#### 1.1.15: Ensure that the scheduler.conf file permissions are set to 600 or more restrictive

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.1.16: Ensure that the scheduler.conf file ownership is set to root:root

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.1.17: Ensure that the controller-manager.conf file permissions are set to 600 or more restrictive

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.1.18: Ensure that the controller-manager.conf file ownership is set to root:root

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.1.19: Ensure that the Kubernetes PKI directory and file ownership is set to root:root

**Severity:** CRITICAL

**Result:** 🟢 Pass

---

#### 1.1.20: Ensure that the Kubernetes PKI certificate file permissions are set to 600 or more restrictive

**Severity:** CRITICAL

**Result:** 🟢 Pass

---

#### 1.1.21: Ensure that the Kubernetes PKI key file permissions are set to 600

**Severity:** CRITICAL

**Result:** 🟢 Pass

---

### 1.2. API Server

#### 1.2.1: Ensure that the --anonymous-auth argument is set to false

**Severity:** MEDIUM

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 1.2.2: Ensure that the --token-auth-file parameter is not set

**Severity:** LOW

**Result:** 🟢 Pass

---

#### 1.2.3: Ensure that the --DenyServiceExternalIPs is not set

**Severity:** LOW

**Result:** 🟢 Pass

---

#### 1.2.4: Ensure that the --kubelet-https argument is set to true

**Severity:** LOW

**Result:** 🟢 Pass

---

#### 1.2.5: Ensure that the --kubelet-client-certificate and --kubelet-client-key arguments are set as appropriate

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.2.6: Ensure that the --kubelet-certificate-authority argument is set as appropriate

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.2.7: Ensure that the --authorization-mode argument is not set to AlwaysAllow

**Severity:** LOW

**Result:** 🟢 Pass

---

#### 1.2.8: Ensure that the --authorization-mode argument includes Node

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.2.9: Ensure that the --authorization-mode argument includes RBAC

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.2.10: Ensure that the admission control plugin EventRateLimit is set

**Severity:** HIGH

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 1.2.11: Ensure that the admission control plugin AlwaysAdmit is not set

**Severity:** LOW

**Result:** 🟢 Pass

---

#### 1.2.12: Ensure that the admission control plugin AlwaysPullImages is set

**Severity:** MEDIUM

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 1.2.13: Ensure that the admission control plugin SecurityContextDeny is set if PodSecurityPolicy is not used

**Severity:** MEDIUM

**Result:** 🟢 Pass

---

#### 1.2.14: Ensure that the admission control plugin ServiceAccount is set

**Severity:** LOW

**Result:** 🟢 Pass

---

#### 1.2.15: Ensure that the admission control plugin NamespaceLifecycle is set

**Severity:** LOW

**Result:** 🟢 Pass

---

#### 1.2.16: Ensure that the admission control plugin NodeRestriction is set

**Severity:** LOW

**Result:** 🟢 Pass

---

#### 1.2.17: Ensure that the --secure-port argument is not set to 0

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 1.2.18: Ensure that the --profiling argument is set to false

**Severity:** LOW

**Result:** 🟢 Pass

---

#### 1.2.19: Ensure that the --audit-log-path argument is set

**Severity:** LOW

**Result:** 🔵 Pass (Additional Configuration Required)

**Details:** Audit logging is not enabled by default, it can be configured as described [here][audit-logging]

---

#### 1.2.20: Ensure that the --audit-log-maxage argument is set to 30 or as appropriate

**Severity:** LOW

**Result:** 🔵 Pass (Additional Configuration Required)

**Details:** Audit logging is not enabled by default, it can be configured as described [here][audit-logging]

---

#### 1.2.21: Ensure that the --audit-log-maxbackup argument is set to 10 or as appropriate

**Severity:** LOW

**Result:** 🔵 Pass (Additional Configuration Required)

**Details:** Audit logging is not enabled by default, it can be configured as described [here][audit-logging]

---

#### 1.2.22: Ensure that the --audit-log-maxsize argument is set to 100 or as appropriate

**Severity:** LOW

**Result:** 🔵 Pass (Additional Configuration Required)

**Details:** Audit logging is not enabled by default, it can be configured as described [here][audit-logging]

---

#### 1.2.24: Ensure that the --service-account-lookup argument is set to true

**Severity:** LOW

**Result:** 🟢 Pass

---

#### 1.2.25: Ensure that the --service-account-key-file argument is set as appropriate

**Severity:** LOW

**Result:** 🟢 Pass

---

#### 1.2.26: Ensure that the --etcd-certfile and --etcd-keyfile arguments are set as appropriate

**Severity:** LOW

**Result:** 🟢 Pass

---

#### 1.2.27: Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate

**Severity:** MEDIUM

**Result:** 🟢 Pass

---

#### 1.2.28: Ensure that the --client-ca-file argument is set appropriate

**Severity:** LOW

**Result:** 🟢 Pass

---

#### 1.2.29: Ensure that the --etcd-cafile argument is set as appropriate

**Severity:** LOW

**Result:** 🟢 Pass

---

#### 1.2.30: Ensure that the --encryption-provider-config argument is set as appropriate

**Severity:** LOW

**Result:** 🔵 Pass (Additional Configuration Required)

**Details:** Encryption configuration can be enabled as described [here][encryption-providers]

---

### 1.3. Controller Manager

#### 1.3.1: Ensure that the --terminated-pod-gc-threshold argument is set as appropriate

**Severity:** MEDIUM

**Result:** 🟢 Pass

---

#### 1.3.3: Ensure that the --use-service-account-credentials argument is set to true

**Severity:** MEDIUM

**Result:** 🟢 Pass

---

#### 1.3.4: Ensure that the --service-account-private-key-file argument is set as appropriate

**Severity:** MEDIUM

**Result:** 🟢 Pass

---

#### 1.3.5: Ensure that the --root-ca-file argument is set as appropriate

**Severity:** MEDIUM

**Result:** 🟢 Pass

---

#### 1.3.6: Ensure that the RotateKubeletServerCertificate argument is set to true

**Severity:** MEDIUM

**Result:** 🟢 Pass

---

#### 1.3.7: Ensure that the --bind-address argument is set to 127.0.0.1

**Severity:** LOW

**Result:** 🟢 Pass

---

### 1.4. Scheduler

#### 1.4.1: Ensure that the --profiling argument is set to false

**Severity:** MEDIUM

**Result:** 🟢 Pass

---

#### 1.4.2: Ensure that the --bind-address argument is set to 127.0.0.1

**Severity:** CRITICAL

**Result:** 🟢 Pass

---

## Control Type: Etcd

#### 2.1: Ensure that the --cert-file and --key-file arguments are set as appropriate

**Severity:** MEDIUM

**Result:** 🟢 Pass

---

#### 2.2: Ensure that the --client-cert-auth argument is set to true

**Severity:** CRITICAL

**Result:** 🟢 Pass

---

#### 2.3: Ensure that the --auto-tls argument is not set to true

**Severity:** CRITICAL

**Result:** 🟢 Pass

---

#### 2.4: Ensure that the --peer-cert-file and --peer-key-file arguments are set as appropriate

**Severity:** CRITICAL

**Result:** 🟢 Pass

---

#### 2.5: Ensure that the --peer-client-cert-auth argument is set to true

**Severity:** CRITICAL

**Result:** 🟢 Pass

---

#### 2.6: Ensure that the --peer-auto-tls argument is not set to true

**Severity:** HIGH

**Result:** 🟢 Pass

---

## Control Type: Control Plane Configuration

### 3.1. Authentication and Authorization

#### 3.1.1: Client certificate authentication should not be used for users (Manual)

**Severity:** HIGH

**Result:** 🔵 Pass (Additional Configuration Required)

**Details:** KubeOne can be configured with OIDC authentication as described [here][oidc]

---

### 3.2. Logging

#### 3.2.1: Ensure that a minimal audit policy is created (Manual)

**Severity:** HIGH

**Result:** 🔵 Pass (Additional Configuration Required)

**Details:** Audit logging is not enabled by default, it can be configured as described [here][audit-logging]

---

#### 3.2.2: Ensure that the audit policy covers key security concerns (Manual)

**Severity:** HIGH

**Result:** 🔵 Pass (Additional Configuration Required)

**Details:** Audit logging is not enabled by default, it can be configured as described [here][audit-logging]

---

## Control Type: Worker Nodes

### 4.1. Worker Node Configuration Files

#### 4.1.1: Ensure that the kubelet service file permissions are set to 600 or more restrictive

**Severity:** HIGH

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

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

_The issue is under investigation to provide a fix in a future KubeOne release_

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

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 4.2.9: Ensure that the --event-qps argument is set to 0 or a level which ensures appropriate event capture

**Severity:** HIGH

**Result:** 🟢 Pass

---

#### 4.2.10: Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate

**Severity:** CRITICAL

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

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

**Result:** 🔵 Pass (Expected Behavior)

---

#### 5.1.2: Minimize access to secrets

**Severity:** HIGH

**Result:** 🔵 Pass (Expected Behavior)

---

#### 5.1.3: Minimize wildcard use in Roles and ClusterRoles

**Severity:** HIGH

**Result:** 🔵 Pass (Expected Behavior)

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

### 5.2. Pod Security Standards

The controls in this section are evaluated against the entire cluster. In a default KubeOne architecture, that includes `kube-system` workloads and static control-plane pods, so some results reflect required system components rather than user-workload policy.

#### 5.2.2: Minimize the admission of privileged containers

**Severity:** HIGH

**Result:** 🔵 Pass (Expected Cluster-Level Result)

**Details:** This cluster-level result is driven by privileged system components such as `canal`, `kube-proxy`, and CSI node plugins.

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

**Result:** 🔵 Pass (Expected Cluster-Level Result)

**Details:** This cluster-level result is driven by system networking and control-plane components that run with `hostNetwork`, including `canal`, `kube-proxy`, `node-local-dns`, and static control-plane pods.

---

#### 5.2.6: Minimize the admission of containers with allowPrivilegeEscalation

**Severity:** HIGH

**Result:** 🔵 Pass (Expected Cluster-Level Result)

**Details:** This cluster-level result is reported for a mix of `kube-system` and static control-plane components that Trivy evaluates together under this control.

---

#### 5.2.7: Minimize the admission of root containers

**Severity:** MEDIUM

**Result:** 🔵 Pass (Expected Cluster-Level Result)

**Details:** This cluster-level result is reported for system components in `kube-system` and the static control plane, some of which run as root or use upstream-default runtime users.

---

#### 5.2.8: Minimize the admission of containers with the NET_RAW capability

**Severity:** MEDIUM

**Result:** 🔵 Pass (Expected Cluster-Level Result)

**Details:** This cluster-level result is reported for DNS and networking components that Trivy flags under this capability control, including `node-local-dns` and `coredns`.

---

#### 5.2.9: Minimize the admission of containers with added capabilities

**Severity:** LOW

**Result:** 🔵 Pass (Expected Cluster-Level Result)

**Details:** This cluster-level result is reported for networking, storage, and control-plane components that retain additional Linux capabilities in their rendered manifests.

---

#### 5.2.10: Minimize the admission of containers with capabilities assigned

**Severity:** LOW

**Result:** 🔵 Pass (Expected Cluster-Level Result)

**Details:** This cluster-level result is reported for system components that retain explicitly assigned capabilities in support of networking, storage, DNS, or control-plane functions.

---

#### 5.2.11: Minimize the admission of containers with capabilities assigned

**Severity:** MEDIUM

**Result:** 🟢 Pass

---

#### 5.2.12: Minimize the admission of HostPath volumes

**Severity:** MEDIUM

**Result:** 🔵 Pass (Expected Cluster-Level Result)

**Details:** This cluster-level result is driven by CNI, CSI, DNS, and control-plane components that mount `hostPath` volumes for node-level configuration, manifests, certificates, or socket access.

---

#### 5.2.13: Minimize the admission of containers which use HostPorts

**Severity:** MEDIUM

**Result:** 🟢 Pass

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

**Result:** 🔵 Pass (Expected Cluster-Level Result)

**Details:** This cluster-level result is reported for system components in `kube-system` and static control-plane pods that do not all declare an explicit seccomp profile in their rendered manifests.

---

#### 5.7.3: Apply Security Context to Your Pods and Containers

**Severity:** HIGH

**Result:** 🔵 Pass (Expected Cluster-Level Result)

**Details:** This cluster-level result is reported for system components that use security-context exceptions or inherit upstream runtime defaults in `kube-system` and the control plane.

---

#### 5.7.4: The default namespace should not be used

**Severity:** MEDIUM

**Result:** 🟢 Pass

---

## References

[audit-logging]: {{< ref "../../../tutorials/creating-clusters-oidc/#audit-logging" >}}
[encryption-providers]: {{< ref "../../../guides/encryption-providers/" >}}
[oidc]: {{< ref "../../../tutorials/creating-clusters-oidc/" >}}
[anon-req]: <https://kubernetes.io/docs/reference/access-authn-authz/authentication/#anonymous-requests>
[eventratelimit]: <https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#eventratelimit>
[securitycontextdeny]: <https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#securitycontextdeny>
