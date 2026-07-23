+++
title = "Budgets & Virtual Keys"
linkTitle = "Budgets & Virtual Keys"
date = 2026-07-23T10:00:00+02:00
weight = 2
description = "Self-service API keys as Kubernetes objects, token and dollar budgets per tenant and per key, live spend in the key's status, and predictable behavior when a limit trips."
+++

Nobody enjoys asking the platform team for an API key. With KubeLB, a tenant doesn't have to: a key is a Kubernetes object in their own cluster. Create it, wait a few seconds, read the Secret that appears next to it. Delete the object and the key stops working everywhere. The platform team sets the guardrails once; after that, key lifecycle is entirely in the tenant's hands.

{{% notice info %}}
Virtual keys, budgets, and metering are Enterprise Edition features. Setting up the gateway itself is covered in [AI & MCP Gateway]({{% relref "../gateway/" %}}).
{{% /notice %}}

## Creating a key

Apply a `VirtualKey` in the tenant cluster:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: VirtualKey
metadata:
  name: team-rag-app
  namespace: ml-team
spec:
  # Optional. Each budget must fit inside the tenant budget for the same
  # window; omit to inherit the tenant defaultKeyBudgets.
  budgets:
    - tokens: 1000000
      window: Day
      onExceed: Block
  rateLimit:
    requestsPerMinute: 100
  expiresAfter: 720h        # capped by, and defaulting to, the tenant maxTTL
  disabled: false           # kill switch: revoke the key, keep the material
```

KubeLB generates the key material centrally, attaches it to the shared gateway, and syncs it back down as a Secret next to the object. The status tells you when it's ready:

```yaml
status:
  phase: Provisioned        # Pending | Provisioned | Rejected | Expired
  keyID: team-rag-app-1a2b3c
  secretRef:
    name: team-rag-app-key  # Secret in the VirtualKey namespace, data key "key"
  expiresAt: "2026-08-21T00:00:00Z"
```

A key comes back **Rejected**, with a condition explaining why, when the tenant's key quota (`virtualKeys.limit`) is used up or a requested budget is larger than the tenant budget for the same window.

Point any OpenAI-compatible SDK at the gateway with the key from the Secret:

```python
client = OpenAI(base_url="http://<gateway-address>/v1", api_key=key)
```

That's the whole client-side story. No provider credentials, no custom SDK.

### Revoking, disabling, expiry

Three ways a key stops working, each for a different situation:

- **Delete the VirtualKey.** The key is revoked and the synced Secret is removed. For keys you're done with.
- **Set `disabled: true`.** The key is revoked but the material is kept, so flipping it back restores the same key with no application redeploy. For incident response.
- **Let it expire.** `expiresAfter` defaults to, and is capped by, the tenant's `maxTTL`. The phase flips to `Expired` and authentication stops.

## Budgets

Budgets exist on three levels, all sharing one shape: an amount in `tokens`, US dollars (`usd`), or both, a calendar `window` (`Day`, `Week`, `Month`), and an `onExceed` action.

The admin sets fleet-wide defaults on the `Config`:

```yaml
spec:
  ai:
    defaultBudgets:
      - tokens: 50000000
        window: Month
        onExceed: Block
        alertThresholdPercent: 80
    virtualKeys:
      limit: 20
      maxTTL: 720h
      defaultKeyBudgets:
        - tokens: 1000000
          window: Day
```

A tenant can be given its own set on the `Tenant`; a non-empty `budgets` list replaces the defaults entirely, one budget per window:

```yaml
spec:
  ai:
    budgets:
      - tokens: 10000000
        window: Month
        onExceed: Block
    virtualKeys:
      limit: 5              # merged field by field with the Config values
