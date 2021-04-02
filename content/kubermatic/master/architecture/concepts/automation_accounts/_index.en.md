+++
title = "Automation Accounts"
date = 2020-03-31T12:01:35+02:00
weight = 15

+++

## Introduction

An automation account is a special type of account intended to represent a non-human user that needs to authenticate and be
authorized to access resources in Kubermatic APIs.

Automation accounts are used in scenarios such as:

- Running workloads on user clusters.
- Running workloads which are not tied to the lifecycle of a human user.

## Core concept
An automation accounts will be considered as a main resource. Only the human user can manage an automation account.
An automation account can be assigned to one of the already defined groups: `owners`, `editors` or `viewers`.
During creation by the human user, the service account will be bound with desired privileges to the all
owned by user projects.

The KKP User object is used as an automation account. To avoid confusion about the purpose of the user the name convention
was introduced. Automation account name starts with prefix `main-serviceaccount-`. The Regular user starts with name: `user-`.
For example:

```bash
$ kubectl get users
NAME                                                               AGE
main-serviceaccount-z97l228h4z                                     7d
main-serviceaccount-zjl54fmlks                                     26d
user-26xq2                                                         311d
```

The `yaml` example of automation account object:

```yaml
apiVersion: kubermatic.k8s.io/v1
kind: User
metadata:
  annotations:
    owner: user@kubermatic.com
  name: main-serviceaccount-wv8gptgdl6
  labels:
    role: owner
spec:
  admin: false
  email: main-serviceaccount-wv8gptgdl6@dev.kubermatic.io
  id: wv8gptgdl6
  name: test
```

Automation accounts are tied to a set of credentials stored as Secrets. Because a `Secret` is namespaced resource the
system needs predefined namespace for it: `kubermatic`. The `OwnerRef` links the secret with the automation account.
A secret will be automatically deleted after automation account removal.

```yaml
 apiVersion: v1
 data:
   token: abcdefgh=
 kind: Secret
 metadata:
   labels:
     name: test
   name: sa-token-zzzzzzzzzz
   namespace: kubermatic
   ownerReferences:
   - apiVersion: kubermatic.k8s.io/v1
     kind: User
     name: main-serviceaccount-xxxxxxxxxx
     uid: 26127a31-507a-11e9-9ea9-42010a9c0125
 type: Opaque

```

### Prerequisites
An automation account use the same authentication methods as project service account. The KKP API takes a flag:

- `service-account-signing-key` - A signing key authenticates the automation account and service account token value using HMAC. It is recommended to use a key with 32 bytes or longer.

An automation account is an automatically enabled authenticator that uses signed bearer tokens to verify requests.

### Accessing API via automation account token

A client that wants to authenticate itself with a server can then do so by including an `Authorization` request header
field with the automation account token:

```HTTP
Authorization: Bearer aaa.bbb.ccc
```

### Using automation accounts with KKP

- You can create a project. The project belongs to the group which is defined for the automation account.
- New created project by automation account has always a human user owner. In this case deleting the automation account is safe
  because project and all dependencies will stay in the KKP.
- It is possible to delete a automation account and then create a new with the same name. You can do the same
  with automation account token.
- You can change the automation account and token names when once created.
- The automation account's token is visible to the user during creation.



