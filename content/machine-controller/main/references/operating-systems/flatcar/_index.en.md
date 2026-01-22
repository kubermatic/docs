+++
title = "Flatcar Container Linux"
date = 2024-05-31T07:00:00+02:00
+++

Flatcar Container Linux is a minimal, container-optimized Linux distribution designed for running containerized workloads at scale.

## Overview

Flatcar Container Linux is:
- **Immutable**: System partition is read-only, reducing attack surface
- **Automatic Updates**: Built-in update mechanism for security patches
- **Container-Focused**: Optimized for running containers
- **Lightweight**: Minimal footprint with only essential components

## Cloud Provider Support

Flatcar is supported on the following cloud providers:

- ✓ AWS
- ✓ Azure
- ✓ Equinix Metal
- ✓ Google Cloud Platform
- ✓ KubeVirt
- ✓ OpenStack
- ✓ vSphere

{{% notice info %}}
Flatcar is **not supported** on: DigitalOcean, Hetzner Cloud, Nutanix, VMware Cloud Director
{{% /notice %}}

## Configuration

To use Flatcar as the operating system:

```yaml
spec:
  template:
    spec:
      providerSpec:
        value:
          operatingSystem: "flatcar"
          operatingSystemSpec:
            # Flatcar-specific configuration
            disableAutoUpdate: false
```

### Operating System Spec Options

```yaml
operatingSystemSpec:
  # Disable automatic updates (not recommended for Flatcar)
  disableAutoUpdate: false
  
  # Provision using Ignition instead of cloud-init
  provisioningUtility: "ignition"
```

## Provisioning

Flatcar uses **Ignition** as its primary provisioning mechanism. Machine-controller generates Ignition configuration that:

1. Configures the container runtime (Docker or containerd)
2. Sets up systemd units for kubelet
3. Configures networking
4. Joins the node to the Kubernetes cluster

{{% notice note %}}
Some providers may also support cloud-init for Flatcar, but Ignition is the recommended method.
{{% /notice %}}

## Stable, Beta, and Alpha Channels

Flatcar provides three release channels:

- **Stable**: Production-ready releases (recommended)
- **Beta**: Pre-production testing
- **Alpha**: Early testing and development

Specify the channel in your cloud provider configuration.

## Provider-Specific Configuration

### AWS

AWS provides Flatcar AMIs in the marketplace:

```yaml
cloudProviderSpec:
  # Let machine-controller select the appropriate Flatcar AMI
  # Or specify a custom AMI
  ami: "ami-xxxxx"  # Flatcar Stable AMI for your region
  
  region: "us-east-1"
  instanceType: "t3.medium"
```

To find Flatcar AMIs:
```bash
aws ec2 describe-images \
  --owners 075585003325 \
  --filters "Name=name,Values=Flatcar-stable-*" \
  --query 'Images[*].[ImageId,Name,CreationDate]' \
  --output table
```

### Azure

Azure provides Flatcar images:

```yaml
cloudProviderSpec:
  imageReference:
    publisher: "kinvolk"
    offer: "flatcar-container-linux"
    sku: "stable"
    version: "latest"
```

### GCP

Google Cloud Platform provides Flatcar images:

```yaml
cloudProviderSpec:
  # Use Flatcar stable image
  customImage: "projects/kinvolk-public/global/images/family/flatcar-stable"
```

### Equinix Metal

Equinix Metal provides Flatcar as an operating system option:

```yaml
cloudProviderSpec:
  operatingSystem: "flatcar_stable"
  # Or use beta/alpha channels
  # operatingSystem: "flatcar_beta"
  # operatingSystem: "flatcar_alpha"
```

### OpenStack

For OpenStack, you need to upload a Flatcar image:

