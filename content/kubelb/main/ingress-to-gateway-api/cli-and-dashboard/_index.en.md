+++
title = "CLI & Dashboard"
linkTitle = "CLI & Dashboard"
date = 2026-02-04T00:00:00+01:00
weight = 2
+++

In addition to the [automated Helm-based converter]({{< relref "../kubelb-automation/" >}}), KubeLB provides two interactive interfaces for Ingress-to-Gateway API migration:

- **CLI** (`kubelb ingress`) -- a command-line workflow for listing, previewing, and converting Ingresses. Ideal for scripting and CI/CD pipelines.
- **Dashboard** (`kubelb serve`) -- a local web UI with the same capabilities, adding visual status overview, side-by-side YAML comparison, and point-and-click batch operations.

Both tools use the same conversion engine, share the same configuration options, and produce identical results.

Full documentation, including prerequisites, usage guides, configuration reference, and demo sections, is available in the CLI section:

**[Ingress to Gateway API -- CLI & Dashboard Guide]({{< relref "../../cli/ingress-to-gateway-api/" >}})**
