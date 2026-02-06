+++
title = "Ubuntu"
date = 2024-05-31T07:00:00+02:00
+++

Ubuntu is the most widely supported operating system across all cloud providers in machine-controller.

## Supported Versions

Machine-controller officially supports and tests the following Ubuntu LTS versions:

- **Ubuntu 20.04 LTS** (Focal Fossa)
- **Ubuntu 22.04 LTS** (Jammy Jellyfish)  
- **Ubuntu 24.04 LTS** (Noble Numbat)

## Cloud Provider Support

Ubuntu is supported on all machine-controller cloud providers:

- AWS
- Azure
- DigitalOcean
- Equinix Metal
- Google Cloud Platform
- Hetzner Cloud
- KubeVirt
- Nutanix
- OpenStack
- VMware Cloud Director
- vSphere

## Configuration

To use Ubuntu as the operating system, set the following in your MachineDeployment:

```yaml
spec:
  template:
    spec:
      providerSpec:
        value:
          operatingSystem: "ubuntu"
          operatingSystemSpec:
            distUpgradeOnBoot: false
```

### Operating System Spec Options

```yaml
operatingSystemSpec:
  # Perform distribution upgrade on first boot
  distUpgradeOnBoot: false
  
  # Disable auto-update (recommended for production)
  disableAutoUpdate: true
```

## Provisioning

Ubuntu instances are provisioned using **cloud-init**. The machine-controller generates cloud-init configuration that:

1. Updates the package cache
2. Installs required packages (containerd, kubelet, kubeadm, kubectl)
3. Configures the container runtime
4. Joins the node to the Kubernetes cluster

## Provider-Specific Configuration

### AWS

AWS provides official Ubuntu AMIs. You can either:

1. **Use default AMI** (recommended): Let machine-controller select the appropriate Ubuntu AMI
2. **Specify custom AMI**: Provide your own AMI ID

```yaml
cloudProviderSpec:
  # Optional: specify a custom Ubuntu AMI
  ami: "ami-0c55b159cbfafe1f0"
  # If not specified, machine-controller will use the latest Ubuntu LTS AMI
```

### Azure

Azure provides Ubuntu images in the marketplace:

```yaml
cloudProviderSpec:
  # Default Ubuntu image (recommended)
  imageReference:
    publisher: "Canonical"
    offer: "0001-com-ubuntu-server-jammy"
    sku: "22_04-lts-gen2"
    version: "latest"
```

### GCP

Google Cloud Platform provides Ubuntu images:

```yaml
cloudProviderSpec:
  # Use default Ubuntu image
  # machine-controller will select: ubuntu-2204-lts
```

For custom images:

```yaml
cloudProviderSpec:
  customImage: "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20231030"
```

### Hetzner Cloud

Hetzner provides Ubuntu images:

```yaml
cloudProviderSpec:
  # The image name is automatically selected
  # Available: ubuntu-20.04, ubuntu-22.04, ubuntu-24.04
```

### DigitalOcean

DigitalOcean provides Ubuntu images:

```yaml
cloudProviderSpec:
  # Image slug is automatically determined based on Ubuntu version
  # Available: ubuntu-20-04-x64, ubuntu-22-04-x64
```

### vSphere

For vSphere, you need to prepare an Ubuntu template VM. See the [vSphere Ubuntu Template Guide]({{< relref "../../cloud-providers/vsphere/template-vm/ubuntu/" >}}).

## Custom Packages

You can install additional packages during provisioning by using cloud-init user data:

```yaml
spec:
  template:
    spec:
      providerSpec:
        value:
          operatingSystem: "ubuntu"
          cloudInit: |
            #cloud-config
            packages:
              - htop
              - vim
              - curl
            runcmd:
              - echo "Custom initialization complete"
```

## Kernel Updates

### Automatic Updates

By default, Ubuntu has unattended-upgrades enabled. To disable:

```yaml
operatingSystemSpec:
  disableAutoUpdate: true
```

### Manual Kernel Updates

For critical kernel updates:

1. Cordon the node: `kubectl cordon <node-name>`
2. Drain the node: `kubectl drain <node-name> --ignore-daemonsets`
3. SSH to the node and update: `sudo apt-get update && sudo apt-get upgrade -y`
4. Reboot the node: `sudo reboot`
5. Uncordon the node: `kubectl uncordon <node-name>`

Or use a rolling update of the MachineDeployment with a newer image.

## Troubleshooting

### Cloud-Init Logs

If a node fails to join the cluster, check cloud-init logs:

```bash
# View cloud-init output
sudo cat /var/log/cloud-init-output.log

# View cloud-init logs
sudo cat /var/log/cloud-init.log

# Check cloud-init status
sudo cloud-init status --long
```

### Package Installation Issues

If package installation fails:

```bash
# Check APT logs
sudo cat /var/log/apt/history.log
sudo cat /var/log/apt/term.log

# Manually update and install
sudo apt-get update
sudo apt-get install -y containerd kubelet kubeadm kubectl
```

### Network Issues

Check network configuration:

```bash
# View network interfaces
ip addr show

# Check DNS resolution
systemd-resolve --status

# Test connectivity
ping -c 4 8.8.8.8
curl https://packages.cloud.google.com
```

## Best Practices

1. **Use LTS Versions**: Stick to LTS versions for production workloads (20.04, 22.04, 24.04)
2. **Disable Auto-Updates**: Control updates through MachineDeployment rolling updates
3. **Use Latest Images**: Keep cloud provider images up to date for security patches
4. **Test Before Production**: Test new Ubuntu versions in staging before production
5. **Monitor Security Updates**: Subscribe to Ubuntu security notices
6. **Use Custom AMIs/Images**: For consistent environments, create custom images with pre-installed packages

## Migration Between Versions

To upgrade Ubuntu versions:

1. Create a new MachineDeployment with the new Ubuntu version
2. Scale up the new deployment
3. Cordon and drain old nodes
4. Scale down the old deployment
5. Verify all workloads are running on new nodes
6. Delete the old MachineDeployment

Example:

```bash
# Scale up new Ubuntu 22.04 deployment
kubectl scale machinedeployment ubuntu-22-workers --replicas=3 -n kube-system

# Wait for new nodes to be ready
kubectl get nodes -w

# Cordon old nodes
kubectl cordon -l ubuntu-version=20.04

# Drain old nodes
kubectl drain -l ubuntu-version=20.04 --ignore-daemonsets --delete-emptydir-data

# Scale down old deployment
kubectl scale machinedeployment ubuntu-20-workers --replicas=0 -n kube-system
```

## Resources

- [Ubuntu Cloud Images](https://cloud-images.ubuntu.com/)
- [Ubuntu Server Guide](https://ubuntu.com/server/docs)
- [Cloud-Init Documentation](https://cloudinit.readthedocs.io/)
- [Ubuntu Security Notices](https://ubuntu.com/security/notices)
- [Ubuntu Release Cycle](https://ubuntu.com/about/release-cycle)