1. Download Flatcar image from [Flatcar releases](https://www.flatcar.org/releases)
2. Upload to OpenStack Glance:
   ```bash
   openstack image create \
     --disk-format qcow2 \
     --container-format bare \
     --file flatcar_production_openstack_image.img \
     flatcar-stable
   ```
3. Reference in MachineDeployment:
   ```yaml
   cloudProviderSpec:
     image: "flatcar-stable"
   ```

### vSphere

For vSphere, import the Flatcar OVA:

1. Download Flatcar OVA from [Flatcar releases](https://www.flatcar.org/releases)
2. Import to vSphere as a VM template
3. Configure in MachineDeployment:
   ```yaml
   cloudProviderSpec:
     templateVMName: "flatcar-stable-template"
   ```

## Updates and Maintenance

### Automatic Updates

Flatcar has built-in automatic updates via the update_engine:

```bash
# Check update status
update_engine_client -status

# Trigger update check
update_engine_client -check_for_update

# View update history
journalctl -u update-engine
```

### Update Strategy

Flatcar updates are:
1. Downloaded in the background
2. Applied to an inactive partition
3. Activated on next reboot

To control updates, configure the update strategy:

```yaml
operatingSystemSpec:
  # Disable automatic updates
  disableAutoUpdate: true
```

### Manual Reboot for Updates

If auto-reboot is disabled, manually reboot nodes after updates:

```bash
# Check if reboot is needed
update_engine_client -status | grep NEED_REBOOT

# Cordon and drain node
kubectl cordon <node-name>
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Reboot the node
sudo reboot

# Uncordon after reboot
kubectl uncordon <node-name>
```

## Container Runtime

Flatcar comes with Docker pre-installed, but containerd is recommended for Kubernetes:

Machine-controller automatically configures containerd on Flatcar nodes.

### Verify Container Runtime

```bash
# Check containerd status
systemctl status containerd

# List running containers
crictl ps

# Check containerd configuration
cat /etc/containerd/config.toml
```

## Troubleshooting

### Check Ignition Logs

If provisioning fails, check Ignition logs:

```bash
# View Ignition journal
journalctl -u ignition

# Check Ignition files applied
ls -la /etc/

# View kubelet status
systemctl status kubelet
journalctl -u kubelet -f
```

### Debugging Provisioning

Access the Flatcar instance via cloud provider console:

```bash
# Check if Ignition ran successfully
journalctl -u ignition-firstboot

# View system logs
journalctl -xe

# Check network configuration
networkctl status
```

### SSH Access

Enable SSH for debugging:

```yaml
cloudProviderSpec:
  # Add SSH key for access
  sshPublicKeys:
    - "ssh-rsa AAAAB3NzaC1yc2E..."
```

Then SSH as the `core` user:
```bash
ssh core@<instance-ip>
```

## Ignition Configuration

For advanced use cases, you can provide custom Ignition configuration:

```yaml
spec:
  template:
    spec:
      providerSpec:
        value:
          operatingSystem: "flatcar"
          operatingSystemSpec:
            provisioningUtility: "ignition"
          # Custom Ignition config (in addition to machine-controller defaults)
          cloudInit: |
            {
              "ignition": {
                "version": "3.0.0"
              },
              "storage": {
                "files": [{
                  "path": "/etc/custom-config",
                  "contents": {
                    "source": "data:,custom%20content"
                  }
                }]
              }
            }
```

## Best Practices

1. **Use Stable Channel**: For production, use the stable channel
2. **Enable Auto-Updates**: Flatcar is designed for automatic updates
3. **Use Containerd**: Prefer containerd over Docker for Kubernetes
4. **Monitor Updates**: Set up monitoring for update status
5. **Test Updates**: Use beta/alpha channels for testing before production
6. **Plan Reboots**: Schedule maintenance windows for update reboots
7. **Use Ignition**: Leverage Ignition for configuration management
8. **Keep Minimal**: Don't add unnecessary packages; keep the system minimal

## Differences from Traditional Linux

- **Read-Only Root**: System partition is read-only
- **No Package Manager**: No apt/yum; use containers for applications
- **Stateless**: System state is reset on updates
- **Ignition vs Cloud-Init**: Uses Ignition for provisioning
- **Core User**: Default user is `core`, not `ubuntu` or `admin`

## Migration to Flatcar

To migrate from Ubuntu to Flatcar:

1. **Test Workloads**: Ensure workloads run on Flatcar
2. **Create New MachineDeployment**: With Flatcar configuration
3. **Scale Up**: Add Flatcar nodes
4. **Migrate Workloads**: Drain Ubuntu nodes
5. **Scale Down**: Remove Ubuntu nodes

Example:

```bash
# Create new Flatcar MachineDeployment
kubectl apply -f flatcar-workers.yaml

# Scale up
kubectl scale machinedeployment flatcar-workers --replicas=3 -n kube-system

# Wait for nodes
kubectl get nodes -w

# Drain Ubuntu nodes
kubectl drain -l os=ubuntu --ignore-daemonsets --delete-emptydir-data

# Scale down Ubuntu deployment
kubectl scale machinedeployment ubuntu-workers --replicas=0 -n kube-system
```

## Complete Example

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: flatcar-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: flatcar-workers
  template:
    metadata:
      labels:
        name: flatcar-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "aws"
          cloudProviderSpec:
            region: "us-east-1"
            availabilityZone: "us-east-1a"
            instanceType: "t3.medium"
            vpcId: "vpc-xxxxx"
            subnetId: "subnet-xxxxx"
            # Flatcar Stable AMI
            ami: "ami-xxxxx"
            diskSize: 50
            tags:
              KubernetesCluster: "my-cluster"
          operatingSystem: "flatcar"
          operatingSystemSpec:
            disableAutoUpdate: false
            provisioningUtility: "ignition"
      versions:
        kubelet: "1.28.0"
```

## Resources

- [Flatcar Container Linux](https://www.flatcar.org/)
- [Flatcar Documentation](https://www.flatcar.org/docs/latest/)
- [Flatcar Releases](https://www.flatcar.org/releases)
- [Ignition Documentation](https://coreos.github.io/ignition/)
- [Flatcar Update Philosophy](https://www.flatcar.org/docs/latest/setup/releases/update-strategies/)

