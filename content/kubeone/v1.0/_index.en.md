+++
title = "KubeOne"
date = 2020-04-01T09:00:00+02:00
+++

KubeOne is a CLI tool for installing, managing, and upgrading Kubernetes
High-Available (HA) clusters. It can be used on any cloud provider,
on-prem or bare-metal cluster.

![KubeOne logo](/img/header-logo-kubeone.png)

## Features

* Supports all upstream-supported Kubernetes versions
* Uses kubeadm to provision clusters
* Comes with a straightforward and easy to use CLI
* Choice of Linux distributions between Ubuntu, CentOS/RHEL and CoreOS
* Integrates with [Cluster-API][5] and [Kubermatic machine-controller][6] to
  manage worker nodes
* Integrates with Terraform for sourcing data about infrastructure and control
  plane nodes
* Officially supports AWS, DigitalOcean, GCE, Hetzner, Packet, OpenStack, VMware
  vSphere and Azure
* Kubernetes Conformance Certified

## KubeOne in Action

[![KubeOne Demo asciicast](https://asciinema.org/a/244104.svg)](https://asciinema.org/a/244104)

## Getting Started

All user documentation is available at the [KubeOne docs website](https://docs.kubermatic.com/kubeone/master/).

We have a getting started tutorial for each provider we support in the
[Getting Started section][13]. For example, the following document shows
[how to get started with KubeOne on AWS][8].

For advanced use cases and other features, check out the
[Using KubeOne section][14].

## Installing KubeOne

### Downloading a binary from GitHub Releases

The recommended way to obtain KubeOne is to grab the
binary from the [GitHub Releases][3] page. On the
releases page, find the binary for your operating system
and architecture and download it or grab the URL and use
`wget` or `curl` to download the binary.

**Version:** version of KubeOne  
**Operating system:** `linux` or `darwin` for macOS

```bash
curl -LO https://github.com/kubermatic/kubeone/releases/download/v<version>/kubeone_<version>_<operating_system>_amd64.zip
```

Extract the binary to the KubeOne directory. On Linux and macOS, you can use `unzip`.

```bash
unzip kubeone_<version>_<operating_system>_amd64.zip -d kubeone_<version>_<operating_system>_amd64
```

Move the `kubeone` binary to your path, so you can easily
invoke it from your terminal.

```bash
sudo mv kubeone_<version>_<operating_system>_amd64/kubeone /usr/local/bin
```

For a quick way to install the lastest version of KubeOne, use
the following commands:

```bash
OS=$(uname)
VERSION=$(curl -w '%{url_effective}' -I -L -s -S https://github.com/kubermatic/kubeone/releases/latest -o /dev/null | sed -e 's|.*/v||')
curl -LO "https://github.com/kubermatic/kubeone/releases/download/v${VERSION}/kubeone_${VERSION}_${OS}_amd64.zip"
unzip kubeone_${VERSION}_${OS}_amd64.zip -d kubeone_${VERSION}_${OS}_amd64
sudo mv kubeone_${VERSION}_${OS}_amd64/kubeone /usr/local/bin
```

### Building KubeOne

The alternative way to install KubeOne is using `go get`.

To get the latest stable release:

```
GO111MODULE=on go get k8c.io/kubeone@master
```

To get other releases, such as alpha, beta, and RC releases, you can provide a
tag to the `go get` command. Check out the [GitHub Releases][github-tags] for
the list of available tags.

```
GO111MODULE=on go get k8c.io/kubeone@<insert-tag>
```

For releases before v1.0.0-rc.1, you have to use the following `go get`
command.

```
GO111MODULE=on go get github.com/kubermatic/kubeone@<insert-tag>
```

While running of the master branch is a great way to peak at and test
the new features before they are released, note that master branch can
break at any time or may contain bugs. Official releases are considered
stable and recommended for the production usage.

If you already have KubeOne repository cloned, you can use `make`
to install it.

```bash
make install
```

### Using package managers

Support for packages managers is still work in progress and expected
to be finished for one of the upcoming release. For details about the
progress follow the [issue #471][12]

#### Arch Linux

`kubeone` can be found in the official Arch Linux repositories:

[https://www.archlinux.org/packages/community/x86_64/kubeone/](https://www.archlinux.org/packages/community/x86_64/kubeone/)

Install it via:

```bash
pacman -S kubeone
```

### Shell completion and generating documentation

KubeOne comes with commands for generating scripts for the shell
completion and for the documentation in format of man pages
and more.

To activate completions for `bash` (or `zsh`), run or put this command
into your `.bashrc` file:

```bash
. <(kubeone completion bash)
```

To put changes in the effect, source your `.bashrc` file.

```bash
source ~/.bashrc
```

To generate documentation (man pages for example, more available), run:

```bash
kubeone document man -o /tmp/man
```

## Kubernetes Versions Compatibility

Each KubeOne version is supposed to support and work with a set of Kubernetes
minor versions. We're targeting to support at least 3 minor Kubernetes versions,
however for early KubeOne releases we're supporting only one or two minor
versions.

New KubeOne release will be done for each minor Kubernetes version. Usually, a
new release is targeted 2-3 weeks after Kubernetes release, depending on number
of changes needed to support a new version.

Since some Terraform releases introduces incompatibilities to previuos versions,
only a specific version range is supported with each KubeOne release.

In the following table you can find what are supported Kubernetes and Terraform
versions for each KubeOne version. KubeOne versions that are crossed out are not
supported. It's highly recommended to use the latest version whenever possible.

| KubeOne version | 1.18 | 1.17 | 1.16 | 1.15 | 1.14 | Terraform | Supported providers                                                |
| --------------- | ---- | ---- | ---- | ---- | ---- | --------- | ------------------------------------------------------------------ |
| v0.11.0+        | +    | +    | +    | +    | -    | v0.12+    | AWS, DigitalOcean, GCE, Hetzner, Packet, OpenStack, vSphere, Azure |
| v0.10.0+        | -    | -    | +    | +    | +    | v0.12+    | AWS, DigitalOcean, GCE, Hetzner, Packet, OpenStack, vSphere, Azure |

## Getting Involved

We very appreciate contributions! If you want to contribute or have an idea for
a new feature or improvement, please check out our [contributing guide][2].

If you want to get in touch with us and discuss about improvements and new
features, please create a new issue on GitHub or connect with us over the
forums or Slack:

* [`#kubeone` channel][4] on [Kubernetes Slack][10]
* [Kubermatic forums][9]

## Reporting Bugs

If you encounter issues, please [create a new issue on GitHub][1] or talk to us
on the [`#kubeone` Slack channel][4]. When reporting a bug please include the
following information:

* KubeOne version or Git commit that you're running (`kubeone version`),
* description of the bug and logs from the relevant `kubeone` command (if
  applicable),
* steps to reproduce the issue,
* expected behavior

If you're reporting a security vulnerability, please follow
[the process for reporting security issues][11].

## Changelog

See [the list of releases][3] to find out about feature changes.

[1]: https://github.com/kubermatic/kubeone/issues
[2]: https://github.com/kubermatic/kubeone/blob/master/CONTRIBUTING.md
[3]: https://github.com/kubermatic/kubeone/releases
[4]: https://kubernetes.slack.com/messages/CNEV2UMT7
[5]: https://github.com/kubernetes-sigs/cluster-api
[6]: https://github.com/kubermatic/machine-controller
[7]: https://github.com/kubermatic/kubeone/tree/master/examples/ansible
[8]: ./getting_started/aws/
[9]: https://forum.kubermatic.com/
[10]: http://slack.k8s.io/
[11]: https://github.com/kubermatic/kubeone/blob/master/CONTRIBUTING.md#reporting-a-security-vulnerability
[12]: https://github.com/kubermatic/kubeone/issues/471
[13]: ./getting_started/
[14]: ./using_kubeone/
[github-tags]: https://github.com/kubermatic/kubeone/tags
