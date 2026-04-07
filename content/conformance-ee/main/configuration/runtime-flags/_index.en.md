+++
title = "Runtime Options"
date = 2026-03-17T10:07:15+02:00
weight = 20
+++

Beyond the YAML configuration file, Conformance EE provides additional runtime options.

## Interactive Mode (CLI)

The `conformance-tester` CLI is the recommended way to run Conformance EE. After downloading the binary via `kubermatic-ee-downloader`, launch it:

```bash
./conformance-tester
```

The interactive TUI guides you through all runtime decisions:

| Step | Description |
|------|-------------|
| Environment | Choose between deploying locally or to an existing cluster |
| Kubeconfig | Select a kubeconfig source (from `KUBECONFIG` env, default path, or custom file) |
| Provider | Choose the cloud provider to test |
| Kubernetes Versions | Select which Kubernetes versions to include |
| OS Distributions | Pick OS distributions and image sources |
| Datacenters | Choose target datacenters |
| Cluster Settings | Configure CNI, proxy mode, expose strategy, and other cluster modifiers |
| Machine Settings | Configure CPU, memory, disk, and other machine modifiers |
| Review & Deploy | Review the generated test matrix and deploy |

All selections made in the TUI are translated into a configuration file and deployed automatically.

## Environment Variables

| Variable | Description |
|----------|-------------|
| `CONFORMANCE_TESTER_CONFIG_FILE` | Path to the YAML configuration file (used in automated/in-cluster mode) |
| `KUBECONFIG` | Path to the kubeconfig file (the TUI auto-detects this) |
| `HIDE_PRESET_CREDENTIALS` | Set to `true` to mask credential values in the TUI |

## In-Cluster Flags

When running Conformance EE as a Kubernetes Job (see [In-Cluster Deployment]({{< ref "../../installation/deployment/" >}})), additional flags can be passed in the Job spec's `args` field to control test execution:

| Flag | Default | Description |
|------|---------|-------------|
| `--datacenters` | `""` | Comma-separated list of datacenters to test |
| `--kube-versions` | `""` | Comma-separated Kubernetes versions to test |
| `--skip-cluster-creation` | `false` | Skip cluster creation; use existing clusters |
| `--skip-cluster-deletion` | `false` | Keep clusters after tests (useful for debugging) |
| `--update-clusters` | `false` | Upgrade existing clusters before running tests |
| `--verbose-logs` | `false` | Show additional log output from test code |

### Examples

Test specific datacenters:

```yaml
args:
  - --datacenters=dc-1,dc-2
```

Keep clusters alive for debugging:

```yaml
args:
  - --skip-cluster-deletion
```

Reuse existing clusters from a previous run:

```yaml
args:
  - --skip-cluster-creation
```

Upgrade existing clusters before testing:

```yaml
args:
  - --update-clusters
  - --skip-cluster-creation
```
