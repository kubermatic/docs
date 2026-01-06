+++
title = "Rocky Linux"
date = 2024-05-31T07:00:00+02:00
+++

Rocky Linux is a community-driven enterprise operating system designed to be 100% bug-for-bug compatible with Red Hat Enterprise Linux (RHEL).

## Overview

Rocky Linux provides:
- **RHEL Compatibility**: Drop-in replacement for RHEL
- **Enterprise-Grade**: Stable and production-ready
- **Community Support**: Active community development
- **Long-Term Support**: Extended support lifecycle

## Cloud Provider Support

Rocky Linux is supported on the following cloud providers:

- ✓ AWS
- ✓ Azure
- ✓ DigitalOcean
- ✓ Equinix Metal
- ✓ KubeVirt
- ✓ OpenStack
- ✓ vSphere

{{% notice info %}}
Rocky Linux is **not supported** on: Google Cloud Platform, Hetzner Cloud, Nutanix, VMware Cloud Director
{{% /notice %}}

## Supported Versions

Machine-controller officially supports:

- **Rocky Linux 8.5+** (recommended)
- **Rocky Linux 9.x** (newer versions)

## Configuration

To use Rocky Linux as the operating system:

```yaml
spec:
  template:
    spec:
      providerSpec:
        value:
          operatingSystem: "rockylinux"
          operatingSystemSpec:
            distUpgradeOnBoot: false
```

### Operating System Spec Options

```yaml
operatingSystemSpec:
  # Perform distribution upgrade on first boot
  distUpgradeOnBoot: false
  
  # Disable automatic updates
  disableAutoUpdate: true
  
  # RHEL subscription (if using RHEL instead of Rocky)
  # Not needed for Rocky Linux
  rhelSubscriptionManagerUser: ""
  rhelSubscriptionManagerPassword: ""
```

## Provisioning

Rocky Linux instances are provisioned using **cloud-init**. The machine-controller generates cloud-init configuration that:

1. Configures YUM/DNF repositories
2. Installs required packages (containerd, kubelet, kubeadm, kubectl)
3. Configures the container runtime
4. Sets up SELinux policies
5. Joins the node to the Kubernetes cluster

## Provider-Specific Configuration

### AWS

Rocky Linux provides official AMIs:

```yaml
cloudProviderSpec:
  # Specify Rocky Linux AMI
  ami: "ami-xxxxx"  # Rocky Linux 8 AMI for your region
  
  region: "us-east-1"
  instanceType: "t3.medium"
```

To find Rocky Linux AMIs:
```bash
aws ec2 describe-images \
  --owners 792107900819 \
  --filters "Name=name,Values=Rocky-8-EC2-Base-*" \
  --query 'Images[*].[ImageId,Name,CreationDate]' \
  --output table
```

### Azure

Rocky Linux images are available in Azure Marketplace:

```yaml
cloudProviderSpec:
  imageReference:
    publisher: "erockyenterprisesoftwarefoundationinc1653071250513"
    offer: "rockylinux"
    sku: "rocky-linux-8"
    version: "latest"
```

### DigitalOcean

DigitalOcean provides Rocky Linux as a distribution:

```yaml
cloudProviderSpec:
  # DigitalOcean automatically selects Rocky Linux image
  region: "nyc3"
  size: "s-2vcpu-4gb"
```

### OpenStack

For OpenStack, upload a Rocky Linux cloud image:

1. Download Rocky Linux cloud image:
   ```bash
   wget https://download.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-GenericCloud-Base.latest.x86_64.qcow2
   ```

2. Upload to OpenStack Glance:
   ```bash
   openstack image create \
     --disk-format qcow2 \
     --container-format bare \
     --file Rocky-8-GenericCloud-Base.latest.x86_64.qcow2 \
     rocky-linux-8
   ```

3. Reference in MachineDeployment:
   ```yaml
   cloudProviderSpec:
     image: "rocky-linux-8"
   ```

### vSphere

For vSphere, prepare a Rocky Linux template VM:

1. Download Rocky Linux ISO or qcow2 image
2. Create a VM or convert qcow2 to VMDK
3. Install cloud-init and configure
4. Use as template in MachineDeployment:
   ```yaml
   cloudProviderSpec:
     templateVMName: "rocky-linux-8-template"
   ```

See the [vSphere Rocky Linux Template Guide]({{< relref "../../cloud-providers/vsphere/template-vm/rockylinux/" >}}).

## SELinux Configuration

Rocky Linux has SELinux enabled by default. Machine-controller automatically configures SELinux policies for Kubernetes.

### Verify SELinux Status

```bash
# Check SELinux status
getenforce

# Should return: Enforcing

# View SELinux denials
ausearch -m avc -ts recent
```

### SELinux and Containers

Machine-controller sets SELinux contexts for:
- Container runtime (containerd)
- Kubelet
- Pod volumes

If you encounter SELinux issues:

```bash
# Check audit logs
tail -f /var/log/audit/audit.log | grep denied

# Temporarily set to permissive (for debugging only)
sudo setenforce 0

# Re-enable enforcing
sudo setenforce 1
```

## Firewall Configuration

Rocky Linux uses firewalld by default. Machine-controller configures necessary ports:

