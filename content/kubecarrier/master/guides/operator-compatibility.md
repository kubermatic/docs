---
title: Operator Compatibility
weight: 20
date: 2021-02-10T13:00:00+02:00
---

Since the operator ecosystem is still evolving, different operators may be built and operate differently, and some
of them may not work correctly with KubeCarrier. This document describes the requirements for operators to be
fully compatible with KubeCarrier.

## CRD Versions

KubeCarrier currently works only with operators that expose CustomResourceDefinitions (CRDs) of version v1, e.g.:

```
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
```

For more information, see the [related issue on GitHub](https://github.com/kubermatic/kubecarrier/issues/546).

## CRD Scope

The CustomResourceDefinition (CRD) can be either namespaced or cluster-scoped, as specified in the CRD's `scope` field.
Since KubeCarrier uses Namespaces to separate individual Accounts, it counts with the ability to create Custom Resources
(CRs) in multiple namespaces. Therefore, KubeCarrier works correctly only with namespaced CRDs.

## Operator Scope
Operators can be either namespace-scoped or cluster-scoped. A namespace-scoped operator watches and manages resources
in a single Namespace, or a fixed list of Namespaces, whereas a cluster-scoped operator watches and manages resources
cluster-wide. Since KubeCarrier uses Namespaces to separate individual Accounts, it counts with the ability to create
Custom Resources (CRs) in multiple namespaces and expects operators to be cluster-scoped to properly handle events on
Custom Resources in any namespace.

Operators built using the [Operator Framework](https://operatorframework.io/) often use the environment variable
`WATCH_NAMESPACE` for switching between namespace-scoped and cluster-scoped mode. In that case, we expect it to be set
to an empty string / unset:

```yaml
    env:
      - name: WATCH_NAMESPACE
        value: ""
```

For more information, read the Operator Scope part of the [Operator Framework documentation](https://sdk.operatorframework.io/docs/building-operators/golang/operator-scope/).

Operators built using the [Kubebuilder SDK](https://book.kubebuilder.io/) can restrict the namespace their controllers
will watch for resources within the initialization of their Manager. To correctly work with KubeCarrier, we expect
their Namespace option to be set to an empty string / unset:

```go
mgr, err := ctrl.NewManager(cfg, manager.Options{Namespace: ""})
```

Apart from operator namespace settings, the RBAC permissions for the operator have to be set cluster-wide as well
(i.e. they should be using ClusterRoles and ClusterRoleBinding as opposed to Roles and RoleBinding).

## Examples of Compatible Operators
The following list contains few examples of operators known to be working correctly with KubeCarrier:

 - [Elastic Cloud on Kubernetes (ECK)](https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html)
 - [Redis Operator](https://github.com/OT-CONTAINER-KIT/redis-operator)
