+++
title = "AWS (Amazon Web Services)"
date = 2024-05-31T07:00:00+02:00
+++

This guide covers machine-controller configuration for Amazon Web Services (AWS).

## Prerequisites

- AWS account with appropriate permissions
- VPC, subnets, and security groups configured
- IAM user or instance profile with required permissions
- Kubernetes cluster with machine-controller installed

## Required AWS Permissions

The AWS credentials used by machine-controller need the following IAM permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeImages",
        "ec2:DescribeRegions",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs",
        "ec2:RunInstances",
        "ec2:TerminateInstances",
        "ec2:CreateTags",
        "ec2:DescribeTags",
        "ec2:DeleteTags",
        "ec2:DescribeVolumes",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:CreateVolume",
        "ec2:DeleteVolume"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:PassRole",
        "iam:GetRole",
        "iam:GetInstanceProfile"
      ],
      "Resource": "*"
    }
  ]
}
```

## Provider Configuration

### Basic Configuration

```yaml
cloudProviderSpec:
  # AWS credentials (can also use environment variables)
  accessKeyId: "<< YOUR_ACCESS_KEY_ID >>"
  secretAccessKey: "<< YOUR_SECRET_ACCESS_KEY_ID >>"
  
  # Region and availability zone
  region: "us-east-1"
  availabilityZone: "us-east-1a"
  
  # VPC and subnet
  vpcId: "vpc-0123456789abcdef0"
  subnetId: "subnet-0123456789abcdef0"
  
  # Instance configuration
  instanceType: "t3.medium"
  diskSize: 50
  diskType: "gp3"
  
  # IAM instance profile (required)
  instanceProfile: "KubernetesWorkerProfile"
  
  # Tags (KubernetesCluster tag is required)
  tags:
    KubernetesCluster: "my-cluster"
    Environment: "production"
```

### Using Secrets for Credentials

Create a secret:

```bash
kubectl create secret generic aws-credentials \
  -n kube-system \
  --from-literal=accessKeyId=<YOUR_ACCESS_KEY_ID> \
  --from-literal=secretAccessKey=<YOUR_SECRET_ACCESS_KEY_ID>
```

Reference in MachineDeployment:

```yaml
cloudProviderSpec:
  accessKeyId:
    secretKeyRef:
      name: aws-credentials
      key: accessKeyId
  secretAccessKey:
    secretKeyRef:
      name: aws-credentials
      key: secretAccessKey
```

### All Configuration Options

```yaml
cloudProviderSpec:
  # Credentials
  accessKeyId: "<< YOUR_ACCESS_KEY_ID >>"
  secretAccessKey: "<< YOUR_SECRET_ACCESS_KEY_ID >>"
  # Can also be set via AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY env vars
  
  # Region and availability zone
  region: "us-east-1"
  availabilityZone: "us-east-1a"
  
  # Network configuration
  vpcId: "vpc-0123456789abcdef0"
  subnetId: "subnet-0123456789abcdef0"
  
  # Public IP assignment (default: true)
  assignPublicIP: true
  
  # Instance configuration
  instanceType: "t3.medium"
  
  # Spot instances (default: false)
  isSpotInstance: false
  spotInstanceMaxPrice: "0.05"  # Optional, only with isSpotInstance: true
  spotInstancePersistentRequest: false  # Optional
  spotInstanceInterruptionBehavior: "terminate"  # terminate or stop
  
  # Storage configuration
  diskSize: 50  # GB
  diskType: "gp3"  # gp2, gp3, io1, io2, st1, sc1, or standard
  diskIops: 3000  # Required for io1/io2
  diskThroughput: 125  # Only for gp3
  ebsVolumeEncrypted: false
  
  # AMI (optional - auto-selected if not specified)
  ami: ""  # e.g., "ami-0c55b159cbfafe1f0"
  
  # Security groups (optional - creates 'kubernetes-v1' if not set)
  securityGroupIDs:
    - "sg-0123456789abcdef0"
  
  # IAM instance profile (required for Kubernetes AWS cloud provider)
  instanceProfile: "KubernetesWorkerProfile"
  
  # Instance metadata options
  instanceMetadataOptions:
    httpTokens: "required"  # required or optional (IMDSv2)
    httpPutResponseHopLimit: 1
  
  # Tags (KubernetesCluster tag is required!)
  tags:
    KubernetesCluster: "my-cluster"
    Environment: "production"
    ManagedBy: "machine-controller"
