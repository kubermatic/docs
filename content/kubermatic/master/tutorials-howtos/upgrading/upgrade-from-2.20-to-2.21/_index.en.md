
+++
title = "Upgrading from 2.20 to 2.21"
date = 2022-08-31T00:00:00+01:00
weight = 120
+++

{{% notice note %}}
Upgrading to KKP 2.21 is only supported from version 2.20. Do not attempt to upgrade from versions prior to that and apply the upgrade step by step over minor versions instead (e.g. from [2.19 to 2.20]({{< ref "../upgrade-from-2.19-to-2.20/" >}}) and then to 2.21). It is also strongly advised to be on the latest 2.20.x patch release before upgrading to 2.21.
{{% /notice %}}

This upgrade guide will walk you through upgrading Kubermatic Kubernetes Platform (KKP) to version 2.21. For the full list of changes in this release, please check out the [KKP changelog for v2.21](https://github.com/kubermatic/kubermatic/blob/master/docs/changelogs/CHANGELOG-2.21.md). Please read the full document before proceeding with the upgrade.

## Pre-Upgrade Considerations

- Support for Kubernetes 1.20 and Kubernetes 1.21 has been removed in KKP. It is recommended to update existing user clusters to 1.22 before proceeding with the upgrade, but user clusters with 1.21 will also be automatically updated to 1.22 as part of the upgrade.
- The expected secret name for S3 credentials has been updated to `kubermatic-s3-credentials`. If the `s3-credentials` secret was manually created instead of using the `minio` Helm chart, the existing `s3-credentials` secret should be duplicated to `kubermatic-s3-credentials`.
- Check the full list of [breaking changes](https://github.com/kubermatic/kubermatic/blob/master/docs/changelogs/CHANGELOG-2.21.md#breaking-changes), specifically for changes to Helm chart values shipped as part of KKP. Adjust your local `values.yaml` and any CRDs manually deployed for the required changes (do not apply them yet, the Helm charts will be updated during the upgrade procedure).

## Upgrade Procedure

Download the latest release archive for the KKP 2.21.x release series from [the release page](https://github.com/kubermatic/kubermatic/releases) and extract it locally on your computer. Make sure you have the `values.yaml` and `KubermaticConfiguration` yaml file you used to deploy KKP 2.20 available, as you need to pass them to the installer. From within the extracted directory, run the installer:

```sh 
$ ./kubermatic-installer deploy kubermatic-master \
  --config path/to/kubermaticconfiguration.yaml \
  --helm-values path/to/values.yaml \
  --force
```

Upgrading seed clusters is no longer necessary in KKP 2.21, unless you are running the `minio` Helm chart as distributed by KKP on them. Apart from upgrading the `minio` chart, no manual steps for seed clusters are required. They will be automatically upgraded by KKP master components.

You can follow the upgrade process by either supervising the pods on master and seed clusters (by simply checking `kubectl get pods -n kubermatic` frequently) or checking status information for the `Seed` objects. A possible command to extract the current status by seed would be:

```sh
$ kubectl get seeds -A -o jsonpath="{range .items[*]}{.metadata.name} - {.status}{'\n'}{end}"
kubermatic - {"clusters":3,"conditions":{"KubeconfigValid":{"lastHeartbeatTime":"2022-08-03T10:10:32Z","reason":"KubeconfigValid","status":"True"},"ResourcesReconciled":{"lastHeartbeatTime":"2022-08-25T09:30:52Z","lastTransitionTime":"2022-08-25T09:30:52Z","reason":"ReconcilingSuccess","status":"True"}},"phase":"Healthy","versions":{"cluster":"v1.23.6","kubermatic":"v2.21.0"}}
```

Particularly interesting for the upgrade process is if the `ResourcesReconciled` condition succeeded and if the `versions.kubermatic` field is showing the target KKP version. If this is not the case yet, the upgrade is still in flight.

After a seed was successfully upgraded, user clusters on that seed should start updating. Observe their control plane components in the respective cluster namespaces if you want to follow the upgrade process. This is the last step of the upgrade, after all user clusters have settled the upgrade is complete.

## Post-Upgrade Considerations

- `operating-system-manager` (OSM) is now enabled by default, which is reflected in the dashboard during cluster creation. For existing clusters, [enableOperatingSystemManager]({{< ref "../../../references/crds/#clusterspec" >}}) is **not** updated and needs to be manually enabled. After enabling OSM, `MachineDeployments` require manual rotation for instances to start using OSM to bootstrap. That can be forced by updating machine annotations, for example.
- Since OPA Gatekeeper has been updated to 3.6.0, new Kubermatic `ConstraintTemplates` need a structurally correct schema in `spec.crd.spec.validation.openAPIV3Schema`. Old templates set the `spec.crd.spec.validation.legacySchema` and need to be migrated to a structurally correct schema (update the schema and set this flag to false). Check out [OPA Gatekeeper documentation](https://open-policy-agent.github.io/gatekeeper/website/docs/constrainttemplates/#v1-constraint-template) for more on this topic.

### KubeVirt Migration

If you already have KKP 2.20 installed and a KubeVirt cluster created with it, please be aware that there is a 
**non backward compatible spec change** for `MachineDeployments`. It means a `MachineDeployment`
created with KKP 2.20 and one created with KKP 2.21 will have different API,
and no automatic migration will happen as KubeVirt is in Technology Preview phase.

Below is the procedure to follow to fully migrate for a KubeVirt cluster:

1) Your existing KKP 2.20 tenant cluster with its existing worker nodes will continue to work.
The restriction is that you will not be able to update the old `MachineDeployment` objects.
Additionally, reconciliation of those objects will not work properly, and you may see errors.
2) Create new `MachineDeployments`.
3) Once the new worker nodes are up and running, you can migrate your workload to the new nodes.
4) Then cleanup the old worker nodes created with KKP 2.20:
    * in the user cluster: delete the old `MachineDeployment` objects.
    * in the KubeVirt infrastructure cluster: delete the corresponding `VirtualMachine`.

## Next Steps

After finishing the upgrade, check out some of the new features that were added in KKP 2.21:

- [Third-party application installs via an application catalogue]({{< ref "../../applications/" >}})
- [Creating external clusters from KKP]({{< ref "../../external-clusters/" >}})
- [Operating System Manager]({{< ref "../../operating-system-manager/" >}}) (available as preview in KKP 2.20, but enabled by default in 2.21)
- Support for Rocky Linux as new OS and VMware Cloud Director as new cloud provider
- [Resource Quotas]({{< ref "../../../architecture/concept/kkp-concepts/resource-quotas/" >}}) (available in Enterprise Edition)
- [KKP role assignments for OIDC groups]({{< ref "../../../architecture/role-based-access-control/groups-support/" >}}) (available in Enterprise Edition)

Check out the [changelog](https://github.com/kubermatic/kubermatic/blob/master/docs/changelogs/CHANGELOG-2.21.md) for a full list of changes.
