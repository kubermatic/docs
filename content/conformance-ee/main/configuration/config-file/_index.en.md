+++
title = "Configuration File"
date = 2026-03-17T10:07:15+02:00
weight = 10
+++

When running Conformance EE interactively via the `conformance-tester` CLI, configuration is handled through the TUI. For automated or in-cluster deployments, you provide a YAML configuration file that controls which providers, Kubernetes versions, OS distributions, and resource sizes are included in the test matrix.

The configuration file path is set via the `CONFORMANCE_TESTER_CONFIG_FILE` environment variable.

## Full Configuration Reference

```yaml
# Cloud providers to test (must match provider name)
providers:
  - kubevirt

# Kubernetes versions to test
releases:
  - "1.31"
  - "1.32"

# OS distributions to include
enableDistributions:
  - ubuntu
  - flatcar

# OS distributions to exclude (takes precedence over enableDistributions)
excludeDistributions: []

# Fine-grained modifier filtering
included:
  datacenterDescriptions: []
  clusterDescriptions:
    - "with cni plugin set to canal"
  machineDescriptions: []

excluded:
  clusterDescriptions:
    - "with mla-logging enabled"

# Resource sizes for the combinatorial matrix
resources:
  cpu: [2, 4]
  memory: ["4Gi", "8Gi"]
  diskSize: ["20Gi", "50Gi"]

# OS image sources per distribution and version
imageSources:
  ubuntu:
    "22.04": "docker://quay.io/kubermatic-virt-disks/ubuntu:22.04"
  flatcar:
    "3374.2.2": "docker://quay.io/kubermatic-virt-disks/flatcar:3374.2.2"

# Operating System Profile annotations
ospAnnotations:
  "k8c.io/operating-system-profile": "osp-ubuntu"

# Custom DNS nameservers
nameservers:
  - "8.8.8.8"
  - "8.8.4.4"

# Container runtime settings applied to all nodes
nodeSettings:
  insecureRegistries:
    - "registry.local:5000"
  registryMirrors:
    - "https://mirror.gcr.io"
  pauseImage: "registry.k8s.io/pause:3.9"

# Reporting
resultsFile: /reports/results.json
reportsRoot: /reports

# Timeouts
controlPlaneReadyWaitTimeout: 10m
nodeReadyTimeout: 20m
customTestTimeout: 10m
nodeCount: 1
```

## Configuration Sections

### Providers

```yaml
providers:
  - kubevirt
```

Specifies which cloud providers to test.

| Provider | Status |
|----------|--------|
| `kubevirt` | Supported |

### Releases

```yaml
releases:
  - "1.31"
  - "1.32"
```

Kubernetes versions to include in the test matrix. Each version is combined with every provider, distribution, and modifier combination.

### Distributions

```yaml
enableDistributions:
  - ubuntu
  - flatcar
excludeDistributions: []
```

Controls which OS distributions are tested. `excludeDistributions` takes precedence over `enableDistributions`.

### Included/Excluded Modifiers

```yaml
included:
  datacenterDescriptions: []
  clusterDescriptions:
    - "with cni plugin set to canal"
  machineDescriptions: []
excluded:
  clusterDescriptions:
    - "with mla-logging enabled"
```

Filters the generated scenario matrix by modifier descriptions. Use this to focus tests on specific configurations or exclude known-problematic combinations.

- **included**: If non-empty, only scenarios matching at least one included description are kept.
- **excluded**: Scenarios matching any excluded description are removed (applied after includes).

### Resources

```yaml
resources:
  cpu: [2, 4]
  memory: ["4Gi", "8Gi"]
  diskSize: ["20Gi", "50Gi"]
```

Resource sizes for machine deployments. Each combination of CPU, memory, and disk size produces a separate machine modifier in the test matrix.

### Image Sources

```yaml
imageSources:
  ubuntu:
    "22.04": "docker://quay.io/kubermatic-virt-disks/ubuntu:22.04"
  flatcar:
    "3374.2.2": "docker://quay.io/kubermatic-virt-disks/flatcar:3374.2.2"
```

Maps OS distribution names and versions to container image URIs used for KubeVirt virtual machine disks.

#### Default Image Sources

When no `imageSources` are configured, the following defaults are used:

| Distribution | Version  | Source                                              |
|--------------|----------|-----------------------------------------------------|
| ubuntu       | 20.04    | `docker://quay.io/kubermatic-virt-disks/ubuntu:20.04` |
| ubuntu       | 22.04    | `docker://quay.io/kubermatic-virt-disks/ubuntu:22.04` |
| rhel         | 8        | `docker://quay.io/kubermatic-virt-disks/rhel:8`       |
| rhel         | 9        | `docker://quay.io/kubermatic-virt-disks/rhel:9`       |
| flatcar      | 3374.2.2 | `docker://quay.io/kubermatic-virt-disks/flatcar:3374.2.2` |
| rockylinux   | 8        | `docker://quay.io/kubermatic-virt-disks/rocky:8`      |
| rockylinux   | 9        | `docker://quay.io/kubermatic-virt-disks/rocky:9`      |

### Node Settings

```yaml
nodeSettings:
  insecureRegistries:
    - "registry.local:5000"
  registryMirrors:
    - "https://mirror.gcr.io"
  pauseImage: "registry.k8s.io/pause:3.9"
```

Container runtime settings applied to all worker nodes in created clusters.

### Timeouts

```yaml
controlPlaneReadyWaitTimeout: 10m
nodeReadyTimeout: 20m
customTestTimeout: 10m
```

| Timeout | Default | Description |
|---------|---------|-------------|
| `controlPlaneReadyWaitTimeout` | `10m` | Time to wait for the control plane to become healthy |
| `nodeReadyTimeout` | `20m` | Time to wait for worker nodes to reach Ready state |
| `customTestTimeout` | `10m` | Timeout for individual custom test cases |
