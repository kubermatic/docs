+++
title = "Configuring Credentials"
date = 2020-08-03T12:00:00+02:00
weight = 1
enableToc = true
+++

KubeOne deploys the provider credentials to the cluster to be used by
components such as
[Kubernetes cloud-controller-manager][cloud-controller-manager] and 
[Kubermatic machine-controller][machine-controller]. Those components
communicate with the provider's API to the create worker nodes, pull the node
metadata, provide advanced capabilities such as LoadBalancer Services and more.
Besides that, Terraform uses the credentials to provision and manage the
infrastructure.

KubeOne can grab credentials from the user's environment or the user can
provide the needed credentials in a dedicated credentials file.

{{% notice warning %}}
As credentials are deployed to the cluster, it's recommended to use
dedicated, non-administrator credentials whenever it's possible.
{{% /notice %}}

{{% notice note %}}
You can skip this document if you're deploying to bare-metal or provider that's
not [natively supported]({{< ref "../compatibility_info#supported-providers" >}}).
{{% /notice %}}

{{% notice note %}}
The credentials file is KubeOne-specific and it will **not** work with
Terraform. If you are using Terraform, consider the
[environment variables approach]({{< ref "#environment-variables" >}}) or check
the Terraform documentation for other authentication options.
{{% /notice %}}

## Environment Variables

By default, KubeOne grabs credentials from the user's environment unless the
credentials file is provided. In the following tables, you can find the 
environment variables used by KubeOne.

{{< tabs name="Environment Variables" >}}
{{% tab name="AWS" %}}
You need an [IAM account](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)
with the appropriate permissions for Terraform to create the infrastructure
and for machine-controller to create worker nodes.

| Environment Variable    | Description                                                                                                                                               |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AWS_ACCESS_KEY_ID`     | The AWS Access Key                                                                                                                                        |
| `AWS_SECRET_ACCESS_KEY` | The AWS Secret Access Key                                                                                                                                 |
| `AWS_PROFILE`           | Name of the profile defined in the `~/.aws/credentials` file. This variable is considered only if `AWS_ACCESS_KEY_ID` or `AWS_SECRET_ACCESS_KEY` is unset |

#

{{% /tab %}}
{{% tab name="Azure" %}}
The following environment variables are needed by machine-controller for
creating worker nodes.

For the Terraform reference please take a look at
[Azure provider docs](https://www.terraform.io/docs/providers/azurerm/index.html#argument-reference).

| Environment Variable  | Description          |
| --------------------- | -------------------- |
| `ARM_CLIENT_ID`       | Azure ClientID       |
| `ARM_CLIENT_SECRET`   | Azure Client secret  |
| `ARM_TENANT_ID`       | Azure TenantID       |
| `ARM_SUBSCRIPTION_ID` | Azure SubscriptionID |

#

{{% /tab %}}
{{% tab name="DigitalOcean" %}}
You need an [API Access Token](https://www.digitalocean.com/docs/api/create-personal-access-token/)
with read and write permission for Terraform to create the infrastructure,
machine-controller to create the worker nodes, and for DigitalOcean Cloud
Controller Manager.

| Environment Variable | Description                                                   |
| -------------------- | ------------------------------------------------------------- |
| `DIGITALOCEAN_TOKEN` | The DigitalOcean API Access Token with read/write permissions |

#

{{% /tab %}}
{{% tab name="GCP" %}}
You need an [Service Account](https://cloud.google.com/iam/docs/creating-managing-service-accounts)
with the appropriate permissions for Terraform to create the infrastructure
and for machine-controller to create worker nodes.

The needed permissions are are:

- *Compute Admin: `roles/compute.admin`*
- *Service Account User: `roles/iam.serviceAccountUser`*
- *Viewer: `roles/viewer`*

If the [`gcloud`](https://cloud.google.com/sdk/install) CLI is installed,
a service account can be created like follow:

```bash
# create new service account
gcloud iam service-accounts create k1-cluster-provisioner

# get your service account id
gcloud iam service-accounts list
# get your project id
gcloud projects list

