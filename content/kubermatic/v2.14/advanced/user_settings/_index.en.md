+++
title = "Kubermatic Kubernetes Platform(KKP) User Settings"
date = 2020-04-01T14:07:15+02:00
weight = 10

+++

This manual explains how to manage KKP user settings via the UI.

### Accessing the User Settings
To access the user settings click the `User Settings` entry in the user menu:

![User menu](/img/kubermatic/v2.14/advanced/user-settings/menu.png)

### User Settings Overview

![User settings view](/img/kubermatic/v2.14/advanced/user-settings/view.png)

The user settings view is devided into two columns:
The left side contains all account details, such as the name and the email of the user, whereas the right side lists all possible settings that a user can make.

* `Items per page` will change the number of visible items per page in a table. It will be applied to all tables within KKP.
* `Theme` lists all available themes for the dashboard so the user can select its prefered one. Read chapter [Customizing the Dashboard Theme]({{< ref "../custom_ui" >}}) to learn more about themes.
* `Default Project` specifies which project should be opened by default. If selected, the user will automatically be redirected to the projects cluster view after login.

All settings changes are saved asynchronously, and the saves are confirmed by the green confirmation icons next to changed settings. Changes are automatically populated to all opened instances of the application.
