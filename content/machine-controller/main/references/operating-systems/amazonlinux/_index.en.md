+++
title = "Amazon Linux 2"
date = 2024-05-31T07:00:00+02:00
+++

Amazon Linux 2 (AL2) is a Linux distribution provided by Amazon Web Services (AWS), optimized for use on AWS infrastructure.

## Overview

Amazon Linux 2 provides:
- **AWS Optimized**: Pre-configured for optimal performance on AWS
- **Long-Term Support**: 5 years of support until June 30, 2025
- **Security Updates**: Regular security patches from AWS
- **Pre-installed Tools**: AWS CLI and other AWS tools included
- **Systemd**: Uses systemd for service management

{{% notice warning %}}
Amazon Linux 2 support ends on June 30, 2025. Consider migrating to Amazon Linux 2023 or other distributions for new deployments.
{{% /notice %}}

## Cloud Provider Support

Amazon Linux 2 is **only supported on AWS**:

- ✓ AWS (Amazon Web Services)
- ✗ Not available on other cloud providers

## Supported Versions

Machine-controller supports:

- **Amazon Linux 2** (all minor versions in the 2.x series)

## Configuration

To use Amazon Linux 2 as the operating system:

```yaml
spec:
  template:
    spec:
      providerSpec:
        value:
          operatingSystem: "amzn2"
          operatingSystemSpec:
            distUpgradeOnBoot: false
```

### Operating System Spec Options

```yaml
operatingSystemSpec:
  # Perform system upgrade on first boot
  distUpgradeOnBoot: false
  
  # Disable automatic updates
  disableAutoUpdate: true
```

## Provisioning

Amazon Linux 2 instances are provisioned using **cloud-init**. The machine-controller generates cloud-init configuration that:

1. Configures YUM repositories (including Kubernetes repository)
2. Installs required packages (containerd, kubelet, kubeadm, kubectl)
3. Configures the container runtime
4. Sets up systemd services
5. Joins the node to the Kubernetes cluster

## AWS-Specific Configuration

### AMI Selection

Amazon Linux 2 AMIs are provided by AWS in all regions:

```yaml
cloudProviderSpec:
  # Option 1: Let machine-controller select the latest AL2 AMI (recommended)
  # Leave ami field empty or omit it
  
  # Option 2: Specify a specific AMI
  ami: "ami-0c55b159cbfafe1f0"  # AL2 AMI for your region
  
  region: "us-east-1"
  availabilityZone: "us-east-1a"
  instanceType: "t3.medium"
```

### Finding Amazon Linux 2 AMIs

To find the latest AL2 AMI in your region:

```bash
# Using AWS CLI
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].[ImageId,Name,CreationDate]' \
  --output table --region us-east-1

# Using Systems Manager Parameter Store (recommended)
aws ssm get-parameters \
  --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 \
  --region us-east-1 \
  --query 'Parameters[0].Value' \
  --output text
```

### EC2 Instance Metadata

Amazon Linux 2 has built-in support for EC2 instance metadata:

```bash
# From within an AL2 instance
# Get instance ID
curl http://169.254.169.254/latest/meta-data/instance-id

# Get instance type
curl http://169.254.169.254/latest/meta-data/instance-type

# Get availability zone
curl http://169.254.169.254/latest/meta-data/placement/availability-zone
```

## Package Management

Amazon Linux 2 uses **YUM** for package management:

```bash
# Update packages
sudo yum update -y

# Install additional packages
sudo yum install -y vim htop

# List installed packages
yum list installed | grep kube

# Search for packages
yum search package-name
```

### Extras Repository

Amazon Linux 2 provides the Extras repository for newer software:

```bash
# List available extras
sudo amazon-linux-extras list

# Install from extras
sudo amazon-linux-extras install docker
sudo amazon-linux-extras install epel
```

### Kubernetes Packages

Machine-controller installs from the Kubernetes repository:
- `kubelet`
- `kubeadm`
- `kubectl`
- `containerd` or `docker`

## Updates and Maintenance

### Automatic Updates

Amazon Linux 2 can be configured for automatic updates:

```yaml
operatingSystemSpec:
  # Disable automatic updates (recommended for Kubernetes)
  disableAutoUpdate: true
```

### Manual Updates

```bash
# Check for updates
sudo yum check-update

# Update all packages
sudo yum update -y

# Update specific package
sudo yum update kubelet

# View update history
sudo yum history
```

### Kernel Updates

After kernel updates, reboot is required:

```bash
# Cordon node
kubectl cordon <node-name>

# Drain workloads
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Reboot the instance
sudo reboot

# Uncordon after reboot
kubectl uncordon <node-name>
```

## Container Runtime

### Containerd (Recommended)

Machine-controller configures containerd as the container runtime:

```bash
# Check containerd status
sudo systemctl status containerd

# View containerd configuration
sudo cat /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd
```

### Docker (Legacy)

For older configurations using Docker:

```bash
# Check Docker status
sudo systemctl status docker

# View Docker info
sudo docker info

# List containers
sudo docker ps
```

## AWS Integration

