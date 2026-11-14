+++
title = "AWS"
date = 2026-11-14T12:00:00+02:00
weight = 5
+++

KubeOne can create the control plane EC2 instances and the kube-apiserver load balancer on AWS itself, so you don't have
to create them with Terraform.

When `controlPlane.nodeSets` is set together with `cloudProvider.aws.controlPlane`, `kubeone apply`:

1. Creates a Network Load Balancer (NLB) with a target group and a TCP
   listener, if they don't exist yet, and sets `apiEndpoint` from the DNS name
   of the NLB.
2. Creates the control plane instances with the machine-controller AWS
   driver.
3. Registers the private IP of each control plane instance in the target
   group.

## Prerequisites

* AWS credentials with permissions to manage EC2 instances and Elastic Load
  Balancing v2 resources (see [IAM Permissions](#iam-permissions)).
* A VPC with at least one subnet for the control plane instances. All nodeSets
  must use the same VPC.
* Security groups for the instances and, optionally, for the NLB. The NLB must
  be allowed to reach port 6443 of the instances.

The [`aws-managed-control-plane`][tf-aws-mcp] Terraform configs create the VPC
subnet, the security groups and an IAM instance profile, but no control plane
instances or load balancer. Use the values of the `vm`, `networking` and
`loadbalancer` Terraform outputs in the manifest.

## Credentials

KubeOne reads `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` from the
credentials file or from the environment. If they aren't set, KubeOne uses the
shared AWS config and credentials files with the profile from the
`AWS_PROFILE` environment variable.

```yaml
AWS_ACCESS_KEY_ID: <access-key-id>
AWS_SECRET_ACCESS_KEY: <secret-access-key>
```

### IAM Permissions

In addition to the permissions that KubeOne usually needs on AWS, the
credentials need these permissions:

* `ec2:RunInstances`, `ec2:DescribeInstances`, `ec2:TerminateInstances`,
  `ec2:CreateTags`, `ec2:DescribeSubnets`, `ec2:DescribeSecurityGroups`
* `elasticloadbalancing:CreateLoadBalancer`,
  `elasticloadbalancing:DescribeLoadBalancers`,
  `elasticloadbalancing:DeleteLoadBalancer`,
  `elasticloadbalancing:CreateTargetGroup`,
  `elasticloadbalancing:DescribeTargetGroups`,
  `elasticloadbalancing:DeleteTargetGroup`,
  `elasticloadbalancing:CreateListener`,
  `elasticloadbalancing:RegisterTargets`,
  `elasticloadbalancing:DescribeTargetHealth`

## Configuration

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: my-cluster

versions:
  kubernetes: 1.36.2

cloudProvider:
  external: true
  aws:
    # Region of the NLB, the target group and the instances. Required.
    region: eu-west-1
    controlPlane:
      loadBalancer:
        # Name of the NLB, at most 32 characters. Default: "<CLUSTER_NAME>-kubeapi"
        name: my-cluster-kubeapi
        # Create an internal NLB instead of an internet-facing one. Default: false
        internal: false
        # Security groups of the NLB
        securityGroupIDs:
          - sg-0123456789abcdef0 # allows port 6443
          - sg-061c2ae9af18bf42c # shared with the nodes
        # Additional tags of the NLB and the target group
        tags:
          env: production

controlPlane:
  nodeSets:
    - name: cp
      replicas: 3
      operatingSystem: ubuntu
      ssh:
        publicKeys:
          - ssh-ed25519 AAAA...
        username: ubuntu
      cloudProviderSpec:
        region: eu-west-1
        availabilityZone: eu-west-1a
        vpcId: vpc-05c39c9a3138e3f8f
        subnetId: subnet-0be46782596b4a0e3
        securityGroupIDs:
          - sg-061c2ae9af18bf42c # shared with the nodes
          - sg-0841224b2e84d2005 # SSH
        instanceProfile: my-cluster-host
        instanceType: t3a.medium
        assignPublicIP: true
        diskSize: 50
        diskType: gp3
```

The `cloudProviderSpec` is the [machine-controller AWS provider
spec][mc-aws].

### Load Balancer Options

| Field | Default | Description |
|-------|---------|-------------|
| `name` | `<CLUSTER_NAME>-kubeapi` | Name of the NLB, at most 32 characters. The target group is named `<name>-tg`, cut to 32 characters |
| `internal` | `false` | Create an internal NLB instead of an internet-facing one |
| `securityGroupIDs` | empty | Security groups of the NLB |
| `tags` | empty | Additional tags of the NLB and the target group |

KubeOne always adds the tags `kubeone_cluster_name: <CLUSTER_NAME>` and
`kubeone_role: api`.

## How the Load Balancer Works

During `kubeone apply`, KubeOne uses the Elastic Load Balancing v2 API to:

1. Find the NLB by name. If it exists, KubeOne reuses it, and its DNS name
   becomes `apiEndpoint.host`.
2. Otherwise, create:
   * A TCP target group on port 6443 with IP targets and a TCP health check
   * The NLB in the subnets of the nodeSets
   * A TCP listener on port 6443 that forwards to the target group
3. Register the private IP of each control plane instance in the target group
   as soon as the instance is created.

If `apiEndpoint` is already known from a previous run, KubeOne skips the load
balancer step.

## Creating the Cluster

```bash
kubeone apply --manifest kubeone.yaml --credentials credentials.yaml
```

## Destroying the Cluster

```bash
kubeone reset --manifest kubeone.yaml --credentials credentials.yaml \
  --destroy-control-plane \
  --destroy-control-plane-load-balancer
```

This deletes the control plane instances, the NLB and the target group. Then
delete the rest of the infrastructure with `terraform destroy`.

[tf-aws-mcp]: https://github.com/kubermatic/kubeone/tree/main/examples/terraform/aws-managed-control-plane
[mc-aws]: https://github.com/kubermatic/machine-controller/blob/main/docs/cloud-provider.md#aws
