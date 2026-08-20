+++
title = "Config Drive"
date = 2025-10-27T10:00:00+02:00
weight = 1
+++

## Config Drive

OpenStack provides two ways for VMs to access metadata: **metadata service** and **config drive**.  
By default, it uses the metadata service.

## Enable Config Drive

To use the config drive approach, you need to enable it when creating the **Machine Deployment**.

When creating a new **User Cluster**, you can enable this option in the **Initial Node** step.

![Enable Config Drive From Wizard](./images/cluster-wizard.png?classes=shadow,border "Enable Config Drive From Wizard")

You can also enable it for new **Machine Deployments** when creating them from the **Add Machine Deployment** dialog.

![Enable Config Drive From Add MD Dialog](./images/add-machine-deployment.png?classes=shadow,border "Enable Config Drive From Add MD Dialog")

## Enforce Config Drive

Admins can enforce the use of the config drive for all newly created **Machine Deployments** in a specific **datacenter** from the **Admin Settings**.

In the Admin Settings page, navigate to the **Datacenters** section.

![Navigate To Datacenters Settings](./images/navigate-datacenters.png?classes=shadow,border "Navigate To Datacenters Settings")

Enable the **Enable Config Drive** option when adding or editing a datacenter for the **OpenStack** provider.

![Enforce To Datacenters](./images/enforce-to-datacenters.png?classes=shadow,border "Enforce To Datacenters")

This will enforce the config drive for all newly created Machine Deployments in that datacenter.

