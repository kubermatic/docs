+++
title = "Upgrading KubeLB"
linkTitle = "Upgrade"
date = 2026-08-11T00:00:00+02:00
description = "Upgrade the KubeLB manager and the tenant CCMs, including the CRD handling that Helm does not do for you."
weight = 25
+++

## Why upgrades need a manual CRD step

Helm applies a chart's `crds/` directory **only on `helm install`**. It skips that directory on every `helm upgrade`, and it never deletes CRDs. This is documented Helm behavior, not a KubeLB limitation, and there is no flag that changes it.

The consequence that catches people out: this rule applies to **addon subcharts as well**. The KubeLB manager chart bundles Gateway API, Envoy Gateway and External DNS CRDs inside its addon subcharts. When you run `helm upgrade`, the addon workloads move to their new versions while their CRDs stay at whatever version was current when the cluster was first installed.

So the CRD apply is a mandatory step of **every upgrade**, not a one-time install step.

{{% notice warning %}}
`helm upgrade` reports success whether or not the CRDs are current. Nothing in the Helm output tells you that the CRDs were skipped.
{{% /notice %}}

## Upgrade order

Upgrade in this order:

1. **CRDs on the management cluster**, then the **KubeLB manager**.
2. **CRDs on each tenant cluster**, then that tenant's **KubeLB CCM**.

Upgrade the manager before the CCMs. The manager owns the shared API surface, and a newer CCM talking to an older manager can send resources the manager does not yet understand. A newer manager with older CCMs is the supported direction and is what you pass through during a rollout.

Do not leave a fleet running mixed versions longer than the rollout needs. Manager and CCM are released and tested as a matched pair; skew is a transitional state, not a supported configuration.

## Management cluster

Pull the chart and apply every CRD it ships, then upgrade the release:

{{< tabs name="KubeLB Manager Upgrade" >}}
{{% tab name="Enterprise Edition" %}}

```sh
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-manager-ee --version=<version> --untardir "." --untar

kubectl apply --server-side --force-conflicts -R \
  -f kubelb-manager-ee/crds/ \
  -f kubelb-manager-ee/charts/kubelb-addons/charts/external-dns/crds/ \
  -f kubelb-manager-ee/charts/kubelb-addons/charts/gateway-helm/charts/crds/crds/

helm upgrade --install kubelb-manager kubelb-manager-ee --namespace kubelb -f values.yaml
```

{{% /tab %}}
{{% tab name="Community Edition" %}}

```sh
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-manager --version=<version> --untardir "." --untar

kubectl apply --server-side --force-conflicts -R \
  -f kubelb-manager/crds/ \
  -f kubelb-manager/charts/kubelb-addons/charts/external-dns/crds/ \
  -f kubelb-manager/charts/kubelb-addons/charts/gateway-helm/charts/crds/crds/

helm upgrade --install kubelb-manager kubelb-manager --namespace kubelb -f values.yaml
```

{{% /tab %}}
{{< /tabs >}}

Three directories, because the chart keeps CRDs in three places:

| Directory | Contents |
|-----------|----------|
| `crds/` | KubeLB's own CRDs |
| `charts/kubelb-addons/charts/external-dns/crds/` | The External DNS `DNSEndpoint` CRD |
| `charts/kubelb-addons/charts/gateway-helm/charts/crds/crds/` | Gateway API and Envoy Gateway CRDs |

`-R` is required: the Gateway API directory has a `generated/` subdirectory holding the Envoy Gateway CRDs, and `kubectl apply -f <dir>` does not descend into subdirectories on its own.

Apply all three even for addons you have not enabled. The chart ships the CRDs regardless of the `enabled` flags, and applying a CRD for an addon you do not run is inert.

{{% notice note %}}
The chart also vendors subcharts that are themselves *named* `crds`, under MetalLB and under `gateway-helm`. Those keep their manifests in `templates/`, so Helm upgrades them normally and they must stay out of the command above. Some of them are Helm templates rather than plain manifests, which `kubectl apply` cannot parse. A blanket `find . -type d -name crds` picks them up and fails; use the three explicit paths.
{{% /notice %}}

## Tenant clusters

The CCM chart bundles no addon subcharts, so its own `crds/` directory is the complete set:

