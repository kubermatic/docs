+++
title = "Requirements"
linkTitle = "Requirements"
date = 2026-07-29T00:00:00+02:00
weight = 5
description = "Version, network, port, and resource sizing requirements for KubeLB management and tenant clusters."
+++

## Versions

See the [Compatibility Matrix]({{< relref "../../compatibility-matrix" >}}) for the tested Kubernetes, Gateway API, and Envoy Gateway versions. The KubeLB Helm charts do not enforce a `kubeVersion` constraint, so version mismatches are not caught at install time.

## Management cluster

Use a dedicated cluster as the KubeLB management cluster. It hosts the data plane for all tenants and should not run unrelated workloads.

KubeLB Manager must be installed in the `kubelb` namespace. The Envoy Proxy pods connect to the xDS control plane at the hard-coded address `envoycp.kubelb.svc:8001`, so installing the manager in any other namespace breaks the data plane.

## Network connectivity

| Direction | Source | Destination | Port/Protocol | Purpose | Required |
|-----------|--------|-------------|---------------|---------|----------|
| Tenant to Management | KubeLB CCM | Management cluster Kubernetes API server | HTTPS, typically 6443 | The CCM connects to the management cluster using the kubeconfig stored in the `kubelb-cluster` secret. The API endpoint advertised in the management cluster's `kube-public/cluster-info` ConfigMap must be reachable from all tenant clusters. | Always |
| Management to Tenant | Envoy Proxy pods | Tenant cluster node addresses | NodePort range, default 30000-32767/TCP,UDP | Direct backend transport mode (default). Traffic is forwarded to the node address selected by `nodeAddressType`. | Direct mode |
| Management to Tenant | Envoy Proxy pods | Tenant proxy | Tenant proxy NodePort, or 15443/TCP with `serviceType: LoadBalancer` | mTLS backend transport mode (Enterprise Edition). All backend traffic goes through the encrypted tenant proxy instead of plain NodePorts. | mTLS mode |
| Clients to Management | Application clients | LoadBalancer services and Gateway listeners in the management cluster | Service-defined ports; Envoy data plane listener ports are allocated from 10000-65535 | Application traffic provisioned by KubeLB. | Always |
| Tenant/CLI to Management | Tunnel agents and `kubelb` CLI | Tunnel connection manager, exposed via Ingress or HTTPRoute | HTTPS, 443 | Tunneling (Enterprise Edition). Connections are outbound-only from the tenant side. | Tunneling |

## Component ports

| Port | Protocol | Component | Scope | Purpose |
|------|----------|-----------|-------|---------|
| 8001 | TCP | KubeLB Manager | In-cluster | Envoy xDS control plane (`envoycp` service) |
| 9443 | TCP | KubeLB Manager | Pod | Metrics endpoint, exposed via kube-rbac-proxy service on 8443 |
| 8081 | TCP | KubeLB Manager | Pod | Health and readiness probes |
| 9445 | TCP | KubeLB CCM | Pod | Metrics endpoint, exposed via kube-rbac-proxy service on 8443 |
| 8081 | TCP | KubeLB CCM | Pod | Health and readiness probes |
| 9001 | TCP | Envoy Proxy pod | Localhost, unless debug mode is enabled | Envoy admin interface |
| 19001 | TCP | Envoy Proxy pod | Pod | Stats endpoint (`/stats/prometheus`) |
| 19002 | TCP | Envoy Proxy pod | Pod | Shutdown manager |
| 19003 | TCP | Envoy Proxy pod | Pod | Readiness |
| 19004 | TCP | Envoy Proxy pod | Pod | Health check listener |
| 15443 | TCP | Tenant proxy (EE) | Tenant cluster, reachable from management cluster | mTLS backend transport listener |
| 19000 | TCP | Tenant proxy (EE) | Pod | Envoy admin interface |
| 19001 | TCP | Tenant proxy (EE) | Pod | Stats endpoint |
| 19002 | TCP | Tenant proxy (EE) | Pod | Shutdown manager |
| 19003 | TCP | Tenant proxy (EE) | Pod | Readiness |
| 19004 | TCP | Tenant proxy (EE) | Pod | Health check listener |
| 8080 | TCP | Connection manager (EE) | In-cluster, exposed via Ingress or HTTPRoute | HTTP server for Envoy and tunnel connections |

## Resource sizing

| Component | Requests | Limits |
|-----------|----------|--------|
| kubelb-manager | 100m CPU / 128Mi | 500m CPU / 512Mi |
| kubelb-ccm | 100m CPU / 128Mi | 500m CPU / 512Mi |
| Connection manager (EE) | 250m CPU / 128Mi | 500m CPU / 256Mi |
| Envoy Proxy pods | none | none |
| Tenant proxy Envoy (EE) | 100m CPU / 128Mi | 1 CPU / 512Mi |

The managed Envoy Proxy pods ship with no default requests or limits (`kubelb.envoyProxy.resources: {}`). Set them for production so the data plane gets scheduled with guaranteed capacity and cannot starve other workloads. Envoy Proxy defaults to 2 replicas with one pod per node.

## Next steps

* [Setup Management Cluster]({{< relref "../management-cluster" >}})
* [Setup Tenant Cluster]({{< relref "../tenant-cluster" >}})
* [Air-Gap Installation]({{< relref "../air-gap" >}})
