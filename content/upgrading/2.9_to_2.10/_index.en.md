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

## `values.yaml` structure for service account tokens
A new flag `service-account-signing-key` was added to the Kubermatic API. It is used to sign service account tokens via
HMAC. It should be unique per Kubermatic installation and can be generated with the command: `base64 -w0 /dev/urandom |head -c 100`
The value for this flag must be stored in `auth` section for `kubermatic`

For example:
```
kubermatic:
  auth:
    serviceAccountKey: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```
