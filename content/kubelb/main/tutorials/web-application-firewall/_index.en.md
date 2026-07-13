+++
title = "Web Application Firewall (Beta)"
linkTitle = "Web Application Firewall"
date = 2026-01-23T10:00:00+02:00
weight = 7
enterprise = true
+++

KubeLB provides Web Application Firewall (WAF) capabilities using the [Coraza WASM filter](https://github.com/corazawaf/coraza-proxy-wasm). It inspects Layer 7 HTTP traffic at the Envoy Proxy level and blocks malicious requests using [OWASP Core Rule Set (CRS)](https://coreruleset.org/docs/) — protecting against SQL injection, XSS, and other injection attacks without application changes.

{{% notice note %}}
WAF is a **beta** feature available in Enterprise Edition only. Suitable for non-critical production workloads; observe WAF metrics (see [Monitoring](#monitoring)) before rolling out broadly.
{{% /notice %}}

## Why WAF?

- SQL injection, XSS, and command injection attacks blocked at the gateway before reaching backends
- OWASP CRS rule sets enabled by default
- No application code changes required — protection applied at infrastructure level
- Per-route or global policies with label-based multi-tenant targeting

Unlike a WAF deployed per cluster, KubeLB manages WAF policies for the whole fleet from the management cluster: platform operators apply policies globally, per tenant, or per route, and application teams can still opt individual services in or out.

## Supported Routes

| Route Type | Supported |
|-----------|-----------|
| HTTPRoute | Yes |
| GRPCRoute | Yes |
| LoadBalancer (Layer 4) | No |
| TCPRoute / UDPRoute / TLSRoute | No |

WAF operates at Layer 7 only and bypasses Layer 4 traffic.

## Enable WAF

WAF was introduced as Alpha in KubeLB v1.3 and promoted to Beta in v1.4. It remains disabled by default — set `kubelb.enableWAF: true` in `values.yaml` to turn it on. The flag is expected to be removed when WAF reaches GA, with WAF enabled by default at that point.

```yaml
kubelb:
  enableWAF: true
```

## Demonstration

![WAF Demo](/img/kubelb/common/waf/demo.gif?classes=shadow,border "WAF Demo")

## WAFPolicy CRD

To manage WAF policies, you can use the `WAFPolicy` CRD which is a **cluster-scoped** resource. The following is an example of a `WAFPolicy` CRD:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: WAFPolicy
metadata:
  name: global-waf
spec:
  global: true
  directives:
    - "SecRuleEngine On"
    - "SecRequestBodyAccess On"
    - "SecRequestBodyLimit 13107200"
    - "Include @crs-setup-conf"
    - "Include @owasp_crs/*.conf"
```

## Targeting

Three mutually exclusive targeting modes:

1. **`targetRef`** — Target a specific route by name/namespace/kind
2. **`targetSelector`** — Match routes by label selector (checks both Route CR labels and embedded source route labels; Route CR labels win on conflict)
3. **`global: true`** — Apply to ALL Layer 7 routes for ALL tenants

Policies without any targeting (`global`, `targetRef`, or `targetSelector`) are **ignored**.

In terms of precedence, `targetRef` has higher precedence than `targetSelector`, which has higher precedence than `global`. Within the same precedence level: **oldest policy wins** (by `creationTimestamp`). Equal timestamps: alphabetically-first name wins.

## Default Directives

When `directives` is empty or omitted, OWASP CRS defaults are applied:

```
SecRuleEngine On
SecRequestBodyAccess On
SecRequestBodyLimit 13107200
Include @crs-setup-conf
Include @owasp_crs/*.conf
```

This enables full OWASP CRS in blocking mode with a 12.5MB request body limit.

## Application Developers Enabling WAF for Applications

Platform administrators can pre-create `WAFPolicy` resources with `targetSelector` matching specific labels, making WAF protection available to application developers without granting them direct access to WAF policies.

Application developers can then enable WAF protection for their routes by simply adding the matching label to their `HTTPRoute` or `GRPCRoute` resources. This self-service approach maintains security boundaries while giving developers control over when to enable protection for their applications.

**Example workflow:**

1. **Admin creates a WAFPolicy** with label-based targeting in management cluster:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: WAFPolicy
metadata:
  name: standard-waf
spec:
  targetSelector:
    matchLabels:
      security.kubelb.io/waf: enabled
```

1. **Developer enables WAF** by adding the label to their HTTPRoute in tenant cluster:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: my-app
  labels:
    security.kubelb.io/waf: enabled  # Enables WAF protection
spec:
  # ... route configuration
```

The WAF policy automatically applies to any route with matching labels, enabling developers to opt-in to security protection without requiring policy creation permissions.

## Tenant-Managed WAF Policies

Everything above is authored by the platform operator in the management cluster. Tenants can also manage their own WAF rules directly from their cluster, with no access to the management cluster or to any admin policy.

A tenant creates a namespaced `TenantWAFPolicy` in their own cluster. KubeLB syncs it up, validates it, and applies it only to that tenant's routes. Because it is bound to the tenant's own namespace, a tenant policy can never reach another tenant or the cluster-wide baseline. The whole feature is opt-in and stays under the operator's control: nothing tenant-authored takes effect unless you enable it.

### Enable tenant policies

Turn it on globally in the `Config` CRD, then optionally tune or disable it per tenant. `Tenant` settings win over `Config`.

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  waf:
    enableTenantPolicies: true    # off by default
    # Optional guardrails:
    # enforceFailureMode: Closed  # pin failureMode for every tenant policy
    # tenantPolicyLimit: 10       # max policies per tenant
    # maxDirectivesPerPolicy: 64
    # maxDirectiveLength: 1024
---
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: tenant-a
spec:
  waf:
    disableTenantPolicies: false  # opt this one tenant out
    limit: 5
```

### Author a policy (tenant side)

In the tenant cluster, a developer creates a `TenantWAFPolicy`. It reads like a trimmed-down `WAFPolicy`: use `targetRef` or `targetSelector` to pick routes, or `default: true` to cover every route the tenant owns. There is no cluster-wide `global` for tenants by design.

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: TenantWAFPolicy
metadata:
  name: my-waf
  namespace: my-app
spec:
  default: true
  directives:
    - "SecRuleEngine On"
    - "Include @crs-setup-conf"
    - "Include @owasp_crs/*.conf"
```

The policy's status is mirrored back into the tenant cluster, so developers can see whether it was accepted, rejected, or gated off without ever looking at the management cluster.

### Guardrails

Tenant input is untrusted, so directives run through a strict allowlist before they reach Envoy. Anything that reads files, fetches remote rules, writes logs, or spawns processes (`SecRemoteRules`, filesystem `Include`, `SecAuditLog`, `exec`, `setenv`, and friends) is rejected, and a tenant cannot remove or disable the operator's rules. Request body limits and rule counts are capped by the `Config` values above. A policy that trips any of these is marked invalid and simply never applied; traffic keeps flowing under whatever admin policy is in place.

### How admin and tenant policies combine

Admin and tenant policies are two independent layers. A route can pick up one of each, and when it does, both run as separate WAF engines chained back to back: admin first, tenant second. A request is blocked if either engine blocks it, so a tenant can only add protection on top of the operator's baseline, never weaken it.

| Admin policy | Tenant policy | Result |
|---|---|---|
| Matches the route (`global`, `targetRef`, or `targetSelector`) | None | Admin rules only |
| None | Matches the route | Tenant rules only, in the tenant's namespace |
| Matches | Matches | Both enforced; blocked if either one matches |
| Blocks a request | Tries to turn its engine off | Still blocked by the admin engine |
| None | Set, but the operator hasn't enabled tenant policies | Ignored, status `TenantWAFDisabled` |
| None | Uses a forbidden directive or exceeds a limit | Rejected, status `TenantWAFInvalid` / `TenantWAFLimitExceeded` |
| Targets tenant A's route | Tenant B `default: true` | No effect on tenant A |

`failureMode` behaves exactly as it does for admin policies, and an operator can pin it for every tenant with `enforceFailureMode` on the `Config` or `Tenant`.

## Examples

### Basic WAF — OWASP CRS Defaults

Target a specific HTTPRoute with default OWASP rules:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: WAFPolicy
metadata:
  name: basic-waf
spec:
  targetRef:
    kind: HTTPRoute
    name: my-app
```

### Global Default — All Layer 7 Routes

Apply WAF to every HTTPRoute and GRPCRoute using `global: true`:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: WAFPolicy
metadata:
  name: global-waf
spec:
  global: true
  directives:
    - "SecRuleEngine On"
    - "SecRequestBodyAccess On"
    - "SecRequestBodyLimit 13107200"
    - "Include @crs-setup-conf"
    - "Include @owasp_crs/*.conf"
```

### Detection-Only Mode

Log malicious requests without blocking — useful for initial rollout:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: WAFPolicy
metadata:
  name: detect-only
spec:
  targetRef:
    kind: HTTPRoute
    name: my-app
  directives:
    - "SecRuleEngine DetectionOnly"
    - "SecRequestBodyAccess On"
    - "Include @crs-setup-conf"
    - "Include @owasp_crs/*.conf"
```

### Label-Based Targeting — Multi-Tenant

Protect all routes belonging to a specific tenant:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: WAFPolicy
metadata:
  name: tenant-a-waf
spec:
  targetSelector:
    matchLabels:
      kubelb.k8c.io/tenant-name: tenant-a
  directives:
    - "SecRuleEngine On"
    - "SecRequestBodyAccess On"
    - "Include @crs-setup-conf"
    - "Include @owasp_crs/*.conf"
```

Or target multiple tenants with `matchExpressions`:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: WAFPolicy
metadata:
  name: multi-tenant-waf
spec:
  targetSelector:
    matchExpressions:
      - key: kubelb.k8c.io/tenant-name
        operator: In
        values: ["tenant-a", "tenant-b"]
```

### GRPCRoute with Custom Rules

Apply custom SecLang rules to a gRPC service:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: WAFPolicy
metadata:
  name: grpc-waf
spec:
  targetRef:
    kind: GRPCRoute
    name: my-grpc-service
    namespace: tenant-name
  directives:
    - "SecRuleEngine On"
    - "SecRequestBodyAccess Off"
    - 'SecRule REQUEST_HEADERS "@detectSQLi" "id:900001,phase:1,deny,status:403,msg:SQLi in header"'
```

## Global Settings for WAF

WAF behavior can be customized globally via the `Config` CRD under `spec.waf`:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  waf:
    # Custom WASM init container image for the Coraza binary
    # Defaults to KubeLB manager image which has the Coraza WASM binary embedded.
    wasmInitContainerImage: "registry.example.com/custom-coraza-wasm:v1"
    # Skip directive validation at reconciliation time
    skipValidation: false
```

{{% notice note %}}
The Coraza WASM binary is embedded in the KubeLB manager image by default. The init container copies it to a shared volume mounted read-only by Envoy at `/etc/envoy/wasm`. Only override `wasmInitContainerImage` if you need a custom build.
{{% /notice %}}

## Policy Update Behavior

When you create, update, or delete a WAFPolicy, KubeLB propagates the configuration to Envoy immediately. However, how quickly these changes affect live traffic depends on HTTP connection lifecycle.

| Connection State | Behavior |
|-----------------|----------|
| New connections | Use updated WAF configuration immediately |
| Existing connections | Continue using previous configuration until connection closes |

HTTP/2 and keep-alive connections are reused for multiple requests. These connections close naturally after an idle timeout (default: 60 seconds), at which point subsequent requests use the updated configuration.

During the brief window after a policy change, requests arriving over existing connections may be processed with the previous WAF rules while new connections use the updated rules. This is standard Envoy behavior and not a security concern — existing connections continue enforcing their original WAF policy until they close.

{{% notice tip %}}
**Testing tip:** When validating WAF policy changes in development, force each request to open a new connection:

```bash
curl -H "Connection: close" https://your-app.example.com/test
```

This ensures every request uses the latest WAF configuration, useful for verifying policy changes take effect.
{{% /notice %}}

## Monitoring

| Metric | Type | Labels | Description |
|--------|------|--------|-------------|
| `kubelb_manager_waf_policies` | Gauge | namespace, status | Count of valid/invalid policies |
| `kubelb_manager_waf_routes_protected` | Gauge | namespace | Routes with active WAF protection |
| `kubelb_manager_waf_routes_blocked` | Gauge | namespace | Routes blocked due to fail-closed |
| `kubelb_manager_waf_filter_failures_total` | Counter | namespace, failure_mode | WAF filter creation failures |
| `kubelb_manager_waf_policy_reconcile_total` | Counter | name, result | Policy reconciliation attempts |
| `kubelb_manager_waf_policy_reconcile_duration_seconds` | Histogram | name | Reconciliation duration |

## Further Reading

- [Coraza WAF](https://coraza.io/)
- [coraza-proxy-wasm](https://github.com/corazawaf/coraza-proxy-wasm)
- [OWASP Core Rule Set](https://coreruleset.org/docs/)
- [ModSecurity SecLang Reference](https://github.com/owasp-modsecurity/ModSecurity/wiki/Reference-Manual-(v3.x))
- [Envoy WASM Filter](https://www.envoyproxy.io/docs/envoy/latest/configuration/http/http_filters/wasm_filter)
