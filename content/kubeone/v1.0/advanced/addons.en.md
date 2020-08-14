+++
title = "Addons"
date = 2020-04-01T12:00:00+02:00
weight = 3
+++

Addons are a mechanism used to deploy Kubernetes resources after provisioning
the cluster. Addons allow operators to use KubeOne to deploy various components
such as CNI and CCM, and various stacks such as logging and monitoring, backups
and recovery, log rotating, and more.

This document explains how to use addons in your workflow. If you want to learn
more about how addons are implemented, you can check the
[design proposal][design-proposal] for more details.

## Writing Addons

Addons are represented as Kubernetes YAML manifests. To deploy an addon, the
operator needs to put a YAML manifest in a directory and provide it as the
addons directory in the KubeOne cluster configuration.

### Templating

Manifests support templating based on [Go templates][go-templates].
The following data is available out of the box:

* KubeOne cluster configuration - `.Config`
* Credentials - `.Credentials`

On top of that, you can use the [`sprig`][sprig] functions in your templates.
For list of available functions, consider the [`sprig` docs][sprig-docs].

### Example

The following snippet shows how an addon looks like and how to use templating:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: example-{{ .Config.Name }} # will be rendered as 'example-cluster_name'
---
apiVersion: v1
kind: Secret
metadata:
  name: credentials
  namespace: kube-system
type: Opaque
data:
  AWS_ACCESS_KEY_ID: {{ .Credentials.AWS_ACCESS_KEY_ID | b64enc }} # will be rendered as base64-encoded AWS access key
  AWS_SECRET_ACCESS_KEY: {{ .Credentials.AWS_SECRET_ACCESS_KEY | b64enc }} # will be rendered as base64-encoded AWS secret access key
```

**Note:** The `b64enc` function is a [`sprig` function][sprig-b64enc].

## Enabling Addons

To enable addons, you need to modify the KubeOne cluster configuration to add
the `addons` config:

```yaml
apiVersion: kubeone.io/v1beta1
kind: KubeOneCluster
versions:
  kubernetes: 1.16.1
cloudProvider:
  aws: {}
# Addons are Kubernetes manifests to be deployed after provisioning the cluster
addons:
  enable: true
  # In case when the relative path is provided, the path is relative
  # to the KubeOne configuration file.
  path: "./addons"
```

The addons path is normalized on the runtime. If you provide a relative path,
the path is relative to the KubeOne configuration file. This means that
`./addons` will be parsed depending on the `kubeone` command you use:
* `kubeone install -m config.yaml` - `./addons`
* `kubeone install -m other/dir/config.yaml` - `./other/dir/addons/config.yaml`

{{% notice note %}}
Subdirectories are not considered when applying addons. Only addons in the root
of the provided directory will be applied.
{{% /notice %}}

## Reconciling Addons

The addons are reconciled after initializing and joining the control plane
nodes nodes when running `kubeone install`, `kubeone upgrade`, or
`kubeone apply`. You can also reconcile addons after the cluster is provisioned
by using `kubeone apply`.

```bash
kubeone apply --manifest kubeone.yaml -t .
```

The reconciliation is done using `kubectl` over SSH, using a
command such as:

```
kubectl apply -f addons.yaml --prune -l kubeone.io/addon
```

Using the `--prune` options means that the next time you run `kubeone`:
* if you updated any manifest, the corresponding resources in the cluster will
be updated,
* if you removed a resource from a manifest, the resource will be removed from
the cluster as well
* if you removed a whole manifest, all resources defined in that manifest will
be removed from the cluster

{{% notice warning %}}
The `--prune` option can be **dangerous**. Always make sure that you have all
needed manifests present in the addons directory and correct addons
configuration before running `kubeone`.
{{% /notice %}}

The addons are applied in the alphabetical order. This means that you can
control in which order addons will be applied by setting the
appropriate file name.

## Example Addons

We provide the example addons that you can use as a template or to handle
various tasks, such as cluster backups. You can find the example addons in
the [`addons`][addons] directory.

[design-proposal]: https://github.com/kubermatic/kubeone/blob/release/v1.0/docs/proposals/20200205-addons.md
[go-templates]: https://golang.org/pkg/text/template/
[sprig]: https://github.com/Masterminds/sprig
[sprig-docs]: http://masterminds.github.io/sprig/
[sprig-b64enc]: http://masterminds.github.io/sprig/encoding.html
[addons]: https://github.com/kubermatic/kubeone/tree/release/v1.0/addons
