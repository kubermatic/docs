+++
title = "Installing KubeV with KDP"
date = 2026-10-12T00:00:00+00:00
weight = 1
+++

This guide installs KubeV together with KDP on the same cluster, the **same-layer** mode. The
installer deploys kcp and KDP next to KubeV, registers KubeV as a KDP service and enables it
in every project. To connect KubeV to a KDP you already run, see
[Connecting to an Existing KDP]({{< ref "../external-kdp" >}}) instead.

KDP mode is part of a regular KubeV installation: you add a `kdp` section to the same
configuration file and run `kubev apply`. Read the
[Declarative Installation]({{< ref "../../installation/declarative-installation" >}}) guide
first if you haven't installed KubeV before.

## Before you start

You need the following, in addition to the usual KubeV requirements:

| What | Why |
| --- | --- |
| **Host names** in DNS | One each for the KubeV dashboard, the KDP dashboard and kcp, for example `kubev.example.com`, `kdp.example.com` and `kcp.example.com`, and one for Dex, such as `dex.example.com`, if the installer deploys it. |
| **A way to publish Services** | An ingress controller, a Gateway or load balancers that can terminate TLS for the KDP dashboard and **pass TLS through** to kcp. The installer creates no Ingress for KDP. |
| **Registry credentials in the environment** | The KDP charts and images are pulled with `KUBEV_USERNAME` and `KUBEV_PASSWORD`. Export them even when the configuration file sets `imagePullSecret`. |
| **A StorageClass for kcp** | kcp keeps its data in etcd on a volume. The installer uses `longhorn` when `storage.longhorn` is configured, and the cluster's default StorageClass otherwise. |
| **An OIDC provider** | KDP, kcp and KubeV all sign users in through it. The installer can deploy Dex, or you can use one you already run. |

## Configure the installation

Add three sections to your configuration file: the identity provider, the dashboard and
`kdp`. This example deploys Dex, signs users in with Google, and makes `alice@example.com` the
first platform administrator:

```yaml
apiVersion: virtualization.k8c.io/v1alpha1
kind: KubeVCluster

# ... controlPlane, networkConfiguration, storage, loadBalancer and the rest of
# your KubeV configuration ...

idp:
  dex:
    issuer: "https://dex.example.com"
    connectors:
      - type: oidc
        id: google
        name: Google
        config:
          issuer: https://accounts.google.com
          clientID: "your-google-client-id"
          clientSecret: "your-google-client-secret"
          redirectURI: "https://dex.example.com/callback"

dashboard:
  enabled: true
  dashboardURL: "https://kubev.example.com"
  auth:
    oidc:
      issuerURL: "https://dex.example.com"     # the same issuer as idp.dex.issuer
      clientID: "kubev-dashboard"
      clientSecret: "a-strong-client-secret"
      redirectURL: "https://kubev.example.com/auth/callback"
      scopes: ["openid", "email", "profile", "groups"]

kdp:
  enabled: true
  admin: "alice@example.com"
  domains:
    dashboard: kdp.example.com                 # served as https://kdp.example.com
    kcp: kcp.example.com                       # served as https://kcp.example.com
  tenantUnderlayInterfaces:
    - "ens[0-9]*"
```

### Sign-in: one OIDC client for everything

KDP mode uses **one** OIDC client, the one in `dashboard.auth.oidc`. The KubeV dashboard and
the KDP dashboard both sign users in with it, and kcp accepts only tokens issued to it. kcp
identifies users by their `email` claim and reads their groups from the `groups` claim, both
prefixed with `oidc:`. So:

- Every user needs an email address in their token, and every connector must only assert
  email addresses its users own.
- Request the `groups` scope, as in the example. Without it, KubeV's tokens carry no groups,
  and nothing granted to a group in KDP applies in KubeV, `adminGroup` included.
- Limit social connectors such as GitHub to your own organizations. kcp trusts the `groups`
  claim, so anyone who can create a group with a privileged name could otherwise claim it.

Who registers the client depends on who runs Dex:

