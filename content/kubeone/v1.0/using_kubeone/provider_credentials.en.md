+++
title = "Provider Credentials"
date = 2020-04-01T12:00:00+02:00
+++

KubeOne deploys the (cloud) provider credentials to the cluster to be used by
components such as [cloud-controller-manager][cloud-controller-manager]
and [machine-controller][machine-controller]. Those components communicate with
the API in order to create worker nodes, pull node metadata and information
from the provider, and more.

KubeOne can grab credentials from the user's environment or the user can
provide the needed credentials in a dedicated credentials file.

{{% notice warning %}}
As credentials are deployed to the cluster, it's recommended to use
dedicated, non-administrator credentials whenever it's possible.
{{% /notice %}}

## Environment Variables

By default, KubeOne grabs credentials from the user's environment unless the
credentials file is provided. In the following table, you can find environment
variables used by KubeOne:

| Environment Variable    | Description                                                       |
| ----------------------- | ----------------------------------------------------------------- |
| `AWS_ACCESS_KEY_ID`     | The AWS Access Key used for creating workers on AWS               |
| `AWS_SECRET_ACCESS_KEY` | The AWS Secret Access Key used for creating workers on AWS        |
| `AWS_PROFILE`           | The AWS profile to be used for creating workers on AWS            |
|                         |                                                                   |
| `DIGITALOCEAN_TOKEN`    | The DigitalOcean API Access Token used for creating workers on DO |
|                         |                                                                   |
| `HCLOUD_TOKEN`          | The Hetzner API Access Token used for creating workers on Hetzner |
|                         |                                                                   |
| `OS_AUTH_URL`           | The URL of OpenStack Identity Service                             |
| `OS_USERNAME`           | The username of the OpenStack user                                |
| `OS_PASSWORD`           | The password of the OpenStack user                                |
| `OS_DOMAIN_NAME`        | The name of the OpenStack domain                                  |
| `OS_TENANT_ID`          | The ID of the OpenStack tenant                                    |
| `OS_TENANT_NAME`        | The name of the OpenStack tenant                                  |
|                         |                                                                   |
| `PACKET_AUTH_TOKEN`     | Packet auth token                                                 |
| `PACKET_PROJECT_ID`     | Packet project ID                                                 |
|                         |                                                                   |
| `VSPHERE_ADDRESS`       | The address of the vSphere instance                               |
| `VSPHERE_USERNAME`      | The username of the vSphere user                                  |
| `VSPHERE_PASSWORD`      | The password of the vSphere user                                  |
|                         |                                                                   |
| `GOOGLE_CREDENTIALS`    | GCE Service Account                                               |
|                         |                                                                   |
| `ARM_CLIENT_ID`         | Azure ClientID                                                    |
| `ARM_CLIENT_SECRET`     | Azure Client secret                                               |
| `ARM_TENANT_ID`         | Azure TenantID                                                    |
| `ARM_SUBSCRIPTION_ID`   | Azure SubscriptionID                                              |

## Credentials File

The credentials file is a key-value YAML file, where the key is the environment
variable name from the [table]({{< ref "#environment-variables" >}}).

The credentials file has the priority over the environment variables, so you
can use the credentials file if you want to use different credentials or if
you don't want to export credentials.

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

KubeOne can source value for supported API fields directly from the
environment. To use this feature, the field value has to be in the format of
`env:<<ENVIRONMENT_VARIABLE>>`. In the following table you can find all
API fields with support for sourcing value using the `env:` prefix:

| Variable                 | Type   | Default Value | Description               |
| ------------------------ | ------ | ------------- | ------------------------- |
| `hosts.ssh_agent_socket` | string | ""            | Socket to be used for SSH |

[cloud-controller-manager]: https://kubernetes.io/docs/concepts/architecture/cloud-controller/
[machine-controller]: https://github.com/kubermatic/machine-controller
