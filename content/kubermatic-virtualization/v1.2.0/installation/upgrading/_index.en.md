+++
title = "Upgrading"
date = 2026-07-24T09:00:00+02:00
weight = 17
+++

This section contains important upgrade notes you should read **before** upgrading a
Kubermatic Virtualization (KubeV) installation to a new version. Read the version-specific
guide for the release you are moving to, then follow the general guidelines below.

## Version-Specific Upgrade Notes

{{% children %}}
{{% /children %}}

## General Guidelines

The following steps apply to every KubeV upgrade.

### How Upgrades Work

KubeV installations are declarative, and `kubev apply` is idempotent: the same command that
installs a cluster also upgrades it. To upgrade, update the KubeV version (and any changed
settings) in your configuration file and re-run `kubev apply` against it — the installer
reconciles the live system to the desired state, handling installation, upgrades, and repairs.

```bash
kubev apply -f cluster.yaml
```

Keep your `cluster.yaml` under version control and treat it as the single source of truth. See
[Declarative Installation]({{< ref "../declarative-installation/" >}}) for the full
configuration reference.

### Upgrade One Minor Version at a Time

Upgrade sequentially through minor versions (for example `v1.1.x` → `v1.2.x`) and read the
version-specific guide for each hop. Do not skip minor versions.

### Create Backups

Even though regular backups should already be in place, ensure fresh backups exist before you
start an upgrade:

* **Your configuration** — keep the exact `cluster.yaml` used for the running installation, plus
  the generated cluster kubeconfig.
* **Cluster state** — back up etcd, or dump the Kubernetes resources you care about:

```bash
export KUBECONFIG=...

while IFS= read -r crd; do
  echo "Dumping $crd ..."
  kubectl get "$crd" -A -o yaml > "$crd.yaml"
done <<< "$(kubectl get crd -o name)"
```

* **Workload data** — snapshot persistent VM and application data through your storage layer (for
  example, Longhorn volume snapshots/backups) according to your disaster-recovery process.

### Repair Before You Upgrade

`kubev apply` does not perform a repair and an upgrade in the same run. If nodes are unhealthy,
first run `kubev apply` with the **current** version to repair the cluster, and only then change
the version and re-run to upgrade.

### Offline / Air-Gapped Installations

In offline mode (`offlineSettings.enabled: true`) KubeV does not reach the public internet during
upgrades. Every container image, Helm chart, and OS package for the target version must be
pre-loaded into your internal mirrors before you upgrade.

### Run the Pre-Flight Check

`kubev apply` runs pre-flight checks and fails fast with a descriptive message if the
configuration is incomplete (for example, missing image-registry credentials) **before** making
any cluster changes. A failed pre-flight leaves the existing installation untouched — resolve the
reported issue and re-run.

### Verify the Upgrade

After `kubev apply` completes, confirm the platform is healthy:

```bash
export KUBECONFIG=kubev-cluster-kubeconfig
kubectl get nodes
kubectl get pods -A
```

All platform components — including `kubev-controller-manager`, the api-server, and (if enabled)
the dashboard — should reach `Running`. Investigate any pod stuck in `ImagePullBackOff`,
`CrashLoopBackOff`, or `Pending`.
