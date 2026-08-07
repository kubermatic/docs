+++
title = "Upgrading to 1.0"
weight = 2
+++

This guide covers upgrading a KDP installation from **0.9.0** to **1.0** (recommended
patch: **1.0.2**). Read it in full before starting — 1.0 is a major release and includes
control-plane (kcp) version changes.

{{% notice warning %}}
Take a backup / snapshot of your kcp state and cluster before upgrading. Test the upgrade
in a non-production environment first.
{{% /notice %}}

## Version matrix

The three KDP components are released together. For KDP 1.0.2, use:

| Component | Chart / image version |
| --------- | --------------------- |
| KDP backend (`developer-platform`) | `1.0.2` |
| KDP dashboard (`developer-platform-dashboard`) | `1.0.2` |
| KDP AI Agent (`developer-platform-ai-agent`) | `1.0.2` |
| kcp Helm chart | `0.16.0` (was `0.14.0`) |
| Dex Helm chart | `0.23.0` (unchanged) |
| api-syncagent (service clusters) | `0.7.0` |

## Breaking changes and required actions

### 1. kcp control-plane upgrade (0.14.0 → 0.16.0)

KDP 1.0 is built against a newer kcp (and Kubernetes) release. Upgrade the kcp Helm chart
to `0.16.0` **before** upgrading the KDP backend:

```bash
helm upgrade --install kcp kcp \
    --repo=https://kcp-dev.github.io/helm-charts \
    --version=0.16.0 \
    --namespace=kdp-system \
    --values=kcp.values.yaml
```

Review your `kcp.values.yaml` against the 0.16.0 chart for renamed or new keys, and re-check
the front-proxy CA bundling step from the
[quickstart]({{< relref "../quickstart" >}}) — the CA Secrets are managed by the kcp chart
and may need to be re-combined after the upgrade.

### 2. `APIExport` / `APIBinding` moved to `apis.kcp.io/v1alpha2`

KDP 1.0 stops using the deprecated `APIExport` virtual-workspace fields and the dashboard
now uses `apis.kcp.io/v1alpha2`. If you maintain any hand-written `APIExport` or `APIBinding`
manifests, migrate them to `apis.kcp.io/v1alpha2`. Existing bindings created via the
dashboard are migrated automatically.

### 3. `docs.kdp.k8c.io` API group removed

The `docs.kdp.k8c.io` API group has been removed. If you referenced it in any automation or
RBAC rules, remove those references.

### 4. Dashboard feature-flag keys are now kebab-case

Environment-variable feature flags in the dashboard Helm values use **kebab-case** keys
(for example `service-composition-enabled`) under `dashboard.config.featureFlags`. If you
override feature flags in your `kdp-dashboard.values.yaml`, rename the keys accordingly.
Note that the structured `dashboard.config.features` block (for example `features.aiAgent`)
is unaffected and keeps its existing camelCase keys.

### 5. New CRDs are installed (inert by default)

The 1.0 charts bundle additional CRDs (for in-development features that are not yet
documented). They are installed but have no effect unless the corresponding optional
components are deployed and enabled, so no action is required during the upgrade.

### 6. Update the api-syncagent on service clusters

If you operate service clusters, upgrade the [api-syncagent]({{< relref "../../service-providers/api-syncagent" >}})
to **v0.7.0**, which is built against kcp 0.32 to match the KDP 1.0 control plane. Upgrade
it after the kcp control plane is on 0.16.0.

## Upgrade order

1. Upgrade **kcp** to `0.16.0` (see above) and confirm the control plane is healthy.
2. Upgrade the **KDP backend** chart to `1.0.2`.
3. Upgrade the **KDP dashboard** chart to `1.0.2` (rename feature-flag keys first, if used).
4. Upgrade the **KDP AI Agent** chart to `1.0.2`.

Each step uses the same `helm upgrade --install …` commands as the
[quickstart]({{< relref "../quickstart" >}}), with `--version=1.0.2` for the KDP charts.

## Verify

- The kcp front-proxy and KDP controller-manager pods are `Ready` in `kdp-system`.
- Existing workspaces, `APIBindings`, and service objects are still present and reconciling.
- You can log in to the dashboard and browse your organization's services.
