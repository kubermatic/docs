+++
title = "From 2.9 to 2.10"
date = 2018-10-23T12:07:15+02:00
publishDate = 2019-03-30T00:00:00+00:00
weight = 13
pre = "<b></b>"
+++

##  The config option `Values.kubermatic.rbac` was moved to `Values.kubermatic.masterController`

## `values.yaml` structure for addons

The structure for configuring the addons has changeg and now contains a subkey `kubernetes`
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

Now there is a subkey `kubernetes` after `addons`:

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
```

