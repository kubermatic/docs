+++
title = "Kubelogin Plugin Usage (kubectl oidc-login)"
date = 2018-08-17T12:07:15+02:00
weight = 30
+++

In this document, we will describe the using [kubelogin plugin](https://github.com/int128/kubelogin) to access the KKP user clusters.

`kubelogin` is a kubectl plugin for Kubernetes OpenID Connect (OIDC) authentication, also known as `kubectl oidc-login`.

## Installation

Install the latest release from Homebrew, Krew, Chocolatey or GitHub Releases.

```bash
# Homebrew (macOS and Linux)
brew install kubelogin

# Krew (macOS, Linux, Windows and ARM)
kubectl krew install oidc-login

# Chocolatey (Windows)
choco install kubelogin
```

## Usage with KKP

Currently, KKP allows you to download a kubeconfig file proxied by the OIDC provider, when the [OIDC Kubeconfig](https://docs.kubermatic.com/kubermatic/v2.27/tutorials-howtos/administration/admin-panel/interface/#enable-oidc-kubeconfig) is enabled.

In order to use kubeconfig plugin, you can download that file and update it to use `kubectl oidc-login`.

The downloaded file would look like this:

```yaml
apiVersion: v1
kind: Config
...
users:
- name: user@example.com
  user:
    auth-provider:
      config:
        client-id: exampleIssuer
        client-secret: xxx
        id-token:  xxx
        idp-issuer-url: https://kkp.example.com/dex
        refresh-token:  xxx
      name: oidc
```

It needs to be converted this way:

```yaml
apiVersion: v1
kind: Config
...
users:
  - name: user@example.com
    user:
      exec:
        apiVersion: client.authentication.k8s.io/v1
        args:
          - oidc-login
          - get-token
          - --oidc-issuer-url=https://kkp.example.com/dex
          - --oidc-client-id=exampleIssuer
          - --oidc-client-secret=xxx
          - --oidc-extra-scope=email
        command: kubectl
        env: null
        interactiveMode: Never
        provideClusterInfo: false
```

This can be achieved by running [yq](https://github.com/mikefarah/yq):

```bash
cat downloaded_kubeconfig | yq '
  .users[0].user as $old |
  .users[0].user = {
    "exec": {
      "apiVersion": "client.authentication.k8s.io/v1",
      "args": [
        "oidc-login",
        "get-token",
        "--oidc-issuer-url=\($old[\"auth-provider\"].config[\"idp-issuer-url\"])",
        "--oidc-client-id=\($old[\"auth-provider\"].config[\"client-id\"])",
        "--oidc-client-secret=\($old[\"auth-provider\"].config[\"client-secret\"])",
        "--oidc-extra-scope=email"
      ],
      "command": "kubectl",
      "env": null,
      "interactiveMode": "Never",
      "provideClusterInfo": false
    }
  }' > kubelogin_enabled_kubeconfig
```

After this step, you can export `KUBECONFIG` variable, and continue with the `kubectl` commands. For the first command, a browser window will be opened to authenticate on KKP. The OIDC token will be stored under the `~/.kube/cache/oidc-login` directory. When the token is expired, same authentication process will be executed again.
