+++
title = "Preparing New Themes"
date = 2018-06-21T14:07:15+02:00
weight = 50
+++

There are two possible approaches of preparing custom themes. They all rely on the same functionality. It all depends on
user access to the application code in order to prepare and quickly test the new theme before using it in the official
deployment.

## Preparing a New Theme With Access to the Sources

This approach grants the possibility to reuse already defined code, to work with SCSS rules and to quickly test your new
theme before applying it to the official deployment. Access to the KKP UI sources is required though. Check out the [Theme with Source]({{< ref "./with-src" >}}) section for more details.

## Preparing a New Theme Without Access to the Sources

This approach has some more limitations like not being able to modify the SCSS rules, but this way does not require
access to the KKP UI sources. Check out the [Theme without Source]({{< ref "./without-src" >}}) section for more details.
