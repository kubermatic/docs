+++
title = "Runtime Flags"
date = 2026-03-17T10:07:15+02:00
weight = 20
+++

In addition to the YAML configuration file, Conformance EE supports command-line flags for controlling test execution behavior. These flags can be passed via the Job spec's `args` field when deploying in-cluster.

## Flags Reference

| Flag | Default | Description |
|------|---------|-------------|
| `--datacenters` | `""` | Comma-separated list of datacenters to test |
| `--kube-versions` | `""` | Comma-separated Kubernetes versions to test |
| `--skip-cluster-creation` | `false` | Skip cluster creation; use existing clusters |
| `--skip-cluster-deletion` | `false` | Keep clusters after tests (useful for debugging) |
| `--update-clusters` | `false` | Upgrade existing clusters before running tests |

## Usage Examples

### Test Specific Datacenters

```
--datacenters=dc-1,dc-2
```

### Test Specific Kubernetes Versions

```
--kube-versions=1.31,1.32
```

### Debug Mode (Keep Clusters)

When debugging test failures, use `--skip-cluster-deletion` to keep clusters alive for investigation:

```
--skip-cluster-deletion
```

### Reuse Existing Clusters

If clusters from a previous run are still available, skip creation:

```
--skip-cluster-creation
```

### Upgrade and Test

Upgrade existing clusters to the next Kubernetes version before running tests:

```
--update-clusters --skip-cluster-creation
```

## Ginkgo Flags

Since Conformance EE uses Ginkgo v2, all standard Ginkgo flags are also available:

| Flag | Description |
|------|-------------|
| `--ginkgo.v` | Verbose output |
| `--ginkgo.nodes=N` | Number of parallel Ginkgo nodes |
| `--ginkgo.focus="pattern"` | Run only specs matching the regex pattern |
| `--ginkgo.skip="pattern"` | Skip specs matching the regex pattern |
| `--ginkgo.label-filter="expression"` | Filter specs by Ginkgo labels |
| `--ginkgo.dry-run` | List all specs without executing them |

### Example: Run Only Canal CNI Tests

```
--ginkgo.focus="canal"
```

### Example: Run 8 Parallel Nodes

```
--ginkgo.nodes=8
```
