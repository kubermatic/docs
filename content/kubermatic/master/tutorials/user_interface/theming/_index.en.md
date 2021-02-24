+++
title = "Preparing New Themes"
date = 2018-06-21T14:07:15+02:00
weight = 50
+++

There are two possible approaches of preparing custom themes. They all rely on the same functionality. It all depends on
user access to the application code in order to prepare and quickly test the new theme before using it in the official
deployment.

- [Preparing a new theme with source access]({{< ref "./with_src" >}}) - this
  approach grants the possibility to reuse already defined code, to work with SCSS rules and to quickly test your new
  theme before applying it to the official deployment. Access to the KKP UI sources is required though.
- [Preparing a new theme without source access]({{< ref "./without_src" >}}) -
  this approach has some more limitations like not being able to modify the SCSS rules, but this way does not require
  access to the KKP UI sources.