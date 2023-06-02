---
title: Components
weight: 20
date: 2021-02-10T11:30:00+02:00
---


KubeCarrier consists of multiple components that are installed on a single Kubernetes Cluster, referred to as [Management Cluster]({{< relref "./concepts#management-cluster" >}}).

All components take the form of Kubernetes Controllers working with `CustomResourceDefinitions` and are build using the [kubebuilder project](https://github.com/kubernetes-sigs/kubebuilder).

## KubeCarrier CLI

The KubeCarrier CLI is a `kubectl` plugin that simplifies the management of your KubeCarrier installation, by providing helpers to validate the environment, trigger the KubeCarrier installation and work with KubeCarrier's APIs.

## KubeCarrier Operator

The KubeCarrier Operator is managing the core KubeCarrier installation and its dynamic components. It runs as a Kubernetes controller and continuously reconciles the KubeCarrier installation to ensure its operation.

## KubeCarrier Manager

The KubeCarrier Manager is the central component of KubeCarrier, that contains all core control loops.

## KubeCarrier API Server

The KubeCarrier API Server provides a public API with separate authentication (OIDC, Service Accounts, Static Users) from the kube-apiserver.
This component is designed as just a slim interface layer with the business logic, validation and authorization all being handled as kube-apiserver extensions.

## Ferry

KubeCarrier's `Ferry` component is responsible for managing the connection to a service cluster, which includes health checking, reporting the Kubernetes version and automated setting up of Namespaces in the connected cluster. For that, it opens an HTTPS connection to the Kubernetes API server of the service clusters.

## Catapult

A `Catapult` instance is automatically created when a `CustomResourceDiscovery` instance was able to discover a CustomResource from a service cluster and the CRD was successfully established within the management cluster's api machinery.

Each `Catapult` instance is responsible for reconciling one `CustomResourceDefinition` type from the management cluster to a service cluster.

## Elevator

An `Elevator` instance is automatically created when a `DerivedCustomResource` instance established a derived `CustomResourceDefinition`.

Each `Elevator` instance is reconciling one type of `CustomResourceDefinition` to its base.
