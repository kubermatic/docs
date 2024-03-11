+++
title = "Benchmark on KubeOne-1.7.3 and Kubernetes-1.27"
date = 2024-03-06T12:01:00+02:00
+++

This benchmark guide helps you evaluate the security of a KubeOne cluster against each control in the CIS Kubernetes Benchmark.

This guide corresponds to the following versions of KubeOne, CIS Benchmarks, and Kubernetes:

| KubeOne Version  | Kubernetes Version | CIS Benchmark Version |
| ---------------- | ------------------ | --------------------- |
| 1.7.3               | 1.27                 | CIS-1.8                    |

## Testing Methodology

Each control in the CIS Kubernetes Benchmark was evaluated against a KubeOne cluster that was configured according to the accompanying hardening guide.

These are the possible results for each control:

**Pass:** The KubeOne cluster passes the audit outlined in the benchmark.

**Not Applicable:** The control is not applicable to KubeOne because of how it is designed to operate. Details are provided for it.

**Warn:** The control is manual in the CIS benchmark and it depends on the cluster's use-case or some other factor that must be determined by the cluster operator. These controls have been evaluated to ensure KubeOne doesn't prevent their implementation, but no further configuration or auditing of the cluster has been performed.

**Fail:** The control will be fixed in a future KubeOne release.

## Control Type: master
### 1.1. Control Plane Node Configuration Files
#### 1.1.1: Ensure that the API server pod specification file permissions are set to 600 or more restrictive (Automated)

**Result:** 🟢 Pass

---
#### 1.1.2: Ensure that the API server pod specification file ownership is set to root:root (Automated)

**Result:** 🟢 Pass

---
#### 1.1.3: Ensure that the controller manager pod specification file permissions are set to 600 or more restrictive (Automated)

**Result:** 🟢 Pass

---
#### 1.1.4: Ensure that the controller manager pod specification file ownership is set to root:root (Automated)

**Result:** 🟢 Pass

---
#### 1.1.5: Ensure that the scheduler pod specification file permissions are set to 600 or more restrictive (Automated)

**Result:** 🟢 Pass

---
#### 1.1.6: Ensure that the scheduler pod specification file ownership is set to root:root (Automated)

**Result:** 🟢 Pass

---
#### 1.1.7: Ensure that the etcd pod specification file permissions are set to 600 or more restrictive (Automated)

**Result:** 🟢 Pass

---
#### 1.1.8: Ensure that the etcd pod specification file ownership is set to root:root (Automated)

**Result:** 🟢 Pass

---
#### 1.1.9: Ensure that the Container Network Interface file permissions are set to 600 or more restrictive (Manual)

**Result:** 🟡 Warn

_The issue is under investigation to provide a fix in a future KubeOne release_

---
#### 1.1.10: Ensure that the Container Network Interface file ownership is set to root:root (Manual)

**Result:** 🟢 Pass

---
#### 1.1.11: Ensure that the etcd data directory permissions are set to 700 or more restrictive (Automated)

**Result:** 🟢 Pass

---
#### 1.1.12: Ensure that the etcd data directory ownership is set to etcd:etcd (Automated)

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---
#### 1.1.13: Ensure that the admin.conf file permissions are set to 600 or more restrictive (Automated)

**Result:** 🟢 Pass

---
#### 1.1.14: Ensure that the admin.conf file ownership is set to root:root (Automated)

**Result:** 🟢 Pass

---
#### 1.1.15: Ensure that the scheduler.conf file permissions are set to 600 or more restrictive (Automated)

**Result:** 🟢 Pass

---
#### 1.1.16: Ensure that the scheduler.conf file ownership is set to root:root (Automated)

**Result:** 🟢 Pass

---
#### 1.1.17: Ensure that the controller-manager.conf file permissions are set to 600 or more restrictive (Automated)

**Result:** 🟢 Pass

---
#### 1.1.18: Ensure that the controller-manager.conf file ownership is set to root:root (Automated)

**Result:** 🟢 Pass

---
#### 1.1.19: Ensure that the Kubernetes PKI directory and file ownership is set to root:root (Automated)

**Result:** 🟢 Pass

---
#### 1.1.20: Ensure that the Kubernetes PKI certificate file permissions are set to 600 or more restrictive (Manual)

**Result:** 🟢 Pass

---
#### 1.1.21: Ensure that the Kubernetes PKI key file permissions are set to 600 (Manual)

**Result:** 🟢 Pass

---
### 1.2. API Server
#### 1.2.1: Ensure that the --anonymous-auth argument is set to false (Manual)

