+++
title = "kcp on the Command Line"
weight = 1
+++

Interacting with KDP means interacting with kcp. Many platform operations like enabling Services,
creating workspaces, etc. are just manipulating kcp directly behind the scenes.

Even though many day-to-day operations will happen within a single workspaces (like deploying or
managing an application), there will also be instances where you might need to interact with kcp
and switch between workspaces. This can be done manually by editing your kubeconfig accordingly,
but is much simpler with the [kcp kubectl plugin](https://docs.kcp.io/kcp/v0.22/concepts/kubectl-kcp-plugin/).
It provides additional commands for common operations in kcp.

Make sure you have the kcp kubectl plugin installed.

## Workspaces

In kcp, workspaces are identified by a prefix in the APIServer path, for example
`https://127.0.0.1/clusters/root:foo` is a different workspace than `https://127.0.0.1/clusters/root:bar`.
Under both URLs will you find a regular Kubernetes API that supports service discovery and everything
else (and more!) you would expect.

To make switching between workspaces (i.e. changing the `clusters.*.server` value) easier, the kcp
kubectl plugin provides the `ws` command, which is like a combination of `cd`, `mkdir` and `pwd`.
Take note of the following examples:

```bash
export KUBECONFIG=/path/to/a/kubeconfig/that/points/to/kcp

# go into the root workspace, no matter where you are
kubectl ws root

# descend into the child namespace "foo" (if you are in root currently,
# you would end up in "root:foo")
kubectl ws foo

# ...is the same as
kubectl ws root:foo

# go one workspace up
kubectl ws ..

# print current workspace
kubectl ws .

# print a tree representation of workspaces
kubectl ws tree

# create a sub workspace (note: this is a special case for the `ws` command,
# not to be confused with the not-working variant `kubectl create ws`)
kubectl ws create --type=… my-subworkspace

# once this workspace is ready (a few seconds later), you could
kubectl ws my-subworkspace
```

## API Management

A KDP Service is reconciled into an `APIExport`. To use this API, you have to _bind to_ it. Binding
involves creating a matching (= same name) `APIBinding` in the workspace where the API should be
made available.

Note that you cannot have 2 `APIExports` that both provide an API `foo.example.com` enabled in the
same workspace.

Binding to an `APIExport` can be done using the kcp kubectl plugin:

```bash
# kubectl kcp bind apiexport <path to KDP Service>:<API Group of the Service>
kubectl kcp bind apiexport root:my-org:my.fancy.api
```

More information on binding APIs can be found in
[Using Services]({{< relref "../../platform-users/consuming-services" >}}).
