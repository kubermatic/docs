+++
title = "Operating Systems"
date = 2024-05-31T07:00:00+02:00
weight = 2
+++

Machine-controller supports multiple operating systems across various cloud providers, allowing you to choose the best OS for your workload requirements.

## Supported Operating Systems

### [Ubuntu]({{< relref "./ubuntu" >}})

Ubuntu is the most widely supported and recommended operating system for machine-controller.

- **Versions**: 20.04 LTS, 22.04 LTS, 24.04 LTS
- **Support**: All cloud providers
- **Provisioning**: cloud-init
- **Best for**: General purpose workloads, widest compatibility

[Read the Ubuntu guide →]({{< relref "./ubuntu" >}})

### [Flatcar Container Linux]({{< relref "./flatcar" >}})

Flatcar is a minimal, container-optimized Linux distribution designed for running containerized workloads.

- **Versions**: Stable, Beta, Alpha channels
- **Support**: AWS, Azure, Equinix Metal, GCP, KubeVirt, OpenStack, vSphere
- **Provisioning**: Ignition (or cloud-init)
- **Best for**: Immutable infrastructure, container-focused deployments

[Read the Flatcar guide →]({{< relref "./flatcar" >}})

### [Red Hat Enterprise Linux (RHEL)]({{< relref "./rhel" >}})

Enterprise-grade Linux distribution from Red Hat.

- **Versions**: 8.x
- **Support**: AWS, Azure, GCP, KubeVirt, OpenStack, vSphere
- **Provisioning**: cloud-init
- **Best for**: Enterprise environments requiring Red Hat support

[Read the RHEL guide →]({{< relref "./rhel" >}})

### [Rocky Linux]({{< relref "./rockylinux" >}})

Community-driven enterprise OS, 100% bug-for-bug compatible with RHEL.

- **Versions**: 8.5+
- **Support**: AWS, Azure, DigitalOcean, Equinix Metal, KubeVirt, OpenStack, vSphere
- **Provisioning**: cloud-init
- **Best for**: RHEL compatibility without subscription costs

[Read the Rocky Linux guide →]({{< relref "./rockylinux" >}})

### [Amazon Linux 2]({{< relref "./amazonlinux" >}})

AWS-optimized Linux distribution (AWS only).

- **Versions**: 2.x
- **Support**: AWS only
- **Provisioning**: cloud-init
- **Best for**: AWS-specific workloads
- **Note**: Support ends June 30, 2025

[Read the Amazon Linux 2 guide →]({{< relref "./amazonlinux" >}})

## Cloud Provider Compatibility Matrix

|   | Ubuntu | Flatcar | RHEL | Amazon Linux 2 | Rocky Linux |
|---|---|---|---|---|---|
| AWS | ✓ | ✓ | ✓ | ✓ | ✓ |
| Azure | ✓ | ✓ | ✓ | ✗ | ✓ |
| DigitalOcean  | ✓ | ✗ | ✗ | ✗ | ✓ |
| Equinix Metal | ✓ | ✓ | ✗ | ✗ | ✓ |
| Google Cloud Platform | ✓ | ✓ | ✗ | ✗ | ✗ |
| Hetzner Cloud | ✓ | ✗ | ✗ | ✗ | ✓ |
| KubeVirt | ✓ | ✓ | ✓ | ✗ | ✓ |
| Nutanix | ✓ | ✗ | ✗ | ✗ | ✗ |
| OpenStack | ✓ | ✓ | ✓ | ✗ | ✓ |
| VMware Cloud Director | ✓ | ✗ | ✗ | ✗ | ✗ |
| vSphere | ✓ | ✓ | ✓ | ✗ | ✓ |

**Legend:** ✓ = Supported, ✗ = Not supported

## Configuration

### Specifying the Operating System

The operating system is set via `machine.spec.providerConfig.operatingSystem`:

```yaml
spec:
  template:
    spec:
      providerSpec:
        value:
          operatingSystem: "ubuntu"  # or: flatcar, rhel, rockylinux, amzn2
          operatingSystemSpec:
            # OS-specific configuration
            distUpgradeOnBoot: false
            disableAutoUpdate: true
```

### Allowed Values

- `ubuntu` - Ubuntu Linux
- `flatcar` - Flatcar Container Linux
- `rhel` - Red Hat Enterprise Linux
- `rockylinux` - Rocky Linux
- `amzn2` - Amazon Linux 2

