+++
title = "Machine deployments"
date = 2019-12-16T12:07:15+02:00
weight = 80
+++

## Add a New Machine Deployment

To add a new machine deployment navigate to your cluster view and click on the `Add Machine Deployment` button:

![Cluster overview with highlighted add button](08-manage-node-deployments-overview.png)

In the popup you can then choose the number of nodes (replicas), kubelet version, etc for your newly created machine deployment. All nodes created in this machine deployment will have the chosen settings.

## Edit the Machine Deployment

To add or delete a worker node you can easily edit the machine deployment in your cluster. Navigate to the cluster overview, scroll down to `Machine Deployments` and click on the edit icon next to the machine deployment you want to edit:

![Machine deployment overview with highlighted edit button](08-manage-node-deployments-edit.png)

In the popup dialog you can now in- or decrease the number of worker nodes which are managed by this machine deployment, as well as their operating system, used image etc.:

![Machine deployment overview with opened edit modal](08-manage-node-deployments-edit-dialog.png)
