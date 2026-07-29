+++
title = "Insights"
linkTitle = "Insights"
date = 2026-07-29T10:00:00+02:00
description = "Deterministic configuration checks that surface problems across tenants as Insight objects."
weight = 37
+++

The management cluster holds every tenant's effective configuration, routes, policies and budgets. Insights evaluates all of it and reports configuration problems across the fleet.

Each finding is one `Insight` object in the namespace of the tenant it concerns, readable with `kubectl` and manageable through GitOps like any other cluster resource.

```bash
kubectl get insights -A
```

```text
NAMESPACE     NAME              CHECK    SEVERITY   STATE   AGE
kubelb        klb002-9f31ab04   KLB002   high       Open    4m
tenant-acme   klb014-3fa2c81b   KLB014   high       Open    4m
```

Checks are deterministic functions of cluster state: the same configuration always produces the same findings, and the absence of a finding means the check ran and passed. Nothing is sampled and no model is involved.

Insights are for the platform operator. They live in tenant namespaces but are not part of the tenant RBAC allowlist, so tenants do not see fleet-relative judgements about their configuration.

## Prerequisites

- A KubeLB management cluster running a manager version that includes the insights engine. The engine is enabled by default.
- Optional: a Prometheus that scrapes the manager for the [posture score](#posture-score), [metrics and alerts](#metrics-and-alerts).

## What it catches

Most checks examine a single tenant. Others compare tenants across the whole fleet, which only the management cluster can do:

- Two tenants claiming the same hostname. Both believe they own it, and neither cluster can see the other.
- A tenant whose certificate request was silently dropped because the hostname sits outside its allowed domains. From inside that tenant cluster it looks like cert-manager is broken.
- A tenant that does not enforce ReferenceGrants, or runs without network policies, while the rest of the fleet does.
- A quota about to refuse the next resource, with nothing but a controller log to explain the refusal.

The [check catalog]({{% relref "./checks/" %}}) lists all of them.

## Turning it off

The engine runs by default. To disable it:

```yaml
kubelb:
  enableInsights: false
```

Checks declare the features they need, so an installation without the WAF or the AI gateway skips those checks instead of reporting everything they cover as broken. Several checks compare tenants against each other and stay silent unless one differs from its peers; others only fire after an age or usage threshold. A healthy installation reports nothing.

## Reading a finding

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Insight
metadata:
  name: klb014-3fa2c81b
  namespace: tenant-acme
  labels:
    kubelb.k8c.io/insight-check: KLB014
    kubelb.k8c.io/insight-severity: high
    kubelb.k8c.io/insight-category: reliability
spec:
  check: KLB014
  slug: hostname-collision
  severity: high
  message: Ingress shop claims api.example.com, also claimed by globex. Traffic for it resolves to whichever claim the dataplane programmed last.
  targetRefs:
    - apiVersion: kubelb.k8c.io/v1alpha1
      kind: Route
      name: 4f2c1a90-...
      namespace: tenant-acme
  remediation:
    summary: Decide which tenant owns the hostname and change the other, or scope the hostname per tenant with spec.allowedDomains so the conflict cannot recur.
  docsURL: https://docs.kubermatic.com/kubelb/main/insights/checks/#klb014
status:
  state: Open
  firstSeen: "2026-07-29T09:12:04Z"
  lastEvaluated: "2026-07-29T09:24:07Z"
```

`evidence` points at the live objects behind the finding rather than copying them, so an insight cannot disagree with the state it describes. `remediation` is text: KubeLB never applies it.

Findings are labelled, so you can list by check, severity or category:

```bash
kubectl get insights -A -l kubelb.k8c.io/insight-severity=high
```

## Triage

Triage is recorded in `spec.triage`. The engine reads it and never writes it, so your decision survives sweeps, manager restarts and a GitOps re-apply.

```yaml
spec:
  triage:
    state: Dismissed
    reason: working_as_intended
```

| State | Meaning |
|-------|---------|
| unset | The finding is open. |
| `Acknowledged` | You have seen it and intend to fix it. It stays visible and keeps counting. |
| `Snoozed` | Hidden until `snoozeUntil`, then it reopens by itself. `snoozeUntil` is required. |
| `Dismissed` | Closed for good. `reason` is required: `working_as_intended`, `accepted_risk`, `false_positive`, `low_priority` or `other`. |

Dismissal survives re-detection: a dismissed finding that keeps reproducing stays dismissed. In a fleet, an unusual tenant configuration is often deliberate.

`status.state` combines your triage with what the checks currently see. When a check stops detecting a finding, the engine sets `Fixed` with a timestamp and deletes the object a day later. `Fixed` is always machine-observed. If the problem returns, the same object reopens with its original `firstSeen`, so a flapping configuration reads as one long-lived issue rather than a series of new ones.

## Suppressing a check

A check that does not suit your installation can be switched off for the whole fleet:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  insights:
    disabledChecks:
      - KLB010
```

Findings of a disabled check are deleted rather than marked fixed, since a check that did not run has not verified anything. The same applies to a check whose feature is unavailable, such as the WAF checks on an installation running without `--enable-waf`: those checks are skipped and counted, not reported as passing.

Prefer dismissing individual findings. A dismissal keeps the check working for everything else it covers.

## Posture score

Alongside the findings, KubeLB scores what it examined:

```text
kubelb_manager_posture_score{tenant="acme", category="security"}  0.83
kubelb_manager_posture_score{tenant="acme", category=""}          0.91
```

The empty category is the tenant's overall score, so you can rank tenants without adding up categories. The formula is the share of examined objects with no problem, counting high-severity findings in full and lower-severity ones at half:

```text
passing / (passing + high + 0.5 * low)
```

Informational findings are observations rather than problems and do not count. Dismissed and snoozed findings leave both sides of the calculation, so triage cannot move a score in either direction. A tenant with nothing applicable to measure exports no score rather than a perfect one.

## Metrics and alerts

| Metric | Description |
|--------|-------------|
| `kubelb_manager_insights` | Open or acknowledged findings by `tenant`, `severity`, `category` and `check_id`. |
| `kubelb_manager_posture_score` | Posture between 0 and 1 by `tenant` and `category`. |
| `kubelb_manager_insights_sweep_duration_seconds` | Duration of a full sweep. |
| `kubelb_manager_insights_checks_skipped_total` | Checks that did not run, by reason. |
| `kubelb_manager_insights_checks_failed_total` | Checks that failed to evaluate. |

`kubelb_manager_insight_info` emits one series per finding, naming the affected object for alerts that need it. Object names are unbounded label values, so it is off by default:

```yaml
kubelb:
  insights:
    perFindingMetrics: true
```

With `prometheusRule.enabled`, the chart ships four alerts: a critical finding that survives several sweeps, a tenant posture below 60% for an hour, a check that panicked, and a sweep loop that stopped. The `KubeLB / Insights` Grafana dashboard shows fleet posture, tenants ordered by posture score, and checks ranked by how many findings they account for.

Kubernetes events are emitted when a finding opens, is fixed, or reopens, not on every sweep.

## How the sweep works

The engine evaluates the whole registry every three minutes, and immediately when the `Config`, a `Tenant`, or a finding's triage changes. It reads the caches the manager already maintains, so a sweep costs no extra API traffic. A check that panics loses its own findings for that round and nothing else.

Because the sweep is idempotent, a manager restart changes nothing. Triage lives on the objects, `firstSeen` is preserved, and the next sweep re-derives the rest.

One limitation: the engine reads the xDS cache in its own process, and the control plane runs on every manager replica while the sweep runs only on the leader. Findings about the dataplane therefore describe the replica that observed them, and say so.

## Table of Contents

{{% children depth=1 %}}
{{% /children %}}
