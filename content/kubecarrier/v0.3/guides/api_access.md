---
title: API Access
weight: 10
slug: api_access
date: 2020-06-26T09:00:00+02:00
enabletoc: true
---

KubeCarrier deploys its own API Server to allow external access and integrations to connect with KubeCarrier.
It's designed as a slim interface layer and all the heavy lifting (validation, authorization, etc.) is still done by Kubernetes Controllers, Kubernetes Admission Webhooks, and other Kubernetes mechanisms.

We decided to build our own custom API Server for a few reasons:

1. Exposing `kube-apiserver` on the public internet is discouraged.
2. We want to enable separate authentication configuration for users of the KubeCarrier API.
3. Long term, we want to support aggregation and discovery from multiple KubeCarrier clusters to enable advanced distributed deployments.

## Accessing the API

The KubeCarrier API Server exposes a Open API Specification under `<host>/v1/openapi` and the Swagger UI under `<host>/v1/swagger/` to browse the API specification.

To access the KubeCarrier API directly, you can use `kubectl port-forward` to expose the api server on localhost.

First you need to get the name of the api server Pod:

```bash
kubectl get pod -n "kubecarrier-system"
```

```bash
NAME                                                      READY   STATUS    RESTARTS   AGE
kubecarrier-api-server-manager-5cf54ddd4b-t2bhv           1/1     Running   0          6m13s
kubecarrier-manager-controller-manager-66d88ccc6c-rkvtl   1/1     Running   0          6m14s
kubecarrier-operator-manager-7498c545c7-pb98w             1/1     Running   0          6m20s
```

Afterwards you can start the port forwarder:

```bash
kubectl port-forward \
  -n "kubecarrier-system" \
  kubecarrier-api-server-manager-5cf54ddd4b-t2bhv 8443:8443
```

{{% notice info %}}
The default TLS serving certificate of the KubeCarrer API Server is self-signed and will raise warnings in all browsers.
See the [TLS](#tls) section for further details.
{{% /notice %}}

And access the Swagger UI on [https://localhost:8443/v1/swagger/](https://localhost:8443/v1/swagger/)

## Authentication

The KubeCarrier API Server supports multiple authentication methods. By default `kubectl kubecarrier setup` starts the KubeCarrier API Server with `ServiceAccount` and `Anonymous` auth enabled.

```yaml
apiVersion: operator.kubecarrier.io/v1alpha1
kind: KubeCarrier
metadata:
  name: kubecarrier
spec:
  api:
    authentication:
    - serviceAccount: {}
    - anonymous: {}
```

Authentication providers will be called in specified order.
You can find more information about each authentication method below.

### Anonymous

Anonymous authentication is enabled by default as the last authenticator.

Every request that cannot be authenticated by another provider, will by authenticated as `system:anonymous` with a group of `system:unauthenticated`.

To grant anonymous access to an Account, it can be added to the Accounts subjects:

```yaml
apiVersion: catalog.kubecarrier.io/v1alpha1
kind: Account
metadata:
  name: team-b
spec:
  metadata:
    displayName: The B Team
    shortDescription: In 1972, a crack commando unit was sent to prison by a military court...
  roles:
  - Tenant
  subjects:
  - kind: User
    name: team-b-member
    apiGroup: rbac.authorization.k8s.io
  - kind: User                          # Add this
    name: system:anonymous              #
    apiGroup: rbac.authorization.k8s.io # <---
```

### ServiceAccount

ServiceAccount authentication is enabled by default.

It allows the use of Kubernetes ServiceAccount tokens to access the KubeCarrier API. To use it, just create a ServiceAccount in an Account namespace and add it to the Account.

To try it out, first create the ServiceAccount:

```bash
kubectl create serviceaccount "my-first-api-sa" -n "team-b"
```

Add the new ServiceAccount to team-b's Account:

```bash
kubectl edit account team-b
```

```yaml
apiVersion: catalog.kubecarrier.io/v1alpha1
kind: Account
metadata:
  name: team-b
spec:
  metadata:
    displayName: The B Team
    shortDescription: In 1972, a crack commando unit was sent to prison by a military court...
  roles:
  - Tenant
  subjects:
  - kind: User
    name: team-b-member
    apiGroup: rbac.authorization.k8s.io
  - kind: ServiceAccount    # Add this
    name: my-first-api-sa   #
    namespace: team-b       #
    apiGroup: ""            # <---
```

To obtain the ServiceAccount token, you have to find the ServiceAccount token secret in the team-b namespace:

```bash
kubectl get secret -n "team-b"
```

```bash
NAME                         TYPE                                  DATA   AGE
default-token-s7vgf          kubernetes.io/service-account-token   3      34s
my-first-api-sa-token-c7hfw  kubernetes.io/service-account-token   3      28s
```

To just get the token and decode the base64 data:

```bash
kubectl get secret \
  -n "team-b" \
  --template="{{.data.token}}" \
  my-first-api-sa-token-c7hfw | base64 -d
```

Prefix the token with `Bearer ` and use it in the swagger UI:

![Swagger UI - API Token][swagger-ui-apikey]

### Static Users

Static users uses a static htpasswd file for user authentication.

First, create a new file via the `htpasswd` utility. In this example, we are using `Bcrypt` as a hashing algorithm. Make sure to specify a strong algorithm, because the default `MD5` hash is insecure.

```bash
htpasswd -B -C 12 -c my-user-file nico@kubermatic.com
```

Load this file into a Kubernetes Secret into the `kubecarrier-system` namespace:

```bash
kubectl create secret generic api-users \
  -n "kubecarrier-system" \
  --from-file="auth=apiusers.htpasswd"
```

Edit the `KubeCarrier` object to configure static users:

```bash
kuebctl edit kubecarrier
```

```yaml
apiVersion: operator.kubecarrier.io/v1alpha1
kind: KubeCarrier
metadata:
  name: kubecarrier
spec:
  api:
    authentication:
    - staticUsers:
        htpasswdSecret:
          name: api-users
```

The KubeCarrier API server will now restart and allow for authentication of users included in the file. Subsequent changes to the htpasswd file in the secret do not require a restart of the API server and will come into effect immediately.

### OIDC

Open ID Connect is the preferred method of authenticating end users with the KubeCarrier API server.
The OIDC settings can be specified by editing the `KubeCarrier` object:

```yaml
apiVersion: operator.kubecarrier.io/v1alpha1
kind: KubeCarrier
metadata:
  name: kubecarrier
spec:
  api:
    authentication:
    - oidc:
        issuerURL: ""
        clientID: ""
        apiAudiences: []
        certificateAuthority:
          name: ""
        usernameClaim: ""
        usernamePrefix: ""
        groupsClaim: ""
        groupsPrefix: ""
        supportedSigningAlgs: []
        requiredClaims: {}
```

A complete API Reference can be found on the [API Reference](../../api_reference) page.

## TLS

By default, KubeCarrier will generate a self-signed certificate for `localhost` and `127.0.0.1` as a minimal TLS setup.

You can configure your own TLS serving certificate for the KubeCarrier API Server in the `KubeCarrier` configuration object.
Alternatively you can terminate TLS via an ingress controller or any other edge load balancer.

{{% notice info %}}
TLS is a requirement the KubeCarrier API server.
{{% /notice %}}

[swagger-ui-apikey]: ../../img/Swagger_apikey.png
