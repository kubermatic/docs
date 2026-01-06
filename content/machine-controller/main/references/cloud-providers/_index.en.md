+++
title = "Cloud Providers"
date = 2024-05-31T07:00:00+02:00
weight = 1
+++

machine-controller supports multiple cloud providers through a unified configuration interface. Each cloud provider has specific configuration requirements and features.

## Overview

When creating a MachineDeployment, you specify the cloud provider configuration in the `cloudProviderSpec` section. This allows machine-controller to provision worker nodes on your chosen infrastructure.

All cloud provider configurations follow a similar pattern:

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: example-machinedeployment
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      name: example-workers
  template:
    metadata:
      labels:
        name: example-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "<provider-name>"
          cloudProviderSpec:
            # Provider-specific configuration here
          operatingSystem: "<os-name>"
          operatingSystemSpec:
            # OS-specific configuration here
      versions:
        kubelet: "1.33.0"
```

## Supported Cloud Providers

### Production-Ready Providers

These providers are actively maintained and tested by the machine-controller team:

- **[AWS]({{< ref "./aws/" >}})** - Amazon Web Services EC2
- **[Azure]({{< ref "./azure/" >}})** - Microsoft Azure Virtual Machines
- **[DigitalOcean]({{< ref "./digitalocean/" >}})** - DigitalOcean Droplets
- **[Google Cloud Platform]({{< ref "./gcp/" >}})** - GCP Compute Engine
- **[Hetzner Cloud]({{< ref "./hetzner/" >}})** - Hetzner Cloud Instances

### Advanced Providers

These providers support advanced use cases and specialized infrastructure:

- **[Anexia Engine]({{< ref "./anexia/" >}})** - Anexia Engine (Alpha)
- **[KubeVirt]({{< ref "./kubevirt/" >}})** - Virtual Machines on Kubernetes
- **[Nutanix]({{< ref "./nutanix/" >}})** - Nutanix AHV
- **[OpenStack]({{< ref "./openstack/" >}})** - OpenStack Compute
- **[VMware Cloud Director]({{< ref "./vmware-cloud-director/" >}})** - VMware VCD
- **[vSphere]({{< ref "./vsphere/" >}})** - VMware vSphere

### Community Providers

These providers are maintained by community contributors:

{{% notice info %}}
Community providers are not part of the automated end-to-end tests and may have different levels of support.
{{% /notice %}}

## Provider-Specific Documentation

Click on any provider above to see detailed configuration options, examples, and specific requirements for that provider.

## Common Configuration Elements

### Credentials

Most cloud providers support multiple methods for providing credentials:

1. **Kubernetes Secrets** (recommended for production)
2. **Environment Variables** (convenient for development)
3. **Direct Values** (not recommended for production)

Example using a Secret:

```yaml
cloudProviderSpec:
  token:
    secretKeyRef:
      namespace: kube-system
      name: machine-controller-<provider>
      key: token
```

### SSH Keys

All providers require SSH public keys for node access:

```yaml
spec:
  providerSpec:
    value:
      sshPublicKeys:
        - "ssh-rsa AAAAB3NzaC1yc2EAAAA..."
```

### Network Configuration

Network settings vary by provider but commonly include:

- VPC/Network ID
- Subnet ID
- Security Groups/Firewall Rules
- Public IP assignment

## Next Steps

1. Choose your cloud provider from the list above
2. Follow the provider-specific documentation
3. Configure your credentials
4. Create your first MachineDeployment

## Further Reading

- [Operating Systems Reference]({{< ref "../operating-systems/" >}})
- [Creating Machines Tutorial]({{< ref "../../tutorials/creating-machines.en.md" >}})
- [machine-controller GitHub Repository](https://github.com/kubermatic/machine-controller)

