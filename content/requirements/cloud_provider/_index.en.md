+++
title = "Cloud Provider"
date = 2018-07-04T12:07:15+02:00
weight = 7
pre = "<b></b>"
+++

## Cloud Provider

### AWS

* Enure that all seed cluster related resources (instances, securitygroups, etc.) in AWS are tagged with the same clustertag as defined in the cloudprovider config (in AWS the tag is called `kubernetes.io/cluster/NAMEOFYOURCLUSTER` and the required value is `shared`).

* Ensure that the seed cluster has (atleast) the following IAM permissions:

    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "VisualEditor0",
                "Effect": "Allow",
                "Action": [
                    "iam:ListRoles"
                ],
                "Resource": [
                    "arn:aws:iam::ACCOUNTID:role/",
                    "arn:aws:iam::ACCOUNTID:role/*"
                ]
            },
            {
                "Sid": "VisualEditor2",
                "Effect": "Allow",
                "Action": [
                    "iam:ListInstanceProfiles"
                ],
                "Resource": [
                    "arn:aws:iam::ACCOUNTID:instance-profile/"
                ]
            },
            {
                "Sid": "VisualEditor1",
                "Effect": "Allow",
                "Action": [
                    "iam:GetRole",
                    "iam:PassRole",
                    "iam:ListRolePolicies"
                    "iam:ListAttachedRolePolicies",
                    "iam:DeleteRolePolicy",
                    "iam:DetachRolePolicy"
                ],
                "Resource": [
                    "arn:aws:iam::ACCOUNTID:role/SpacesKubermatic",
                    "arn:aws:iam::ACCOUNTID:role/kubermatic-*"
                ]
            },
            {
                "Sid": "UseKubermaticRoles",
                "Effect": "Allow",
                "Action": [
                    "iam:AttachRolePolicy",
                    "iam:CreateRole",
                    "iam:DeleteRole"
                ],
                "Resource": [
                    "arn:aws:iam::ACCOUNTID:role/kubermatic-*"
                ]
            },
            {
                "Sid": "UseInstanceProfiles",
                "Effect": "Allow",
                "Action": [
                    "iam:CreateInstanceProfile",
                    "iam:GetInstanceProfile",
                    "iam:DeleteInstanceProfile",
                    "iam:AddRoleToInstanceProfile",
                    "iam:RemoveRoleFromInstanceProfile"
                ],
                "Resource": [
                    "arn:aws:iam::ACCOUNTID:instance-profile/kubermatic-*"
                ]
            }
        ]
    }
    ```
