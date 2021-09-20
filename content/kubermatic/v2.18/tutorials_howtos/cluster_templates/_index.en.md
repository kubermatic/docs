+++
title = "Cluster templates"
date = 2021-08-02T14:07:15+02:00
weight = 20

+++

This section describes the usage of cluster templates in the KKP.

Cluster templates are designed to standardize and simplify the creation of Kubernetes clusters. A cluster template is a
reusable cluster template object. The more details about cluster template you can find here: [cluster template guide]({{< ref "../../guides/cluster_templates" >}})

## Create cluster template

There are to ways to create cluster template. First you can do this during the cluster creation in the last `Summary` step:

![Create from cluster wizard](/img/kubermatic/v2.18/tutorials/cluster_template/create_from_cluster_wizard.png?classes=shadow,border "Cluster template creation")

Press button `Save Cluster Template` to create the template. Now you can specify the name and scope.

The new created cluster template is visible in `Cluster Templates` menu:

![Create from cluster wizard](/img/kubermatic/v2.18/tutorials/cluster_template/cluster_template_menu.png?classes=shadow,border "Cluster template view")

You can also create a cluster template in this view. You will be redirected to the cluster creation wizard.

## Create cluster from the template

On the right side you can find two action buttons:
 - Create Cluster from Template
 - Delete Cluster Template

![Create from cluster wizard](/img/kubermatic/v2.18/tutorials/cluster_template/actions.png?classes=shadow,border "Action buttons")

### Create Cluster from Template
During the cluster creation process the end user can pick the desired template and specify number of cluster instances.
The cluster template doesn't create any link to the clusters. They work independently.

![Create from cluster wizard](/img/kubermatic/v2.18/tutorials/cluster_template/create_cluster.png?classes=shadow,border "Create clusters from template")
### Delete Cluster Template

![Create from cluster wizard](/img/kubermatic/v2.18/tutorials/cluster_template/delete_template.png?classes=shadow,border "Delete template")

You can also use templates int the `Clusters` menu.

![Create from cluster wizard](/img/kubermatic/v2.18/tutorials/cluster_template/create_from_clusters.png?classes=shadow,border "Create from Clusters")
