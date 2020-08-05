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

### AWS

| Environment Variable    | Description                                                                                                                                           |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AWS_ACCESS_KEY_ID`     | The AWS Access Key                                                                                                                                    |
| `AWS_SECRET_ACCESS_KEY` | The AWS Secret Access Key                                                                                            |
| `AWS_PROFILE`           | Name of the profile defined in the `~/.aws/credentials` file. This variable is considered only if `AWS_ACCESS_KEY_ID` or `AWS_SECRET_ACCESS_KEY` is unset |

### Azure

| Environment Variable  | Description          |
| --------------------- | -------------------- |
| `ARM_CLIENT_ID`       | Azure ClientID       |
| `ARM_CLIENT_SECRET`   | Azure Client secret  |
| `ARM_TENANT_ID`       | Azure TenantID       |
| `ARM_SUBSCRIPTION_ID` | Azure SubscriptionID |

### DigitalOcean

| Environment Variable | Description                                                                                                                         |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `DIGITALOCEAN_TOKEN` | The DigitalOcean API Access Token with read/write permissions |

### Google Cloud Platform (GCP)

| Environment Variable | Description         |
| -------------------- | ------------------- |
| `GOOGLE_CREDENTIALS` | GCE Service Account |

### Hetzner Cloud

| Environment Variable | Description                                                       |
| -------------------- | ----------------------------------------------------------------- |
| `HCLOUD_TOKEN`       | The Hetzner API Access Token |

### OpenStack

| Environment Variable | Description                           |
| -------------------- | ------------------------------------- |
| `OS_AUTH_URL`        | The URL of OpenStack Identity Service |
| `OS_USERNAME`        | The username of the OpenStack user    |
| `OS_PASSWORD`        | The password of the OpenStack user    |
| `OS_DOMAIN_NAME`     | The name of the OpenStack domain      |
| `OS_TENANT_ID`       | The ID of the OpenStack tenant        |
| `OS_TENANT_NAME`     | The name of the OpenStack tenant      |

### Packet

| Environment Variable | Description       |
| -------------------- | ----------------- |
| `PACKET_AUTH_TOKEN`  | Packet auth token |
| `PACKET_PROJECT_ID`  | Packet project ID |

### vSphere

| Environment Variable | Description                         |
| -------------------- | ----------------------------------- |
| `VSPHERE_ADDRESS`    | The address of the vSphere instance |
| `VSPHERE_USERNAME`   | The username of the vSphere user    |
| `VSPHERE_PASSWORD`   | The password of the vSphere user    |

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
