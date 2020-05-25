+++
title = "Service Accounts"
date = 2019-06-13T12:01:35+02:00
weight = 3

+++

### Service Accounts

Service accounts allow using a long-lived token that you can use to authenticate with Kubermatic API.

A service account is a special type of user account that belongs to the Kubermatic project, instead of an individual
end user. Your project resources assume the identity of the service account to call Kubermatic APIs, so that the users
are not directly involved. A service account has JWT token which is used to authenticate to Kubermatic API. The JWT token
by default expires after 3 years.

## Core Concept

A Service accounts are considered as project's resource. Only the owner of the project  can create a service account.
There is no need to create a new groups for SA, we want to assign a service account to one of the already defined groups:
`editors` or `viewers`.

The Kubermatic User object is used as a service account. To avoid confusion about the purpose of the user the name convention
was introduced. Service account name starts with prefix `serviceaccount-`. The Regular user starts with name: `user-`.
For example:

```bash
$ kubectl get users
NAME                                                               AGE
serviceaccount-z97l228h4z                                          7d
serviceaccount-zjl54fmlks                                          26d
user-26xq2                                                         311d
```

A service account is linked to the project automatically by service account binding controller. The controller creates
`UserProjectBinding` which specifies a binding between a service account and a project. A `UserProjectBinding` uses a
`OwnerRef` to create connection with the project. A service account will be automatically deleted after project removal.

The `yaml` example of service account object:

```yaml
apiVersion: kubermatic.k8s.io/v1
kind: User
metadata:
  creationTimestamp: "2019-03-27T07:57:55Z"
  generation: 1
  name: serviceaccount-xxxxxxxxxx
  ownerReferences:
  - apiVersion: kubermatic.k8s.io/v1
    kind: Project
    name: yyyyyyyyyy
    uid: c7694392-43e4-11e9-b04b-42010a9c0119
spec:
  email: serviceaccount-xxxxxxxxxx@localhost
  id: 3fa771ea25b4a2065ace5f3d508b2335d450402f0d73d5e59fa84b41_KUBE
  name: test
```

Service accounts are tied to a set of credentials stored as Secrets. Because a `Secret` is namespaced resource the
system needs predefined namespace for it: `kubermatic`.

Secret label `project-id` is used to create link between secret and project. The `OwnerRef` links the secret with the
service account. A secret will be automatically deleted after service account removal.

```yaml
 apiVersion: v1
 data:
   token: abcdefgh=
 kind: Secret
 metadata:
   labels:
     name: test
     project-id: yyyyyyyyyy
   name: sa-token-zzzzzzzzzz
   namespace: kubermatic
   ownerReferences:
   - apiVersion: kubermatic.k8s.io/v1
     kind: User
     name: serviceaccount-xxxxxxxxxx
     uid: 26127a31-507a-11e9-9ea9-42010a9c0125
 type: Opaque

```

### Prerequisites

A service account is an automatically enabled authenticator that uses signed bearer tokens to verify requests. The Kubermatic API takes a flag:

- `service-account-signing-key` - A signing key authenticates the service account's token value using HMAC. It is recommended to use a key with 32 bytes or longer.

### Keeping Track of Service Accounts and Tokens

It is possible to create multiple service accounts for the given project. The service account name must be unique for
project scope. The service account can have multiple tokens with unique names.

The display name of the service account and token is a good way to capture additional information, such as the purpose of
the service account or token.

### Managing Service Accounts and Tokens

It is possible to delete a service account and then create a new service account with the same name. You can do the same
with service account token.

You can change the service account and token names when once created.

The service account token is visible to the user during creation.

{{% notice note %}}
**Note:** Make sure to save this token at a safe place on your own device. It cannot be displayed again after closing the dashboard window.
{{% /notice %}}

The user can also regenerate a token but the previous one will be revoked.

### Accessing API via Service Account Token

A client that wants to authenticate itself with a server can then do so by including an `Authorization` request header
field with the service account token:

```HTTP
Authorization: Bearer aaa.bbb.ccc
```
