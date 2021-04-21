+++
title = "Admission plugins configuration"
date = 2021-02-05T14:07:15+02:00
weight = 150

+++

This page explains how to configure Admission Controllers in the Kubermatic.


### How do I turn on an admission controller? 

The Kubermatic manages the Kubernetes API server by setting the `enable-admission-plugins` flag with a comma-delimited
list of admission control plugins to be enabled during cluster creation.

In the current version, the default ones are:
```
NamespaceLifecycle
LimitRanger
ServiceAccount
DefaultStorageClass
DefaultTolerationSeconds
MutatingAdmissionWebhook
ValidatingAdmissionWebhook
Priority
ResourceQuota
```

The Kubermatic provides also two additional plugins: `PodNodeSelector` and `PodSecurityPolicy`. They can be selected in the
UI wizard.

![View](/img/kubermatic/v2.16/advanced/admission_plugins_configuration/select.png)


### PodNodeSelector configuration
Selecting `PodNodeSelector` plugin expands an additional view for the plugin configuration.

![View](/img/kubermatic/v2.16/advanced/admission_plugins_configuration/configuration.png)

In this view you can define selector for namespaces that have no label selector specified. This example defines the default
`NodeSelector` for the cluster, as well as whitelist for each namespace.
Every pod created in the `production` namespace will be injected the NodeSelector `env=production`
Every pod in the `development` namespace will inherit the `clusterDefaultNodeSelector`, in this case `env=development`.
