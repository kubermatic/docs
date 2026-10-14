+++
title = "The Operator"
date = 2026-06-11T09:00:00+02:00
weight = 1
+++

The operator path is to describe the run in a `ConfigMaxRun` resource, apply it, watch it, and read
the result. Prerequisites are listed on the
[Running ConfigMax]({{< ref "../_index.en.md" >}}) page.

## 1. Describe the run

Create a file `my-run.yaml`. This example discovers the subnets-per-tenant ceiling and stops when
the cluster shows strain, when a one-hour timeout elapses, or when 10,000 subnets are reached,
whichever occurs first:

```yaml
apiVersion: configmax.kubermatic.io/v1alpha1
kind: ConfigMaxRun
metadata:
  name: my-run
  namespace: configmax
spec:
  image: "quay.io/kubermatic/configmax:latest"   # benchmark image
  profile: custom                                 # custom applies the fields below
  tests:
    - subnetsPerVPC                               # the test or tests to run
  overrides:
    subnetsPerVPC:
      mode: discovery                             # discovery | target | workload-slo
      discovery:
        initialBatch: 100                         # objects in the first batch
        growthFactor: "1.5"                        # batch size multiplied by 1.5 each round
        batchPauseSec: 5                          # settle time between batches
        hardTimeoutSec: 3600                      # wall-clock cap (one hour)
        safetyBound: 10000                        # absolute upper limit
      distressOverrides:
        sampleIntervalSec: 30                     # how often to check for strain
        consecutiveSamples: 3                     # trips required before stopping
  settings:
    cleanupAfterRun: true                         # delete test objects when done
    stopOnFirstError: false
  ttlAfterFinished: 259200                        # keep the result for three days, then GC
```

The two most significant fields are `mode`, which determines how the run decides to stop, and
`discovery`, which determines how aggressively the run applies load.

## 2. Apply and monitor the run

```bash
kubectl apply -f my-run.yaml

# high-level progress
kubectl -n configmax get configmaxrun my-run

# detailed status (phase, current test, messages)
kubectl -n configmax describe configmaxrun my-run
```

The `get` output shows the profile, the phase (`Pending`, `Provisioning`, `Running`, `Completed`),
and a progress summary.

## 3. Read the result

Once the phase is `Completed`, the primary figures are available in `.status.results`:

```bash
kubectl -n configmax get configmaxrun my-run \
  -o jsonpath='{range .status.results[*]}{.test}{": "}{.highestCount}{" (stopped by "}{.stoppedBy}{")\n"}{end}'
```

Example output:

```
subnetsPerVPC: 8001 (stopped by safety-bound)
```

`highestCount` is the discovered maximum, and `stoppedBy` states why the run stopped: a distress
signal, `timeout`, or `safety-bound` (the configured cap). The full per-batch curve and cluster
snapshots are available under `.status.report`.

## Key parameters

These are the fields changed most often. All live under `spec`.

| Field | Values | Purpose |
|---|---|---|
| `profile` | `smoke` · `medium` · `full` · `custom` | Preset scale. Use `custom` to control the fields below. |
| `tests` | list of test IDs | Which benchmarks to run (for example `subnetsPerVPC`, `vpcsPerCluster`, `networkPoliciesPerNamespace`, `nicsPerVM`). Honored only with `profile: custom`. |
| `overrides.<test>.mode` | `discovery` · `target` · `workload-slo` | How the test decides to stop. |
| `discovery.initialBatch` | integer (default 10) | Objects created in the first batch. |
| `discovery.growthFactor` | string float (default `"2.0"`) | Batch-size multiplier each round. A lower value produces a more gradual ramp. |
| `discovery.batchPauseSec` | integer (default 5) | Settle time between batches; raise it to let the controller catch up. |
| `discovery.hardTimeoutSec` | integer (default 14400) | Wall-clock cap on the whole run. |
| `discovery.safetyBound` | integer (default 100000) | Absolute object-count cap; stops the run even with no distress. |
| `discovery.targetCount` | integer | For `mode: target` only: the count to reach for a pass. |
| `distressOverrides.*` | integers | Tune the strain thresholds and sampling cadence. |
| `settings.cleanupAfterRun` | bool (default true) | Delete benchmark objects when the run finishes. |
| `settings.stopOnFirstError` | bool (default false) | Stop a test at the first create error instead of probing for the breaking point. |

## Profiles at a glance

| Profile | Scale | Typical duration | Use for |
|---|---|---|---|
| `smoke` | minimal counts, every test | about 15 to 30 minutes | a post-install sanity check or a CI gate |
| `medium` | moderate limits | about 2 to 4 hours | a balanced capacity snapshot |
| `full` | large-scale, true breaking points | 8 to 12 hours or more | a complete configuration-maximum sweep |
| `custom` | whatever you specify | varies | targeting one test or one parameter |

{{% notice tip %}}
Begin with `profile: smoke` to confirm that the operator and harness function end to end, then
switch to a `custom` run that targets the specific capability of interest. Full-cluster sweeps are
best scheduled to run overnight.
{{% /notice %}}
