+++
title = "AWS"
date = 2018-09-20T12:12:15+02:00
weight = 7

+++

## AWS

Ensure that the user used by the machine-controller has (at least) the following IAM permissions:

{{% notice note %}}
Permissions listed here are permission required by the Kubermatic machine-controller. Terraform, and components deployed by KubeOne (such as external cloud-controller-manager) might require additional permissions.
{{% /notice %}}

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetInstanceProfile",
                "iam:ListInstanceProfiles"
            ],
            "Resource": "arn:aws:iam::YOUR_ACCOUNT_ID:instance-profile/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:DeleteRolePolicy",
                "iam:GetRole",
                "iam:ListAttachedRolePolicies",
                "iam:ListRolePolicies",
                "iam:PassRole",
                "iam:PutRolePolicy"
            ],
            "Resource": "arn:aws:iam::YOUR_ACCOUNT_ID:role/YOUR_CLUSTER_NAME-*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:AddRoleToInstanceProfile",
                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:GetInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile"
            ],
            "Resource": "arn:aws:iam::YOUR_ACCOUNT_ID:instance-profile/YOUR_CLUSTER_NAME-*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:ConfigureHealthCheck",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteRule",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyRule",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetRulePriorities",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:SetWebAcl",
                "sts:GetFederationToken"
            ],
            "Resource": "*"
        }
    ]
}
```

- YOUR_ACCOUNT_ID is the account ID on AWS <https://docs.aws.amazon.com/IAM/latest/UserGuide/console_account-alias.html>
- YOUR_CLUSTER_NAME is the name of your kubeone cluster.
