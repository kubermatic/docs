+++
title = "Client IP Preservation"
linkTitle = "Client IP Preservation"
date = 2025-01-16T10:00:00+02:00
weight = 13
+++

Preserving the original client IP address is critical for logging, rate-limiting, access control lists, and compliance. KubeLB's multi-cluster proxy architecture introduces up to three SNAT (Source Network Address Translation) hops that can replace the real client IP with internal addresses. This guide explains how to preserve client IP at each hop.

## Understanding SNAT in KubeLB

Traffic flowing through KubeLB passes through three potential SNAT points:

```
Client → [SNAT#1] Cloud LB / kube-proxy → Envoy Pod → [SNAT#2] New TCP connection → Tenant Node:NodePort → [SNAT#3] kube-proxy → Backend Pod
```

| SNAT Point | Cause | Solution |
|------------|-------|----------|
| **SNAT#1** | kube-proxy on management cluster NATs traffic to Envoy pod | `externalTrafficPolicy: Local` on tenant Service (propagated to Envoy Service) |
| **SNAT#2** | Envoy opens a new upstream TCP connection — source becomes Envoy pod IP | Proxy Protocol v2 (L4 TCP) or X-Forwarded-For header (L7 HTTP) |
| **SNAT#3** | kube-proxy on tenant cluster NATs NodePort traffic to backend pod | `externalTrafficPolicy: Local` on tenant backend Service |

## Strongly Recommended: Cilium DSR on Management Cluster

Cloud load balancers (AWS NLB, GCP, Azure) often perform SNAT before traffic reaches cluster nodes, which can make `externalTrafficPolicy: Local` insufficient on its own. Running [Cilium](https://cilium.io/) in [Direct Server Return (DSR) mode](https://docs.cilium.io/en/stable/network/kubernetes/kubeproxy-free/#dsr-mode) on the management cluster encodes the original source IP at the kernel level, sidestepping cloud-specific NAT behavior entirely.

```yaml
# Cilium Helm values for DSR mode
kubeProxyReplacement: true
loadBalancer:
  mode: dsr
```

{{% notice note %}}
KubeLB automatically propagates `externalTrafficPolicy` from the tenant Service to the Envoy Service in the management cluster. Cilium DSR is not required but is strongly recommended for cloud environments where the load balancer itself performs SNAT.
{{% /notice %}}

## Layer 4: Proxy Protocol v2

For Layer 4 (TCP) services, Envoy can prepend a [Proxy Protocol v2](https://www.haproxy.org/download/1.8/doc/proxy-protocol.txt) header on upstream connections. This header carries the original client IP, allowing the backend to extract it even though Envoy opened a new TCP connection (SNAT#2).

### How to Enable

Add the `kubelb.k8c.io/proxy-protocol: v2` annotation to the tenant Service. Combine with `externalTrafficPolicy: Local` to also solve SNAT#1 and SNAT#3:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-tcp-service
  namespace: default
  annotations:
    kubelb.k8c.io/proxy-protocol: "v2"
spec:
  type: LoadBalancer
  externalTrafficPolicy: Local
  ports:
    - port: 5000
      targetPort: 5000
      protocol: TCP
  selector:
    app: my-tcp-app
```

{{% notice warning %}}
The backend application **must** be configured to parse Proxy Protocol headers. Sending proxy protocol v2 headers to a non-PP-aware backend will cause connection failures or data corruption.
{{% /notice %}}

### Backend Configuration Examples

**NGINX:**

```nginx
server {
    listen 5000 proxy_protocol;
    # real_ip_header proxy_protocol; # optional: populate $remote_addr
}
```

**HAProxy:**

```
listen my-service
    bind *:5000 accept-proxy
```

## Layer 7: X-Forwarded-For

For Layer 7 (HTTP) traffic routed through Ingress or Gateway API (HTTPRoute), Envoy automatically appends the `X-Forwarded-For` (XFF) header with the client IP. **No additional configuration is needed.**

- Envoy's `use_remote_address` and `xff_num_trusted_hops` are already configured by KubeLB.
- Backend applications should read the first entry in the `X-Forwarded-For` header to obtain the client IP.

For Gateway API users who need to tune client IP detection (e.g., when multiple proxies are involved), use a **ClientTrafficPolicy** resource with `xForwardedFor.numTrustedHops`. See the [Client Traffic Policy]({{< ref "../gatewayapi/client-traffic-policy" >}}) tutorial for details.

## Summary

| Layer | Mechanism | Configuration | Backend Requirement |
|-------|-----------|---------------|---------------------|
| Layer 4 (TCP) | Proxy Protocol v2 | Annotation `kubelb.k8c.io/proxy-protocol: v2` on tenant Service | Must parse proxy protocol v2 headers (NGINX, HAProxy, Envoy, Traefik) |
| Layer 7 (HTTP) | X-Forwarded-For | Automatic for Ingress / HTTPRoute | Read `X-Forwarded-For` header |
| Both | `externalTrafficPolicy: Local` | Set on tenant Service (KubeLB propagates to Envoy Service) | None |
| Both | Cilium DSR (recommended) | Helm config on management cluster | None |

## Known Limitations

- **UDP**: There is no Proxy Protocol equivalent for UDP. SNAT#2 is unavoidable for UDP traffic — the backend will see Envoy's pod IP as the source.
- **Proxy Protocol requires backend support**: Non-PP-aware applications will break when receiving proxy protocol v2 headers. This is why proxy protocol v2 is opt-in via annotation.
- **`externalTrafficPolicy: Local` routing constraint**: Traffic is only routed to nodes running Envoy pods. This is the standard pattern for ingress controllers and cloud LB health checks automatically avoid nodes without Envoy pods.