**Result:** 🔵 Not Applicable

**Details:** This is mitigated by RBAC, please see https://kubernetes.io/docs/reference/access-authn-authz/authentication/#anonymous-requests

---
#### 1.2.2: Ensure that the --token-auth-file parameter is not set (Automated)

**Result:** 🟢 Pass

---
#### 1.2.3: Ensure that the --DenyServiceExternalIPs is set (Manual)

**Result:** 🔵 Not Applicable

**Details:** When DenyServiceExternalIPs is enabled, users of the cluster may not create new Services which use externalIPs and may not add new values to externalIPs on existing Service objects. It is not enabled by default, and it is not in the enabled plugins list

---
#### 1.2.4: Ensure that the --kubelet-client-certificate and --kubelet-client-key arguments are set as appropriate (Automated)

**Result:** 🟢 Pass

---
#### 1.2.5: Ensure that the --kubelet-certificate-authority argument is set as appropriate (Automated)

**Result:** 🟢 Pass

---
#### 1.2.6: Ensure that the --authorization-mode argument is not set to AlwaysAllow (Automated)

**Result:** 🟢 Pass

---
#### 1.2.7: Ensure that the --authorization-mode argument includes Node (Automated)

**Result:** 🟢 Pass

---
#### 1.2.8: Ensure that the --authorization-mode argument includes RBAC (Automated)

**Result:** 🟢 Pass

---
#### 1.2.9: Ensure that the admission control plugin EventRateLimit is set (Manual)

**Result:** 🔵 Not Applicable

**Details:** EventRateLimit admission control plugin in in Alpha state, please see https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#eventratelimit

---
#### 1.2.10: Ensure that the admission control plugin AlwaysAdmit is not set (Automated)

**Result:** 🟢 Pass

---
#### 1.2.11: Ensure that the admission control plugin AlwaysPullImages is set (Manual)

**Result:** 🔵 Not Applicable

**Details:** AlwaysPullImages admission control will force all images to be pulled every time, it's not efficient for all users. This can be performed by a Kyverno or OPA policy

---
#### 1.2.12: Ensure that the admission control plugin SecurityContextDeny is set if PodSecurityPolicy is not used (Manual)

**Result:** 🔵 Not Applicable

**Details:** SecurityContextDeny admission control plugin is deprecated as of Kubernetes 1.27: https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#securitycontextdeny

---
#### 1.2.13: Ensure that the admission control plugin ServiceAccount is set (Automated)

**Result:** 🟢 Pass

---
#### 1.2.14: Ensure that the admission control plugin NamespaceLifecycle is set (Automated)

**Result:** 🟢 Pass

---
#### 1.2.15: Ensure that the admission control plugin NodeRestriction is set (Automated)

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---
#### 1.2.16: Ensure that the --profiling argument is set to false (Automated)

**Result:** 🟢 Pass

---
#### 1.2.17: Ensure that the --audit-log-path argument is set (Automated)

**Result:** 🟠 Configurable

**Details:** Audit logging is not enabled by default, it can be configured as described here: https://docs.kubermatic.com/kubeone/v1.7/tutorials/creating-clusters-oidc/#audit-logging

---
#### 1.2.18: Ensure that the --audit-log-maxage argument is set to 30 or as appropriate (Automated)

**Result:** 🟠 Configurable

**Details:** Audit logging is not enabled by default, it can be configured as described here: https://docs.kubermatic.com/kubeone/v1.7/tutorials/creating-clusters-oidc/#audit-logging

---
#### 1.2.19: Ensure that the --audit-log-maxbackup argument is set to 10 or as appropriate (Automated)

**Result:** 🟠 Configurable

**Details:** Audit logging is not enabled by default, it can be configured as described here: https://docs.kubermatic.com/kubeone/v1.7/tutorials/creating-clusters-oidc/#audit-logging

---
#### 1.2.20: Ensure that the --audit-log-maxsize argument is set to 100 or as appropriate (Automated)

**Result:** 🟠 Configurable

**Details:** Audit logging is not enabled by default, it can be configured as described here: https://docs.kubermatic.com/kubeone/v1.7/tutorials/creating-clusters-oidc/#audit-logging

---
#### 1.2.21: Ensure that the --request-timeout argument is set as appropriate (Manual)

**Result:** 🔵 Not Applicable

**Details:** By default it's 60 seconds. Setting this timeout limit to be too large can exhaust the API server resources making it prone to Denial-of-Service attack. Hence, it is recommended to set this limit as appropriate and change the default limit of 60 seconds only if needed