```

## Complete MachineDeployment Examples

### Basic Ubuntu Workers

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: aws-ubuntu-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: aws-ubuntu-workers
  template:
    metadata:
      labels:
        name: aws-ubuntu-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "aws"
          cloudProviderSpec:
            region: "us-east-1"
            availabilityZone: "us-east-1a"
            vpcId: "vpc-0123456789abcdef0"
            subnetId: "subnet-0123456789abcdef0"
            instanceType: "t3.medium"
            diskSize: 50
            diskType: "gp3"
            assignPublicIP: true
            instanceProfile: "KubernetesWorkerProfile"
            accessKeyId:
              secretKeyRef:
                name: aws-credentials
                key: accessKeyId
            secretAccessKey:
              secretKeyRef:
                name: aws-credentials
                key: secretAccessKey
            tags:
              KubernetesCluster: "my-cluster"
          operatingSystem: "ubuntu"
          operatingSystemSpec:
            distUpgradeOnBoot: false
      versions:
        kubelet: "1.28.0"
```

### Spot Instance Workers

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: aws-spot-workers
  namespace: kube-system
spec:
  replicas: 5
  selector:
    matchLabels:
      name: aws-spot-workers
  template:
    metadata:
      labels:
        name: aws-spot-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "aws"
          cloudProviderSpec:
            region: "us-east-1"
            availabilityZone: "us-east-1a"
            vpcId: "vpc-0123456789abcdef0"
            subnetId: "subnet-0123456789abcdef0"
            instanceType: "t3.large"
            isSpotInstance: true
            spotInstanceMaxPrice: "0.10"
            spotInstanceInterruptionBehavior: "terminate"
            diskSize: 100
            diskType: "gp3"
            instanceProfile: "KubernetesWorkerProfile"
            tags:
              KubernetesCluster: "my-cluster"
              WorkloadType: "batch"
          operatingSystem: "ubuntu"
      versions:
        kubelet: "1.28.0"
```

### High-Performance I/O Workers

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: aws-io-workers
  namespace: kube-system
spec:
  replicas: 2
  selector:
    matchLabels:
      name: aws-io-workers
  template:
    metadata:
      labels:
        name: aws-io-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "aws"
          cloudProviderSpec:
            region: "us-east-1"
            availabilityZone: "us-east-1a"
            vpcId: "vpc-0123456789abcdef0"
            subnetId: "subnet-0123456789abcdef0"
            instanceType: "i3.2xlarge"
            diskSize: 200
            diskType: "io2"
            diskIops: 10000
            ebsVolumeEncrypted: true
            instanceProfile: "KubernetesWorkerProfile"
            tags:
              KubernetesCluster: "my-cluster"
              WorkloadType: "database"
          operatingSystem: "ubuntu"
      versions:
        kubelet: "1.28.0"
```

### Amazon Linux 2 Workers

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: aws-al2-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: aws-al2-workers
  template:
    metadata:
      labels:
        name: aws-al2-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "aws"
          cloudProviderSpec:
            region: "us-east-1"
            availabilityZone: "us-east-1a"
            vpcId: "vpc-0123456789abcdef0"
            subnetId: "subnet-0123456789abcdef0"
            instanceType: "t3.medium"
            diskSize: 50
            diskType: "gp3"
            instanceProfile: "KubernetesWorkerProfile"
            tags:
              KubernetesCluster: "my-cluster"
          operatingSystem: "amzn2"
          operatingSystemSpec:
            distUpgradeOnBoot: false
      versions:
        kubelet: "1.28.0"
```

## AMI Selection

### Auto-Selection (Recommended)

Leave the `ami` field empty to let machine-controller auto-select the appropriate AMI based on the operating system and region.

### Finding Ubuntu AMIs

```bash
# Latest Ubuntu 22.04 LTS
aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].[ImageId,Name]' \
  --output table --region us-east-1
```

### Finding Amazon Linux 2 AMIs

```bash
# Using Systems Manager Parameter Store
aws ssm get-parameter \
  --name /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 \
  --region us-east-1 \
  --query 'Parameter.Value' \
  --output text
```

## Network Configuration

### Public vs Private Subnets

**Public Subnet** (with Internet Gateway):
```yaml
cloudProviderSpec:
  subnetId: "subnet-public"
  assignPublicIP: true
```

**Private Subnet** (with NAT Gateway):
```yaml
cloudProviderSpec:
  subnetId: "subnet-private"
  assignPublicIP: false
```

### Security Groups

Machine-controller creates a `kubernetes-v1` security group by default. To use custom security groups:

```yaml
cloudProviderSpec:
  securityGroupIDs:
    - "sg-worker-nodes"
    - "sg-cluster-communication"
