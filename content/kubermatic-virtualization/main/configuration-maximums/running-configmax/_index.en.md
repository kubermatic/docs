+++
title = "Running ConfigMax"
date = 2026-06-11T09:00:00+02:00
weight = 3
+++

ConfigMax runs **inside the cluster** as an operator. You describe what to test in a single
`ConfigMaxRun` YAML file, apply it, and read the result back from the object's status. No external
tooling or connectivity is required.

Two ways to run it:

- [The operator (recommended)]({{< ref "./operator" >}}) — apply a `ConfigMaxRun` custom resource;
  the benchmark runs as an in-cluster Job. Use this for anything long-running.
- [The CLI binary]({{< ref "./cli" >}}) — the same benchmark engine as a standalone binary run from
  your workstation. Use it for quick smoke runs and first iterations.

## Prerequisites

- A running Kubermatic Virtualization cluster with `kubectl` access.
- The **ConfigMax operator** installed (it provides the `ConfigMaxRun` custom resource and a
  controller that turns each request into an in-cluster benchmark Job). The operator ships with the
  Kubermatic Virtualization tooling; install its manifests into the `configmax` namespace.
- If your image registry is private, an image-pull secret in the `configmax` namespace.
