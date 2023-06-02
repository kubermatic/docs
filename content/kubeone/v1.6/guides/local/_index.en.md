+++
title = "All-in-one Cluster"
date = 2022-08-05T15:58:00+02:00
+++

## Introduction

`kubeone local` subcommand helps initializing a **local** (i.e. on a local
machine), cluster. Container runtime, control-plane and kubelet with some basics
like CNI will be installed, together with removed taints to unblock the single
Node for a regular workloads. We call this "all-in-one cluster".

{{% notice warning %}}
`kubeone local` will do changes to your operating system, don't run it on a
working machine.
{{% /notice %}}

## Use Cases

A all-in-one setup could be useful for cases such as:
* Single edge server
* Developer VM
* CI VM

## Prerequisite

Local user that run the `kubeone local` ether has to have passwordless `sudo` or
be a `root` user.

### How to configure passwordless sudo

Edit the `/etc/sudoers` file with:
```shell
sudo visudo
```

Add a line:
```
<your_username> ALL=(ALL:ALL) NOPASSWD:ALL
```
Replacing `<your_username>` with your login (i.e. the value of shell `$USER`).

## Usage

For `kubeone local` the manifest is **optional**! You only need a config, if you
really want to customize something. By default manifest will be generated in
memory.

The Kubernetes api endpoint would be autodetect to the default gateway
interface. It can also be specified using `--apiendpoint` flag.

## Configuration

You can provide **optional** KubeOne Cluster manifest. Some parts of it will be
forcefully rewritten. Such fields include:

* `name`: will always be `local`
* `controlPlane`: will always be equal to local node, with Public and Private IP
  set to detected default IP, with empty `Taints`.
* `cloudProvider` will always be set to `None`
* `machineController.deploy` will always be set to `false`
* `operatingSystemManager.deploy` will be always set to `false`
* `versions.kubernetes` default to `1.24.2`, but can be set using flag
  `--kubernetes-version`

Rest of configuration is up to you. Config will be defaulted as usual (i.e. you
can omit specifying CNI or containerRuntime). 