# create policy binding
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID --member 'serviceAccount:YOUR_SERVICE_ACCOUNT_ID' --role='roles/compute.admin'
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID --member 'serviceAccount:YOUR_SERVICE_ACCOUNT_ID' --role='roles/iam.serviceAccountUser' 
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID --member 'serviceAccount:YOUR_SERVICE_ACCOUNT_ID' --role='roles/viewer'
``` 

A *Google Service Account* for the platform has to be created, see
[Creating and managing service accounts](https://cloud.google.com/iam/docs/creating-managing-service-accounts).

The result is a JSON file containing the fields:

- `type`
- `project_id`
- `private_key_id`
- `private_key`
- `client_email`
- `client_id`
- `auth_uri`
- `token_uri`
- `auth_provider_x509_cert_url`
- `client_x509_cert_url`

```bash
# create a new json key for your service account
gcloud iam service-accounts keys create --iam-account YOUR_SERVICE_ACCOUNT k1-cluster-provisioner-sa-key.json
```

Also, the Compute Engine API has to be enabled for the project in the
[Google APIs Console](https://console.developers.google.com/apis/dashboard).

Once you have the Service Account, you need to set `GOOGLE_CREDENTIALS`
environment variable:

```bash
# export JSON file content of created service account json key
export GOOGLE_CREDENTIALS=$(cat ./k1-cluster-provisioner-sa-key.json)
```

| Environment Variable | Description         |
| -------------------- | ------------------- |
| `GOOGLE_CREDENTIALS` | GCE Service Account |

#

{{% /tab %}}
{{% tab name="Hetzner" %}}
You need a Hetzner API Token for Terraform to create the infrastructure,
machine-controller to create worker nodes, and for Hetzner Cloud Controller
Manager.

| Environment Variable | Description                  |
| -------------------- | ---------------------------- |
| `HCLOUD_TOKEN`       | The Hetzner API Access Token |

#

{{% /tab %}}
{{% tab name="OpenStack" %}}
The following environment variables are needed by Terraform for creating the
infrastructure and for machine-controller to create the worker nodes.

| Environment Variable | Description                           |
| -------------------- | ------------------------------------- |
| `OS_AUTH_URL`        | The URL of OpenStack Identity Service |
| `OS_USERNAME`        | The username of the OpenStack user    |
| `OS_PASSWORD`        | The password of the OpenStack user    |
| `OS_DOMAIN_NAME`     | The name of the OpenStack domain      |
| `OS_TENANT_ID`       | The ID of the OpenStack tenant        |
| `OS_TENANT_NAME`     | The name of the OpenStack tenant      |

#

{{% /tab %}}
{{% tab name="Packet" %}}
You need an [API Access Token](https://support.packet.com/kb/articles/api-integrations)
for Terraform to create the infrastructure, machine-controller to create worker
nodes, and for Packet Cloud Controller Manager.

| Environment Variable | Description       |
| -------------------- | ----------------- |
| `PACKET_AUTH_TOKEN`  | Packet auth token |
| `PACKET_PROJECT_ID`  | Packet project ID |

#

{{% /tab %}}
{{% tab name="vSphere" %}}
The following environment variables are needed by machine-controller for
creating the worker nodes.

For the Terraform reference, please take a look at
[vSphere provider docs](https://www.terraform.io/docs/providers/vsphere/index.html#argument-reference)


| Environment Variable | Description                         |
| -------------------- | ----------------------------------- |
| `VSPHERE_ADDRESS`    | The address of the vSphere instance |
| `VSPHERE_USERNAME`   | The username of the vSphere user    |
| `VSPHERE_PASSWORD`   | The password of the vSphere user    |

#

{{% /tab %}}
{{< /tabs >}}

## Credentials File

The credentials file is a key-value YAML file, where the key is the environment
variable name from the [environment variables section][environemnt-variables].
It has the priority over the environment variables, so you can use it if you
want to use different credentials or if you don't want to export credentials
as environment variables.

Besides credentials, the credentials file can take the cloud-config file, which
is provided using the `cloudConfig` key. This can be useful in cases when the
cloud-config contains secrets and you want to keep secrets in a different file.

The credentials file can look like the following one:

```yaml
VSPHERE_ADDRESS: "<<VSPHERE_ADDRESS>>"
VSPHERE_USERNAME: "<<VSPHERE_USERNAME>>"
VSPHERE_PASSWORD: "<<VSPHERE_PASSWORD>>"
cloudConfig: |
    <<VSPHERE_CLOUD_CONFIG>>
```

The credentials file is provided to KubeOne using the `--credentials` or `-c`
flag, such as:

```bash
kubeone install --manifest kubeone.yaml --credentials credentials.yaml -t tf.json
```

## Environment Variables in the Configuration Manifest

KubeOne can source values for supported fields in the configuration manifest
directly from the environment. The value has to be in the format of
`env:<<ENVIRONMENT_VARIABLE>>`.

In the following table you can find the configuration manifest fields with
support for sourcing value using the `env:` prefix:

| Variable                 | Type   | Default Value | Description               |
| ------------------------ | ------ | ------------- | ------------------------- |
| `hosts.ssh_agent_socket` | string | ""            | Socket to be used for SSH |

[cloud-controller-manager]: https://kubernetes.io/docs/concepts/architecture/cloud-controller/
[machine-controller]: {{< ref "../concepts#kubermatic-machine-controller" >}}
[environemnt-variables]: {{< ref "#environment-variables" >}}
