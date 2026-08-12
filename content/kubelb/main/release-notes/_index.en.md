+++
title = "Release Notes"
date = 2024-03-15T00:00:00+01:00
description = "Release history for KubeLB with notable changes in each version."
weight = 60
aliases = ["/kubelb/main/cli/release-notes/"]
+++

## v1.5.0

**GitHub release: [v1.5.0](https://github.com/kubermatic/kubelb/releases/tag/v1.5.0)**

### Urgent Upgrade Notes

These notes apply to both Community Edition (`kubelb-manager`) and Enterprise
Edition (`kubelb-manager-ee`). See [Upgrading KubeLB]({{< relref "../installation/upgrade" >}})
for the full upgrade procedure.

#### Apply the Gateway API CRDs before upgrading

KubeLB v1.5.0 upgrades the bundled Envoy Gateway from 1.7.2 to 1.8.3. Envoy
Gateway 1.8.3 requires the `ListenerSet` CRD
(`listenersets.gateway.networking.k8s.io`), which is part of Gateway API v1.5.
The chart ships this CRD, but Helm only applies a chart's `crds/` directory on
`helm install`; it skips it on `helm upgrade`. Existing installations therefore
end up running Envoy Gateway 1.8.3 without the CRD it needs.

Before running `helm upgrade`, apply the Gateway API bundle:

```bash
kubectl apply --server-side --force-conflicts -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/experimental-install.yaml
```

Fresh installations are unaffected, because `helm install` applies the CRDs
itself.

{{% notice warning %}}
The failure is delayed if you skip this step. The upgrade reports success and
traffic keeps flowing, because the existing `envoy-gateway` pod keeps running.
The new pod never becomes ready, and the Gateway API control plane only goes
down the next time that pod restarts — a node reboot, an eviction, or a scale
event, which can be days later. The pod then crashloops with
`no matches for kind "ListenerSet" in version "gateway.networking.k8s.io/v1"`.
Recovery is the same `kubectl apply` above.
{{% /notice %}}

#### Expected disruption

Expect a one-time Layer 7 disruption of roughly 1.5–2.5 minutes during the
manager upgrade, caused by the Envoy resource-naming migration and the Envoy
Gateway roll. Layer 4 traffic is unaffected.

#### Rolling back

v1.5.0 installs a `safe-upgrades.gateway.networking.k8s.io`
ValidatingAdmissionPolicy that denies rolling the Gateway API CRDs back to a
v1.4.x bundle. Do not downgrade the CRDs: the newer CRDs work with the older
Envoy Gateway. See [Rolling back]({{< relref "../installation/upgrade#rolling-back" >}})
for the full rollback constraints.

#### Leftover CRD from v1.5.0-beta.0

Clusters upgraded from `v1.5.0-beta.0` still carry the
`virtualkeys.kubelb.k8c.io` CRD. The feature it belonged to was removed before
v1.5.0 and Helm never deletes CRDs, so the leftover is inert but should be
cleaned up:

```bash
kubectl delete crd virtualkeys.kubelb.k8c.io
```

**Full Changelog**: <https://github.com/kubermatic/kubelb/compare/v1.4.0...v1.5.0>
