+++
title = "The Operator"
date = 2026-06-11T09:00:00+02:00
weight = 1
+++

The operator path: describe the run in a `ConfigMaxRun` resource, apply it, watch it, read the
result. Prerequisites are listed on the
[Running ConfigMax]({{< ref "../_index.en.md" >}}) page.

## 1. Describe the run

Create a file `my-run.yaml`. This example discovers the subnets-per-tenant ceiling, stopping when
the cluster shows strain, a 1-hour timeout fires, or 10,000 subnets are reached — whichever comes
first:

```yaml
apiVersion: configmax.kubermatic.io/v1alpha1
kind: ConfigMaxRun
metadata:
  name: my-run
  namespace: configmax
spec:
  image: "quay.io/kubermatic/configmax:latest"   # benchmark image
  profile: custom                                 # custom = use the fields below
  tests:
    - subnetsPerVPC                               # which test(s) to run
  overrides:
    subnetsPerVPC:
      mode: discovery                             # discovery | target | workload-slo
      discovery:
        initialBatch: 100                         # objects in the first batch
        growthFactor: "1.5"                        # batch size ×1.5 each round
        batchPauseSec: 5                          # settle time between batches
        hardTimeoutSec: 3600                      # wall-clock cap (1 hour)
        safetyBound: 10000                        # absolute upper limit
      distressOverrides:
        sampleIntervalSec: 30                     # how often to check for strain
        consecutiveSamples: 3                     # trips needed before stopping
  settings:
    cleanupAfterRun: true                         # delete test objects when done
    stopOnFirstError: false
  ttlAfterFinished: 259200                        # keep result 3 days, then GC
```

The two blocks that matter most are `mode` (how the run decides to stop) and `discovery` (how
aggressively it pushes load).

## 2. Apply it and watch

```bash
kubectl apply -f my-run.yaml

# high-level progress
kubectl -n configmax get configmaxrun my-run

# live detail (phase, current test, messages)
kubectl -n configmax describe configmaxrun my-run
```

The `get` output shows the profile, phase (`Pending` → `Provisioning` → `Running` → `Completed`),
and a progress summary.

## 3. Read the result

When the phase is `Completed`, the headline numbers are in `.status.results`:

```bash
kubectl -n configmax get configmaxrun my-run \
  -o jsonpath='{range .status.results[*]}{.test}{": "}{.highestCount}{" (stopped by "}{.stoppedBy}{")\n"}{end}'
```

Example output:

```
subnetsPerVPC: 8001 (stopped by safety-bound)
```

`highestCount` is your discovered maximum; `stoppedBy` tells you *why* the run stopped — a distress
signal, `timeout`, or `safety-bound` (the configured cap). The full per-batch curve and cluster
snapshots live under `.status.report` for deeper analysis.

## Key parameters

These are the fields you will most often change. All live under `spec`.

| Field | Values | Purpose |
|---|---|---|
| `profile` | `smoke` · `medium` · `full` · `custom` | Preset scale. Use `custom` to control the fields below. |
| `tests` | list of test IDs | Which benchmarks to run (e.g. `subnetsPerVPC`, `vpcsPerCluster`, `networkPoliciesPerNamespace`, `nicsPerVM`). Only honored with `profile: custom`. |
| `overrides.<test>.mode` | `discovery` · `target` · `workload-slo` | How the test decides to stop. |
| `discovery.initialBatch` | integer (default 10) | Objects created in the first batch. |
| `discovery.growthFactor` | string float (default `"2.0"`) | Batch size multiplier each round. Lower = gentler ramp. |
| `discovery.batchPauseSec` | integer (default 5) | Settle time between batches; raise it to let the controller catch up. |
| `discovery.hardTimeoutSec` | integer (default 14400) | Wall-clock cap on the whole run. |
| `discovery.safetyBound` | integer (default 100000) | Absolute object-count cap — stops even with no distress. |
| `discovery.targetCount` | integer | For `mode: target` only: the count to reach for a PASS. |
| `distressOverrides.*` | integers | Tune the strain thresholds and sampling cadence. |
| `settings.cleanupAfterRun` | bool (default true) | Delete benchmark objects when the run finishes. |
| `settings.stopOnFirstError` | bool (default false) | Stop a test at the first create error instead of probing for the breaking point. |

## Profiles at a glance

| Profile | Scale | Typical duration | Use for |
|---|---|---|---|
| `smoke` | minimal counts, every test | ~15–30 min | Post-install sanity check, CI gate |
| `medium` | moderate limits | ~2–4 h | A balanced capacity snapshot |
| `full` | large-scale, true breaking points | 8–12 h+ | A full configuration-maximum sweep |
| `custom` | whatever you specify | varies | Targeting one test or one parameter |

{{% notice tip %}}
Start with `profile: smoke` to confirm the operator and harness work end-to-end, then switch to a
`custom` run that targets just the capability you care about. Full-cluster sweeps are best run
overnight.
{{% /notice %}}
