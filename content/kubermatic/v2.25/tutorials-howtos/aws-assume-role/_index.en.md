+++
title = "Deploy with AWS AssumeRole"
date = 2022-01-04T10:23:15+02:00
weight = 19

+++

AWS provides a feature called [AssumeRole][aws-docs-assume-role] to retrieve temporary security credentials for IAM roles.
The IAM roles can belong to someone elses AWS account, allowing you to act on their behalf.
Using KKP you are able to use the `AssumeRole` feature to easily deploy user clusters to AWS accounts that you normally do not have access to.

## How it Works

![Running user clusters using an assumed IAM role](/img/kubermatic/v2.25/tutorials/aws-assume-role-sequence-diagram.png?width=1000&classes=shadow,border "Running user clusters using an assumed IAM role")

## Benefits
  * Privilege escalation
    - Get access to someones elses AWS account (e.g. a customer) to run user clusters on their behalf
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

![Enabling AWS AssumeRole in the cluster creation wizard](/img/kubermatic/v2.25/tutorials/aws-assume-role-wizard.png?classes=shadow,border "Enabling AWS AssumeRole in the cluster creation wizard")

## Notes
Please note that KKP has no way to clean up clusters after a trust relationship has been removed.
You should assure that all resources managed by KKP have been shut down before removing access.

[aws-docs-assume-role]: https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html
[aws-docs-how-to-trust-policies]: https://aws.amazon.com/blogs/security/how-to-use-trust-policies-with-iam-roles/
[aws-docs-confused-deputy]: https://docs.aws.amazon.com/IAM/latest/UserGuide/confused-deputy.html
