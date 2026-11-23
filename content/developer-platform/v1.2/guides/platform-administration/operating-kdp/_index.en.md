+++
title = "Operating KDP"
weight = 5
+++

This page covers running a KDP installation day to day: what runs where, how to watch it, what
to back up and what to look at when something goes wrong. All settings are values of the KDP Helm
chart (`developer-platform`) unless stated otherwise.

## Components

The KDP chart deploys these components into `kdp-system`:

| Component | Replicas | Purpose |
| --------- | -------- | ------- |
| `kdp-controller-manager` | 2 | Runs KDP's controllers and its admission webhook (port 9443). |
| `kdp-virtual-workspaces` | 2 | Serves the service catalogue and UI configuration views behind the kcp front-proxy. |
| `kdp-virtual-workspaces-aggregator` | 2 | Combines the virtual workspaces. |
| `kdp-exporter` | 1 | Exports Prometheus metrics about workspaces and services. Run only one. |
| `kdp-storage-server` | 2 | Stores uploaded service and Blueprint logos on a volume. |
| `kdp-mcp-server`, MCP gateway | 1 each, off by default | See [MCP Gateway]({{< ref "/developer-platform/v1.2/guides/platform-administration/mcp-gateway" >}}). |

kcp, Dex and the dashboard are installed by their own charts. All KDP objects, such as services,
Blueprints, workspaces and RBAC, are stored in kcp, not in the host cluster.

## Health and high availability

- Only one controller manager replica is active at a time. The others wait on a leader election
  lease named `kdp-controller-manager` in the `default` namespace of kcp's `root` workspace. All
  replicas serve the admission webhook.
- The controller manager and the aggregator have readiness probes (`/readyz`). The MCP server
  has `/healthz` and `/readyz`. The virtual workspaces, the exporter and the storage server have no
  probes, so check them through their logs and metrics.
- The chart creates no PodDisruptionBudgets. Add your own if node maintenance must not take down
  all replicas of a component at once.
- The storage server's two replicas share one `ReadWriteOnce` volume, so they are scheduled onto
  the same node.

## Metrics

| Source | Endpoint | Metrics |
| ------ | -------- | ------- |
| `kdp-exporter` | port 8385 | `kcp_workspace_info`, `kdp_service_info`, plus scrape duration and success |
| `kdp-virtual-workspaces-aggregator` | HTTPS `/metrics` on port 8080 | `kdp_vw_aggregator_*` |

To have Prometheus Operator scrape them, set `kdp.exporter.serviceMonitor.enabled: true` and
`kdp.virtualWorkspacesAggregator.serviceMonitor.enabled: true`.

The controller manager's metrics only listen on `127.0.0.1:8285` inside its pod, so they can't be
scraped from outside.

## Logs

KDP components log in JSON at info level. For debug logs, set `logDebug: true` on the component,
for example `kdp.controllerManager.logDebug`, `kdp.virtualWorkspaces.logDebug`,
`kdp.virtualWorkspacesAggregator.logDebug` or `kdp.storageServer.logDebug`.

KDP's controllers don't create Kubernetes events, so `kubectl get events` won't show their
activity. Check the status conditions of the objects instead, and the controller manager's logs.

## Backup

Back up these three things:

1. **kcp's etcd.** It holds all KDP state: workspaces, services, `APIBindings`, Blueprints,
   service objects, RBAC and the kubeconfig Secrets KDP generates for service providers.
2. **The storage server's volume.** Uploaded logos are stored on the `kdp-storage-server`
   volume (`/data`), not in kcp. Without it, logos are lost.
3. **The certificates in the host cluster.** kcp's CAs and KDP's client certificates are
   cert-manager Secrets in `kdp-system`. Restoring kcp without its CAs invalidates every
   kubeconfig and service provider credential.

Keep your Helm values files too, including the OIDC client secrets.

The storage server's volume defaults to 1Gi from the default storage class. Change this under
`kdp.storageServer.storage` (`size`, `storageClassName`, `accessMode`) before the first install,
as most storage classes can't shrink or move an existing volume.

## Admission webhook

When a service provider restricts a service to organisations or projects (see
[Configuring Services]({{< ref "/developer-platform/v1.2/guides/service-providers/configuring-services#restricting-where-a-service-can-be-used" >}})),
KDP registers an admission webhook for that service's resources. The webhook fails closed with a
5-second timeout: if no controller manager replica can answer, creating any object of that
service fails until the controller manager is back.

## Common problems

- **Deleting a Blueprint or Blueprint instance hangs.** These objects have finalizers that the
  controller manager removes. Check that it is running and has a leader.
- **New workspaces don't get the default roles.** See the depth limit and readiness notes under
  [RBAC]({{< ref "/developer-platform/v1.2/introduction/concepts/rbac#cross-workspace-rbac-propagation" >}}).
- **Logo uploads fail.** Check the `/services/storage/` route on the kcp front-proxy and
  `dashboard.config.storage.serverURL`. See
  [Get Started]({{< ref "/developer-platform/v1.2/get-started" >}}).
- **The controller manager doesn't start.** It needs kcp's client CA certificate and key and the
  server CA certificate; check that the cert-manager Certificates in `kdp-system` are `Ready`.
