+++
title = "Dynamic Datacenters"
description = "In this chapter, you learn about dynamic datacenters which allow Administrators to control the datacenters available in Kubermatic Kubernetes Platform."
date = 2020-02-10T11:07:15+02:00
weight = 20
+++

![Dynamic Datacenters](/img/kubermatic/v2.18/ui/dc.png?classes=shadow,border "Dynamic Datacenters View")

Dynamic Datacenters view in the Admin Panel allows Administrators to control the datacenters available
in KKP. The most important capabilities that this view provides are listing, filtering, creating, editing and deleting
datacenters. All of these will be described below.

- ### [Listing & Filtering Datacenters](#add)
- ### [Creating & Editing Datacenters](#cre)
- ### [Deleting Datacenters](#del)

## Listing & Filtering Datacenters {#add}
Besides traditional list functionalities the Dynamic Datacenter view provides filtering options. Datacenters can be
filtered by:

- Seed
- Country
- Provider

Filters are applied together, that means result datacenters have to match all the filtering criteria.

## Creating & Editing Datacenters {#cre}
Datacenters can be added after clicking on the plus icon in the top right corner of the Dynamic Datacenters view. To
edit datacenter Administrator should click on the pencil icon that appears after putting mouse over one of the rows with
datacenters.

In both cases the dialog will look very similar but in the edit mode not all fields can be changed. Provider and seed
can be set only during the datacenter creation.

![Edit Datacenter](/img/kubermatic/v2.18/ui/dc_edit1.png?classes=shadow,border&height=600 "Dynamic Datacenters Edit Dialog")

![Edit Datacenter](/img/kubermatic/v2.18/ui/dc_edit2.png?classes=shadow,border&height=600 "Dynamic Datacenters Edit Dialog")

Fields available in the dialogs:

- Name
- Provider
- Seed
- Country - country where datacenter is located.
- Location - precise location of the datacenter, i.e. city where it is located.
- Required Email Domains - only users from the specified domains will be able to use this datacenter.
- Enforce Pod Security Policy - enforces pod security policy in all clusters using this datacenter.
- Enforce Audit Logging - enforces audit logging in all clusters using this datacenter.
- Provider Configuration - provider configuration in the YAML format.

## Deleting Datacenters {#del}
Datacenters can be deleted after clicking on the trash icon that appears after putting mouse over one of the rows with
datacenters.

![Delete Datacenter](/img/kubermatic/v2.18/ui/dc_delete.png?classes=shadow,border&height=200 "Dynamic Datacenters Delete Dialog")
