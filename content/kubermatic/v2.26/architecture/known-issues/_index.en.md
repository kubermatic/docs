+++
title = "Known Issues"
date = 2022-07-22T12:22:15+02:00
weight = 25

+++

## Overview

This page documents the list of known issues and possible work arounds/solutions.

## Oidc refresh tokens are invalidated when the same user/client id pair is authenticated multiple times

### Problem

For oidc authentication to user cluster there is always the same issuer used. This leads to invalidation of refresh tokens when a new authentication happens with the same user because existing refresh tokens for the same user/client pair are invalidated when a new one is requested.


### Root Cause

By default it is only possible to have one refresh token per user/client pair in dex for security reasons. There is an open issue regarding this in the [upstream repository](https://github.com/dexidp/dex/issues/981). The refresh token has by default also no expiration set. This is useful to stay logged in over a longer time because the id_token can be refreshed unless the refresh token is invalidated.

One example would be to download a kubeconfig of one cluster and then of another with the same user. You should only be able to use the first kubeconfig until the id_token expires because the refresh token was already invalidated by the download of the second one.

### Solution

You can either change this in dex configuration by setting `userIDKey` to `jti` in the connector section or you could configure an other oidc provider which supports multiple refresh tokens per user-client pair like keycloak does by default.

#### dex

The following yaml snippet is an example how to configure an oidc connector to keep the refresh tokens.

```yaml
    connectors:
      - config:
          clientID: <client_id>
          clientSecret: <client_secret>
          orgs:
          - name: <github_organization>
          redirectURI: https://kubermatic.test/dex/callback
        id: github
        name: GitHub
        type: github
        userIDKey: jti
        userNameKey: email
```

#### external provider

For an explanation how to configure an other oidc provider than dex take a look at [oidc-provider-configuration]({{< ref "../../tutorials-howtos/oidc-provider-configuration" >}}).

### security implications regarding dex solution

For dex this has some implications. With this configuration a token is generated for each user session. The number of objects stored in kubernetes regarding refresh tokens has no limit anymore. The principle that one refresh belongs to one user/client pair is a security consideration which would be ignored in that case. The only way to revoke a refresh token is then to do it via grpc api which is not exposed by default or by manually deleting the related refreshtoken resource in the kubernetes cluster.

## Workaround for the Bitnami registry changes if upgrade is not possible

Customers who are completely unable to upgrade to KKP patch version 2.26.12 or above, may use a workaround.
This should be treated as a last resort method and comes with downsides on future upgrades. Specifically, with the patch releases, we are also moving to mirrored helm-charts to ensure stability and independence going forward. This workaround will not migrate to the mirrored charts, it will only switch images.

Workaround in detail:

1. Add the following to your mla values.yaml at the top level:

  ```yaml
  cortex:
    memcached-blocks-index:
      image:
        registry: quay.io
        repository: kubermatic-mirror/images/memcached
      metrics:
        image:
          registry: quay.io
          repository: kubermatic-mirror/images/memcached-exporter
    memcached-blocks:
      image:
        registry: quay.io
        repository: kubermatic-mirror/images/memcached
      metrics:
        image:
          registry: quay.io
          repository: kubermatic-mirror/images/memcached-exporter
    memcached-blocks-metadata:
      image:
        registry: quay.io
        repository: kubermatic-mirror/images/memcached
      metrics:
        image:
          registry: quay.io
          repository: kubermatic-mirror/images/memcached-exporter
  ```

2. Re-run the mla installation process in accordance with the [official documentation](../../tutorials-howtos//monitoring-logging-alerting//user-cluster/admin-guide/#installing-mla-stack-in-a-seed-cluster) with a kubermatic installer matching your current KKP version.
