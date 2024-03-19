+++
title = "Update an Application"
date =  2022-08-03T16:43:41+02:00
weight = 4
+++

This guide targets Cluster Admins and details how to update an Application installed in the user cluster.
For more details on Applications, please refer to our [Applications Primer]({{< ref "../../../architecture/concept/kkp-concepts/applications/" >}}).

## Update an Application via the UI
Go to the Applications Tab and click on the pen icon to edit the application.

![Applications Tab](/img/kubermatic/v2.24/applications/applications_edit_icon.png?classes=shadow,border "Applications edit button")

Then you can update the values and or version using the editor.

{{% notice warning %}}
If you update the application's version, you may have to update the values accordingly.
{{% /notice %}}


![Applications Tab](/img/kubermatic/v2.24/applications/applications_edit_values.png?classes=shadow,border "Applications edit values and version")

## Update an Application via GitOps
Use `kubectl` to edit the applicationInstallation CR.

```sh
kubectl -n <namespace> edit applicationinstallation <name>
```

{{% notice warning %}}
If you update the application's version, you may have to update the values accordingly.
{{% /notice %}}


Then you can check the progress of your upgrade in `status.conditions`. For more information, please refer to [Application Life Cycle]({{< ref "../../../architecture/concept/kkp-concepts/applications/application-installation#application-life-cycle" >}}).
