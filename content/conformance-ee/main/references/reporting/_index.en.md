+++
title = "Reporting"
date = 2026-03-17T10:07:15+02:00
weight = 40
+++

Conformance EE provides two reporting mechanisms: **JUnit XML reports** for CI integration and **ConfigMap live reporting** for real-time test visibility.

## JUnit XML Reports

After each Ginkgo spec, a JUnit XML file is written to the configured `reportsRoot` directory. The XML structure reflects the Ginkgo `By()` steps within each spec as individual test cases.

### Report Structure

```
reports/
├── junit.with_kubernetes_1.31.1_and_ubuntu_22.04_and_canal.xml
├── junit.with_kubernetes_1.31.1_and_flatcar_3374.2.2_and_cilium.xml
└── ...
```

### CI Compatibility

JUnit XML files are compatible with:

| CI System | Configuration |
|-----------|---------------|
| GitHub Actions | `EnricoMi/publish-unit-test-result-action` |
| Jenkins | JUnit post-build action |
| GitLab CI | `artifacts.reports.junit` |
| Azure DevOps | PublishTestResults task |

## ConfigMap Live Reporting

While JUnit XML is only available after the suite completes, the ConfigMap reporter provides **live visibility** into test progress during execution.

### How It Works

After each spec on any Ginkgo node, results are patched into a shared Kubernetes ConfigMap using JSON merge patches. This is safe for concurrent writes from multiple Ginkgo nodes.

### ConfigMap Naming

```
conformance-reports-<project-name>
```

The name is sanitized to meet Kubernetes naming rules (lowercase, alphanumeric, hyphens only, max 253 characters).

### Spec Key Format

Each spec gets a unique key derived from SHA-256 of the spec's full text:

```
spec-<first 32 hex chars of sha256(spec.FullText())>
```

### Spec Value Format

```json
{
  "state": "passed",
  "duration": "2m34s",
  "text": "KubeVirt with kubernetes version 1.31.1 operating system set to ubuntu 22.04 ...",
  "failure": ""
}
```

### Viewing Live Results

```bash
# List all report ConfigMaps
kubectl get configmap -n conformance-tests -l app=conformance-reports

# View detailed results
kubectl get configmap conformance-reports-<project> \
  -n conformance-tests -o jsonpath='{.data}' | jq .
```

### Concurrency Safety

The reporter uses Kubernetes JSON merge patches (`MergePatchType`) which are safely applied by the API server without read-modify-write races. A 5-attempt exponential backoff (100ms, 200ms, 300ms, ...) handles transient API errors.

### Size Limits

ConfigMaps in Kubernetes have a 1 MiB size limit. At suite completion, all JUnit XML files from the reports directory are pushed into the same ConfigMap, respecting this limit.
