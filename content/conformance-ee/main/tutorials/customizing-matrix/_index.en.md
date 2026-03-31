+++
title = "Customizing the Test Matrix"
date = 2026-03-17T10:07:15+02:00
weight = 20
+++

This guide explains how to customize the test matrix to focus on specific configurations or expand coverage.

## Understanding the Test Matrix

Conformance EE generates test scenarios by combining:

- **Cloud Providers** (e.g., KubeVirt)
- **Kubernetes Versions** (e.g., 1.31, 1.32)
- **OS Distributions** (e.g., Ubuntu, Flatcar)
- **Cluster Modifiers** (CNI, proxy mode, expose strategy, etc.)
- **Machine Modifiers** (CPU, memory, disk, DNS policy, etc.)
- **Datacenter Modifiers** (VPC, subnet, storage class)

The total number of scenarios is the product of all these dimensions, after deduplication.

## Filtering by Modifier Description

Use the `included` and `excluded` fields to filter the test matrix:

### Include Only Specific Configurations

```yaml
included:
  clusterDescriptions:
    - "with cni plugin set to canal"
    - "with proxy mode set to ipvs"
  machineDescriptions:
    - "with ubuntu"
```

When `included` is non-empty, only scenarios matching at least one description are kept.

### Exclude Problematic Combinations

```yaml
excluded:
  clusterDescriptions:
    - "with mla-logging enabled"
    - "with opa integration enabled"
```

Excluded descriptions are applied after includes and remove any matching scenarios.

## Controlling Resource Sizes

Reduce the matrix by limiting resource combinations:

```yaml
# Minimal: single resource size
resources:
  cpu: [2]
  memory: ["4Gi"]
  diskSize: ["20Gi"]

# Full: multiple resource sizes (4x more scenarios)
resources:
  cpu: [2, 4]
  memory: ["4Gi", "8Gi"]
  diskSize: ["20Gi", "50Gi"]
```

## Testing Specific Kubernetes Versions

```yaml
releases:
  - "1.31"
  # Add more versions to expand testing
  - "1.32"
```

## Testing Specific Distributions

```yaml
enableDistributions:
  - ubuntu
  - flatcar
  - rhel
  - rockylinux

# Or exclude specific ones
excludeDistributions:
  - rhel
```

## Using Ginkgo Label Filters

For runtime filtering without changing the config file, use Ginkgo label filters:

```bash
--ginkgo.label-filter="kubevirt && canal"
```

## Estimating Matrix Size

Use `--ginkgo.dry-run` to see all generated scenarios without executing them:

```bash
--ginkgo.dry-run --ginkgo.v
```

This lists every spec that would run, helping you estimate the size of your test matrix and verify your filters are working correctly.
