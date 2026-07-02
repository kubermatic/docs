+++
title = "The CLI Binary"
date = 2026-06-11T09:00:00+02:00
weight = 2
+++

The same benchmark engine ships as a standalone `configmax` binary. It runs the identical test
code directly against a kubeconfig — no operator install needed. Use it for quick smoke runs and
first iterations on a development cluster; prefer the
[operator]({{< ref "../operator" >}}) for anything long-running (the CLI
runs from your workstation, so a laptop sleep or a network blip cancels the run).

```bash
# 1. Point the config at your cluster: copy benchmarks/configs/default.yaml
#    and set cluster.kubeconfigPath, then enable the test(s) you want, e.g.:
#
#    cluster:
#      kubeconfigPath: "/path/to/kubeconfig"
#    networking:
#      subnetsPerVPC:
#        enabled: true
#        mode: discovery
#        discovery:
#          initialBatch: 5
#          growthFactor: 2.0
#          hardTimeoutSec: 300
#          safetyBound: 500

# 2. Inspect the cluster without creating anything
configmax discover --config my-config.yaml

# 3. Run the enabled benchmarks
configmax run --config my-config.yaml

# 4. Re-read a saved result or render a report
configmax results --file benchmarks/results/<result>.json
configmax report  --file benchmarks/results/<result>.json --format html
```

Results print as a summary table and persist as JSON under `benchmarks/results/`, including the
per-batch curve and the stop reason — the same data the operator reports in `.status.results`.
The config file accepts the same `mode` / `discovery` / `distressOverrides` fields as the CRD
overrides shown on the [operator]({{< ref "../operator" >}}) page.
