+++
title = "Offline / Air-Gapped Settings"
date = 2026-03-17T10:07:15+02:00
weight = 15
+++

When running Conformance EE in an **offline** or **air-gapped** environment, additional settings must be configured so that worker nodes can pull container images and resolve DNS without access to the public internet. These settings are exposed both in the interactive TUI and in the YAML configuration file.

## TUI Stage: Configure KubeVirt Settings

In the TUI, the offline-related settings are presented in the **Configure KubeVirt Settings** stage, which appears after distribution selection and *before* the Machine Deployment Settings view. The stage is divided into six sections that can be navigated with `Tab`:

| Section | Description |
|---------|-------------|
| **Image Sources** | OS disk image URIs per distribution and version (e.g. `docker://registry.local/virt-disks/ubuntu:22.04`) |
| **OSP Annotations** | Per-distribution Operating System Profile annotations applied to `MachineDeployment` resources (e.g. `osp-ubuntu-offline`) |
| **Nameservers** | Custom DNS nameservers injected into worker node configuration |
| **Insecure Registries** | Container registries that do not use TLS (passed to the container runtime) |
| **Registry Mirrors** | Mirror URLs the container runtime should use instead of upstream registries |
| **Pause Image** | Override for the `pause` container image used by the container runtime |

### TUI Controls

| Key | Action |
|-----|--------|
| `Tab` | Switch between sections |
| `↑` / `↓` | Navigate entries within a section |
| `Space` | Edit the focused entry |
| `a` or `+` | Add a new entry |
| `d` or `Del` | Delete the focused entry |
| `Tab` (while editing) | Cycle between fields in multi-field entries (Image Sources, OSP Annotations) |
| `Enter` | Continue to the next stage |
| `Esc` | Go back |

## Configuration File Reference

All offline settings can also be provided directly in the YAML configuration file:

### Image Sources

```yaml
imageSources:
  ubuntu:
    "22.04": "docker://registry.local/virt-disks/ubuntu:22.04"
  flatcar:
    "3374.2.2": "docker://registry.local/virt-disks/flatcar:3374.2.2"
```

Maps OS distribution names and versions to container image URIs. In air-gapped setups, point these at an internal registry that mirrors the required KubeVirt virtual machine disk images.

### OSP Annotations

```yaml
ospAnnotations:
  ubuntu: "osp-ubuntu-offline"
  flatcar: "osp-flatcar-offline"
```

Per-distribution annotation values that will be set on `MachineDeployment` resources. These are typically used to select an [Operating System Profile](https://docs.kubermatic.com/kubermatic/main/tutorials-howtos/operating-system-manager/usage/#using-custom-operatingsystemprofiles) configured for offline package installation.

### Nameservers

```yaml
nameservers:
  - "10.0.0.53"
  - "10.0.0.54"
```

Custom DNS nameservers to configure on worker nodes. Use this when the default cluster DNS cannot resolve names required during node bootstrapping (e.g. an internal package mirror).

### Node Settings

The `nodeSettings` block groups container-runtime-level overrides applied to every worker node:

```yaml
nodeSettings:
  insecureRegistries:
    - "registry.local:5000"
  registryMirrors:
    - "https://mirror.internal.example.com"
  pauseImage: "registry.local:5000/pause:3.9"
```

| Field | Description |
|-------|-------------|
| `insecureRegistries` | Registries that do **not** use TLS. The container runtime is configured to allow plain HTTP pulls from these addresses. |
| `registryMirrors` | Mirror URLs. The container runtime will attempt to pull images from these mirrors before falling back to the upstream registry. |
| `pauseImage` | Fully-qualified image reference for the `pause` container. Override this when the default `registry.k8s.io/pause` is not reachable. |

## Defaults

When no offline settings are configured:

- **Image Sources** are pre-populated with the public `quay.io/kubermatic-virt-disks/` images for all supported distributions and versions.
- **OSP Annotations**, **Nameservers**, **Insecure Registries**, **Registry Mirrors**, and **Pause Image** are empty (not set).

{{% notice tip %}}
In a fully online environment, the default image sources work out of the box and none of the other offline settings are needed. You only need to configure this stage when your cluster nodes cannot reach the public internet.
{{% /notice %}}

## Example: Fully Air-Gapped Configuration

```yaml
providers:
  - kubevirt

releases:
  - "1.31"

enableDistributions:
  - ubuntu

# --- Offline settings ---

imageSources:
  ubuntu:
    "22.04": "docker://registry.internal.example.com/virt-disks/ubuntu:22.04"

ospAnnotations:
  ubuntu: "osp-ubuntu-airgapped"

nameservers:
  - "10.100.0.53"

nodeSettings:
  insecureRegistries:
    - "registry.internal.example.com:5000"
  registryMirrors:
    - "https://registry.internal.example.com"
  pauseImage: "registry.internal.example.com:5000/pause:3.9"

# --- Standard settings ---

resources:
  cpu: [2]
  memory: ["4Gi"]
  diskSize: ["25Gi"]

controlPlaneReadyWaitTimeout: 10m
nodeReadyTimeout: 20m
nodeCount: 1
reportsRoot: /reports
```
