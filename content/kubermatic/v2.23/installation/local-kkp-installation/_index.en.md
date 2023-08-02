+++
title = "Local Kubermatic Kubernetes Platform (KKP) CE Installation"
linkTitle = "Local Installation"
date = 2023-06-26T09:49:10+02:00
weight = 200
enableToc = true
+++

{{% notice warning %}}
Local KKP installation is **not** intended for production setups.
{{% /notice %}}

This page will guide you through using the KKP installer local command `kubermatic-installer local`. This command simplifies and automates the installation of KKP CE using `kind` and a preconfigured KubeVirt seed. The command is intended only for evaluation and local development purposes. For production KKP installation use the [CE installation guide](../install-kkp-ce) or [EE installation guide](../install-kkp-ee).

## Pre-Installation Requirements

- **Operating System:** Currently, only Linux is supported.
- **Disk Space:** A minimum of 10Gi is recommended.
- **RAM:** At least 8Gi of RAM is needed; 16Gi is recommended for more than a single KubeVirt user cluster.
- **`kind`** (version 0.17 or higher): Please refer to the [`kind` documentation](https://kind.sigs.k8s.io/docs/user/quick-start/) for installation instructions.

{{% notice warning %}}
The `kubermatic-installer local kind` is currently considered experimental. It will install [KubeVirt](https://kubevirt.io/quickstart_kind/) and [CDI](https://kubevirt.io/labs/kubernetes/lab2.html) inside of the `kind` cluster and for every user cluster download VM image from Kubermatic hosted registry. KubeVirt nodes may require significant portion of your available CPU and RAM, in addition to 600Mi of disk space per VM image.
{{% /notice %}}

## Installation Procedure

Follow these steps to use the KKP installer local command:

**1. Download the installer.** This is the only manual step; there's no need to prepare any configuration since the installer should automatically configure KKP.

{{< tabs name="Download the installer" >}}
{{% tab name="Linux" %}}
```bash
VERSION=$(curl -w '%{url_effective}' -I -L -s -S https://github.com/kubermatic/kubermatic/releases/latest -o /dev/null | sed -e 's|.*/v||')
wget https://github.com/kubermatic/kubermatic/releases/download/v${VERSION}/kubermatic-ce-v${VERSION}-linux-amd64.tar.gz
tar -xzvf kubermatic-ce-v${VERSION}-linux-amd64.tar.gz
```
{{% /tab %}}
{{% tab name="MacOS" %}}
```bash
# Determine your macOS processor architecture type
# Replace 'amd64' with 'arm64' if using an Apple Silicon (M1) Mac.
export ARCH=amd64
# For latest version:
VERSION=$(curl -w '%{url_effective}' -I -L -s -S https://github.com/kubermatic/kubermatic/releases/latest -o /dev/null | sed -e 's|.*/v||')
# For specific version set it explicitly:
# VERSION=2.21.x
wget "https://github.com/kubermatic/kubermatic/releases/download/v${VERSION}/kubermatic-ce-v${VERSION}-darwin-${ARCH}.tar.gz"
tar -xzvf "kubermatic-ce-v${VERSION}-darwin-${ARCH}.tar.gz"
```
{{% /tab %}}
{{< /tabs >}}

You can find more information regarding the download instructions in the [CE installation guide](../install-kkp-ce/#download-the-installer).

**2. Run the `local` command.**

```bash
./kubermatic-installer local kind
```

The KKP installation should take no longer than a couple of minutes.
First, it creates a `kind` cluster named `kind-kkp-cluster`, exposes ports `443`, `80` for the KKP API, KKP dashboard, dex, and ports `6443`, `8088` for user cluster `kube-apiserver` via the [tunneling expose strategy](../../tutorials-howtos/networking/expose-strategies/#tunneling). You can examine the generated `kind` config, as well as the generated Kubermatic and Helm values configuration, under your working directory:

```none
./examples/kind-config.yaml
./examples/kubermatic.yaml
./examples/values.yaml
```

The installer also configures a single `Seed` and `Presets` for KubeVirt user clusters deployed in the same `kind` cluster. You can inspect the resources using `kubectl`:

```bash
kubectl get seed -nkubermatic kubermatic -o yaml 
kubectl get preset -nkubermatic local -o yaml
```

## Post-Installation

After completing the installation, you should have a local, trimmed-down KKP setup suitable for development purposes. The installer will provide login instructions:

```none
INFO[0408] KKP installed successfully, login at http://10.0.0.12.nip.io
INFO[0408]   Default login:    kubermatic@example.com
INFO[0408]   Default password: password
```

## Teardown Procedure

When you're finished experimenting with your local KKP setup, you can easily terminate it with a single command:

```bash
kind delete cluster --name kkp-cluster
```

## Configuration and Customization

The KKP dashboard is [exposed using `nip.io`](https://nip.io/), and certain browser plugins, such as various ad blockers, may prevent access to `nip.io`. If this is the case, consider disabling these plugins.

By default, KubeVirt is configured to use hardware virtualization. If this is not possible for your setup, consider [setting KubeVirt to use software emulation mode](https://github.com/kubevirt/kubevirt/blob/v1.0.0-rc.0/docs/software-emulation.md).

On Linux, KubeVirt uses the inode notify kernel subsystem `inotify` to watch for changes in certain files. Usually you shouldn't need to configure this but in case you can observe the `virt-handler` failing with
```
kubectl log -nkubevirt ds/virt-handler
...
{"component":"virt-handler","level":"fatal","msg":"Failed to create an inotify watcher","pos":"cert-manager.go:105","reason":"too many open files","timestamp":"2023-06-22T09:58:24.284130Z"}
```
You may need to set the default values higher to ensure KubeVirt operates correctly. How to change this, along with reasonably elevated values, is described below but it's recommended to inspect your system to figure out the correct `inotify` values depending on your needs and current setup.
```bash
sudo sysctl -w fs.inotify.max_user_watches=524288
sudo sysctl -w fs.inotify.max_user_instances=256
```