{{< tabs name="KubeLB CCM Upgrade" >}}
{{% tab name="Enterprise Edition" %}}

```sh
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-ccm-ee --version=<version> --untardir "." --untar

kubectl apply --server-side --force-conflicts -f kubelb-ccm-ee/crds/

helm upgrade --install kubelb-ccm kubelb-ccm-ee --namespace kubelb -f values.yaml
```

{{% /tab %}}
{{% tab name="Community Edition" %}}

```sh
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-ccm --version=<version> --untardir "." --untar

kubectl apply --server-side --force-conflicts -f kubelb-ccm/crds/

helm upgrade --install kubelb-ccm kubelb-ccm --namespace kubelb -f values.yaml
```

{{% /tab %}}
{{< /tabs >}}

## Upgrading to v1.5.0

### Gateway API CRDs are required before the upgrade

KubeLB v1.5.0 moves the bundled Envoy Gateway from 1.7.2 to 1.8.3. Envoy Gateway 1.8.3 requires the `ListenerSet` CRD (`listenersets.gateway.networking.k8s.io`), which arrived in Gateway API v1.5. The chart ships it, but as described above `helm upgrade` will not apply it.

Run the management cluster CRD apply above **before** `helm upgrade`. Fresh installations are unaffected, because `helm install` applies the CRDs itself.

### Symptom if you skipped it

The failure is delayed, which makes it hard to connect back to the upgrade:

* `helm upgrade` reports success.
* The existing `envoy-gateway` pod keeps running and traffic keeps flowing.
* The new ReplicaSet never becomes ready.
* The Gateway API control plane only actually goes down the next time that pod restarts — a node reboot, an eviction, or a scale event — which can be days later.

The `envoy-gateway` pod crashloops with:

```text
failed to create gatewayapi controller: error watching resources:
no matches for kind "ListenerSet" in version "gateway.networking.k8s.io/v1"
```

Check for it with:

```bash
kubectl get crd listenersets.gateway.networking.k8s.io
```

Recovery is the CRD apply itself. Run the management cluster command above; the pod recovers on its own once the CRD exists. No rollback or reinstall is needed.

### Expected disruption

Plan for a one-time Layer 7 disruption of roughly **1.5–2.5 minutes** during the manager upgrade. It is caused by the Envoy resource-naming migration and the Envoy Gateway roll, and it happens once per management cluster. Layer 4 traffic is unaffected.

A `helm upgrade` that fails on a transient apiserver error is safe to re-run with the identical command; it picks up where it left off.

### Rolling back

Do **not** downgrade the Gateway API CRDs when rolling back. The newer CRDs work with the older Envoy Gateway, so a rollback of the workloads needs no CRD change at all.

Two version-skew traps to avoid:

* When rolling a tenant's CCM back to v1.4.x, set `kubelb.installGatewayAPICRDs=false` on the CCM chart. The old CCM's CRD installer crashloops trying to downgrade the newer CRDs already on the cluster.
* A fresh `helm install` of an older chart on a cluster that already has the newer CRDs needs `--skip-crds`. Unlike `helm upgrade`, `helm install` applies the chart's `crds/` directory, and that apply is a CRD downgrade.

v1.5.0 installs a `safe-upgrades.gateway.networking.k8s.io` ValidatingAdmissionPolicy that rejects any Gateway API CRD older than v1.5.0. If you downgrade to a v1.4.x bundle while it is in place, the apply is denied with:

```text
Installing CRDs with version before v1.5.0 is prohibited by default.
```

Delete the binding and the policy first:

```bash
kubectl delete validatingadmissionpolicybinding safe-upgrades.gateway.networking.k8s.io
kubectl delete validatingadmissionpolicy safe-upgrades.gateway.networking.k8s.io
```

### Gateway API channel

The bundled Gateway API CRDs are `channel=experimental, bundle-version=v1.5.1`. Clusters running KubeLB v1.4.x are on `channel=experimental, bundle-version=v1.4.1`, so this is an in-channel upgrade: no experimental fields are stripped and the `safe-upgrades` policy rules pass.

{{% notice warning %}}
Do not apply the upstream `standard-install.yaml` bundle to an existing KubeLB cluster. KubeLB ships the experimental channel, and applying the standard channel over it is a channel downgrade that strips experimental fields from your Gateway API resources.
{{% /notice %}}
