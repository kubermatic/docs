+++
title = "Using kubectl"
date = 2019-11-13T12:07:15+02:00
weight = 70
+++

See the [Official kubectl Install Instructions](https://kubernetes.io/docs/tasks/tools/install-kubectl/) for a tutorial on how to install kubectl on your system. Once you have it installed, [download the kubeconfig](../06-download-kubeconfig/), change into the download directory and export it to your environment:

```bash
$ export KUBECONFIG=$PWD/kubeconfig-admin-czmg7r2sxm
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"13", GitVersion:"v1.13.0", GitCommit:"...", GitTreeState:"clean", BuildDate:"...", GoVersion:"go1.11.2", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"14", GitVersion:"v1.14.8", GitCommit:"...", GitTreeState:"clean", BuildDate:"...", GoVersion:"go1.12.10", Compiler:"gc", Platform:"linux/amd64}
```
