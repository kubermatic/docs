+++
title = "AWS"
date = 2018-07-04T12:07:15+02:00
weight = 7
pre = "<b></b>"
+++

## AWS

<details>
<summary>**Ensure that the user used to create clusters via Kubermatic has (atleast) the following IAM permissions (Click to expand):** </summary>

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "iam:ListInstanceProfiles",
            "Resource": "arn:aws:iam::YOUR_ACCOUNT_ID:instance-profile/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:DeleteRolePolicy",
                "iam:DetachRolePolicy",
                "iam:GetRole",
                "iam:ListAttachedRolePolicies",
                "iam:ListRolePolicies",
                "iam:PassRole"
            ],
            "Resource": [
                "arn:aws:iam::YOUR_ACCOUNT_ID:role/SpacesKubermatic",
                "arn:aws:iam::YOUR_ACCOUNT_ID:role/kubermatic-*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:AddRoleToInstanceProfile",
                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:DeleteRole",
                "iam:GetInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile"
            ],
            "Resource": "arn:aws:iam::YOUR_ACCOUNT_ID:instance-profile/kubermatic-*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "elasticloadbalancing:*",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteRule",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyRule",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetRulePriorities",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:SetWebAcl",
                "sts:GetFederationToken"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:AttachRolePolicy",
                "iam:CreateRole",
                "iam:DeleteInstanceProfile",
                "iam:DeleteRole"
            ],
            "Resource": "arn:aws:iam::YOUR_ACCOUNT_ID:role/kubermatic-*"
        }
    ]
}
```
</details>
