---
title: Use Cases
weight: 30
date: 2021-02-10T11:30:00+02:00
---

The KubeCarrier application service management platform can help you to build complex multi-application,
multi-cluster and hybrid-cloud solutions that can be easily managed from a central place, without
compromises on security aspects. To give you an idea, here are some examples:

## SaaS (Software as a Service) Platform
With KubeCarrier it is very easy to build a custom SaaS platform consisting of a single or multiple
applications (e.g. a webserver with a cache server and a database), running in single- or multi-cluster
Kubernetes infrastructure, that end users can just instantiate with a single click or API call.

## Multi-Provider SaaS Service Hub / Catalog
Since KubeCarrier can support multiple Service Providers, it is possible to use it as a
neutral Service Hub for SaaS Offerings from different independent Service Providers. For Example,
a provider from company A can offer a database SaaS, whereas another provider from company B
can provide a web application SaaS that may be using that database. Any user accessing the Service
Catalog can easily deploy their set of services across multiple providers, running in their own
separated infrastructures.

## Multi-Regional Service Deployments
In order to build multi-regional, highly-available solutions, it is often needed to deploy
the same set of applications into multiple Kubernetes clusters. In such deployments, it is critical to
manage the applications as a cattle, not as a pet - especially if we are speaking about dozens or hundreds
of clusters. KubeCarrier can be used as a central management hub for applications that run across many clusters.

## Hybrid Cloud Service Deployments
Complex application services consisting of multiple interconnected components can benefit from a deployment
in hybrid cluster scenarios. For instance, an application core may be running at a cloud provider,
the database with sensitive data in an on-premises cluster, whereas computational-intensive tasks
may need to be running in a cluster with specialized hardware resources - all at the same time.
With KubeCarrier, it is easy to manage such deployments from a central place and roll-out new tenant
deployments across all clusters at once.

## Multi-Cluster Machine Learning
A special case of the Hybrid Cloud Service Deployments is Multi-Cluster Machine Learning. In machine learning
world, it is very common to use specialized clusters with GPUs for training the models, and different clusters
for serving the trained models. If multi-tenancy is added into such a scenario, it may be non-trivial to manage.
With KubeCarrier, the hybrid machine learning deployments can be easily managed from a central place.

## Centralized Edge Management Hub
The world of Edge Computing brings the challenge of managing applications across hundreds or thousands of
small Kubernetes clusters. With KubeCarrier, the applications can be easily deployed into thousands
of Kubernetes clusters with a single click or API call. And that does not include only the deployment,
but all day 2 operations as well.
