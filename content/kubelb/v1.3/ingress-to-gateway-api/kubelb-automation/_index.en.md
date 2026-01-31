+++
title = "Automated Conversion with KubeLB [Experimental]"
linkTitle = "KubeLB Automation"
date = 2026-01-30T00:00:00+01:00
weight = 1
+++

{{% notice warning %}}
**Experimental Feature:** This converter is provided on a best-effort basis. Not all NGINX annotations have Gateway API equivalents. Test thoroughly in non-production environments first. Some configurations will require manual intervention.
{{% /notice %}}

KubeLB can automatically convert your Ingress resources to Gateway API. Point it at your Ingresses, and it creates the equivalent HTTPRoutes and GRPCRoutes for you.

{{% notice info %}}
**Supported Controllers:** Currently, the converter only supports **ingress-nginx** as the source Ingress controller. Gateway API resources (HTTPRoute, GRPCRoute, Gateway) are converted in a generic manner and work with any implementation. However, policy generation (SecurityPolicy, BackendTrafficPolicy) is only supported for **Envoy Gateway**. Support for other controllers may be added in the future.
{{% /notice %}}

## How It Works

1. The converter watches your Ingress resources
2. For each Ingress, it creates an HTTPRoute (or GRPCRoute for gRPC backends)
3. For annotations that map to Envoy Gateway policies (CORS, rate limiting, timeouts, etc.), it creates the corresponding SecurityPolicy or BackendTrafficPolicy resources.
4. It manages a Gateway resource with listeners for your TLS hosts
5. Status annotations on your Ingress tell you what happened

The created routes persist even after you delete the source Ingress, allowing you to migrate gradually and delete Ingresses at your own pace.

## Getting Started

### Choose Your Mode

#### Integrated Mode (Recommended)

You're already using KubeLB for load balancing and want to add conversion:

```yaml
kubelb:
  tenantName: <your-tenant-name>
  clusterSecretName: kubelb-cluster
  enableGatewayAPI: true
  ingressConversion:
    enabled: true
    gatewayName: kubelb
    gatewayClass: kubelb
```

With integrated mode, KubeLB handles everything for you:

- **No Gateway setup required per tenant cluster** — KubeLB manages the Gateway lifecycle, GatewayClass, and all CRDs. No need to install Envoy Gateway separately in each tenant cluster. Envoy Gateway is installed in the manager cluster.
- **Policy support out of the box** — Envoy Gateway policies (ClientTrafficPolicy, BackendTrafficPolicy) work automatically since KubeLB's manager cluster has the CRDs installed.
- **Centralized traffic management** — Converted routes are synced to the manager cluster where KubeLB serves traffic using its Layer 7 load balancing capabilities.
- **Multi-tenant ready** — Each tenant cluster can run the converter independently while KubeLB handles traffic routing centrally.

#### Standalone Mode

You just want the converter, without KubeLB's load balancing and other controllers:

```yaml
kubelb:
  ingressConversion:
    enabled: true
    standaloneMode: true
    gatewayName: my-gateway
    gatewayClass: eg  # match your Gateway implementation
```

In standalone mode, you don't need `tenantName` or `clusterSecretName`.

### Prerequisites (Standalone Mode)

Before running the converter in standalone mode, set up your Gateway API implementation:

**1. Install Envoy Gateway**

