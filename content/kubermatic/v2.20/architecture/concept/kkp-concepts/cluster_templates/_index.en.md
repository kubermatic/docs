+++
title = "Cluster Templates"
date = 2021-08-02T14:07:15+02:00
title_tag = "Cluster Templates - Concepts"
weight = 1

+++

## Understanding Cluster Templates
Cluster templates are designed to standardize and simplify the creation of Kubernetes clusters. A cluster template is a
reusable cluster template object. It guarantees that every cluster it provisions from the template is uniform and consistent
in the way it is produced.

A cluster template allows you to specify a provider, node layout, and configurations to materialize a cluster instance
via Kubermatic API or UI.

## Scope
The cluster templates are accessible from different levels.
 - global: (managed by admin user) visible to everyone
 - project: accessible to the project users
 - user: accessible to the template owner in every project, where the user is in the owner or editor group

Template management is available from project level.
The regular user with owner or editor privileges can create template in project or user scope.
The admin user can create a template for every project in every scope. Template in `global` scope can be created only by admins.

## Credentials
Creating cluster from the template requires credentials to authenticate with the cloud provider. During template creation
the credentials are stored in the secret which is assigned to the cluster template. The credential secret is independent.
It's just a copy of credentials specified manually by the user or taken from the preset. Any credentials update must be
processed on the cluster template.

## Creating and Using Templates
Cluster templates can be created from scratch to pre-define the cluster configuration. The whole process is done in the UI wizard for the cluster creation.

During the cluster creation process, the end user can pick template and specify the desired number of cluster instances.
The cluster template doesn't create any link to the clusters. They work independently.
