---
title: kubectl plugin
weight: 10
date: 2020-04-24T09:00:00+02:00
---

## Install the KubeCarrier kubectl plugin

To install the KubeCarrier kubectl plugin, just visit the KubeCarrier [release page](https://github.com/kubermatic/kubecarrier/releases), download the archive and put the contained `kubecarrier` binary into your `$PATH` as `kubectl-kubecarrier`.

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
To install KubeCarrier into a cluster, execute the `kubectl kubecarrier setup` command:

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

Take a look at [Debugging Cheat Sheet]({{< relref "../../cheat_sheets/debugging" >}}) if you encounter any issues by installation.
