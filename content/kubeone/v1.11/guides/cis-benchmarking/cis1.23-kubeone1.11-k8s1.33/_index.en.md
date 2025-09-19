+++
title = "Benchmark on Kubernetes 1.33 with KubeOne 1.11.0"
date = 2025-09-19T16:02:37+02:00
+++

This guide helps you evaluate the security of a Kubernetes cluster created using KubeOne against each control in the CIS Kubernetes Benchmark.

This guide corresponds to the following versions of KubeOne, CIS Benchmarks, and Kubernetes:

| KubeOne Version  | Kubernetes Version | CIS Benchmark Version |
| ---------------- | ------------------ | --------------------- |
| 1.11.0               | 1.33.4                 | CIS-1.23                    |

## Testing Methodology

### Running the Benchmark

[Trivy](https://github.com/aquasecurity/trivy) was used to run the benchmark. Trivy runs [kube-bench](https://github.com/aquasecurity/kube-bench) under the hood and checks if the cluster meets the CIS Kubernetes Benchmark.

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

**Result:** 🟢 Pass

---

#### 1.1.2: Ensure that the API server pod specification file ownership is set to root:root

**Result:** 🟢 Pass

---

#### 1.1.3: Ensure that the controller manager pod specification file permissions are set to 600 or more restrictive

**Result:** 🟢 Pass

---

#### 1.1.4: Ensure that the controller manager pod specification file ownership is set to root:root

**Result:** 🟢 Pass

---

#### 1.1.5: Ensure that the scheduler pod specification file permissions are set to 600 or more restrictive

**Result:** 🟢 Pass

---

#### 1.1.6: Ensure that the scheduler pod specification file ownership is set to root:root

**Result:** 🟢 Pass

---

#### 1.1.7: Ensure that the etcd pod specification file permissions are set to 600 or more restrictive

**Result:** 🟢 Pass

---

#### 1.1.8: Ensure that the etcd pod specification file ownership is set to root:root

**Result:** 🟢 Pass

---

#### 1.1.9: Ensure that the Container Network Interface file permissions are set to 600 or more restrictive

**Result:** 🟢 Pass

---

#### 1.1.10: Ensure that the Container Network Interface file ownership is set to root:root

**Result:** 🟢 Pass

---

#### 1.1.11: Ensure that the etcd data directory permissions are set to 700 or more restrictive

**Result:** 🟢 Pass

---

#### 1.1.12: Ensure that the etcd data directory ownership is set to etcd:etcd

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 1.1.13: Ensure that the admin.conf file permissions are set to 600

**Result:** 🟢 Pass

---

#### 1.1.14: Ensure that the admin.conf file ownership is set to root:root

**Result:** 🟢 Pass

---

#### 1.1.15: Ensure that the scheduler.conf file permissions are set to 600 or more restrictive

**Result:** 🟢 Pass

---

#### 1.1.16: Ensure that the scheduler.conf file ownership is set to root:root

**Result:** 🟢 Pass

---

#### 1.1.17: Ensure that the controller-manager.conf file permissions are set to 600 or more restrictive

**Result:** 🟢 Pass

---

#### 1.1.18: Ensure that the controller-manager.conf file ownership is set to root:root

**Result:** 🟢 Pass

---

#### 1.1.19: Ensure that the Kubernetes PKI directory and file ownership is set to root:root

**Result:** 🟢 Pass

---

#### 1.1.20: Ensure that the Kubernetes PKI certificate file permissions are set to 600 or more restrictive

**Result:** 🟢 Pass

---

#### 1.1.21: Ensure that the Kubernetes PKI key file permissions are set to 600

**Result:** 🟢 Pass

---

### 1.2. API Server

#### 1.2.1: Ensure that the --anonymous-auth argument is set to false

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 1.2.2: Ensure that the --token-auth-file parameter is not set

**Result:** 🟢 Pass

---

#### 1.2.3: Ensure that the --DenyServiceExternalIPs is not set

**Result:** 🟢 Pass

---

#### 1.2.4: Ensure that the --kubelet-https argument is set to true

**Result:** 🟢 Pass

---

#### 1.2.5: Ensure that the --kubelet-client-certificate and --kubelet-client-key arguments are set as appropriate

**Result:** 🟢 Pass

---

#### 1.2.6: Ensure that the --kubelet-certificate-authority argument is set as appropriate

**Result:** 🟢 Pass

---

#### 1.2.7: Ensure that the --authorization-mode argument is not set to AlwaysAllow

**Result:** 🟢 Pass

---

#### 1.2.8: Ensure that the --authorization-mode argument includes Node

**Result:** 🟢 Pass

---

#### 1.2.9: Ensure that the --authorization-mode argument includes RBAC

**Result:** 🟢 Pass

---

#### 1.2.10: Ensure that the admission control plugin EventRateLimit is set

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 1.2.11: Ensure that the admission control plugin AlwaysAdmit is not set

**Result:** 🟢 Pass

---

#### 1.2.12: Ensure that the admission control plugin AlwaysPullImages is set

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 1.2.13: Ensure that the admission control plugin SecurityContextDeny is set if PodSecurityPolicy is not used

**Result:** 🟢 Pass

---

#### 1.2.14: Ensure that the admission control plugin ServiceAccount is set

**Result:** 🟢 Pass

---

#### 1.2.15: Ensure that the admission control plugin NamespaceLifecycle is set

**Result:** 🟢 Pass

---

#### 1.2.16: Ensure that the admission control plugin NodeRestriction is set

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 1.2.17: Ensure that the --secure-port argument is not set to 0

**Result:** 🟢 Pass

---

#### 1.2.18: Ensure that the --profiling argument is set to false

**Result:** 🟢 Pass

---

#### 1.2.19: Ensure that the --audit-log-path argument is set

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 1.2.20: Ensure that the --audit-log-maxage argument is set to 30 or as appropriate

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 1.2.21: Ensure that the --audit-log-maxbackup argument is set to 10 or as appropriate

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 1.2.22: Ensure that the --audit-log-maxsize argument is set to 100 or as appropriate

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 1.2.24: Ensure that the --service-account-lookup argument is set to true

**Result:** 🟢 Pass

---

#### 1.2.25: Ensure that the --service-account-key-file argument is set as appropriate

**Result:** 🟢 Pass

---

#### 1.2.26: Ensure that the --etcd-certfile and --etcd-keyfile arguments are set as appropriate

**Result:** 🟢 Pass

---

#### 1.2.27: Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate

**Result:** 🟢 Pass

---

#### 1.2.28: Ensure that the --client-ca-file argument is set appropriate

**Result:** 🟢 Pass

---

#### 1.2.29: Ensure that the --etcd-cafile argument is set as appropriate

**Result:** 🟢 Pass

---

#### 1.2.30: Ensure that the --encryption-provider-config argument is set as appropriate

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

### 1.3. Controller Manager

#### 1.3.1: Ensure that the --terminated-pod-gc-threshold argument is set as appropriate

**Result:** 🟢 Pass

---

#### 1.3.3: Ensure that the --use-service-account-credentials argument is set to true

**Result:** 🟢 Pass

---

#### 1.3.4: Ensure that the --service-account-private-key-file argument is set as appropriate

**Result:** 🟢 Pass

---

#### 1.3.5: Ensure that the --root-ca-file argument is set as appropriate

**Result:** 🟢 Pass

---

#### 1.3.6: Ensure that the RotateKubeletServerCertificate argument is set to true

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 1.3.7: Ensure that the --bind-address argument is set to 127.0.0.1

**Result:** 🟢 Pass

---

### 1.4. Scheduler

#### 1.4.1: Ensure that the --profiling argument is set to false

**Result:** 🟢 Pass

---

#### 1.4.2: Ensure that the --bind-address argument is set to 127.0.0.1

**Result:** 🟢 Pass

---

## Control Type: Etcd

#### 2.1: Ensure that the --cert-file and --key-file arguments are set as appropriate

**Result:** 🟢 Pass

---

#### 2.2: Ensure that the --client-cert-auth argument is set to true

**Result:** 🟢 Pass

---

#### 2.3: Ensure that the --auto-tls argument is not set to true

**Result:** 🟢 Pass

---

#### 2.4: Ensure that the --peer-cert-file and --peer-key-file arguments are set as appropriate

**Result:** 🟢 Pass

---

#### 2.5: Ensure that the --peer-client-cert-auth argument is set to true

**Result:** 🟢 Pass

---

#### 2.6: Ensure that the --peer-auto-tls argument is not set to true

**Result:** 🟢 Pass

---

## Control Type: Control Plane Configuration

### 3.1. Authentication and Authorization

#### 3.1.1: Client certificate authentication should not be used for users (Manual)

**Result:** Manual check required

---

### 3.2. Logging

#### 3.2.1: Ensure that a minimal audit policy is created (Manual)

**Result:** Manual check required

---

#### 3.2.2: Ensure that the audit policy covers key security concerns (Manual)

**Result:** Manual check required

---

## Control Type: Worker Nodes

### 4.1. Worker Node Configuration Files

#### 4.1.1: Ensure that the kubelet service file permissions are set to 600 or more restrictive

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 4.1.2: Ensure that the kubelet service file ownership is set to root:root

**Result:** 🟢 Pass

---

#### 4.1.3: If proxy kubeconfig file exists ensure permissions are set to 600 or more restrictive

**Result:** 🟢 Pass

---

#### 4.1.4: If proxy kubeconfig file exists ensure ownership is set to root:root

**Result:** 🟢 Pass

---

#### 4.1.5: Ensure that the --kubeconfig kubelet.conf file permissions are set to 600 or more restrictive

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 4.1.6: Ensure that the --kubeconfig kubelet.conf file ownership is set to root:root

**Result:** 🟢 Pass

---

#### 4.1.7: Ensure that the certificate authorities file permissions are set to 600 or more restrictive

**Result:** 🟢 Pass

---

#### 4.1.8: Ensure that the client certificate authorities file ownership is set to root:root

**Result:** 🟢 Pass

---

#### 4.1.9: If the kubelet config.yaml configuration file is being used validate permissions set to 600 or more restrictive

**Result:** 🟢 Pass

---

#### 4.1.10: If the kubelet config.yaml configuration file is being used validate file ownership is set to root:root

**Result:** 🟢 Pass

---

### 4.2. Kubelet

#### 4.2.1: Ensure that the --anonymous-auth argument is set to false

**Result:** 🟢 Pass

---

#### 4.2.2: Ensure that the --authorization-mode argument is not set to AlwaysAllow

**Result:** 🟢 Pass

---

#### 4.2.3: Ensure that the --client-ca-file argument is set as appropriate

**Result:** 🟢 Pass

---

#### 4.2.4: Verify that the --read-only-port argument is set to 0

**Result:** 🟢 Pass

---

#### 4.2.5: Ensure that the --streaming-connection-idle-timeout argument is not set to 0

**Result:** 🟢 Pass

---

#### 4.2.6: Ensure that the --protect-kernel-defaults argument is set to true

**Result:** 🟢 Pass

---

#### 4.2.7: Ensure that the --make-iptables-util-chains argument is set to true

**Result:** 🟢 Pass

---

#### 4.2.8: Ensure that the --hostname-override argument is not set

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 4.2.9: Ensure that the --event-qps argument is set to 0 or a level which ensures appropriate event capture

**Result:** 🟢 Pass

---

#### 4.2.10: Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 4.2.11: Ensure that the --rotate-certificates argument is not set to false

**Result:** 🟢 Pass

---

#### 4.2.12: Verify that the RotateKubeletServerCertificate argument is set to true

**Result:** 🟢 Pass

---

#### 4.2.13: Ensure that the Kubelet only makes use of Strong Cryptographic Ciphers

**Result:** 🟢 Pass

---

## Control Type: Policies

### 5.1. RBAC and Service Accounts

#### 5.1.1: Ensure that the cluster-admin role is only used where required

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 5.1.2: Minimize access to secrets

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 5.1.3: Minimize wildcard use in Roles and ClusterRoles

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 5.1.6: Ensure that Service Account Tokens are only mounted where necessary

**Result:** 🟢 Pass

---

#### 5.1.8: Limit use of the Bind, Impersonate and Escalate permissions in the Kubernetes cluster

**Result:** 🟢 Pass

---

### 5.2. Pod Security Standards

#### 5.2.2: Minimize the admission of privileged containers

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 5.2.3: Minimize the admission of containers wishing to share the host process ID namespace

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 5.2.4: Minimize the admission of containers wishing to share the host IPC namespace

**Result:** 🟢 Pass

---

#### 5.2.5: Minimize the admission of containers wishing to share the host network namespace

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 5.2.6: Minimize the admission of containers with allowPrivilegeEscalation

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 5.2.7: Minimize the admission of root containers

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 5.2.8: Minimize the admission of containers with the NET_RAW capability

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 5.2.9: Minimize the admission of containers with added capabilities

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 5.2.10: Minimize the admission of containers with capabilities assigned

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 5.2.11: Minimize the admission of containers with capabilities assigned

**Result:** 🟢 Pass

---

#### 5.2.12: Minimize the admission of HostPath volumes

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 5.2.13: Minimize the admission of containers which use HostPorts

**Result:** 🟢 Pass

---

### 5.3. Network Policies and CNI

#### 5.3.1: Ensure that the CNI in use supports Network Policies (Manual)

**Result:** Manual check required

---

#### 5.3.2: Ensure that all Namespaces have Network Policies defined

**Result:** 🟢 Pass

---

### 5.4. Secrets Management

#### 5.4.1: Prefer using secrets as files over secrets as environment variables (Manual)

**Result:** Manual check required

---

#### 5.4.2: Consider external secret storage (Manual)

**Result:** Manual check required

---

### 5.5. Extensible Admission Control

#### 5.5.1: Configure Image Provenance using ImagePolicyWebhook admission controller (Manual)

**Result:** Manual check required

---

### 5.7. General Policies

#### 5.7.1: Create administrative boundaries between resources using namespaces (Manual)

**Result:** Manual check required

---

#### 5.7.2: Ensure that the seccomp profile is set to docker/default in your pod definitions

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 5.7.3: Apply Security Context to Your Pods and Containers

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---

#### 5.7.4: The default namespace should not be used

**Result:** 🟢 Pass

---

## References

[audit-logging]: {{< ref "../../../tutorials/creating-clusters-oidc/#audit-logging" >}}
[encryption-providers]: {{< ref "../../../guides/encryption-providers/" >}}
[oidc]: {{< ref "../../../tutorials/creating-clusters-oidc/" >}}
[anon-req]: <https://kubernetes.io/docs/reference/access-authn-authz/authentication/#anonymous-requests>
[eventratelimit]: <https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#eventratelimit>
[securitycontextdeny]: <https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#securitycontextdeny>
