+++
title = "Configuration"
date = 2026-03-17T10:07:15+02:00
weight = 20
+++

Conformance EE can be configured in two ways:

1. **Interactive TUI** — The `conformance-tester` CLI guides you through all configuration options interactively.
2. **YAML Configuration File** — For headless or automated runs (e.g., in-cluster Jobs), provide a YAML file via the `CONFORMANCE_TESTER_CONFIG_FILE` environment variable.

If no configuration file is set, built-in defaults are used.

## Table of Content

{{% children depth=5 %}}
{{% /children %}}
