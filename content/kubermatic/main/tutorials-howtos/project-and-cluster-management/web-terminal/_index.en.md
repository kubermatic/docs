+++
title = "Web Terminal"
date = 2023-01-30T14:40:55+02:00
weight = 80
+++

Web terminal allows `kubectl` access to a user cluster directly from the KKP dashboard web interface.
Therefore, you can also manage your cluster with the Web Terminal by using `kubectl` commands there.

To enable it:

1. Enable the `OIDCKubeCfgEndpoint` feature gate in `spec.featureGates` of the `KubermaticConfiguration`.
2. In the [Interface section]({{< ref "../../administration/admin-panel/interface" >}}) of the Admin Panel, enable **OIDC Kubeconfig** and **Web Terminal**.
   These switches set `spec.enableOIDCKubeconfig` and `spec.webTerminalOptions.enabled` of the `KubermaticSetting` object
   `globalsettings`. If you manage it as a manifest, set both:

   ```yaml
   apiVersion: kubermatic.k8c.io/v1
   kind: KubermaticSetting
   metadata:
     name: globalsettings
   spec:
     enableOIDCKubeconfig: true
     webTerminalOptions:
       enabled: true
   ```

After enabling it, a button will appear on the top right side of the user cluster page and the API will allow its usage.

The web terminal runs in one of two modes:

- **OIDC mode** (default): the terminal uses the user's own OIDC login.
- **ServiceAccount mode**: the terminal uses a ServiceAccount that acts as the user. See [ServiceAccount Mode](#serviceaccount-mode).

{{% notice tip %}}
We highly recommend ServiceAccount mode. Enable it by setting the `WebTerminalServiceAccount` feature gate to `true`.
{{% /notice %}}

![Web Terminal](web-terminal.png?classes=shadow,border)

**Note:** in OIDC mode, you are asked to login to KKP again when you open the terminal for the first time and after a session has expired. Please use a user with the ***same Kubermatic user email***.

## How it works

After KKP UI establishes a websocket connection with the KKP API, webterminal-related Kubernetes resources are deployed in the user cluster.
These are responsible for executing the commands (pod), managing expiration, cleanup and network policy.

Then, the API starts streaming terminal commands from the UI to the Web Terminal pod deployed in the user cluster.

After 30 minutes, the expiration happens and every deployed resource is destroyed. Although, 5 minutes before the expiration time,
the user is asked for extending the terminal for more 30 minutes.

## ServiceAccount Mode

In ServiceAccount mode, the terminal uses a ServiceAccount instead of the user's OIDC login. For every user who opens a terminal,
KKP creates a ServiceAccount, a ClusterRole and a ClusterRoleBinding in the user cluster. The ClusterRole only allows impersonating the session
user's email and OIDC groups. The terminal pod runs a `kubectl proxy` container with the ServiceAccount token, which sends every
request as the session user. The shell container has no credentials of its own. No second login is needed.

### Enabling ServiceAccount Mode

ServiceAccount mode is available in KKP 2.31.4 and later, and it is the highly recommended mode. In addition to the settings in
the beginning of this page, set the `WebTerminalServiceAccount` and `OpenIDAuthPlugin` feature gates to `true`:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  featureGates:
    OIDCKubeCfgEndpoint: true
    OpenIDAuthPlugin: true
    WebTerminalServiceAccount: true
```

Changing the `WebTerminalServiceAccount` feature gate restarts the KKP API, the KKP controller managers, the KKP webhook and the
user cluster controller manager of every user cluster once. A terminal pod from the other mode is replaced when the next session starts.

ServiceAccount mode works only for user clusters that use the default KKP authentication. KKP refuses to open the terminal, and
shows the reason, when:

- the user cluster, its Seed or its datacenter has its own authentication configuration,
- the user cluster sets its own OIDC issuer (`spec.oidc.issuerURL` and `spec.oidc.clientID`),
- the Seed uses its own OIDC provider (`spec.oidcProviderConfiguration`),
- the `OpenIDAuthPlugin` feature gate is disabled, or
- the email of the user is not verified.

The dashboard shows one message for the first three cases. The KKP API logs the exact reason as
`web terminal refused for cluster <cluster ID>: <reason>`.

A Seed `spec.oidcProviderConfiguration` refuses ServiceAccount mode even when it repeats the values of the
`KubermaticConfiguration`. If it sets only `issuerURL`, `issuerClientID` and `issuerClientSecret`, with the same values as
`spec.auth.tokenIssuer`, `spec.auth.issuerClientID` and `spec.auth.issuerClientSecret`, and `spec.featureGates` of the
`KubermaticConfiguration` contains `OpenIDAuthPlugin`, you can remove it from the Seed. User clusters keep the same OIDC settings.

### Admission Policies

When ServiceAccount mode is enabled, KKP adds three ValidatingAdmissionPolicies to every user cluster. They make sure that only
KKP can open sessions in web terminal pods and use the web terminal ServiceAccounts:

| Policy | Denies for everyone except KKP |
|---|---|
| `kubermatic-webterminal-access` | `exec`, `attach`, `port-forward` and ephemeral containers on `webterminal-*` pods in `kube-system`, and token requests for `webterminal-*` ServiceAccounts |
| `kubermatic-webterminal-serviceaccount-pods` | New pods that run as a `webterminal-*` ServiceAccount, and image changes of such pods |
| `kubermatic-webterminal-serviceaccount-secrets` | Token Secrets for `webterminal-*` ServiceAccounts |

KKP restores a changed or deleted policy within seconds. After the feature gate is disabled, KKP removes the policies once no
web terminal session is left in the user cluster.

### Behavior in ServiceAccount Mode

- Commands in the terminal always run as the session user.
- The audit log of the user cluster shows the ServiceAccount as the user and the email as the impersonated user.

## Permissions in the Web Terminal

On user clusters that use the default KKP authentication, commands in the terminal run as the user's OIDC identity in both
modes: the email and the OIDC groups with the `oidc:` prefix. Project roles do not apply in the terminal. Only the user who
created the cluster gets cluster-admin permissions automatically. All other users, including KKP admins and Project editors, get errors such as `pods is forbidden` until they are bound by email or by OIDC group
in the RBAC settings of the cluster. See [Cluster Access]({{< ref "../../cluster-access" >}}).

![Web Terminal sequence diagram](web-terminal-sequence-diagram.png?classes=shadow,border)

## Additional Configuration

`KubermaticSettings` CRD allows to configure additional options for the web terminal.

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticSetting
metadata:
  name: globalsettings
...
spec:
  webTerminalOptions:
    enabled: true
    # Allow internet access from the web terminal
    enableInternetAccess: true
    # Additional environment variables that will be added to the web terminal pod
    additionalEnvironmentVariables:
      - name: "FOO"
        value: "bar"
```

## Troubleshooting

### Connection being closed after some time

KKP sets a fixed 1 hour timeout on the `kubermatic` HTTPRoute to support long-lasting connections of the web terminal. If you route through a user-managed external Gateway instead, make sure its timeouts allow connections to stay open for an hour. The `httpRoute.timeout` value in your `values.yaml` applies to the Dex and IAP routes, not to the `kubermatic` HTTPRoute.

### Cannot connect to other pods or internet from the web terminal pod

The `network policy` deployed to the user cluster restricts access from the web terminal `pod` and allows only the egress traffic to the Kubernetes API server. Therefore you will not be able to access any other pods in the cluster from the web terminal pod.
