+++
title = "From 2.9 to 2.10"
date = 2018-10-23T12:07:15+02:00
publishDate = 2019-04-30T00:00:00+00:00
weight = 13
pre = "<b></b>"
+++

## `values.yaml` structure for addons

With the addition of Openshift as supported platform the structure for configuring the addons has
changed to allow for a distinct configuration of Openshift and Kubernetes.
Before it was like this:

```
     addons:
       image:
         repository: "quay.io/kubermatic/addons"
         tag: "v0.1.18"
         pullPolicy: "IfNotPresent"
       # list of Addons to install into every user-cluster. All need to exist in the addons image
       defaultAddons:
       - canal
       - dashboard
       - dns
       - kube-proxy
       - openvpn
       - rbac
       - kubelet-configmap
       - default-storage-class
```

Now there is a subkey `openshift` or `kubernetes` after `addons`:

```
     addons:
       kubernetes:
         defaultAddons:
         - canal
         - dashboard
         - dns
         - kube-proxy
         - openvpn
         - rbac
         - kubelet-configmap
         - default-storage-class
         image:
           repository: "quay.io/kubermatic/addons"
           tag: "v0.1.18"
           pullPolicy: "IfNotPresent
       openshift:
         defaultAddons:
         - networking
         - openvpn
         image:
           repository: "quay.io/kubermatic/openshift-addons"
           tag: "v0.3"
           pullPolicy: "IfNotPresent"
```

## `values.yaml` the domain parameter for API deployment

A new parameter `domain` was added for kubermatic API deployment: `-domain={{ .Values.kubermatic.domain }}`
This domain name is used to create unique email address for a ServiceAccount objects in API.
Depends on the kubermatic installation the `domain` should be specified:

```
kubermatic:
  # external domain for the kubermatic installation. For example 'dev.kubermatic.io'
  domain: "example.com"

```
