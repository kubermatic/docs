+++
title = "Known Issues"
date = 2025-10-22T12:00:00+02:00
weight = 25

+++

## Overview

This page documents the list of known issues and possible workarounds/solutions.

## Cilium 1.18 fails installation on older Ubuntu 22.04 kernels

_**Affected Components**_: Cilium 1.18.x deployed as a system application on User Clusters

_**Affected OS Image**_: `Ubuntu 22.04.1 LTS (GNU/Linux 5.15.0-47-generic x86_64)`

### Problem

Clusters running on Ubuntu 22.04 nodes with the kernel version `5.15.0-47-generic` experience Cilium pod failures. During initialization, the Cilium agent is unable to load certain eBPF programs (`tail_nodeport_nat_egress_ipv4`) into the kernel due to a verifier bug in older kernel versions.
The kernel verifier will report:

```bash
error="attaching cilium_host: loading eBPF collection into the kernel: 
program tail_nodeport_nat_egress_ipv4: load program: 
permission denied: 1074: (71) r1 = *(u8 *)(r2 +23): R2 invalid mem access 'inv' (665 line(s) omitted)"
```

Because of this issue we have `cilium-agent` failing, and `hubble-generate-certs` jobs timing out when attempting to create the CA secrets in the specified namespace.

### Root Cause

`Ubuntu’s 5.15.0-47 kernel` (and older builds) lacks critical eBPF verifier precision propagation fixes. Cilium 1.18 has datapath programs that depend on these verifier improvements.

### Workarounds

1. On cluster creation in KKP, enable the option to `Upgrade system on first boot`. For existing clusters we can edit the machine deployment and enable the `Upgrade system on first boot` option.
2. Upgrade the kernel on Ubuntu 22.04 nodes:

  ```bash
  sudo apt update && sudo apt upgrade -y && sudo reboot
  ```

  The node will boot into **5.15.0-160-generic**, and Cilium starts successfully.

3. For OpenStack, switch worker image (in your data center provider options) from kubermatic-ubuntu (22.04) to Ubuntu 24.04 LTS (6.8.x kernel).

### Planned resolution

Future Kubermatic images will default to Ubuntu 24.04 to ensure compatibility with newer Cilium releases.

## OIDC refresh tokens are invalidated when the same user/client ID pair is authenticated multiple times

### Problem

For oidc authentication to user cluster there is always the same issuer used. This leads to invalidation of refresh tokens when a new authentication happens with the same user because existing refresh tokens for the same user/client pair are invalidated when a new one is requested.

### Root Cause

By default it is only possible to have one refresh token per user/client pair in dex for security reasons. There is an open issue regarding this in the [upstream repository](https://github.com/dexidp/dex/issues/981). The refresh token has by default also no expiration set. This is useful to stay logged in over a longer time because the id_token can be refreshed unless the refresh token is invalidated.

One example would be to download a kubeconfig of one cluster and then of another with the same user. You should only be able to use the first kubeconfig until the id_token expires because the refresh token was already invalidated by the download of the second one.

### Solution

You can either change this in dex configuration by setting `userIDKey` to `jti` in the connector section or you could configure an other oidc provider which supports multiple refresh tokens per user-client pair like keycloak does by default.

#### Dex

The following yaml snippet is an example how to configure an oidc connector to keep the refresh tokens.

```yaml
    connectors:
      - id: oidc
        name: OIDC
        type: Google
        config:
          clientID: <client_id>
          clientSecret: <client_secret>
          redirectURI: https://kkp.example.com/dex/callback
          scopes:
            - openid
            - profile
            - email
            - offline_access
          # Workaround to support multiple user_id/client_id pairs concurrently
          # Configurable key for user ID look up
          # Default: id
          userIDKey: <<userIDValue>>
          # Optional: Configurable key for user name look up
          # Default: user_name
          userNameKey: <<userNameValue>>
```

#### External provider

For an explanation how to configure an other oidc provider than dex take a look at [oidc-provider-configuration]({{< ref "../../tutorials-howtos/oidc-provider-configuration" >}}).

### Security implications regarding dex solution

For dex this has some implications. With this configuration a token is generated for each user session. The number of objects stored in kubernetes regarding refresh tokens has no limit anymore. The principle that one refresh belongs to one user/client pair is a security consideration which would be ignored in that case. The only way to revoke a refresh token is then to do it via grpc api which is not exposed by default or by manually deleting the related refreshtoken resource in the kubernetes cluster.

## API server Overload Leading to Instability in Seed due to Konnectivity

Issue: <https://github.com/kubermatic/kubermatic/issues/13321>

Status: Fixed

An issue has been identified where the overloaded API server of a user cluster managed by a Seed can impact the stability of API servers in all other user clusters managed by the same Seed.
This resulted in various control plane components and applications failing to communicate with the apiserver due to timeouts and context cancellation errors.
Moreover, Konnectivity Server container in API server pod emits "Receive channel from agent is full" logs.

> Upstream issue can be found [here](https://github.com/kubernetes-sigs/apiserver-network-proxy/issues/586).

### Solution

The newly introduced `args` field in KKP v2.28.0 for configuring Konnectivity deployments (both Agent and Server) allows users to set any flags, including `--xfr-channel-size`.

**Important Note:** The `--xfr-channel-size` flag in Konnectivity is available starting from Kubernetes v1.31.0. Ensure that the Kubernetes cluster version is compatible to use this new flag.

#### Updating Konnectivity Server

To update the Konnectivity Server configuration, the Seed's `defaultComponentSettings` must be updated.
The new `args` field is available under `spec.defaultComponentSettings.konnectivityProxy`. 
An example configuration is shown below:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Seed
metadata:
  name: <<exampleseed>>
  namespace: kubermatic
spec:
  defaultComponentSettings:
    konnectivityProxy:
      # Args configures arguments (flags) for the Konnectivity deployments.
      args: ["--xfr-channel-size=20"]
```

This sets `--xfr-channel-size=20` flag for Konnectivity Server, which runs as a sidecar to the Kubernetes API server.

#### Updating Konnectivity Agent

To update the Konnectivity Agent configuration, the Cluster's `componentsOverride` must be updated.
The new `args` field is available under `spec.componentsOverride.konnectivityProxy`. 
An example configuration is shown below:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Cluster
metadata:
  name: <<examplecluster>>
  namespace: kubermatic
spec:
  componentsOverride:
    konnectivityProxy:
      # Args configures arguments (flags) for the Konnectivity deployments.
      args: ["--xfr-channel-size=300"]
```

This sets `--xfr-channel-size=300` flag for Konnectivity Agent, which runs on the user cluster.
