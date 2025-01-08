+++
title = "Known Issues"
date = 2022-07-22T12:22:15+02:00
weight = 25

+++

## Overview

This page documents the list of known issues and possible work arounds/solutions.

## Oidc refresh tokens are invalidated when the same user/client id pair is authenticated multiple times

### Problem

One example would be to download a kubeconfig of one cluster and then of another with the same user. You should only be able to use the first kubeconfig until the id_token expires because the refresh token was already invalidated by the download of the second one. This happens when a new one was requested. 


### Root Cause

With the default helm chart values for dex it is only possible to have one refresh token per user/client pair for security reasons. The refresh token has by default also no expiration set. This is useful to stay logged in over a longer time because the id_token can be refreshed unless the refresh token is invalidated.


### Solution

You can either change this in dex helm values by setting `userIDKey` to `jti` and `userNameKey` for example to `email` in the config section of a connector or you could configure an other oidc provider which supports multiple refresh tokens per user-client pair like keycloak does by default. 

For dex this has some implications. With this configuration a token is generated for each user session. The number of objects stored in kubernetes regarding refresh tokens has no limit anymore. The principle that one refresh token belongs to one user/client pair is a security consideration which would be ignored in that case. The only way to revoke a refresh token is then to do it via grpc api which is not exposed by default or by manually deleting the related refreshtoken resource in the kubernetes cluster.

For an explanation how to configure an other oidc provider than dex take a look at [oidc-provider-configuration]({{< ref "../../tutorials-howtos/oidc-provider-configuration" >}}).
