+++
title = "Admin Panel"
date = 2018-08-09T12:07:15+02:00
weight = 40
+++

This document describes how an administrator can change KKP configuration using the user interface.

## Admin Panel


### Accessing the Admin Panel

The Admin Panel is a view that can be accessed only by the users with admin rights. Admin rights can be granted from
the admin panel itself and also from the kubectl by setting the `spec.admin` field of the user object to `true`.

After logging in to the dashboard with an administrator you should be able to access the admin panel from the menu up
top.

### Admin Panel Overview

The Admin Panel contains multiple settings that are global for the whole KKP. The settings are applied after changing
them, there is no need for any additional confirmations. After changing the setting you will notice the spinner next to
the field that will turn into the green arrow once the setting will be saved.

#### Custom Links
An administrator is able to specify all the custom links that will be displayed in the application. Each custom link 
should have a label, URL and location. Additionally, it is possible to link to the icon that will be displayed next to 
the custom link. Some of the popular services like GitHub, Slack or Twitter will use their specific icons, others will 
use the default one if the custom icon is not specified.

#### Cleanup on Cluster Deletion

#### Displayed Distributions

#### Machine Deployment
An administrator is able to change the number of initial replicas count that will be used by default for all the machine
deployments that will be created.

#### Enable Kubernetes Dashboard

#### Enable OIDC Kubeconfig

#### Enable External Clusters

#### User Project Limit

#### Resource Quota

