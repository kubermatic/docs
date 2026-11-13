+++
title = "Personally Identifiable Information Analysis: Kubernetes and KubeOne System Logs"
date = 2024-03-06T12:00:00+02:00
weight = 10
+++

This document provides a comprehensive analysis of potential Personally Identifiable Information (PII) and personal data (indirect identifiers) that may be present in system logs from Kubernetes clusters deployed using KubeOne.

**Target Audience**: Platform operators, security teams, compliance officers

**Prerequisites**: Basic understanding of Kubernetes and KubeOne

While KubeOne inherently tries to avoid logging any PII, there are some cases where it is unavoidable and outside the control of the platform operator. This could be a component that KubeOne ships or the underlying Kubernetes components.

## PII Categories (GDPR-Aligned)

System logs from Kubernetes clusters may contain the following types of PII:

### Direct Identifiers

* **Usernames**: Kubernetes usernames, system usernames, service account names
* **Email addresses**: From TLS certificate subjects (CN, O, OU), OIDC claims, audit logs, or user labels
* **IP addresses**: Client IPs

### Indirect Identifiers

* **Resource names**: Pod names, namespace names, deployment names containing user/org identifiers
  * Example: `webapp-john-deployment`, `john-doe-dev` namespace
* **Hostnames**: Node hostnames with user or organizational patterns
  * Example: `worker-john-prod-01.company.com`
* **Labels and annotations**: Custom metadata that may include user data
  * Example: `owner=john.doe@company.com`
* **Volume paths**: Mount paths revealing directory structures with usernames
  * Example: `/home/john/data:/data`

### Cloud Provider Identifiers

* **Account IDs**: AWS account IDs, Azure subscription IDs, GCP project IDs
* **Resource IDs**: Instance IDs, VPC IDs, volume IDs, subnet IDs, security group IDs
* **DNS names**: Load balancer DNS, instance DNS names
* **Geographic data**: Availability zones, regions

### Operational Data That May Reveal personal data

* **DNS queries**: Service/pod names in DNS lookups
* **HTTP/gRPC metadata**: URLs, headers, cookies (if Layer 7 visibility enabled in CNI)
* **Error messages**: Often contain detailed context with resource IDs and user identifiers
* **Audit logs**: Comprehensive request/response data including full user context

## Risk Assessment Matrix

| Component | User Identity | IP Addresses | Credentials | Cloud IDs | Risk Level |
|-----------|---------------|--------------|-------------|-----------|------------|
| kube-apiserver | ✅ High | ✅ High | ✅ High | ❌ No | 🔴 **HIGH** |
| kubelet | ⚠️ Medium | ✅ High | ✅ High | ❌ No | 🔴 **HIGH** |
| etcd | ✅ High | ⚠️ Medium | ✅ High | ❌ No | 🔴 **HIGH** |
| Cloud Controller Managers | ❌ No | ✅ High | ✅ High | ✅ High | 🔴 **HIGH** |
| CSI Drivers | ❌ No | ⚠️ Medium | ✅ High | ✅ High | 🔴 **HIGH** |
| Secrets Store CSI | ❌ No | ❌ No | ✅ High | ⚠️ Low | 🔴 **HIGH** |
| Cilium | ⚠️ Medium | ✅ High | ❌ No | ❌ No | 🟡 **MEDIUM-HIGH** |
| kube-controller-manager | ⚠️ Low | ⚠️ Medium | ⚠️ Medium | ⚠️ Medium | 🟡 **MEDIUM** |
| kube-scheduler | ⚠️ Low | ❌ No | ❌ No | ❌ No | 🟡 **MEDIUM** |
| kube-proxy | ❌ No | ✅ High | ❌ No | ❌ No | 🟡 **MEDIUM** |
| CoreDNS | ⚠️ Low | ⚠️ Medium | ❌ No | ❌ No | 🟡 **MEDIUM** |
| Canal | ❌ No | ✅ High | ❌ No | ❌ No | 🟡 **MEDIUM** |
| WeaveNet | ❌ No | ✅ High | ⚠️ Low | ❌ No | 🟡 **MEDIUM** |
| cluster-autoscaler | ⚠️ Low | ⚠️ Low | ⚠️ Low | ✅ High | 🟡 **MEDIUM** |
| NodeLocalDNS | ⚠️ Low | ⚠️ Medium | ❌ No | ❌ No | 🟡 **MEDIUM** |
| metrics-server | ⚠️ Low | ❌ No | ❌ No | ❌ No | 🟢 **LOW-MEDIUM** |
| machine-controller | ⚠️ Low | ❌ No | ⚠️ Low | ✅ High | 🟢 **LOW** |
| operating-system-manager | ⚠️ Low | ❌ No | ❌ No | ⚠️ Low | 🟢 **LOW** |

**Legend**:

* ✅ High: Frequent and detailed PII exposure
* ⚠️ Medium: Moderate PII exposure
* ❌ No: Minimal or no PII exposure

### Understanding Risk Context

While the risk matrix provides a helpful overview of potential PII exposure, it is important to note that the risk is not always proportional to the exposure. For example, a low-risk component may have high exposure if it is combined with a high-risk component.

An example of this would be a component that logs a full Kubernetes resource in case of a validation failure. The Kubernetes resource itself may contain PII, and while the fields that might contain personal data are not directly being referred to in the logs, the full resource is being logged. This results in private data being exposed to the logs. It is always recommended to review and sanitize the logs before sharing them anywhere.

## Log Filtering and Sanitization

### Automated PII Filtering

Implement automated filtering in your log aggregation pipeline to remove PII and personal data from the logs.

#### Use external tools for PII Redaction

* [Presidio](https://microsoft.github.io/presidio/) - A set of tools for data protection and privacy
* [Azure Purview](https://learn.microsoft.com/en-us/purview/information-protection) - A cloud-based data governance service that helps you manage and protect your sensitive data

### Manual PII Filtering - Common patterns to filter

```regex
# Email addresses
[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}

# IPv4 addresses
\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b

# Basic Auth in URLs
https?://[^:]+:[^@]+@
```

## Best Practices

### Before sharing logs with Kubermatic Support

1. Identify the time range needed (minimize data exposure)
2. Export only relevant namespaces/components
3. Run PII redaction tool or scripts
4. Manual review of first 100 lines to verify redaction
5. Approval from data protection officer (if required)

## Conclusion

### Key Points

1. Kubernetes logs contain significant PII, especially from kube-apiserver, kubelet, etcd, and all cloud provider components
2. Higher log verbosity (v=4-5) dramatically increases PII exposure
3. Cloud provider account identifiers are prevalent in Cloud Controller Managers (CCMs) and CSI drivers
4. Automated filtering tools are essential for safe log sharing at scale
5. Manual review is still necessary to catch context-specific PII

### Best Practice for Support

## Additional Resources

### GDPR and Privacy

* [GDPR Official Text](https://gdpr-info.eu/)
* [Article 29 Working Party Opinion on Personal Data](https://ec.europa.eu/justice/article-29/documentation/opinion-recommendation/index_en.htm)
