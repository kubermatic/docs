+++
title = "Predefined Roles"
date = 2020-04-02T12:07:15+02:00
weight = 10
pre = "<b></b>"
+++

## Overview

A project is an entity that holds various resources.  All resources in a project are equal in terms of the `groups` attached
to them. Affiliation of a `user` to one of the `groups` give them certain powers they are allowed to use within a project.

### Kubermatic roles

There are three roles: owner, editor, and viewer. These roles are concentric; that is, the owner role includes the permissions
in the editor role, and the editor role includes the permissions in the viewer role.

  - **viewer**: can only read
  
  - **editor**: viewer + can create, edit & delete cluster
  
  - **owner**: editor + manage permissions for a project
  
The following table summarizes the permissions:

| Name                                              | Permissions                                                                                                                                                                                                                                                                            |
|---------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| viewer                                            | Permissions for read-only actions that do not affect the state, such as viewing.<br>Viewers are not allowed to interact with service accounts (user).<br>Viewers are not allowed to interact with members of a project (UserProjectBinding)                                            |
| editor                                            | All viewer permissions, plus permissions to create, edit & delete the cluster.<br>Editors are not allowed to delete a project. Editors are not allowed to interact with members of a project (UserProjectBinding).<br>Editors are not allowed to interact with service accounts (user) |
| owner (role can not be held by a service account) | All editor permissions and permissions for managing permissions for a project.<br>Only the owners of a project can create a service account (aka. users)<br>Only the owners of a project can manipulate members                                                                        |

### Kubermatic Service Accounts

A service account is a special type of user account that belongs to the Kubermatic project, instead of to an individual
end-user. A service accounts are considered as project's resource. Only the owner of a project can create and update a
service account. There is no need to create new groups for service accounts. It’s assigned to one of the already defined
groups:`editors` or `viewers`.
