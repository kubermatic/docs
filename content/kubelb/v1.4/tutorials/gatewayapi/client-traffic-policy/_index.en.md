+++
title = "Client Traffic Policy"
linkTitle = "Client Traffic Policy"
date = 2025-01-16T10:00:00+02:00
weight = 4
enterprise = true
+++

ClientTrafficPolicy is an Envoy Gateway extension that configures how Envoy Proxy behaves with downstream clients—the connections coming into the proxy from external clients or services.

## Use Cases

ClientTrafficPolicy allows you to configure:

- **Connection timeouts**: TCP connection and HTTP idle timeouts
- **HTTP settings**: HTTP/1.1 and HTTP/2 specific configurations
- **TLS settings**: Client certificate validation, TLS versions, cipher suites
- **Client IP detection**: Extracting client IPs from XFF headers or proxy protocol
- **Connection limits**: Per-connection buffer limits
- **Health check endpoints**: Configuring health check paths

## How It Works in KubeLB

KubeLB synchronizes ClientTrafficPolicy resources from tenant clusters to the management cluster. The policy is attached to a Gateway resource and applies to all listeners on that Gateway.

1. Create a ClientTrafficPolicy in your tenant cluster
2. Reference your Gateway in the policy's `targetRef`
3. KubeLB CCM syncs the policy to the management cluster
4. Envoy Gateway applies the configuration to the Envoy proxy

## Example: Basic ClientTrafficPolicy

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: ClientTrafficPolicy
metadata:
  name: client-timeout-policy
  namespace: default
spec:
  targetRef:
    group: gateway.networking.k8s.io
    kind: Gateway
    name: kubelb
  timeout:
    http:
      requestReceivedTimeout: 30s
```

## Example: HTTP/2 Configuration

Configure HTTP/2 settings for clients:

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: ClientTrafficPolicy
metadata:
  name: http2-policy
  namespace: default
spec:
  targetRef:
    group: gateway.networking.k8s.io
    kind: Gateway
    name: kubelb
  http2:
    initialStreamWindowSize: 64Ki
    initialConnectionWindowSize: 1Mi
    maxConcurrentStreams: 200
```

## Example: Client IP Detection

Extract real client IPs when behind a load balancer:

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: ClientTrafficPolicy
metadata:
  name: client-ip-policy
  namespace: default
spec:
  targetRef:
    group: gateway.networking.k8s.io
    kind: Gateway
    name: kubelb
  clientIPDetection:
    xForwardedFor:
      numTrustedHops: 2
```

## Disabling ClientTrafficPolicy

Platform administrators can disable ClientTrafficPolicy synchronization at the global or tenant level:

### Global

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  gatewayAPI:
    disableClientTrafficPolicy: true
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
    disableClientTrafficPolicy: true
```

## Further Reading

- [Envoy Gateway ClientTrafficPolicy Documentation](https://gateway.envoyproxy.io/docs/api/extension_types/#clienttrafficpolicy)
- [Envoy Gateway Traffic Management](https://gateway.envoyproxy.io/docs/tasks/traffic/)
