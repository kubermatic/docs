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
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "iam:ListInstanceProfiles",
            "Resource": "arn:aws:iam::< YOUR_ACCOUNT_ID >g:instance-profile/*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:PassRole",
                "iam:DetachRolePolicy",
                "iam:ListAttachedRolePolicies",
                "iam:DeleteRolePolicy",
                "iam:ListRolePolicies"
            ],
            "Resource": [
                "arn:aws:iam::< YOUR_ACCOUNT_ID >g:role/SpacesKubermatic",
                "arn:aws:iam::< YOUR_ACCOUNT_ID >g:role/kubermatic-*"
            ]
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:AttachRolePolicy"
            ],
            "Resource": "arn:aws:iam::< YOUR_ACCOUNT_ID >g:role/kubermatic-*"
        },
        {
            "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": [
                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:GetInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:AddRoleToInstanceProfile"
            ],
            "Resource": "arn:aws:iam::< YOUR_ACCOUNT_ID >g:instance-profile/kubermatic-*"
        },
        {
            "Sid": "VisualEditor4",
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:ModifyListener",
                "sts:GetFederationToken",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetRulePriorities",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:SetWebAcl",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:DeleteRule",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:*",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:ModifyRule",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:DescribeTargetGroups",
                "ec2:*",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:DeleteListener"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor5",
            "Effect": "Allow",
            "Action": "iam:CreateRole",
            "Resource": "arn:aws:iam::< YOUR_ACCOUNT_ID >:role/kubermatic-*"
        },
        {
            "Sid": "VisualEditor6",
            "Effect": "Allow",
            "Action": "iam:AttachRolePolicy",
            "Resource": "arn:aws:iam::< YOUR_ACCOUNT_ID >:role/kubermatic-*"
        },
        {
            "Sid": "VisualEditor7",
            "Effect": "Allow",
            "Action": "iam:CreateInstanceProfile",
            "Resource": "arn:aws:iam::< YOUR_ACCOUNT_ID >:instance-profile/kubermatic-instance-profile-*"
        },
        {
            "Sid": "VisualEditor8",
            "Effect": "Allow",
            "Action": "iam:AddRoleToInstanceProfile",
            "Resource": "arn:aws:iam::< YOUR_ACCOUNT_ID >:instance-profile/kubermatic-instance-profile-*"
        },
        {
            "Sid": "VisualEditor9",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::< YOUR_ACCOUNT_ID >:role/kubermatic-role-*"
        },
        {
            "Sid": "VisualEditor10",
            "Effect": "Allow",
            "Action": "iam:GetRole",
            "Resource": "arn:aws:iam::< YOUR_ACCOUNT_ID >:role/kubermatic-role-*"
        },
        {
            "Sid": "VisualEditor11",
            "Effect": "Allow",
            "Action": "iam:GetInstanceProfile",
            "Resource": "arn:aws:iam::< YOUR_ACCOUNT_ID >:instance-profile/kubermatic-*"
        },
        {
            "Sid": "VisualEditor12",
            "Effect": "Allow",
            "Action": "iam:RemoveRoleFromInstanceProfile",
            "Resource": "arn:aws:iam::< YOUR_ACCOUNT_ID >:instance-profile/kubermatic-*"
        },
        {
            "Sid": "VisualEditor13",
            "Effect": "Allow",
            "Action": "iam:DeleteInstanceProfile",
            "Resource": "arn:aws:iam::< YOUR_ACCOUNT_ID >:instance-profile/kubermatic-*"
        },
        {
            "Sid": "VisualEditor14",
            "Effect": "Allow",
            "Action": "iam:ListAttachedRolePolicies",
            "Resource": "arn:aws:iam::< YOUR_ACCOUNT_ID >:role/kubermatic-*"
        },
        {
            "Sid": "VisualEditor15",
            "Effect": "Allow",
            "Action": "iam:DetachRolePolicy",
            "Resource": "arn:aws:iam::< YOUR_ACCOUNT_ID >:role/kubermatic-*"
        },
        {
            "Sid": "VisualEditor16",
            "Effect": "Allow",
            "Action": [
                "iam:DeleteInstanceProfile",
                "iam:DeleteRole"
            ],
            "Resource": [
                "arn:aws:iam::< YOUR_ACCOUNT_ID >:instance-profile/kubermatic-*",
                "arn:aws:iam::< YOUR_ACCOUNT_ID >:role/kubermatic-*"
            ]
        }
    ]
}
```
</details>