### Operating System Spec Options

Common options across operating systems:

```yaml
operatingSystemSpec:
  # Perform distribution upgrade on first boot
  distUpgradeOnBoot: false
  
  # Disable automatic updates (recommended for production)
  disableAutoUpdate: true
  
  # Provisioning utility (flatcar specific)
  provisioningUtility: "ignition"  # or "cloud-init"
  
  # RHEL subscription (RHEL only)
  rhelSubscriptionManagerUser: ""
  rhelSubscriptionManagerPassword: ""
```

## Supported OS Versions

{{% notice info %}}
The table below lists the OS versions validated in our automated tests. Machine-controller may work with other OS versions, but official support is only provided for these versions.
{{% /notice %}}

|   | Supported Versions |
|---|----------|
| Ubuntu | 20.04 LTS, 22.04 LTS, 24.04 LTS |
| Flatcar | Stable, Beta, Alpha channels |
| RHEL | 8.x |
| Rocky Linux | 8.5+ |
| Amazon Linux 2 | 2.x (EOL: June 30, 2025) |

## Provisioning Methods

### cloud-init

Most operating systems use **cloud-init** for provisioning:

- Ubuntu
- RHEL
- Rocky Linux
- Amazon Linux 2
- Flatcar (optional)

Cloud-init handles:
- Package installation
- User management
- Network configuration
- Custom scripts execution

### Ignition

Flatcar primarily uses **Ignition** for provisioning:

- Declarative configuration
- Run once at first boot
- JSON/YAML configuration format
- Better for immutable infrastructure

## Choosing an Operating System

Consider the following factors:

### Use Ubuntu if:
- You need widest cloud provider support
- You want community support and extensive documentation
- You're building general-purpose clusters
- You prefer familiar Debian-based systems

### Use Flatcar if:
- You want immutable infrastructure
- You're running container-only workloads
- You need automatic atomic updates
- You prefer minimal attack surface

### Use RHEL if:
- You require enterprise support from Red Hat
- You have existing RHEL infrastructure
- You need certified enterprise software
- You have Red Hat subscriptions

### Use Rocky Linux if:
- You want RHEL compatibility without costs
- You need enterprise-grade stability
- You're migrating from CentOS
- You prefer community-driven development

### Use Amazon Linux 2 if:
- You're exclusively on AWS
- You want AWS-optimized performance
- You need tight AWS service integration
- You're already using AL2

## Complete Example

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: ubuntu-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: ubuntu-workers
  template:
    metadata:
      labels:
        name: ubuntu-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "aws"
          cloudProviderSpec:
            region: "us-east-1"
            instanceType: "t3.medium"
            # ... cloud provider config
          operatingSystem: "ubuntu"
          operatingSystemSpec:
            distUpgradeOnBoot: false
            disableAutoUpdate: true
      versions:
        kubelet: "1.28.0"
```

## Migration Between Operating Systems

To migrate from one OS to another:

1. Create new MachineDeployment with target OS
2. Scale up new deployment
3. Drain old nodes
4. Scale down old deployment

See individual OS guides for specific migration instructions.

## Troubleshooting

### Common Issues

1. **Provisioning Failures**: Check cloud-init/ignition logs
2. **Package Installation Errors**: Verify repository access
3. **Node Not Joining**: Check network connectivity and credentials
4. **Kernel Issues**: Ensure supported kernel version

See the [Troubleshooting Guide]({{< ref "../../support/troubleshooting/" >}}) for detailed solutions.

## Best Practices

1. **Use LTS/Stable Versions**: For production workloads
2. **Test Before Production**: Validate OS changes in staging
3. **Disable Auto-Updates**: Control updates via MachineDeployments
4. **Monitor Security**: Subscribe to security mailing lists
5. **Document Choices**: Record OS selection rationale
6. **Plan Migrations**: Test OS upgrades thoroughly

## Additional Resources

- [Cloud Providers Documentation]({{< ref "../cloud-providers/" >}})
- [Troubleshooting Guide]({{< ref "../../support/troubleshooting/" >}})
- [Architecture Overview]({{< ref "../../architecture/" >}})
- [Machine-Controller GitHub](https://github.com/kubermatic/machine-controller)
