+++
title = "Theming"
date = 2018-06-21T14:07:15+02:00
weight = 50

+++

This guide explains the KKP UI theming capabilities.

{{% notice info %}}
Theming capabilities are available in the Enterprise Edition only. Community Edition uses the default light theme which
cannot be changed.
{{% /notice %}}

## Switching Themes
KKP UI provides three theming options out of the box:

- Light - default option
- Dark 
- System - picks light or dark theme based on the user's operating system theme

Users can select a theme option that he wants to use in the `User Settings` view. It can be accessed from the user menu.

![Default Themes](/img/kubermatic/master/ui/themes.gif?classes=shadow,border&height=400 "KKP UI Default Themes")

## Disabling Theming Functionality
In order to disable theming options for all users and enforce using only the default theme, set `enforced_theme`
property in the application `config.json` file to the name of the theme that should be enforced (i.e. `light`).

## Possible Customizing Approaches
There are two possible approaches of preparing custom themes. They all rely on the same functionality. It all depends on
user access to the application code in order to prepare and quickly test the new theme before using it in the official
deployment.

- [Preparing a new theme with source access]({{< ref "../../../tutorials/user_interface/theming/with_src" >}}) - this
  approach grants the possibility to reuse already defined code, to work with SCSS rules and to quickly test your new
  theme before applying it to the official deployment. Access to the KKP UI sources is required though.
- [Preparing a new theme without source access]({{< ref "../../../tutorials/user_interface/theming/without_src" >}}) -
  this approach has some more limitations like not being able to modify the SCSS rules, but this way does not require
  access to the KKP UI sources.
  