### IAM Instance Profile

Amazon Linux 2 integrates with IAM for permissions:

```yaml
cloudProviderSpec:
  # Specify IAM instance profile
  instanceProfile: "KubernetesWorkerProfile"
```

The instance profile should have permissions for:
- EC2 operations
- EBS volume management
- Route53 (if using external-dns)
- ELB (if using LoadBalancer services)

### CloudWatch Logs

Configure CloudWatch logging:

```bash
# Install CloudWatch agent
sudo yum install amazon-cloudwatch-agent -y

# Configure agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard

# Start agent
sudo systemctl start amazon-cloudwatch-agent
```

## Troubleshooting

### Cloud-Init Logs

```bash
# View cloud-init output
sudo cat /var/log/cloud-init-output.log

# View cloud-init logs
sudo cat /var/log/cloud-init.log

# Check cloud-init status
sudo cloud-init status --long
```

### System Logs

```bash
# View system messages
sudo tail -f /var/log/messages

# View kubelet logs
sudo journalctl -u kubelet -f

# View containerd logs
sudo journalctl -u containerd -f
```

### Package Issues

```bash
# Clean YUM cache
sudo yum clean all
sudo yum makecache

# Verify Kubernetes repository
sudo yum repolist | grep kubernetes

# Check for repository errors
sudo yum repolist -v
```

### Network Troubleshooting

```bash
# Check network interfaces
ip addr show

# Test DNS
nslookup kubernetes.default

# Check routes
ip route show

# Test connectivity
curl -k https://<api-server>:6443
```

## Migration to Amazon Linux 2023

Amazon Linux 2023 (AL2023) is the successor to AL2 with extended support:

### Key Differences

- **Longer Support**: 5 years vs AL2
- **Newer Packages**: More recent software versions
- **SELinux**: Enabled by default
- **Systemd**: Enhanced systemd integration

### Migration Steps

1. Create new MachineDeployment with AL2023
2. Test workloads on AL2023 nodes
3. Gradually scale up AL2023, scale down AL2
4. Update documentation and runbooks

```yaml
# AL2023 MachineDeployment (when supported)
spec:
  template:
    spec:
      providerSpec:
        value:
          operatingSystem: "amzn2023"  # Future support
          # ... rest of config
```

## Complete Example

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: amzn2-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: amzn2-workers
  template:
    metadata:
      labels:
        name: amzn2-workers
        os: amazon-linux-2
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
            # Let machine-controller select latest AL2 AMI
            # ami: ""
            diskSize: 50
            diskType: "gp3"
            instanceProfile: "KubernetesWorkerProfile"
            tags:
              KubernetesCluster: "my-cluster"
              OS: "amazon-linux-2"
          operatingSystem: "amzn2"
          operatingSystemSpec:
            distUpgradeOnBoot: false
            disableAutoUpdate: true
      versions:
        kubelet: "1.28.0"
```

## Best Practices

1. **Use Latest AMI**: Always use the latest AL2 AMI for security patches
2. **Plan Migration**: Start planning migration to AL2023 or Ubuntu
3. **Disable Auto-Updates**: Control updates via MachineDeployment rolling updates
4. **Use Instance Profiles**: Leverage IAM roles instead of credentials
5. **Monitor EOL**: Track AL2 end-of-life date (June 30, 2025)
6. **Test Updates**: Validate AMI updates in non-production first
7. **CloudWatch Integration**: Use CloudWatch for centralized logging
8. **Optimize for AWS**: Leverage AWS-specific features and integrations

## Custom Configuration

Add custom packages or scripts using cloud-init:

```yaml
spec:
  template:
    spec:
      providerSpec:
        value:
          operatingSystem: "amzn2"
          cloudInit: |
            #cloud-config
            packages:
              - vim
              - htop
              - aws-cli
            runcmd:
              - echo "Custom AL2 configuration"
              - amazon-linux-extras install epel -y
```

## Advantages of Amazon Linux 2

1. **AWS Optimized**: Best performance on AWS infrastructure
2. **Pre-installed Tools**: AWS CLI and tools included
3. **Security**: Regular security updates from AWS
4. **Support**: Backed by AWS support
5. **Cost**: No additional licensing costs

## Limitations

1. **AWS Only**: Cannot be used on other cloud providers
2. **EOL Approaching**: Support ends June 30, 2025
3. **Package Versions**: May have older package versions
4. **Limited Ecosystem**: Smaller community compared to Ubuntu

## Resources

- [Amazon Linux 2 User Guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/amazon-linux-2-virtual-machine.html)
- [Amazon Linux 2 FAQs](https://aws.amazon.com/amazon-linux-2/faqs/)
- [Amazon Linux 2 Release Notes](https://aws.amazon.com/amazon-linux-2/release-notes/)
- [Amazon Linux AMI Finder](https://aws.amazon.com/blogs/compute/query-for-the-latest-amazon-linux-ami-ids-using-aws-systems-manager-parameter-store/)
- [Migration to AL2023](https://docs.aws.amazon.com/linux/al2023/ug/migration.html)

