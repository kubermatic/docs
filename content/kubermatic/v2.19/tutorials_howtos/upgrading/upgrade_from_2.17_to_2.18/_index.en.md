+++
title = "Upgrading from 2.17 to 2.18"
date = 2021-06-08T18:33:39+02:00
weight = 105
+++

## Helm cert-manager email

Now every `certManager.clusterIssuers` has to set `.email` in chart cert-manager.

## kubeadm-configmap addon

A new `kubeadm-configmap` addon has been added, which is necessary for `bringyourown` clusters. In case that you are overriding the default addons list in your `KubermaticConfiguration` (`userClusters.addons.kubernetes.defaultManifests`), make sure to add `kubeadm-configmap` addon into the list. You can use `kubermatic-installer print` command to check the exact default addons list.
