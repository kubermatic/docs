+++
title = "Cluster Templates"
date = 2021-08-02T14:07:15+02:00
title_tag = "Cluster Templates - Tutorial"
weight = 5

+++

This section describes the usage of cluster templates in the KKP.

Cluster templates are designed to standardize and simplify the creation of Kubernetes clusters. A cluster template is a
reusable cluster template object. The more details about cluster template you can find here: [cluster template guide]({{< ref "../../architecture/concept/kkp-concepts/cluster-templates" >}})

## Create Cluster Template

There are two ways to create cluster template. First, you can do this during the cluster creation in the last `Summary` step:

![Create from cluster wizard](/img/kubermatic/main/tutorials/cluster_template/create_from_cluster_wizard.png?classes=shadow,border "Cluster Template creation")

Press button `Save Cluster Template` to create the template. Now you can specify the name and scope.

The newly created cluster template is visible in `Cluster Templates` menu:

![Create from cluster wizard](/img/kubermatic/main/tutorials/cluster_template/cluster_template_menu.png?classes=shadow,border "Cluster Template view")

You can also create a cluster template in this view. You will be redirected to the cluster creation wizard.

## Using Cluster Templates

On the right side, you can find the action buttons:

- Edit Cluster Template
- Create Clusters from Template
- Delete Cluster Template

## Create Clusters from Template

User can pick the desired template and specify number of cluster instances. The cluster template doesn't create any link to the clusters. They work independently.

![Create from cluster template wizard](/img/kubermatic/main/tutorials/cluster_template/create_cluster.png?classes=shadow,border "Create Clusters from Template")

## Edit Cluster Template

From cluster template list, users can select to edit the cluster template, the wizard will walk you through each step from the cluster template creation wizard.
![Edit cluster template](/img/kubermatic/main/tutorials/cluster_template/edit_cluster_template.png?classes=shadow,border "Edit Cluster Template")

Finally, user can choose to either update the existing cluster template or create a new cluster template that contains all the modifications.

![Create from cluster template wizard](/img/kubermatic/main/tutorials/cluster_template/edit_cluster_template_summary.png?classes=shadow,border "Save Cluster Template")

## Delete Cluster Template

![Delete from cluster template wizard](/img/kubermatic/main/tutorials/cluster_template/delete_template.png?classes=shadow,border "Delete Cluster Template")
