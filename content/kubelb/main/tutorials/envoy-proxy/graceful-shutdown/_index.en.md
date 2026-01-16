+++
title = "Graceful Shutdown"
linkTitle = "Graceful Shutdown"
date = 2025-01-16T10:00:00+02:00
weight = 1
+++

Graceful shutdown ensures Envoy proxy instances drain existing connections before terminating, preventing connection drops during pod rollouts, scaling events, or cluster upgrades.

## Why Graceful Shutdown?

Without graceful shutdown, when an Envoy pod terminates:

- Active connections are immediately dropped
- In-flight requests may fail
- Clients experience errors during deployments

With graceful shutdown enabled (default), the shutdown manager sidecar intercepts SIGTERM signals and orchestrates a controlled drain process, allowing existing connections to complete.

## Configuration

Configure graceful shutdown in the `Config` CRD under `spec.envoyProxy.gracefulShutdown`:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  envoyProxy:
    gracefulShutdown:
      disabled: false
      drainTimeout: 60s
      minDrainDuration: 5s
      terminationGracePeriodSeconds: 300
```

### Configuration Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `disabled` | bool | `false` | Set to `true` to disable graceful shutdown |
| `drainTimeout` | duration | `60s` | Maximum time to drain connections before forced termination |
| `minDrainDuration` | duration | `5s` | Minimum time to wait during drain, even if no connections |
| `terminationGracePeriodSeconds` | int64 | `300` | Pod termination grace period in seconds |
| `shutdownManagerImage` | string | *(built-in)* | Custom shutdown manager container image |

## How It Works

1. Kubernetes sends SIGTERM to the Envoy pod
2. The shutdown manager sidecar intercepts the signal
3. Envoy enters draining state and stops accepting new connections
4. Existing connections continue to be served
5. After `drainTimeout` or when all connections close (whichever comes first), Envoy terminates
6. The `minDrainDuration` ensures a minimum drain window for late-arriving requests

## Example: High-Traffic Production Setup

For environments with long-lived connections or high traffic:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  envoyProxy:
    gracefulShutdown:
      drainTimeout: 120s
      minDrainDuration: 10s
      terminationGracePeriodSeconds: 180
```

## Example: Disable Graceful Shutdown

For development environments where fast restarts are preferred:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  envoyProxy:
    gracefulShutdown:
      disabled: true
```

## Further Reading

- [Envoy Drain Documentation](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/operations/draining)
