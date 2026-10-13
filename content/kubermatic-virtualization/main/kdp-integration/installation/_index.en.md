+++
title = "Installation"
date = 2026-10-12T00:00:00+00:00
weight = 2
+++

KDP mode is part of a regular KubeV installation: you add a `kdp` section to the same
configuration file and run the installer. The section decides which of three modes you get.

## Choose a mode

| | Bring your own KDP | Same layer | Nested cluster |
| --- | --- | --- | --- |
| **Configuration** | `kdp.external` | neither `external` nor `cluster` | `kdp.cluster` |
| **Where KDP runs** | Wherever you already run it. | On the KubeV cluster, in namespace `kdp-system`. | In its own Kubernetes cluster, on three KubeVirt VMs on the KubeV cluster. |
| **KDP version** | 1.2.1 or newer, yours. | 1.2.1, installed for you. | 1.2.1, installed for you. |
| **Who registers the KubeV service in KDP** | `kubermatic-virtualization kdp connect`, with a kcp administrator's kubeconfig. | The installer. | The installer. |
| **KubeV dashboard** | Yes. | Yes. | No. |
| **Enabling KubeV in projects** | In the KDP catalog, per project. | Automatic, in every project. | In the KDP catalog, per project. |
| **Status** | Supported. | Supported. | Experimental. Not for production. |

- Choose **[Bring your own KDP]({{< ref "./external-kdp" >}})** when your organization already runs
  KDP, and KubeV should become one more service in it.
- Choose **[Same layer]({{< ref "./same-layer" >}})** for a new platform that runs both. It needs the
  least work: the installer sets everything up.
- Use the **[Nested cluster]({{< ref "./nested" >}})** only to try KDP out, for example in a lab.

## What every mode needs

- **A KubeV installation configuration.** KDP mode adds to it. Read
  [Declarative Installation]({{< ref "../../installation/declarative-installation" >}}) first if
  you haven't installed KubeV before.
- **The installer**, `kubermatic-virtualization`, from the
  [Kubermatic EE Downloader]({{< ref "../../getting-kubermatic-virtualization" >}}). The commands
  in this section assume it is on your `PATH`.
- **Registry credentials** in `KUBEV_USERNAME` and `KUBEV_PASSWORD`, in the same layer and nested
  modes. The KDP charts and images are pulled with them, even when the configuration sets
  `imagePullSecret`.
- **An OIDC identity provider that KDP and KubeV share**, except in nested mode, which brings its
  own. KDP, kcp and the KubeV dashboard all sign users in with one OIDC client. kcp identifies
  users by their `email` claim, so every user needs an email address in their token.
- **Agreed organization and project names.** At most 16 characters, without `--`: see
  [Names KubeV can use]({{< ref "../how-it-works#names-kubev-can-use" >}}).

The installer asks for confirmation before it changes anything. Add `-y` to skip the question, for
example in a pipeline. It logs every step to the terminal, and the details to
`kubermatic-virtualization.log` in the temporary directory, or the file named in `--log-file`.

## The `kdp` section

| Field | Modes | Default | Description |
| --- | --- | --- | --- |
| `enabled` | all | `false` | Turns on KDP mode. |
| `admin` | all | — | Email address of the first platform administrator. One of `admin` and `adminGroup` is required in the same layer and nested modes. With your own KDP, both are optional, and `kdp connect` grants the one you set. |
| `adminGroup` | all | — | OIDC group whose members are platform administrators. Wins when both are set. Only works when your login method puts groups in the token. `system:authenticated`, `system:unauthenticated` and `system:masters` are refused: at the end of the installation, or by `kdp connect` before it writes anything. |
| `providerWorkspace` | all | `root:kubev` | The KDP workspace that holds the KubeV service. Must be below `root`, not `root` itself. With your own KDP, the workspace where you register it. |
| `tenantUnderlayInterfaces` | all | empty | Host network interfaces that projects may use for underlay subnets, as names or globs such as `ens[0-9]*`. While the list is empty, projects can't create underlay subnets. See [Underlay networks for projects]({{< ref "../operations#underlay-networks-for-projects" >}}). |
| `domains.base` | all | — | A base domain. The installer derives `dashboard.<base>`, `kcp.<base>` and, in nested mode, `dex.<base>` from it. |
| `domains.dashboard` | same layer, nested | `dashboard.<base>` | Public address of the KDP dashboard. |
| `domains.kcp` | all | `kcp.<base>` | Public address of kcp. HTTPS only. |
| `domains.dex` | nested | `dex.<base>` | Public address of the nested Dex. |
| `dashboardEncryptionKey` | same layer, nested | generated | Key that encrypts the KDP dashboard's session cookies. Generated on the first run and kept in the Secret `kdp-system/kubev-kdp-dashboard-encryption-key`, on the cluster KDP runs in. Set it to use your own, such as the output of `openssl rand -hex 32`. |
| `dexCASecretName` | same layer | — | Secret in `kdp-system` with the CA (key `ca.crt`) that signs your Dex's certificate. It makes kcp trust a private CA, but the KDP dashboard and KubeV don't use it: give Dex a publicly trusted certificate. |
| `kcpCASecretName` | same layer | created for you | Secret in `kubermatic-virtualization` with the CA (key `ca.crt`) the KubeV API server uses to verify kcp. Leave it empty: the installer creates `kubev-kcp-front-proxy-ca`. With your own KDP, use `external.caSecretName` instead. |
| `external.kcpBaseURL` | bring your own | `https://<domains.kcp>` | Address of your kcp's front-proxy, as the KubeV API server reaches it. |
| `external.caSecretName` | bring your own | — | A Secret you keep in `kubermatic-virtualization`, with the CA (key `ca.crt`) that signs your kcp's certificate. Leave it out, and `kdp connect` fills `kubev-kcp-front-proxy-ca` from the kcp kubeconfig. |
| `ca.certificate`, `ca.privateKey` | nested | self-signed | A CA of your own, in PEM, to sign the nested KDP's certificates. |
| `cluster` | nested | — | Selects nested mode: see [Nested Cluster]({{< ref "./nested" >}}). |

With the KubeV dashboard enabled, KDP mode also requires:

- `dashboard.auth.oidc`. Basic and no authentication are refused.
- `dashboard.dashboardURL`, the absolute `http://` or `https://` address users open KubeV at. KDP's
  button links to it, and KubeV uses it after sign-in and to protect VM consoles. When it is
  `https`, the session cookie is sent over TLS only.

Also add `groups` to `dashboard.auth.oidc.scopes`, so that roles granted to groups in KDP apply in
KubeV. Nothing checks it, and the default scopes leave it out:

```yaml
dashboard:
  auth:
    oidc:
      scopes: ["openid", "email", "profile", "groups"]
```

## Pages

{{% children %}}
{{% /children %}}