---
#### 1.2.22: Ensure that the --service-account-lookup argument is set to true (Automated)

**Result:** 🟢 Pass

---
#### 1.2.23: Ensure that the --service-account-key-file argument is set as appropriate (Automated)

**Result:** 🟢 Pass

---
#### 1.2.24: Ensure that the --etcd-certfile and --etcd-keyfile arguments are set as appropriate (Automated)

**Result:** 🟢 Pass

---
#### 1.2.25: Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate (Automated)

**Result:** 🟢 Pass

---
#### 1.2.26: Ensure that the --client-ca-file argument is set as appropriate (Automated)

**Result:** 🟢 Pass

---
#### 1.2.27: Ensure that the --etcd-cafile argument is set as appropriate (Automated)

**Result:** 🟢 Pass

---
#### 1.2.28: Ensure that the --encryption-provider-config argument is set as appropriate (Manual)

**Result:** 🟠 Configurable

**Details:** Encryption configuration can be enabled as described here: https://docs.kubermatic.com/kubeone/v1.7/guides/encryption-providers/

---
#### 1.2.29: Ensure that encryption providers are appropriately configured (Manual)

**Result:** 🟠 Configurable

**Details:** Encryption configuration can be enabled as described here: https://docs.kubermatic.com/kubeone/v1.7/guides/encryption-providers/

---
#### 1.2.30: Ensure that the API Server only makes use of Strong Cryptographic Ciphers (Manual)

**Result:** 🟢 Pass

---
### 1.3. Controller Manager
#### 1.3.1: Ensure that the --terminated-pod-gc-threshold argument is set as appropriate (Manual)

**Result:** 🟢 Pass

---
#### 1.3.2: Ensure that the --profiling argument is set to false (Automated)

**Result:** 🟢 Pass

---
#### 1.3.3: Ensure that the --use-service-account-credentials argument is set to true (Automated)

**Result:** 🟢 Pass

---
#### 1.3.4: Ensure that the --service-account-private-key-file argument is set as appropriate (Automated)

**Result:** 🟢 Pass

---
#### 1.3.5: Ensure that the --root-ca-file argument is set as appropriate (Automated)

**Result:** 🟢 Pass

---
#### 1.3.6: Ensure that the RotateKubeletServerCertificate argument is set to true (Automated)

**Result:** 🟢 Pass

---
#### 1.3.7: Ensure that the --bind-address argument is set to 127.0.0.1 (Automated)

**Result:** 🟢 Pass

---
### 1.4. Scheduler
#### 1.4.1: Ensure that the --profiling argument is set to false (Automated)

**Result:** 🟢 Pass

---
#### 1.4.2: Ensure that the --bind-address argument is set to 127.0.0.1 (Automated)

**Result:** 🟢 Pass

---
## Control Type: etcd
### 2. Etcd Node Configuration
#### 2.1: Ensure that the --cert-file and --key-file arguments are set as appropriate (Automated)

**Result:** 🟢 Pass

---
#### 2.2: Ensure that the --client-cert-auth argument is set to true (Automated)

**Result:** 🟢 Pass

---
#### 2.3: Ensure that the --auto-tls argument is not set to true (Automated)

**Result:** 🟢 Pass

---
#### 2.4: Ensure that the --peer-cert-file and --peer-key-file arguments are set as appropriate (Automated)

**Result:** 🟢 Pass

---
#### 2.5: Ensure that the --peer-client-cert-auth argument is set to true (Automated)

**Result:** 🟢 Pass

---
#### 2.6: Ensure that the --peer-auto-tls argument is not set to true (Automated)

**Result:** 🟢 Pass

---
#### 2.7: Ensure that a unique Certificate Authority is used for etcd (Manual)

**Result:** 🟢 Pass

---
## Control Type: controlplane
### 3.1. Authentication and Authorization
#### 3.1.1: Client certificate authentication should not be used for users (Manual)

**Result:** 🟠 Configurable

**Details:** KubeOne can be configured with OIDC authentication: https://docs.kubermatic.com/kubeone/v1.7/tutorials/creating-clusters-oidc/

---
#### 3.1.2: Service account token authentication should not be used for users (Manual)

**Result:** 🟠 Configurable

**Details:** KubeOne can be configured with OIDC authentication: https://docs.kubermatic.com/kubeone/v1.7/tutorials/creating-clusters-oidc/

---
#### 3.1.3: Bootstrap token authentication should not be used for users (Manual)

**Result:** 🟠 Configurable

