+++
title = "How To run Clusters on AWS using assumed roles"
date = 2022-01-04T10:23:15+02:00
weight = 16

+++

AWS provides a feature called [AssumeRole][aws-docs-assume-role] to retrieve temporary security credentials (access key ID, secret access key and session ID) for AWS resources and actions that you do not have regular access to (e. g. accessing and creating resources in the AWS account of a customer).
Using KKP you are able to use the `AssumeRole` feature to run user clusters in someone elses AWS account.

## How it works

![How to run user clusters on AWS using assumed roles](/img/kubermatic/master/tutorials/aws_assume_role_sequence_diagram.png?width=1000&classes=shadow,border "How to run user clusters on AWS using assumed roles")

## Benefits
  * Privilege escalation
    - Get access to someones elses AWS account to run user clusters on their behalf
    - While not described here, it is also possible to assume a role belonging to the same AWS account to escalate your privileges inside of your account
  * Billing: All user cluster resources will be billed to **AWS account B** (the "external" account)
  * Control: The owner of **AWS account B** (e.g. the customer) has control over all resources created in his account

## Prerequisites
 * An **AWS account A** that is allowed to assume the **IAM role R** of a second **AWS account B**
    - **A** needs to be able to perform the API call `sts:AssumeRole`
    - You can test assuming the role by running the following AWS CLI command as **AWS account A**: \
    `aws sts assume-role --role-arn "arn:aws:iam::YOUR_AWS_ACCOUNT_B_ID:role/YOUR_IAM_ROLE" --role-session-name "test" --external-id "YOUR_EXTERNAL_ID_IF_SET"`
 * An **IAM role R** on **AWS account B**
    - The role should have all necessary permissions to run user clusters (IAM, EC2, Route53)
    - The role should have a trust relationship configured that allows **A** to assume the role **R**. Please refer to this [AWS article about trust relationships][aws-docs-how-to-trust-policies] for more information
    - Setting an `External ID` is optional but recommended when configuring the trust relationship. It helps avoiding the [confused deputy problem][aws-docs-confused-deputy]

## Usage
Creating a new cluster using an assumed role is a breeze.
During cluster creation choose AWS as your provider and configure the cluster to your liking.
After entering your AWS access credentials (access key ID and secret access key) choose "Enable Assume Role" (1), enter the ARN of the IAM role you would like to assume in field (2) (IAM role ARN should be in the format `arn:aws:iam::ID_OF_AWS_ACCOUNT_B:role/ROLE_NAME`) and if the IAM role has an optional `External ID` add it in field (3).
After that you can proceed as usual.

![Enabling AWS AssumeRole in the cluster creation wizard](/img/kubermatic/master/tutorials/aws_assume_role_wizard.png?classes=shadow,border "Enabling AWS AssumeRole in the cluster creation wizard")

## Notes
Please note that KKP has no way to clean up clusters after a trust relationship has been removed.
You should assure that all resources managed by KKP have been shut down before removing access.

[aws-docs-assume-role]: https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html
[aws-docs-how-to-trust-policies]: https://aws.amazon.com/blogs/security/how-to-use-trust-policies-with-iam-roles/
[aws-docs-confused-deputy]: https://docs.aws.amazon.com/IAM/latest/UserGuide/confused-deputy.html
