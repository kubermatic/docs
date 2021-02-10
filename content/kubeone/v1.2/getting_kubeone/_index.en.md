+++
title = "Getting KubeOne"
date = 2020-07-30T12:00:00+02:00
weight = 1
enableToc = true
+++

## Install KubeOne using the script

The fastest way to get KubeOne is to use our installation script:

```
curl -sfL get.kubeone.io | sh
```

The installation script downloads the release archive from GitHub, installs
the KubeOne binary in your `/usr/local/bin` directory and unpacks the example
Terraform configs in your current working directory. If you want to inspect the
script before running it, you can use a command such as
`curl -sfL get.kubeone.io | less` or check it on [GitHub][github-script].

## Downloading a binary from GitHub Releases

You can download the binary from the [GitHub Releases][github-releases].
Find the archive for your operating system and architecture, and download it
or grab the URL and use it with `wget` or `curl`.

**Version:** version of KubeOne
**Operating system:** `linux` or `darwin` for macOS

```
curl -LO https://github.com/kubermatic/kubeone/releases/download/v<version>/kubeone_<version>_<operating_system>_amd64.zip
```

Extract the archive. On Linux and macOS, you can use `unzip`.

```
unzip kubeone_<version>_<operating_system>_amd64.zip -d kubeone_<version>_<operating_system>_amd64
```

Move the `kubeone` binary to your `$PATH`, so you can easily invoke it from
your terminal.

```
sudo mv kubeone_<version>_<operating_system>_amd64/kubeone /usr/local/bin
```

For a quick way to install the latest version of KubeOne, use
the following commands:

```
OS=$(uname)
VERSION=$(curl -w '%{url_effective}' -I -L -s -S https://github.com/kubermatic/kubeone/releases/latest -o /dev/null | sed -e 's|.*/v||')

curl -LO "https://github.com/kubermatic/kubeone/releases/download/v${VERSION}/kubeone_${VERSION}_${OS}_amd64.zip"

unzip kubeone_${VERSION}_${OS}_amd64.zip -d kubeone_${VERSION}_${OS}_amd64
sudo mv kubeone_${VERSION}_${OS}_amd64/kubeone /usr/local/bin
```

## Using package managers

Support for packages managers is still work in progress. For more details
about the progress follow the [issue #471][package-managers-issue]

### Arch Linux

KubeOne can be found in the [official Arch Linux repositories][arch-linux].
Use `pacman` or your preferred package manager to install it.

```
pacman -S kubeone
```

## Building KubeOne

If you have the Go toolchain configured, you can use `go get` to obtain KubeOne.

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

If you already have KubeOne repository cloned, you can use `make`
to install it.

```
make install
```

{{% notice note %}}
While running of the master branch is a great way to peak at and test
the new features before they are released, note that master branch can
break at any time or may contain bugs. Official releases are considered
stable and recommended for the production usage.
{{% /notice %}}


## Shell completion and generating documentation

KubeOne comes with commands for generating scripts for the shell completion
and for the documentation in format of man pages and more.

### Shell completion for Bash

To active completion for your current session, run the following command.

```
source <(kubeone completion bash)
```

To active completion permanently, add the command to your `~/.bashrc` file.

```
echo "source <(kubeone completion bash)" >> ~/.bashrc
```

### Shell completion for ZSH

To active completion for your current session, run the following command.

```
source <(kubeone completion zsh)
```

To active completion permanently, add the command to your `~/.zshrc` file.

```
echo "source <(kubeone completion bash)" >> ~/.zshrc
```

### Generating documentation

To generate documentation (man pages for example, more available), run:

```
kubeone document man -o /tmp/man
```

[github-releases]: https://github.com/kubermatic/kubeone/releases
[github-script]: https://github.com/kubermatic/kubeone/blob/master/install.sh
[github-tags]: https://github.com/kubermatic/kubeone/tags
[package-managers-issue]: https://github.com/kubermatic/kubeone/issues/471
[arch-linux]: https://www.archlinux.org/packages/community/x86_64/kubeone/