**Details:** KubeOne can be configured with OIDC authentication: https://docs.kubermatic.com/kubeone/v1.7/tutorials/creating-clusters-oidc/

---
### 3.2. Logging
#### 3.2.1: Ensure that a minimal audit policy is created (Manual)

**Result:** 🟠 Configurable

**Details:** Audit logging is not enabled by default, it can be configured as described here: https://docs.kubermatic.com/kubeone/v1.7/tutorials/creating-clusters-oidc/#audit-logging

---
#### 3.2.2: Ensure that the audit policy covers key security concerns (Manual)

**Result:** 🟠 Configurable

**Details:** Audit logging is not enabled by default, it can be configured as described here: https://docs.kubermatic.com/kubeone/v1.7/tutorials/creating-clusters-oidc/#audit-logging

---
## Control Type: node
### 4.1. Worker Node Configuration Files
#### 4.1.1: Ensure that the kubelet service file permissions are set to 600 or more restrictive (Automated)

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---
#### 4.1.2: Ensure that the kubelet service file ownership is set to root:root (Automated)

**Result:** 🟢 Pass

---
#### 4.1.3: If proxy kubeconfig file exists ensure permissions are set to 600 or more restrictive (Manual)

**Result:** 🔵 Not Applicable

**Details:** KubeOne does not contain `/etc/kubernetes/proxy.conf` file

---
#### 4.1.4: If proxy kubeconfig file exists ensure ownership is set to root:root (Manual)

**Result:** 🔵 Not Applicable

**Details:** KubeOne does not contain `/etc/kubernetes/proxy.conf` file

---
#### 4.1.5: Ensure that the --kubeconfig kubelet.conf file permissions are set to 600 or more restrictive (Automated)

**Result:** 🟢 Pass

---
#### 4.1.6: Ensure that the --kubeconfig kubelet.conf file ownership is set to root:root (Automated)

**Result:** 🟢 Pass

---
#### 4.1.7: Ensure that the certificate authorities file permissions are set to 600 or more restrictive (Manual)

**Result:** 🟢 Pass

---
#### 4.1.8: Ensure that the client certificate authorities file ownership is set to root:root (Manual)

**Result:** 🟢 Pass

---
#### 4.1.9: If the kubelet config.yaml configuration file is being used validate permissions set to 600 or more restrictive (Automated)

**Result:** 🔴 Fail

_The issue is under investigation to provide a fix in a future KubeOne release_

---
#### 4.1.10: If the kubelet config.yaml configuration file is being used validate file ownership is set to root:root (Automated)

**Result:** 🟢 Pass

---
### 4.2. Kubelet
#### 4.2.1: Ensure that the --anonymous-auth argument is set to false (Automated)

**Result:** 🟢 Pass

---
#### 4.2.2: Ensure that the --authorization-mode argument is not set to AlwaysAllow (Automated)

**Result:** 🟢 Pass

---
#### 4.2.3: Ensure that the --client-ca-file argument is set as appropriate (Automated)

**Result:** 🟢 Pass

---
#### 4.2.4: Verify that the --read-only-port argument is set to 0 (Manual)

**Result:** 🟢 Pass

---
#### 4.2.5: Ensure that the --streaming-connection-idle-timeout argument is not set to 0 (Manual)

**Result:** 🟢 Pass

---
#### 4.2.6: Ensure that the --make-iptables-util-chains argument is set to true (Automated)

**Result:** 🟢 Pass

---
#### 4.2.7: Ensure that the --hostname-override argument is not set (Manual)

**Result:** 🟢 Pass

---
#### 4.2.8: Ensure that the eventRecordQPS argument is set to a level which ensures appropriate event capture (Manual)

**Result:** 🟢 Pass

---
#### 4.2.9: Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate (Manual)

**Result:** 🟢 Pass

**Details:** This is a manual check, `--tls-cert-file` and `--tls-private-key-file` options are provided to Kubelet

---
#### 4.2.10: Ensure that the --rotate-certificates argument is not set to false (Automated)

**Result:** 🟢 Pass

---
#### 4.2.11: Verify that the RotateKubeletServerCertificate argument is set to true (Manual)

**Result:** 🟢 Pass

---
#### 4.2.12: Ensure that the Kubelet only makes use of Strong Cryptographic Ciphers (Manual)

**Result:** 🟡 Warn

_The issue is under investigation to provide a fix in a future KubeOne release_

---
#### 4.2.13: Ensure that a limit is set on pod PIDs (Manual)

**Result:** 🟡 Warn

_The issue is under investigation to provide a fix in a future KubeOne release_

---
