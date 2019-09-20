+++
title = "AWS"
date = 2018-09-20T12:12:15+02:00
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
            "Action": [
                "iam:ListInstanceProfiles",
                "iam:GetInstanceProfile"
            ],
            "Resource": "arn:aws:iam::YOUR_ACCOUNT_ID:instance-profile/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:PutRolePolicy",
                "iam:PassRole",
                "iam:ListRolePolicies",
                "iam:ListAttachedRolePolicies",
                "iam:DeleteRolePolicy",
                "iam:CreateRole",
                "iam:DeleteRole"
            ],
            "Resource": "arn:aws:iam::YOUR_ACCOUNT_ID:role/kubernetes-*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:AddRoleToInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:GetInstanceProfile",
                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile"
            ],
            "Resource": "arn:aws:iam::YOUR_ACCOUNT_ID:instance-profile/kubernetes-*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*",
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
        }
    ]
}
```
</details>