Follow the [Envoy Gateway installation guide](https://gateway.envoyproxy.io/docs/tasks/quickstart/) to install it in your cluster.

**2. Create a GatewayClass**

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: eg
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
```

Make sure the `gatewayClass` in your values matches this name.

**3. (Optional) Pre-create a Gateway**

The converter creates a Gateway automatically. If you need custom parameters (specific listeners, infrastructure settings, etc.), create it yourself first:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: my-gateway
  namespace: default
spec:
  gatewayClassName: eg
  listeners:
    - name: http
      protocol: HTTP
      port: 80
```

Set `gatewayName` and `gatewayNamespace` in your values to match. The converter will use your existing Gateway instead of creating one.

### Install

{{% notice tip %}}
Review the [Configuration Options](#all-configuration-options) before installing to customize the converter for your environment.
{{% /notice %}}

{{< tabs name="installation" >}}
{{% tab name="Community Edition" %}}

```sh
helm upgrade --install kubelb-ccm oci://quay.io/kubermatic/helm-charts/kubelb-ccm --version=v1.3.0 --namespace kubelb -f values.yaml --create-namespace
```

{{% notice info %}}
**Policy CRDs required:** To auto-create Envoy Gateway policies (SecurityPolicy, BackendTrafficPolicy), install the Envoy Gateway CRDs before running the converter. Without them, policy-related annotations generate warnings instead of resources.
{{% /notice %}}

{{% /tab %}}
{{% tab name="Enterprise Edition" %}}

```sh
helm upgrade --install kubelb-ccm oci://quay.io/kubermatic/helm-charts/kubelb-ccm-ee --version=v1.3.0 --namespace kubelb -f values.yaml --create-namespace
```

{{% notice info %}}
Enterprise Edition requires `imagePullSecrets` to pull images from the registry.
{{% /notice %}}

{{% /tab %}}
{{< /tabs >}}

### Check Your Results

After installation, check if your Ingresses are being converted:

```bash
# Watch all converted Ingresses
watch "kubectl get ingress -A -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,STATUS:.metadata.annotations.kubelb\.k8c\.io/conversion-status' | grep -E 'converted|partial'"

# Check conversion status for a specific Ingress
kubectl get ingress my-app -o jsonpath='{.metadata.annotations.kubelb\.k8c\.io/conversion-status}'

# View any warnings (annotations that couldn't be fully converted)
kubectl get ingress my-app -o jsonpath='{.metadata.annotations.kubelb\.k8c\.io/conversion-warnings}'

# List created routes
kubectl get httproutes -l kubelb.k8c.io/source-ingress=my-app.default
```

The status will be one of:

- `converted` — Everything worked
- `partial` — Some routes worked, others didn't
- `pending` — Routes created but Gateway controller hasn't accepted them yet
- `skipped` — Ingress uses unsupported features (like canary)
- `failed` — Something went wrong

## Customizing Behavior

### Filter Which Ingresses to Convert

By default, all Ingresses are converted. To convert only specific ones:

```yaml
ingressConversion:
  ingressClass: "nginx"  # only convert Ingresses with this class
```

To exclude a specific Ingress, annotate it:

```yaml
metadata:
  annotations:
    kubelb.k8c.io/skip-conversion: "true"
```

### Transform Hostnames

Useful for migrating between environments. Convert `app.staging.example.com` to `app.prod.example.com`:

```yaml
ingressConversion:
  domainReplace: "staging.example.com"
  domainSuffix: "prod.example.com"
```

### Add Gateway Annotations

The converter creates a Gateway resource for you. To add annotations (e.g., for cert-manager):

```yaml
ingressConversion:
  gatewayAnnotations: "cert-manager.io/cluster-issuer=letsencrypt,external-dns.alpha.kubernetes.io/target=lb.example.com"
```

{{% notice tip %}}
Your existing cert-manager ClusterIssuer for Ingress likely won't work with Gateway API out of the box. See [Cert Manager Migration](cert-manager) for details.
{{% /notice %}}

### All Configuration Options

| Helm Value | Default | Description |
|------------|---------|-------------|
| `ingressConversion.enabled` | `false` | Enables the converter. When true, Ingress resources are watched and converted to HTTPRoute/GRPCRoute. |
| `ingressConversion.standaloneMode` | `false` | Run only the converter without KubeLB load balancing. Disables all other controllers including Ingress, Gateway, and Service controllers. Useful for clusters not using KubeLB. |
| `ingressConversion.gatewayName` | `kubelb` | Name of the Gateway resource that converted HTTPRoutes will reference in their `parentRefs`. The converter creates this Gateway automatically. |
| `ingressConversion.gatewayNamespace` | `kubelb` | Namespace where the shared Gateway is created. This is required and must be set to a valid namespace. |
| `ingressConversion.gatewayClass` | `kubelb` | GatewayClass that the created Gateway references. Must match an existing GatewayClass in your cluster (e.g., `eg`). |
| `ingressConversion.ingressClass` | `""` | Filter which Ingresses to convert. Only Ingresses with this class (via `spec.ingressClassName` or `kubernetes.io/ingress.class` annotation) are processed. When empty, all Ingresses are converted. |
| `ingressConversion.domainReplace` | `""` | Source domain suffix to find in Ingress hostnames. Must be used with `domainSuffix`. Example: with `domainReplace=example.com` and `domainSuffix=new.io`, `app.example.com` becomes `app.new.io`. |
| `ingressConversion.domainSuffix` | `""` | Target domain suffix that replaces the source domain. Must be used with `domainReplace`. If either is empty, hostnames are not transformed. |
| `ingressConversion.gatewayAnnotations` | `""` | Annotations added to the created Gateway resource. Format: comma-separated `key=value` pairs. Common uses: cert-manager issuer, external-dns target. |
| `ingressConversion.propagateExternalDnsAnnotations` | `true` | Copy external-dns annotations from Ingress to Gateway/HTTPRoute. The `target` annotation goes to Gateway; other external-dns annotations go to HTTPRoute. |
| `ingressConversion.disableEnvoyGatewayFeatures` | `false` | Disable automatic creation of Envoy Gateway policies (SecurityPolicy, BackendTrafficPolicy). When true, only warnings are generated for policy-related annotations. |
| `ingressConversion.copyTLSSecrets` | `true` | Copy TLS secrets from Ingress namespace to Gateway namespace. Required for cross-namespace certificate references. See [TLS Secret Handling](#tls-secret-handling). |

### TLS Secret Handling

When an Ingress references a TLS secret, Gateway API requires the secret to be in the same namespace as the Gateway. Since the converter creates a shared Gateway (typically in the `kubelb` namespace), TLS secrets from Ingress namespaces must be copied.

**How it works:**

1. When `copyTLSSecrets: true` (default), secrets are copied from the Ingress namespace to the Gateway namespace
2. Copied secrets are named `ingress-<namespace>-<secretname>` to avoid conflicts
3. The Gateway's listener references the copied secret

**Example:** An Ingress in namespace `app` with `secretName: tls-cert` results in:

- Secret copied to `kubelb/ingress-app-tls-cert`
- Gateway listener references `ingress-app-tls-cert`

**With domain transformation:**

When using `domainReplace` and `domainSuffix` to transform hostnames, the original TLS certificate may not be valid for the new domain. In this case:

1. The original secret is still copied (provides a starting point)
2. Configure cert-manager on the Gateway to issue new certificates for the transformed domains
3. Cert-manager will overwrite the copied secret with a valid certificate

```yaml
ingressConversion:
  domainReplace: "old.example.com"
  domainSuffix: "new.example.com"
  gatewayAnnotations: "cert-manager.io/cluster-issuer=letsencrypt"
```

**Disabling secret sync:**

If you manage TLS secrets separately using different workflows or cert-manager can generate them for new domains. It's recommended to disable the secret sync and manage TLS secrets separately:

```yaml
ingressConversion:
  copyTLSSecrets: false
```

{{% notice warning %}}
With `copyTLSSecrets: false`, you must ensure TLS secrets exist in the Gateway namespace. Without them, Gateway listeners will show `ResolvedRefs: False` and your routes won't work.
{{% /notice %}}

## What Gets Converted

### Annotations That Work Automatically

These NGINX annotations are converted to native Gateway API features:

| NGINX Annotation | Gateway API Equivalent |
|------------------|------------------------|
| `nginx.ingress.kubernetes.io/ssl-redirect` | RequestRedirect filter (HTTP→HTTPS, 301) |
| `nginx.ingress.kubernetes.io/force-ssl-redirect` | RequestRedirect filter (HTTP→HTTPS, 308) |
| `nginx.ingress.kubernetes.io/permanent-redirect` | RequestRedirect filter (301) |
| `nginx.ingress.kubernetes.io/permanent-redirect-code` | Status code for permanent-redirect |
| `nginx.ingress.kubernetes.io/temporal-redirect` | RequestRedirect filter (302) |
| `nginx.ingress.kubernetes.io/rewrite-target` | URLRewrite filter (ReplacePrefixMatch) |
| `nginx.ingress.kubernetes.io/use-regex` | `pathType: RegularExpression` |
| `nginx.ingress.kubernetes.io/proxy-set-headers` | RequestHeaderModifier filter (Set) |
| `nginx.ingress.kubernetes.io/custom-headers` | ResponseHeaderModifier filter (Add) |
| `nginx.ingress.kubernetes.io/upstream-vhost` | RequestHeaderModifier (Host header) |
| `nginx.ingress.kubernetes.io/x-forwarded-prefix` | RequestHeaderModifier (X-Forwarded-Prefix) |
| `nginx.ingress.kubernetes.io/hsts` | ResponseHeaderModifier (Strict-Transport-Security) |
| `nginx.ingress.kubernetes.io/hsts-max-age` | Part of HSTS header |
| `nginx.ingress.kubernetes.io/hsts-include-subdomains` | Part of HSTS header |
| `nginx.ingress.kubernetes.io/hsts-preload` | Part of HSTS header |
| `nginx.ingress.kubernetes.io/backend-protocol: GRPC` | Creates GRPCRoute instead of HTTPRoute |
| `nginx.ingress.kubernetes.io/backend-protocol: HTTPS` | HTTPRoute + BackendTLSPolicy warning |

### Envoy Gateway Policy Generation

For policy generation, we only support Envoy Gateway as the target Gateway API implementation. The converter auto-creates **SecurityPolicy** and **BackendTrafficPolicy** resources. **ClientTrafficPolicy** is not auto-created because it targets Gateway, this results in it being applied to all listeners on the Gateway and that can cause issues for other HTTPRoutes on the same Gateway. Annotations requiring ClientTrafficPolicy generate warnings instead.

Policy generation is enabled by default in both standalone and integrated modes, and can be disabled by configuring the values.yaml with:

```yaml
ingressConversion:
  disableEnvoyGatewayFeatures: true
```

When disabled, annotations are still converted to suggestions placed in the `conversion-warnings` annotation on the Ingress resource.

### Annotations with Auto-Created Policies

These annotations automatically create Envoy Gateway policies:

| NGINX Annotation | Created Policy |
|------------------|----------------|
| `nginx.ingress.kubernetes.io/enable-cors` | SecurityPolicy: spec.cors |
| `nginx.ingress.kubernetes.io/cors-allow-origin` | SecurityPolicy: spec.cors.allowOrigins |
| `nginx.ingress.kubernetes.io/cors-allow-methods` | SecurityPolicy: spec.cors.allowMethods |
| `nginx.ingress.kubernetes.io/cors-allow-headers` | SecurityPolicy: spec.cors.allowHeaders |
| `nginx.ingress.kubernetes.io/cors-expose-headers` | SecurityPolicy: spec.cors.exposeHeaders |
| `nginx.ingress.kubernetes.io/cors-allow-credentials` | SecurityPolicy: spec.cors.allowCredentials |
| `nginx.ingress.kubernetes.io/cors-max-age` | SecurityPolicy: spec.cors.maxAge |
| `nginx.ingress.kubernetes.io/whitelist-source-range` | SecurityPolicy: spec.authorization.rules (allow) |
| `nginx.ingress.kubernetes.io/denylist-source-range` | SecurityPolicy: spec.authorization.rules (deny) |
| `nginx.ingress.kubernetes.io/auth-type: basic` | SecurityPolicy: spec.basicAuth |
| `nginx.ingress.kubernetes.io/auth-secret` | SecurityPolicy: spec.basicAuth.secretRef |
| `nginx.ingress.kubernetes.io/proxy-connect-timeout` | BackendTrafficPolicy: spec.timeout.tcp.connectTimeout |
| `nginx.ingress.kubernetes.io/proxy-read-timeout` | BackendTrafficPolicy: spec.timeout.http.requestTimeout |
| `nginx.ingress.kubernetes.io/proxy-send-timeout` | BackendTrafficPolicy: spec.timeout.http.requestTimeout |
| `nginx.ingress.kubernetes.io/limit-rps` | BackendTrafficPolicy: spec.rateLimit.local |
| `nginx.ingress.kubernetes.io/limit-rpm` | BackendTrafficPolicy: spec.rateLimit.local |
| `nginx.ingress.kubernetes.io/limit-connections` | BackendTrafficPolicy: spec.circuitBreaker.maxConnections |

### Annotations That Need Manual Follow-up

These annotations generate warnings only—manual configuration is required:

| NGINX Annotation | Reason / Suggested Policy |
|------------------|---------------------------|
| `nginx.ingress.kubernetes.io/auth-url` | ExtAuth requires manual backend reference configuration |
| `nginx.ingress.kubernetes.io/proxy-body-size` | ClientTrafficPolicy targets Gateway (not HTTPRoute) |
| `nginx.ingress.kubernetes.io/affinity: cookie` | Session persistence needs manual BackendTrafficPolicy config |
| `nginx.ingress.kubernetes.io/session-cookie-*` | BackendTrafficPolicy: spec.sessionPersistence.cookie |
| `nginx.ingress.kubernetes.io/proxy-ssl-*` | BackendTLSPolicy: spec.tls |
| `nginx.ingress.kubernetes.io/app-root` | Create separate HTTPRoute rule for "/" path with redirect filter |
| `nginx.ingress.kubernetes.io/ssl-passthrough` | Create TLSRoute instead of HTTPRoute |
| `nginx.ingress.kubernetes.io/preserve-host: "false"` | Add URLRewrite filter with hostname at backend level |

**Note:** After manual follow-up, update the annotation `kubelb.k8c.io/conversion-status` to `converted`. This helps track which Ingresses have been fully migrated. This is required so that the converter knows
 that the conversion is complete and it can stop watching the Ingress resource.

### Annotations That Don't Work

These have no Gateway API equivalent:

| NGINX Annotation | Reason |
|------------------|--------|
| `nginx.ingress.kubernetes.io/configuration-snippet` | Raw NGINX config, not portable |
| `nginx.ingress.kubernetes.io/server-snippet` | Raw NGINX config, not portable |
| `nginx.ingress.kubernetes.io/stream-snippet` | Raw NGINX config, not portable |
| `nginx.ingress.kubernetes.io/enable-modsecurity` | WAF rules, implementation-specific |
| `nginx.ingress.kubernetes.io/enable-owasp-core-rules` | WAF rules, implementation-specific |
| `nginx.ingress.kubernetes.io/upstream-hash-by` | Custom load balancing algorithm |
| `nginx.ingress.kubernetes.io/canary-*` | Ingress skipped entirely (see below) |

### Canary Ingresses

Ingresses with `nginx.ingress.kubernetes.io/canary: "true"` are skipped entirely. NGINX canary Ingresses work by modifying a primary Ingress, which doesn't translate to Gateway API.

Instead, use HTTPRoute's native traffic splitting:

```yaml
spec:
  rules:
  - backendRefs:
    - name: stable
      port: 80
      weight: 90
    - name: canary
      port: 80
      weight: 10
```

## Limitations

- **RegularExpression paths** depend on your Gateway implementation's support
- **Envoy Gateway policies** are created locally in the tenant cluster—ensure Envoy Gateway CRDs are installed
- **cert-manager annotations** aren't propagated automatically—use `gatewayAnnotations` instead
- **GRPCRoute** doesn't support HTTPRoute filters (redirects, rewrites, headers)
- **Gateway listeners** are shared across all converted Ingresses
- **TLS secrets** are copied to Gateway namespace by default; with domain transformation, you may need cert-manager to issue new certificates

## Troubleshooting

### Re-triggering Conversion for an Ingress

Once an Ingress is marked as `converted` or `partial`, the converter stops watching it. If the conversion was incorrect or you want to re-run it (e.g., after fixing Gateway configuration), reset the status:

```bash
# Reset conversion status to re-trigger conversion
kubectl annotate ingress <ingress-name> kubelb.k8c.io/conversion-status-

# Also remove the verification timestamp if present
kubectl annotate ingress <ingress-name> kubelb.k8c.io/verification-timestamp-
```

The converter will pick up the Ingress on its next reconciliation cycle and re-convert it.

### Finding Broken Conversions

To find Ingresses that were marked as converted but whose HTTPRoutes are not actually accepted:

```bash
# List all HTTPRoutes with their acceptance status
kubectl get httproute -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name} Accepted={.status.parents[0].conditions[?(@.type=="Accepted")].status} Reason={.status.parents[0].conditions[?(@.type=="Accepted")].reason}{"\n"}{end}'

# Find routes that are not accepted
kubectl get httproute -A -o json | jq -r '.items[] | select(.status.parents[0].conditions[] | select(.type=="Accepted" and .status!="True")) | "\(.metadata.namespace)/\(.metadata.name): \(.status.parents[0].conditions[] | select(.type=="Accepted") | .reason)"'
```

### Common Issues

| Symptom | Cause | Solution |
|---------|-------|----------|
| HTTPRoute shows `NotAllowedByListeners` | Gateway doesn't allow routes from this namespace | Check Gateway's `spec.listeners[].allowedRoutes` configuration |
| Gateway listener shows `ResolvedRefs: False` | TLS secret missing in Gateway namespace | Enable `copyTLSSecrets: true` or manually create secret |
| Status stuck on `pending` | Gateway controller slow to update status | Wait for reconciliation (5s intervals) or check Gateway controller logs |
| Policies not created | Envoy Gateway CRDs not installed | Install Envoy Gateway CRDs or set `disableEnvoyGatewayFeatures: true` |
