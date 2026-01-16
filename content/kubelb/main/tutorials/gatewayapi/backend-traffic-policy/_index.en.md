+++
title = "Backend Traffic Policy"
linkTitle = "Backend Traffic Policy"
date = 2025-01-16T10:00:00+02:00
weight = 5
enterprise = true
+++

BackendTrafficPolicy is an Envoy Gateway extension that configures connection behavior, resilience, and performance optimizations between Envoy Proxy and upstream backends—the services that Envoy routes traffic to.

## Use Cases

BackendTrafficPolicy allows you to configure:

- **Load balancing**: Algorithm selection (round robin, least request, random, etc.)
- **Retries**: Automatic retry configuration for failed requests
- **Timeouts**: Connection and request timeouts to backends
- **Health checking**: Active health checks for upstream services
- **Connection settings**: Keep-alive, connection limits, and DNS configuration
- **Rate limiting**: Request rate limits to protect backends

## How It Works in KubeLB

KubeLB synchronizes BackendTrafficPolicy resources from tenant clusters to the management cluster. The policy can be attached to a Gateway, HTTPRoute, or GRPCRoute to control how traffic flows to backends.

1. Create a BackendTrafficPolicy in your tenant cluster
2. Reference your target resource (Gateway or Route) in the policy's `targetRef`
3. KubeLB CCM syncs the policy to the management cluster
4. Envoy Gateway applies the configuration to upstream clusters

## Example: Basic Retry Policy

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: BackendTrafficPolicy
metadata:
  name: retry-policy
  namespace: default
spec:
  targetRef:
    group: gateway.networking.k8s.io
    kind: HTTPRoute
    name: backend
  retry:
    numRetries: 3
    retryOn:
      - connect-failure
      - retriable-status-codes
    retriableStatusCodes:
      - 503
```

## Example: Load Balancing Configuration

Configure least-request load balancing:

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: BackendTrafficPolicy
metadata:
  name: lb-policy
  namespace: default
spec:
  targetRef:
    group: gateway.networking.k8s.io
    kind: HTTPRoute
    name: backend
  loadBalancer:
    type: LeastRequest
    leastRequest:
      choiceCount: 4
```

## Example: Connection Timeouts

Set timeouts for backend connections:

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: BackendTrafficPolicy
metadata:
  name: timeout-policy
  namespace: default
spec:
  targetRef:
    group: gateway.networking.k8s.io
    kind: HTTPRoute
    name: backend
  timeout:
    tcp:
      connectTimeout: 10s
    http:
      connectionIdleTimeout: 60s
      maxConnectionDuration: 300s
```

## Example: Active Health Checks

Configure active health checking for backends:

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: BackendTrafficPolicy
metadata:
  name: health-check-policy
  namespace: default
spec:
  targetRef:
    group: gateway.networking.k8s.io
    kind: HTTPRoute
    name: backend
  healthCheck:
    active:
      type: HTTP
      http:
        path: /healthz
        expectedStatuses:
          - 200
      interval: 10s
      timeout: 5s
      unhealthyThreshold: 3
      healthyThreshold: 2
```

## Disabling BackendTrafficPolicy

Platform administrators can disable BackendTrafficPolicy synchronization at the global or tenant level:

### Global

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  gatewayAPI:
    disableBackendTrafficPolicy: true
```

### Tenant

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: my-tenant
  namespace: kubelb
spec:
  gatewayAPI:
    disableBackendTrafficPolicy: true
```

## Further Reading

- [Envoy Gateway BackendTrafficPolicy Documentation](https://gateway.envoyproxy.io/docs/api/extension_types/#backendtrafficpolicy)
- [Envoy Gateway Traffic Management](https://gateway.envoyproxy.io/docs/tasks/traffic/)