```

Required ingress rules:
- Port 10250: Kubelet API (from control plane)
- Port 30000-32767: NodePort services (optional)
- ICMP: For health checks
- All traffic from cluster CIDR

## IAM Configuration

### Worker Node IAM Policy

Create an IAM policy for worker nodes:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeRegions",
        "ec2:DescribeRouteTables",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVolumes",
        "ec2:DescribeAvailabilityZones",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyVolume",
        "ec2:AttachVolume",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:DeleteRoute",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteVolume",
        "ec2:DetachVolume",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:DescribeVpcs",
        "elasticloadbalancing:*",
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup"
      ],
      "Resource": "*"
    }
  ]
}
```

### Create IAM Role and Instance Profile

```bash
# Create role
aws iam create-role \
  --role-name KubernetesWorkerRole \
  --assume-role-policy-document file://trust-policy.json

# Attach policy
aws iam attach-role-policy \
  --role-name KubernetesWorkerRole \
  --policy-arn arn:aws:iam::ACCOUNT_ID:policy/KubernetesWorkerPolicy

# Create instance profile
aws iam create-instance-profile \
  --instance-profile-name KubernetesWorkerProfile

# Add role to instance profile
aws iam add-role-to-instance-profile \
  --instance-profile-name KubernetesWorkerProfile \
  --role-name KubernetesWorkerRole
```

## Spot Instances

### Configuration

```yaml
cloudProviderSpec:
  isSpotInstance: true
  spotInstanceMaxPrice: "0.10"  # Maximum price per hour
  spotInstanceInterruptionBehavior: "terminate"  # or "stop"
  spotInstancePersistentRequest: false
```

### Best Practices

1. **Use for Fault-Tolerant Workloads**: Batch jobs, stateless apps
2. **Set Appropriate Max Price**: Based on on-demand price
3. **Use Multiple Instance Types**: Spread across types for availability
4. **Handle Interruptions**: Use node problem detector and pod disruption budgets
5. **Mix with On-Demand**: Don't rely solely on spot instances

## Disk Configuration

### EBS Volume Types

- **gp3** (default): General purpose SSD, best price/performance
- **gp2**: General purpose SSD, older generation
- **io1/io2**: Provisioned IOPS SSD, for high-performance databases
- **st1**: Throughput optimized HDD, for big data
- **sc1**: Cold HDD, for infrequent access
- **standard**: Magnetic, legacy

### Example Configurations

**High IOPS:**
```yaml
cloudProviderSpec:
  diskSize: 500
  diskType: "io2"
  diskIops: 64000
  ebsVolumeEncrypted: true
```

**High Throughput:**
```yaml
cloudProviderSpec:
  diskSize: 500
  diskType: "gp3"
  diskIops: 16000
  diskThroughput: 1000
```

## Troubleshooting

### Instance Creation Fails

```bash
# Check machine events
kubectl describe machine <machine-name> -n kube-system

# Common issues:
# - Insufficient IAM permissions
# - Invalid subnet/VPC configuration
# - Instance type not available in AZ
# - Exceeded EC2 limits/quotas
```

### Nodes Not Joining Cluster

```bash
# SSH to instance (if accessible)
ssh -i key.pem ubuntu@<instance-ip>

# Check cloud-init logs
sudo cat /var/log/cloud-init-output.log

# Check kubelet
sudo systemctl status kubelet
sudo journalctl -u kubelet -f
```

### Security Group Issues

```bash
# Verify security group allows required ports
aws ec2 describe-security-groups \
  --group-ids sg-xxxxx \
  --region us-east-1
```

## Multi-AZ Deployment

Deploy workers across multiple availability zones:

```yaml
---
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: workers-us-east-1a
  namespace: kube-system
spec:
  replicas: 2
  template:
    spec:
      providerSpec:
        value:
          cloudProviderSpec:
            availabilityZone: "us-east-1a"
            subnetId: "subnet-az-a"
---
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: workers-us-east-1b
  namespace: kube-system
spec:
  replicas: 2
  template:
    spec:
      providerSpec:
        value:
          cloudProviderSpec:
            availabilityZone: "us-east-1b"
            subnetId: "subnet-az-b"
```

## Best Practices

1. **Use Instance Profiles**: Prefer IAM roles over static credentials
2. **Enable EBS Encryption**: For compliance and security
3. **Tag Resources**: Use consistent tagging for cost tracking
4. **Use Private Subnets**: Deploy workers in private subnets with NAT
5. **Multi-AZ Deployment**: Spread workers across AZs for HA
6. **Right-Size Instances**: Start small, scale based on metrics
7. **Monitor Costs**: Use AWS Cost Explorer and set up billing alerts
8. **Use Latest AMIs**: Keep AMIs updated for security patches

## Resources

- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [EC2 Instance Types](https://aws.amazon.com/ec2/instance-types/)
- [EBS Volume Types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html)
- [Spot Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