```

And each key can carry its own budgets, as long as they fit inside the tenant's (shown above). `defaultKeyBudgets` gives every key an independent copy of the listed budgets; keys do not share them.

When a budget trips, `onExceed` decides what happens: `Block` rejects requests with 429 until the window resets, `Throttle` degrades traffic to `throttleRequestsPerMinute` instead of cutting it off, and `Notify` lets traffic flow and only raises the flag through status and metrics. `alertThresholdPercent` warns before the cliff, at the percentage you pick.

### What enforcement can and cannot do

Read this part before you promise anyone hard caps:

- Enforcement is post-hoc. Token counts come from provider responses, so the request that crosses the budget completes, and the one after it is rejected. Streamed responses are counted when the stream ends. Budgets are guardrails, not prepaid cards.
- Day windows are enforced inline by the global rate-limit service, and only when `spec.ai.rateLimitService` is set and the `ratelimit` + `valkey` addons run. Without them, a tenant with a Day budget gets `AIBudgetUnenforceable=True` on its `TenantState`, and Day traffic flows uncapped. The condition is loud on purpose.
- Week and Month windows are metered but not inline-enforced in this release.
- `usd` budgets (a decimal string like `"99.50"`) need the model cost catalog on the data plane. Without it, only token budgets are enforceable.
- Both `tokens` and `usd` set? Whichever runs out first wins.

## Watching spend

Tenants can't reach the management cluster's Prometheus, so KubeLB brings the number to them: the manager reads each key's consumption and writes it into the `VirtualKey` status, which is mirrored down to the tenant cluster.

```yaml
status:
  spend:
    - window: Day
      tokens: 412331
      windowStart: "2026-07-22T00:00:00Z"
```

This needs a Prometheus that scrapes the agentgateway proxy. Point KubeLB at yours; it does not run one:

```yaml
spec:
  ai:
    prometheus:
      url: http://prometheus-operated.monitoring.svc:9090
      # bearerTokenSecretRef: {name: prom-token, key: token}   # optional
      # caCertSecretRef: {name: prom-ca, key: ca.crt}          # optional
```

Without `prometheus` configured, provisioning and Day budgets work as before, but no key reports spend and the tenant's `TenantState` carries `AISpendMeteringDisabled=True` so the gap is visible instead of silent.

## When a request is rejected

Client applications see exactly two error shapes at the gateway:

| Status | Cause | Headers |
| --- | --- | --- |
| 401 | Missing or unknown key, revoked/expired key | — |
| 429 | Day budget or per-key rate limit exhausted | `RateLimit-Limit`, `RateLimit-Remaining`, `RateLimit-Reset`, `Retry-After` |

The `RateLimit-*` headers describe the most exhausted limit. `RateLimit-Reset` and `Retry-After` both carry the seconds until that window resets, so stock retry middleware, including the OpenAI SDKs, backs off for the right amount of time instead of hammering a closed door. Successful responses carry the informative `RateLimit-*` variants too, which means a client can see its remaining budget on every call without any extra endpoint.

## Showback for the platform team

Every request is attributed with `tenant_id` and `key_id`, in Prometheus metrics and in the gateway's access logs, with identical labels in both. Metrics answer "what happened"; the logs are there so a billing-grade pipeline can be built later without relabeling anything.

The `kubelb-addons` chart can render recording rules (`aiRecordingRules.enabled`) that pre-aggregate the raw series into a stable contract:

| Series | Labels | Meaning |
| --- | --- | --- |
| `kubelb:ai_tokens:increase1h` | `tenant_id`, `key_id`, `gen_ai_token_type` | Tokens in the trailing hour, input/output split |
| `kubelb:ai_requests:increase1h` | `tenant_id`, `key_id` | Requests in the trailing hour |
| `kubelb:ai_tokens_by_model:increase1h` | `tenant_id`, `gen_ai_system`, `gen_ai_response_model` | Tokens per provider and model |

The rules record hourly increases; sum them over whatever window a dashboard renders. Two forms are available: a `PrometheusRule` for prometheus-operator users (`aiRecordingRules.prometheusRule`) or a plain rule-file ConfigMap for vanilla Prometheus (`aiRecordingRules.configMap`). Build on the `kubelb:*` series, not the raw `agentgateway_*` names, which can change between upstream releases.
