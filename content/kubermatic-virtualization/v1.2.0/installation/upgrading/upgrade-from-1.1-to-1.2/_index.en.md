+++
title = "Upgrading to KubeV v1.2.0"
date = 2026-07-24T09:00:00+02:00
weight = 10
+++

{{% notice note %}}
Upgrading to KubeV v1.2.0 is supported from v1.1.x. If you are on an older release, upgrade step
by step over minor versions first. It is also advised to be on the latest v1.1.x patch release
before upgrading to v1.2.0.
{{% /notice %}}

This guide walks you through upgrading a Kubermatic Virtualization (KubeV) installation from
v1.1.x to v1.2.0. Read the full document before starting, then follow the
[general guidelines]({{< ref "../" >}}) (backups, minor-by-minor, repair-before-upgrade).

## Pre-Upgrade Considerations

### Image Pull Secret Moved to the Top Level

In v1.1.x the registry pull secret was configured under `dashboard.imagePullSecret`. In v1.2.0
the pull secret is a **top-level `imagePullSecret`** field that is applied to all platform
components. This matters because the `kubev-controller-manager` is always deployed — even when the
dashboard is disabled — and it reads its pull secret **only** from the top-level field.

{{% notice warning %}}
**Action required.** If your v1.1.x configuration sets the pull secret only under
`dashboard.imagePullSecret`, move that value to the top-level `imagePullSecret` before upgrading.
If you do not, `kubev-controller-manager` fails to pull its image and enters `ImagePullBackOff`
(`401 UNAUTHORIZED`). In v1.2.0 the `kubev apply` pre-flight check detects the missing top-level
field and stops with a descriptive error before making any cluster changes.
{{% /notice %}}

#### Migration Procedure

Move the pull secret to the top level of your configuration file. The value is unchanged — only
its location moves.

**v1.1.x (old) — pull secret under `dashboard`:**

```yaml
apiVersion: virtualization.k8c.io/v1alpha1
kind: KubeVCluster

dashboard:
  enabled: true
  imagePullSecret: |
    {"auths":{"quay.io":{"auth":"<base64 of username:password>"}}}
```

**v1.2.0 (new) — top-level `imagePullSecret`:**

```yaml
apiVersion: virtualization.k8c.io/v1alpha1
kind: KubeVCluster

# required for every installation — applied to all platform components
imagePullSecret: |
  {"auths":{"quay.io":{"auth":"<base64 of username:password>"}}}

dashboard:
  enabled: true
```

Alternatively, export the credentials as environment variables before running `kubev apply`, so
nothing is stored in the file:

```bash
export KUBEV_USERNAME=myuser
export KUBEV_PASSWORD=mypassword
kubev apply -f cluster.yaml
```

Not sure where the field belongs? Generate an annotated example and search for `imagePullSecret`:

```bash
kubev config print --full
```

{{% notice note %}}
Air-gapped installations that pull every image from a mirror configured under `offlineSettings`
do not need a top-level `imagePullSecret`; in that case the pre-flight check does not require it.
{{% /notice %}}

## Upgrade Procedure

1. Apply the [Migration Procedure](#migration-procedure) above to your `cluster.yaml`.
2. Set the KubeV version in `cluster.yaml` to v1.2.0.
3. Ensure all nodes are healthy (repair first if needed — see the
   [general guidelines]({{< ref "../" >}})).
4. Re-run apply:

```bash
kubev apply -f cluster.yaml
```

The pre-flight check runs first. If the top-level `imagePullSecret` (or `KUBEV_USERNAME`/
`KUBEV_PASSWORD`) is missing on a non-air-gapped install, apply stops before changing anything —
add the field and re-run.

## Verify the Upgrade

```bash
export KUBECONFIG=kubev-cluster-kubeconfig
kubectl get pods -A
```

Confirm `kubev-controller-manager` (and, if enabled, the api-server and dashboard) is `Running`
and not `ImagePullBackOff`. To inspect a failing controller-manager:

```bash
kubectl -n kubermatic-virtualization describe pod -l app.kubernetes.io/name=kubev-controller-manager
```
