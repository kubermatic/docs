---
title: Installation
weight: 20
slug: installation
date: 2020-04-24T09:00:00+02:00
---

KubeCarrier is distributed via a public container registry [quay.io/kubecarrier](https://quay.io/kubecarrier). While the KubeCarrier installation is managed by the KubeCarrier operator, installing and upgrading the operator is done via our kubectl plugin.

This CLI tool will gain more utility functions as the project matures.

## Install the kubectl plugin

To install the kubectl plugin, just visit the KubeCarrier [release page](https://github.com/kubermatic/kubecarrier/releases), download the archive and put the contained `kubecarrier` binary into your `$PATH` as `kubectl-kubecarrier`.

Make sure the binary is executable.

If everything worked, you should now be setup with the `kubecarrier` plugin:
*(Your version should be way newer than this example)*

```bash
$ kubectl kubecarrier version --full
branch: master
buildTime: "2020-02-25T14:03:31Z"
commit: a23bdbe
goVersion: go1.13
platform: linux/amd64
version: master-a23bdbe
```

## Install KubeCarrier

```bash
# make sure you are connected to the cluster,
# that you want to install KubeCarrier on
$ kubectl config current-context
kind-kubecarrier

# install KubeCarrier
$ kubectl kubecarrier setup
0.03s ✔  Create "kubecarrier-system" Namespace
0.19s ✔  Deploy KubeCarrier Operator
6.29s ✔  Deploy KubeCarrier
```

The `kubectl kubecarrier setup` command is idempotent, so its safe to just re-run it multiple times, if you encounter any error in your setup.

Take a look at [Debugging Cheat Sheet](../cheat_sheets/debugging.md) if you encounter issues by installation.