```bash
# Check firewall status
sudo firewall-cmd --state

# List allowed services
sudo firewall-cmd --list-all

# Required ports are automatically configured:
# - 10250 (Kubelet API)
# - 30000-32767 (NodePort services)
```

## Package Management

Rocky Linux uses **DNF** (YUM) for package management:

```bash
# Update packages
sudo dnf update -y

# Install additional packages
sudo dnf install -y vim htop

# List installed packages
dnf list installed | grep kube
```

### Kubernetes Packages

Machine-controller installs:
- `kubelet`
- `kubeadm`
- `kubectl`
- `containerd`

## Updates and Maintenance

### Automatic Updates

Rocky Linux can be configured for automatic updates:

```yaml
operatingSystemSpec:
  # Disable automatic updates (recommended for Kubernetes nodes)
  disableAutoUpdate: true
```

### Manual Updates

For manual updates:

```bash
# Update all packages
sudo dnf update -y

# Update specific package
sudo dnf update kubelet

# Check for updates
sudo dnf check-update
```

### Kernel Updates

After kernel updates, reboot is required:

```bash
# Cordon node
kubectl cordon <node-name>

# Drain node
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Reboot
sudo reboot

# Uncordon after reboot
kubectl uncordon <node-name>
```

## Troubleshooting

### Cloud-Init Logs

Check cloud-init logs for provisioning issues:

```bash
# View cloud-init output
sudo cat /var/log/cloud-init-output.log

# View cloud-init logs
sudo cat /var/log/cloud-init.log

# Check cloud-init status
sudo cloud-init status --long
```

### Package Installation Issues

```bash
# Check DNF logs
sudo cat /var/log/dnf.log

# Verify repositories
sudo dnf repolist

# Clean cache
sudo dnf clean all
sudo dnf makecache
```

### SELinux Troubleshooting

```bash
# Check for SELinux denials
sudo ausearch -m avc -ts recent

# Generate SELinux policy (if needed)
sudo audit2allow -a -M mypolicy
sudo semodule -i mypolicy.pp

# Check SELinux boolean settings
getsebool -a | grep container
```

### Kubelet Issues

```bash
# Check kubelet status
sudo systemctl status kubelet

# View kubelet logs
sudo journalctl -u kubelet -f

# Restart kubelet
sudo systemctl restart kubelet
```

## Differences from CentOS/RHEL

Rocky Linux is designed as a CentOS replacement:

- **Community-Driven**: Not owned by Red Hat
- **Free**: No subscription required (unlike RHEL)
- **Compatible**: Binary compatible with RHEL
- **Active Development**: Regular updates and security patches

## Migration from CentOS

To migrate from CentOS to Rocky Linux:

1. Create new MachineDeployment with Rocky Linux
2. Scale up Rocky Linux nodes
3. Drain CentOS nodes
4. Scale down CentOS deployment

Example:

```bash
# Create Rocky Linux MachineDeployment
kubectl apply -f rocky-workers.yaml

# Scale up
kubectl scale machinedeployment rocky-workers --replicas=3 -n kube-system

# Wait for nodes
kubectl get nodes -w

# Drain CentOS nodes
kubectl drain -l os=centos --ignore-daemonsets --delete-emptydir-data

# Scale down
kubectl scale machinedeployment centos-workers --replicas=0 -n kube-system
```

## Complete Example

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: rocky-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: rocky-workers
  template:
    metadata:
      labels:
        name: rocky-workers
        os: rockylinux
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
            ami: "ami-xxxxx"  # Rocky Linux 8 AMI
            diskSize: 50
            tags:
              KubernetesCluster: "my-cluster"
              OS: "rocky-linux-8"
          operatingSystem: "rockylinux"
          operatingSystemSpec:
            distUpgradeOnBoot: false
            disableAutoUpdate: true
      versions:
        kubelet: "1.28.0"
```

## Best Practices

1. **Use Latest Minor Version**: Stay current with Rocky 8.x updates
2. **Disable Auto-Updates**: Control updates through MachineDeployment rolling updates
3. **Keep SELinux Enforcing**: Don't disable SELinux in production
4. **Monitor Security Updates**: Subscribe to Rocky Linux security mailing list
5. **Test Updates**: Validate updates in staging before production
6. **Use Official Images**: Use official Rocky Linux cloud images
7. **Document Customizations**: Keep track of any custom configurations
8. **Regular Maintenance**: Schedule regular update windows

## Custom Packages and Configuration

Install additional packages using cloud-init:

```yaml
spec:
  template:
    spec:
      providerSpec:
        value:
          operatingSystem: "rockylinux"
          cloudInit: |
            #cloud-config
            packages:
              - vim
              - htop
              - curl
            runcmd:
              - echo "Custom configuration"
              - systemctl enable --now myservice
```

## Resources

- [Rocky Linux Official Site](https://rockylinux.org/)
- [Rocky Linux Documentation](https://docs.rockylinux.org/)
- [Rocky Linux Downloads](https://rockylinux.org/download)
- [Rocky Linux GitHub](https://github.com/rocky-linux)
- [Rocky Linux Cloud Images](https://download.rockylinux.org/pub/rocky/)
- [SELinux User Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/using_selinux/)

