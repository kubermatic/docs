+++
title = "Running ConfigMax"
date = 2026-06-11T09:00:00+02:00
weight = 3
+++

ConfigMax runs within the cluster as an operator. A run is described in a single `ConfigMaxRun`
YAML resource, applied to the cluster, and its result is read back from the object's status. It
requires no external tooling or network connectivity.

There are two ways to run it:

- [The operator (recommended)]({{< ref "./operator" >}}): apply a `ConfigMaxRun` custom resource,
  and the benchmark runs as an in-cluster Job. Use this for any long-running test.
- [The CLI binary]({{< ref "./cli" >}}): the same benchmark engine as a standalone binary run from
  a workstation. Use it for quick smoke runs and early iterations.

## Prerequisites

- A running Kubermatic Virtualization cluster with `kubectl` access.
- The **ConfigMax operator**, which provides the `ConfigMaxRun` custom resource and converts each
  request into an in-cluster benchmark Job. The operator ships with the Kubermatic Virtualization
  tooling; install its manifests into the `configmax` namespace.
- An image-pull secret in the `configmax` namespace if the image registry is private.
