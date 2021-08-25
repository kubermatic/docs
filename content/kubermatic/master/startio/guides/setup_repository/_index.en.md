+++
title = "Setup your GitHub repository"
weight = 30
enableToc = true
+++

The goal of the setup is to put the downloaded directory structure into your GitHub repository,
so let’s get started with creating a fresh repository for this purpose and then setup the GitHub Secrets before
pushing the code to the repository.

## Create GitHub repository

Create a new repository on GitHub [manually](https://docs.github.com/en/get-started/quickstart/create-a-repo) or using [GitHub CLI](https://cli.github.com/manual/gh_repo_create).

Also prepare an [Access token](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token)
for GitHub which will be used for GitOps tool bootstrap.


## Prepare AWS credentials

Login to [AWS console](https://console.aws.amazon.com/console) and create your access keys under IAM or using
AWS CLI `aws iam create-access-key`.

Credentials should be static and do not utilize any tools like `aws-iam-authenticator` because they are also stored as secret in your Kubernetes cluster.


## Generate SSH keys

SSH public/private key-pair is used for accessing the cluster nodes. You can generate these keys locally and you will need to set them inside the GitHub Secrets below.

You can use following command to generate the keys:
```shell
ssh-keygen -t rsa -b 4096 -C "admin@kubermatic.com"
```

You will be prompted to provide a key location, e.g. `k8s_rsa`.


## Setup GitHub Secrets

Go to your GitHub repository under **Settings** -> **Secrets** and setup following secrets:

* `AWS_ACCESS_KEY_ID` with value of _AccessKeyId_ from above step
* `AWS_SECRET_ACCESS_KEY` with value of _SecretAccessKey_ from above step
* `SOPS_AGE_SECRET_KEY` with value of generated AGE secret key (see secrets.md file)
* `TOKEN_GITHUB` with value of GitHub access token from above step
* `SSH_PRIVATE_KEY` with value of private SSH key (e.g. `k8s_rsa`)
* `SSH_PUBLIC_KEY` with value of public SSH key (e.g. `k8s_rsa.pub`)

## Commit and push the content to GitHub repository

Now it’s time to push the generated structure in your repository.

Example:
```shell
git init
git checkout -b main
git add .
git commit -m "Initial setup for KKP on Autopilot"
git remote add origin git@github.com:<GITHUB_OWNER>/<GITHUB_REPOSITORY>
git push -u origin main
```

## Enjoy automated pipeline delivery

At this point, GitHub Workflow should be triggered and you can watch it in the *Actions* menu on your repository.
After all steps are complete, it may still take a few minutes to reconcile the required state (as the Flux is delivering additional steps independently).

![GitHub Workflow](pipeline.png?width=700px&classes=shadow,border "GitHub Workflow")

Congratulations, now it’s time to login to your KKP and create your first user cluster!

![KKP Login Page](kkp-login.png?width=700px&classes=shadow,border "KKP Login Page")
![KKP UI](kkp-ui.png?width=700px&classes=shadow,border "KKP UI")

See the details about creating User Cluster in Kubermatic Kubernetes Platform [documentation]({{< ref "../../../tutorials_howtos/project_and_cluster_management/" >}}).