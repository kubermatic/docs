+++
title = "Upgrading to KKP 2.29"
date = 2025-10-21T12:00:00+02:00
weight = 10
+++

{{% notice note %}}
Upgrading to KKP 2.29 is only supported from version 2.28. Do not attempt to upgrade from versions prior to that and apply the upgrade step by step over minor versions instead (e.g. from [2.27 to 2.28]({{< ref "../upgrade-from-2.27-to-2.28/" >}}) and then to 2.29). It is also strongly advised to be on the latest 2.28.x patch release before upgrading to 2.29.
{{% /notice %}}

This guide will walk you through upgrading Kubermatic Kubernetes Platform (KKP) to version 2.29. For the full list of changes in this release, please check out the [KKP changelog for v2.29](https://github.com/kubermatic/kubermatic/blob/main/docs/changelogs/CHANGELOG-2.29.md). Please read the full document before proceeding with the upgrade.

## Pre-Upgrade Considerations

{{% notice warning %}}
Please review [known issues]({{< ref "../../../architecture/known-issues/" >}}) before upgrading to understand if any issues might affect you.
{{% /notice %}}

### Alloy Helm Chart Integration and Promtail Removal

KKP 2.29 fully replaces Promtail with the Grafana Alloy for log shipping in seed clusters. When upgrading, the installer will remove Promtail if it was previously installed. **Alloy is now the only supported log shipper for seed cluster logs.**

#### Migration Procedure

If you are using `kubermatic-installer` for the Seed MLA installation, then it will take care of removing the resources for the deprecated Promtail helm-chart and installing the new Grafana Alloy helm-chart. You just need to run the following command:

```bash
./kubermatic-installer deploy seed-mla --helm-values values.yaml
```

If you are installing MLA using GitOps / Manual way using Helm CLI, before upgrading, you must delete the existing Helm release before doing the upgrade.

```bash
helm uninstall promtail -n logging
```

Afterwards you can install the new release from the chart using Helm CLI or using your favourite GitOps tool.

## Upgrade Procedure

Before starting the upgrade, make sure your KKP Master and Seed clusters are healthy with no failing or pending Pods. If any Pod is showing problems, investigate and fix the individual problems before applying the upgrade. This includes the control plane components for user clusters, unhealthy user clusters should not be submitted to an upgrade.

### KKP Master Upgrade

Download the latest 2.29.x release archive for the correct edition (`ce` for Community Edition, `ee` for Enterprise Edition) from [the release page](https://github.com/kubermatic/kubermatic/releases) and extract it locally on your computer. Make sure you have the `values.yaml` you used to deploy KKP 2.29 available and already adjusted for any 2.29 changes (also see [Pre-Upgrade Considerations](#pre-upgrade-considerations)), as you need to pass it to the installer. The `KubermaticConfiguration` is no longer necessary (unless you are adjusting it), as the KKP operator will use its in-cluster representation. From within the extracted directory, run the installer:

```sh
$ ./kubermatic-installer deploy kubermatic-master --helm-values path/to/values.yaml

# example output for a successful upgrade
INFO[0000] 🚀 Initializing installer…                     edition="Enterprise Edition" version=v2.29.0
INFO[0000] 🚦 Validating the provided configuration…     
INFO[0000] ✅ Provided configuration is valid.           
INFO[0000] 🚦 Validating existing installation…          
INFO[0002]    Checking seed cluster…                     seed=kubermatic
INFO[0005] ✅ Existing installation is valid.            
INFO[0005] 🛫 Deploying KKP master stack…                
INFO[0005]    💾 Deploying kubermatic-fast StorageClass… 
INFO[0005]    ✅ StorageClass exists, nothing to do.     
INFO[0005]    📦 Deploying nginx-ingress-controller…     
INFO[0008]       Deploying Helm chart…                  
INFO[0016]    ✅ Success.                                
INFO[0016]    📦 Deploying cert-manager…                 
INFO[0017]       Deploying Custom Resource Definitions… 
INFO[0028]       Deploying Helm chart…                  
INFO[0035]    ✅ Success.                                
INFO[0035]    📦 Deploying Dex…                          
INFO[0037]       Updating release from 2.28.3 to 2.29.0… 
INFO[0090]    ✅ Success.                                
INFO[0090]    📦 Deploying Kubermatic Operator…          
INFO[0090]       Deploying Custom Resource Definitions… 
INFO[0118]       Deploying Helm chart…                  
INFO[0121]       Updating release from 2.28.3 to 2.29.0… 
INFO[0211]    ✅ Success.                                
INFO[0211]    📝 Applying Kubermatic Configuration…      
INFO[0211]    ✅ Success.                                
INFO[0211]    📦 Deploying Telemetry…                    
INFO[0212]       Updating release from 2.28.3 to 2.29.0… 
INFO[0219]    ✅ Success.                                
INFO[0219]    Deploying default Policy Template catalog 
INFO[0219]    📡 Determining DNS settings…               
INFO[0219]    The main Ingress is ready.       
INFO[0220]         Service             : nginx-ingress-controller / nginx-ingress-controller
INFO[0220]         Ingress via hostname: <Load Balancer>.eu-central-1.elb.amazonaws.com
INFO[0220]
INFO[0220]       Please ensure your DNS settings for "<KKP FQDN>" include the following records:
INFO[0220]
INFO[0220]          <KKP FQDN>.    IN  CNAME  <Load Balancer>.eu-central-1.elb.amazonaws.com.
INFO[0220]          *.<KKP FQDN>.  IN  CNAME  <Load Balancer>.eu-central-1.elb.amazonaws.com.
INFO[0220]
INFO[0220] 🛬 Installation completed successfully. ✌

```

Upgrading seed clusters is not necessary, unless you are running the `minio` Helm chart or User Cluster MLA as distributed by KKP on them. They will be automatically upgraded by KKP components.

You can follow the upgrade process by either supervising the Pods on master and seed clusters (by simply checking `kubectl get pods -n kubermatic` frequently) or checking status information for the `Seed` objects. A possible command to extract the current status by seed would be:

```bash
$ kubectl get seeds -A -o jsonpath="{range .items[*]}{.metadata.name} - {.status}{'\n'}{end}"

kubermatic - {"clusters":0,"conditions":{"ClusterInitialized":{"lastHeartbeatTime":"2025-10-21T12:48:12Z","message":"All KKP CRDs have been installed successfully.","reason":"CRDsUpdated","status":"True"},"KubeconfigValid":{"lastHeartbeatTime":"2025-10-21T12:48:08Z","reason":"KubeconfigValid","status":"True"},"ResourcesReconciled":{"lastHeartbeatTime":"2025-10-21T12:48:16Z","reason":"ReconcilingSuccess","status":"True"}},"phase":"Healthy","versions":{"cluster":"v1.33.5","kubermatic":"v2.29.0"}}
```

Of particular interest to the upgrade process is if the `ResourcesReconciled` condition succeeded and if the `versions.kubermatic` field is showing the target KKP version. If this is not the case yet, the upgrade is still in flight. If the upgrade is stuck, try `kubectl -n kubermatic describe seed <seed name>` to see what exactly is keeping the KKP Operator from updating the Seed cluster.

## Post-Upgrade Considerations

### Deprecations and Removals

Some functionality of KKP has been deprecated or removed with KKP 2.29. You should review the full [changelog](https://github.com/kubermatic/kubermatic/blob/main/docs/changelogs/CHANGELOG-2.29.md) and adjust any automation or scripts that might be using deprecated fields or features. Below is a list of changes that might affect you:

- Promtail has been removed as a log shipper for seed clusters in favor of the Grafana Alloy Helm chart. Please ensure you have migrated to Alloy before upgrading, as Promtail will be uninstalled during the upgrade process.

## Next Steps

<!--
Mention next steps here.
-->
