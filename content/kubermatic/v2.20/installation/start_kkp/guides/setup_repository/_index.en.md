+++
title = "Setup your Git repository"
weight = 30
+++

The goal of the setup is to put the downloaded directory structure into your Git repository,
so let’s get started with creating a fresh repository for this purpose and then setup the required Variables or Secrets before
pushing the code to the repository.

{{% notice warning %}}
Following sections will be different based on the combination of Git and Cloud providers you have chosen.
{{% /notice %}}

## Create Git repository

{{< tabs name="Create Git repository" >}}
{{% tab name="GitHub" %}}
Create a new repository on GitHub [manually](https://docs.github.com/en/get-started/quickstart/create-a-repo) or using [GitHub CLI](https://cli.github.com/manual/gh_repo_create).

Also prepare an [Access token](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token)
for GitHub which will be used in the next section while preparing Secrets. Token will be used for the Flux bootstrap on repository.
{{% /tab %}}
{{% tab name="GitLab" %}}
Create new repository on GitLab [manually](https://docs.gitlab.com/ee/user/project/working_with_projects.html#create-a-project).

Also prepare a [GitLab API token](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html) which will be used for GitOps setup. [Project access token](https://docs.gitlab.com/ee/user/project/settings/project_access_tokens.html) can be used as well.
{{% /tab %}}
{{% tab name="Bitbucket" %}}
Create new repository on Bitbucket [manually](https://support.atlassian.com/bitbucket-cloud/docs/create-a-git-repository/).

The generated SSH Key on the next step will be added to your [SSH Keys](https://bitbucket.org/account/settings/ssh-keys/) for GitOps setup.
{{% /tab %}}
{{% /tabs %}}


## Prepare Cloud provider credentials

{{< tabs name="Cloud Provider Credentials" >}}
{{% tab name="AWS" %}}
Login to [AWS console](https://console.aws.amazon.com/console) and create your access keys under IAM or using
AWS CLI `aws iam create-access-key`.

{{% notice warning %}}
Credentials should be static and do not utilize any tools like `aws-iam-authenticator` because they are also stored as secret in your Kubernetes cluster.
{{% /notice %}}

{{% /tab %}}
{{% tab name="Azure" %}}
Login to [Azure portal](https://portal.azure.com/) and create a role and service account (application).

See [KubeOne documentation]({{< ref "../../../../../../kubeone/main/architecture/requirements/machine-controller/azure/" >}}) for more details.

Values of tenantId, subscriptionId, clientId and clientSecret will be set in the variables / secrets for the pipeline.

See [terraform setup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#argument-reference) requirements.
{{% /tab %}}
{{% tab name="GCP" %}}
You need a Service Account with the appropriate permissions for Terraform to create the infrastructure and for machine-controller to create worker nodes.

Use `gcloud` CLI tool to create these credentials.

```bash
export GCLOUD_PROJECT="{{ .Configuration.KubernetesSpec.CloudProvider.GCE.Project }}"
export SERVICE_ACCOUNT_NAME="k1-cluster-provisioner"
gcloud config set project $GCLOUD_PROJECT
# create new service account
gcloud iam service-accounts create "${SERVICE_ACCOUNT_NAME}"
# get your service account id
export SERVICE_ACCOUNT_ID=$(gcloud iam service-accounts list --filter="name:${SERVICE_ACCOUNT_NAME}" --format='value(email)')
# create policy bindings for KKP
gcloud projects add-iam-policy-binding "${GCLOUD_PROJECT}" --member="serviceAccount:${SERVICE_ACCOUNT_ID}" --role='roles/compute.admin'
gcloud projects add-iam-policy-binding "${GCLOUD_PROJECT}" --member="serviceAccount:${SERVICE_ACCOUNT_ID}" --role='roles/iam.serviceAccountUser'
gcloud projects add-iam-policy-binding "${GCLOUD_PROJECT}" --member="serviceAccount:${SERVICE_ACCOUNT_ID}" --role='roles/viewer'
gcloud projects add-iam-policy-binding "${GCLOUD_PROJECT}" --member="serviceAccount:${SERVICE_ACCOUNT_ID}" --role='roles/storage.admin'
# create policy bindings for Google GitHub actions
gcloud iam service-accounts add-iam-policy-binding ${SERVICE_ACCOUNT_ID} --member="serviceAccount:${SERVICE_ACCOUNT_ID}" --role='roles/iam.serviceAccountTokenCreator'
# create a new json key for your service account
gcloud iam service-accounts keys create --iam-account "${SERVICE_ACCOUNT_ID}" "${SERVICE_ACCOUNT_NAME}-sa-key.json"
# check JSON file content of created service account json key, value will be used for GOOGLE_CREDENTIALS variable later
cat "${SERVICE_ACCOUNT_NAME}-sa-key.json"
```

See [KubeOne documentation]({{< ref "../../../../../../kubeone/main/architecture/requirements/machine-controller/google-cloud/" >}}) for more details.
{{% /tab %}}
{{% tab name="OpenStack" %}}
Terraform provider will need to set the environment variables to access the OpenStack API.

See there related [KubeOne documentation]({{< ref "../../../../../../kubeone/main/guides/credentials/#environment-variables" >}}), select OpenStack tab.
{{% /tab %}}
{{% tab name="vSphere" %}}
Terraform provider will need to set the environment variables to access the vSphere instance.

See there related [KubeOne documentation]({{< ref "../../../../../../kubeone/main/guides/credentials/#environment-variables" >}}), select vSphere tab and
pay attention to the vSphere specific [permissions]({{< ref "../../../../../../kubeone/main/architecture/requirements/machine-controller/vsphere/" >}}).
{{% /tab %}}
{{% /tabs %}}

## Generate SSH keys

SSH public/private key-pair is used for accessing the cluster nodes. You can generate these keys locally, and you will need to set them inside the Pipeline Variables below.

You can use following command to generate the keys:
```bash
ssh-keygen -t rsa -b 4096 -C "admin@kubermatic.com" -f ~/.ssh/k8s_rsa
```

{{% notice warning %}}
Make sure you don't have a passphrase set on the private key as it would cause an issue in automated pipeline.
{{% /notice %}}

## Setup Pipeline Secrets / Variables

Preparation of pipeline variables depends on selected Git and Cloud provider combination.

Please pay attention to the following combination to include all required variables for pipeline to run.

{{< tabs name="Git Variables" >}}
{{% tab name="GitHub" %}}
Go to your GitHub repository under **Settings** -> **Secrets** and setup following secrets:

| Secret Name             | Description                                                          |
| ------------------------| ---------------------------------------------------------------------|
| `SOPS_AGE_SECRET_KEY`   | The generated AGE secret key (see _secrets.md_ file)                 |
| `TOKEN_GITHUB`          | The GitHub access token from above step                              |
| `SSH_PRIVATE_KEY`       | The private SSH key (content of `~/.ssh/k8s_rsa`) from above step    |
| `SSH_PUBLIC_KEY`        | The public SSH key (content of `~/.ssh/k8s_rsa.pub`) from above step |
{{% /tab %}}
{{% tab name="GitLab" %}}
Go to your GitLab project under "Settings" -> "CI/CD" -> "Variables" and setup following variables:

| Secret Name             | Description                                                          |
| ------------------------| ---------------------------------------------------------------------|
| `SOPS_AGE_SECRET_KEY`   | The generated AGE secret key (see _secrets.md_ file)                 |
| `GITLAB_TOKEN`          | The GitLab access token from above step                              |
| `SSH_PRIVATE_KEY`       | The private SSH key (content of `~/.ssh/k8s_rsa`) from above step    |
| `SSH_PUBLIC_KEY`        | The public SSH key (content of `~/.ssh/k8s_rsa.pub`) from above step |
{{% /tab %}}
{{% tab name="Bitbucket" %}}
Go to your Bitbucket project under "Repository Settings" -> "PIPELINES" -> "Settings" and click on "Enable Pipelines".

Then navigate to "Repository Settings" -> "PIPELINES" -> "Repository Variables" and setup following variables (Make sure that "Secured" is always set):

| Secret Name             | Description                                                                       |
| ------------------------|-----------------------------------------------------------------------------------|
| `SOPS_AGE_SECRET_KEY`   | The generated AGE secret key (see _secrets.md_ file)                              |
| `SSH_PRIVATE_KEY`       | Base64 encoded value of private SSH key (`base64 -w0 k8s_rsa`) from above step    |
| `SSH_PUBLIC_KEY`        | Base64 encoded value of public SSH key (`base64 -w0 k8s_rsa.pub`) from above step |
{{% /tab %}}
{{% /tabs %}}

In addition to above, configure following secrets for selected cloud provider.

{{< tabs name="Cloud provider variables" >}}
{{% tab name="AWS" %}}
| Secret Name             | Description                                                          |
| ------------------------| ---------------------------------------------------------------------|
| `AWS_ACCESS_KEY_ID`     | The AWS Access Key ID from above step                                |
| `AWS_SECRET_ACCESS_KEY` | The AWS Secret Access Key from above step                            |
{{% /tab %}}
{{% tab name="Azure" %}}
| Secret Name             | Description                                                          |
| ------------------------| ---------------------------------------------------------------------|
| `ARM_TENANT_ID`         | The Azure tenant ID                                                  |
| `ARM_SUBSCRIPTION_ID`   | The Azure Subscription ID                                            |
| `ARM_CLIENT_ID`         | The Azure Client ID (Application)                                    |
| `ARM_CLIENT_SECRET`     | The Azure Client Secret for client authentication                    |
{{% /tab %}}
{{% tab name="GCP" %}}
For **GitHub** and **GitLab**:
| Secret Name             | Description                                                                                |
| ------------------------| -------------------------------------------------------------------------------------------|
| `GOOGLE_CREDENTIALS`    | The service account key (content of `${SERVICE_ACCOUNT_NAME}-sa-key.json`) from above step |

For **Bitbucket**:
| Secret Name             | Description                                                                                |
| ------------------------| -------------------------------------------------------------------------------------------|
| `GCLOUD_SERVICE_KEY`    | The Base64 encoded service account key (`base64 -w0 ${SERVICE_ACCOUNT_NAME}-sa-key.json`). |
{{% /tab %}}
{{% tab name="OpenStack" %}}
| Secret Name             | Description                                                          |
| ------------------------| -------------------------------------------------------------------- |
| `OS_AUTH_URL`           | The URL of OpenStack Identity Service                                |
| `OS_USERNAME`           | The username of the OpenStack user                                   |
| `OS_PASSWORD`           | The password of the OpenStack user                                   |
| `OS_DOMAIN_NAME`        | The name of the OpenStack domain                                     |
| `OS_TENANT_ID`          | The ID of the OpenStack tenant (project)                             |
| `OS_TENANT_NAME`        | The name of the OpenStack tenant (project)                           |
{{% /tab %}}
{{% tab name="vSphere" %}}
| Secret Name             | Description                                                          |
| ------------------------| -------------------------------------------------------------------- |
| `VSPHERE_SERVER`        | The vCenter server name for vSphere API operations                   |
| `VSPHERE_USER`          | The username for vSphere API operations                              |
| `VSPHERE_PASSWORD`      | The password for vSphere API operations                              |
{{% /tab %}}
{{% /tabs %}}

## Commit and push the content to Git repository

Now it’s time to push the generated structure in your repository.

Example:
```bash
git init
git checkout -b main
git add .
git commit -m "Initial setup for KKP on Autopilot"
git remote add origin <your-git-repository-remote>
git push -u origin main
```

## Enjoy automated pipeline delivery

At this point, GitHub Workflow, GitLab's CI/CD pipeline or Bitbucket Pipeline should be triggered, and you can watch it on your repository.
After all steps are complete, it may still take a few minutes to reconcile the required state (as the Flux is delivering additional steps independently).

![GitHub Workflow](pipeline.png?width=700px&classes=shadow,border "GitHub Workflow")

Congratulations, now it’s time to login to your KKP and create your first user cluster!

![KKP Login Page](kkp-login.png?width=700px&classes=shadow,border "KKP Login Page")
![KKP UI](kkp-ui.png?width=700px&classes=shadow,border "KKP UI")

See the details about creating User Cluster in Kubermatic Kubernetes Platform [documentation]({{< ref "../../../../tutorials_howtos/project_and_cluster_management/" >}}).