| Your setup | What to do |
| --- | --- |
| **The installer deploys Dex** (`idp.dex`) | Nothing. The installer registers the client with both callbacks, the KubeV dashboard's `redirectURL` and the KDP dashboard's `https://<kdp.domains.dashboard>/api/auth/callback/oidc`, and turns off Dex's approval screen. If you list the client in `idp.dex.staticClients` yourself, the installer leaves it alone: add both callbacks there. |
| **You run the OIDC provider** (`idp.none`) | Register the client yourself, with both callbacks. The installer prints a Dex `staticClients` entry you can copy. |

If your Dex serves a certificate from a private CA, kcp must trust that CA to verify tokens.
Create a Secret with the CA certificate under the key `ca.crt` in the `kdp-system` namespace,
and name it in `kdp.dexCASecretName`. On a new cluster, `kdp-system` only exists once the
installer has run: run `kubev apply` once, create the Secret, and run `kubev apply` again.

### The `kdp` section

| Field | Required | Default | Description |
| --- | --- | --- | --- |
| `enabled` | Yes | `false` | Turns on KDP mode. |
| `admin` | One of `admin` or `adminGroup` | — | Email address of the first platform administrator. |
| `adminGroup` | One of `admin` or `adminGroup` | — | OIDC group whose members are platform administrators. Preferred over `admin`, since membership is then managed in your identity provider, but only works when your login method puts groups in the token: LDAP, or GitHub limited to your organizations, do; Google through Dex's `oidc` connector doesn't. Wins when both are set. `system:authenticated`, `system:unauthenticated` and `system:masters` are refused. |
| `providerWorkspace` | No | `root:kubev` | The KDP workspace that holds the KubeV service. Must be below `root`, not `root` itself. |
| `domains.dashboard` | No | `dashboard.<base>` | Public address of the KDP dashboard. See [Addresses](#addresses). |
| `domains.kcp` | No | `kcp.<base>` | Public address of kcp. HTTPS only. |
| `domains.base` | No | — | A base domain. The installer derives `dashboard.<base>` and `kcp.<base>` from it for the fields you leave empty. |
| `tenantUnderlayInterfaces` | No | empty | Host network interfaces that projects may use for underlay subnets, as names or globs such as `ens[0-9]*`. While the list is empty, projects can't create underlay subnets. See [Underlay networks for projects]({{< ref "../operations#underlay-networks-for-projects" >}}). |
| `dexCASecretName` | No | — | Secret in `kdp-system` with the CA (key `ca.crt`) that signs Dex's certificate. Only needed when Dex uses a private CA. |
| `kcpCASecretName` | No | created by the installer | Secret in the `kubermatic-virtualization` namespace with the CA (key `ca.crt`) the KubeV API server uses to verify kcp. Leave it empty: the installer creates `kubev-kcp-front-proxy-ca` from kcp's own CA. |
| `dashboardEncryptionKey` | No | generated | Key that encrypts the KDP dashboard's session cookies. The installer generates one on the first run and keeps it in the Secret `kdp-system/kubev-kdp-dashboard-encryption-key`, so sessions survive later runs. Set it to use your own, for example the output of `openssl rand -hex 32`. |

The installer also checks these settings when KDP mode is on:

- `dashboard.enabled` needs `dashboard.auth.oidc`. Basic and no authentication are refused.
- `dashboard.dashboardURL` must be the absolute `http://` or `https://` address users open
  KubeV at. KDP's button links to it, and KubeV uses it after sign-in and to protect VM
  consoles. When it is `https`, the session cookie is sent over TLS only.

#### Addresses

Each entry under `domains` is a host name (`kdp.example.com`), a host and port
(`kcp.example.com:8443`) or a full URL (`https://kcp.example.com:8443`). A host name alone
means HTTPS on port 443, except `localhost`, which means the port-forwards below.

Without `domains`, the installer configures KDP for local testing through port-forwards:
`http://localhost:30880` for the KDP dashboard and `https://localhost:30843` for kcp. Set
`domains` for anything else: the addresses are built into KDP's configuration and its
certificates.

## Install

Export the registry credentials and run the installer:

```bash
export KUBEV_USERNAME=<your-username>
export KUBEV_PASSWORD=<your-password>
kubev apply -f cluster.yaml
```

Besides the usual KubeV components, the installer:

1. Installs kcp and KDP in the `kdp-system` namespace.
2. Creates the provider workspace `root:kubev` and registers the KubeV service,
   `virtualization.k8c.io`, in it, with the button that opens KubeV.
3. Applies the admission policies that keep each project's objects inside the project, in kcp
   and on the KubeV cluster.
4. Deploys the api-syncagent in the `kubev-syncagent` namespace, and publishes KubeV's resource
   types to KDP.
5. Lets the platform administrators create organizations and projects, and makes them owners of
   the provider workspace.
6. Lets every signed-in user see KubeV in KDP's catalog. What users can do in a project still
   depends on their roles there.
7. Starts enabling KubeV in every KDP project. A project gets the KubeV service about 30
   seconds after it is created.
8. Gives the KubeV API server kcp's CA, in the Secret
   `kubermatic-virtualization/kubev-kcp-front-proxy-ca`, unless you set `kdp.kcpCASecretName`.

At the end it prints where to publish the KDP dashboard and kcp.

## Publish the KDP dashboard and kcp

The installer runs both behind cluster-internal Services. Publish them at the addresses you
set in `kdp.domains`:

| Service | Port | Publish it at | TLS |
| --- | --- | --- | --- |
| `kdp-system/kdp-dashboard` | 3000 | `kdp.domains.dashboard` | The Service speaks plain HTTP. Terminate TLS in front of it. |
| `kdp-system/kcp-front-proxy` | 8443 | `kdp.domains.kcp` | kcp terminates TLS itself. **Pass TLS through**, don't terminate it. |

Dex and the KubeV dashboard must be reachable at their addresses too, as in any KubeV
installation with OIDC.

{{% notice warning %}}
**Users' browsers talk to kcp directly.** The KDP dashboard calls kcp from the browser, and
users who work with `kubectl` connect to it too. kcp serves a certificate from its own private
CA, so browsers and `kubectl` must trust that CA, or KDP pages fail to load. The installer keeps
the CA in a Secret. Export it and install it as trusted on your users' machines:

```bash
kubectl -n kubermatic-virtualization get secret kubev-kcp-front-proxy-ca \
  -o jsonpath='{.data.ca\.crt}' | base64 -d > kcp-ca.pem
```

The file holds two certificates, kcp's intermediate CA and its root CA, and both must be
trusted: kcp doesn't send the intermediate. If your tool imports one certificate per file, split
it first.
{{% /notice %}}

## Check the installation

1. Open the KDP dashboard and sign in as a platform administrator: a member of `adminGroup`,
   or the `admin` user.
2. Create an organization, and a project in it. Keep both names to 16 characters or less,
   without `--`; see [Names KubeV can use]({{< ref "../operations#names-kubev-can-use" >}}).
   A new organization or project can take a few minutes to become ready.
3. Open the project's **Services** page. Within about 30 seconds, **KubeV Virtualization**
   is listed as enabled.
4. Choose **Open KubeV Virtualization**. The KubeV dashboard opens in the project.

On the KubeV cluster, check that the api-syncagent runs and that every published resource
type made it to KDP. The second command prints nothing when all of them did:

```bash
kubectl -n kubev-syncagent get deployment kubev-api-syncagent
kubectl get publishedresources.syncagent.kcp.io -o json \
  | jq -r '.items[] | select(.status.resourceSchemaName == null) | .metadata.name'
```

## Re-running the installer

`kubev apply` is idempotent. To change a KDP setting, edit the configuration file and run it
again. It keeps the generated encryption key and the existing KDP data.

To update only the KDP part of an installed cluster, without touching nodes, Kubernetes or
the KubeV components, add `--kdp-only`:

```bash
kubev apply -f cluster.yaml --kdp-only --kubeconfig <host-cluster-kubeconfig>
```

`--kdp-only` can't do a first installation: it needs KDP to be installed already, and it
doesn't update Helm releases. Run a full `kubev apply` for those.
