+++
title = "User Settings"
date = 2020-04-01T14:07:15+02:00
weight = 10

+++

This manual explains how to manage KKP user settings via the UI.

### Accessing the User Settings

To access the user settings click the `User Settings` entry in the user menu:

![User Menu](/img/kubermatic/master/ui/admin_panel_access.png?height=300px&classes=shadow,border "Accessing the User Settings")

### User Settings Overview

![User Settings](/img/kubermatic/master/ui/user_settings.png?classes=shadow,border "User Settings")

The user settings view is divided into two columns:
The left side contains all account details, such as the name and the email of the user, whereas the right side lists all possible settings that a user can make.

* `Items per page` will change the number of visible items per page in a table. It will be applied to all tables within KKP.
* `Theme` lists all available themes for the dashboard so the user can select its preferred one. Read chapter [Customizing the Dashboard Theme]({{< ref "../../../architecture/concept/kkp-concepts/user-interface/theming/" >}}) to learn more about themes.
* `Default Project` specifies which project should be opened by default. If selected, the user will automatically be redirected to the projects cluster view after login.
* `Project Landing Page` specifies the default landing page after selecting of a project. If the `Project Overview` option is selected (default option), users will be automatically redirected to the Project Overview tab view. If the `Clusters` option is selected, users will be automatically redirected to the Clusters tab view.

All settings changes are saved asynchronously, and the saves are confirmed by the green confirmation icons next to changed settings. Changes are automatically populated to all opened instances of the application.
