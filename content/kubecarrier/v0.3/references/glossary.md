---
title: Glossary
weight: 40
date: 2020-04-24T09:00:00+02:00
enabletoc: true
---

A glossary of terms used throughout this documentation.

## Kubernetes Controller

[Kubernetes Controllers][k8s-controller] are the driving force behind Kubernetes, they ensure step-by-step that the desired state in the Kubernetes state database is executed and realized in the real world.


## CustomResourceDefinition - CRD

[Custom Resources][custom-resources] are extensions of the Kubernetes API. This page discusses when to add a custom resource to your Kubernetes cluster and when to use a standalone service. It describes the two methods for adding custom resources and how to choose between them.


## Kubernetes Operator

A [Kubernetes Operator][k8s-operator] is a method of packaging, deploying and managing a Kubernetes application. A Kubernetes application is an application that is both deployed on Kubernetes and managed using the Kubernetes APIs and kubectl tooling.

To be able to make the most of Kubernetes, you need a set of cohesive APIs to extend in order to service and manage your applications that run on Kubernetes. You can think of Operators as the runtime that manages this type of application on Kubernetes.

Kubernetes Operators usually consist of multiple Kubernetes Controllers and `CustomResourceDefinitions`. For more information, read the [About Kubernetes Operators]({{< relref "./kubernetes-operators" >}}) page.


## Kubernetes Webhooks

Kubernetes Webhooks complement CustomResourceDefinitions by adding a mechanism to attach custom validation, defaulting and version conversion logic to CRDs.
You can read more about it in the Kubernetes documentation about [Admission Controllers][admission-controllers].

- `MutatingWebhookConfiguration`
  Can be used to set defaults or otherwise manipulate custom resources before validation and storage.

- `ValidatingWebhookConfiguration`
  Can be used to validate custom resources on creation or update.

- `ConversionWebhook`
  Can be used to convert between versions of the same custom resource and allow to still serve older api versions. e.g. they can convert a `v1alpha1` object into it's `v1` representation and vice versa.

## Kubernetes RBAC
RBAC (Role-Based Access Control) is a method of regulating access to computer or network resources based on the roles
of individual users within an organization.

[RBAC authorization in Kubernetes][k8s-rbac] uses the
`rbac.authorization.k8s.io` API group to drive authorization decisions, which allows Kubernetes administrators
to dynamically configure policies through the Kubernetes API.


[k8s-controller]: https://kubernetes.io/docs/concepts/architecture/controller/
[custom-resources]: https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/
[k8s-operator]: https://kubernetes.io/docs/concepts/extend-kubernetes/operator/
[admission-controllers]: https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/
[k8s-rbac]: https://kubernetes.io/docs/reference/access-authn-authz/rbac/