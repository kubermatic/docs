+++
title = "Create a new project"
date = 2019-10-17T12:07:15+02:00
weight = 20
pre = "<b></b>"
+++

## Create a new project

Clusters are assigned to projects, so in order to create a cluster, you must create a project first. In the Kubermatic dashboard, choose `Add Project`:

![Add Project](01-create-project-overview.png)

Assign your new project a name:

![Dialog to assign a project name](01-create-project-name.png)

You can assign key-label pairs to your projects. These will be inherited by the clusters and cluster nodes in this project. You can assign multiple key-label pairs to a project.

After you click `Save`, the project will be created. If you click on it now, you will see options for adding clusters and SSH keys.

![Creating the project](01-create-project-creating.png)

## Delete a project

To delete a project, move the cursor over the line with the project name and click the trash bucket icon.

![Deleting the project](01-delete-project.png)
