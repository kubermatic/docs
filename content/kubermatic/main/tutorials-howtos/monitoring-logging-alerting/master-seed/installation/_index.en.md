+++
linkTitle = "Installation"
title = "Installation of the Master / Seed MLA Stack"
date = 2020-02-14T12:07:15+02:00
weight = 10
+++

This chapter describes how to setup the [KKP Master / Seed MLA (Monitoring, Logging & Alerting) stack]({{< relref "../../../../architecture/monitoring-logging-alerting/master-seed/" >}}). It's highly recommended to install this stack on the master and all seed clusters.

### Requirements

The exact requirements for the stack depend highly on the expected cluster load; the following are the minimum viable resources:

* 4 GB RAM
* 2 CPU cores
* 200 GB disk storage

This guide assumes the following tools are available:

* Helm 3.x
* kubectl 1.16+

## Monitoring, Logging & Alerting Components

This chapter describes how to setup the Kubermatic Kubernetes Platform (KKP) master / seed monitoring, logging & alerting components. It's highly recommended to install this
stack on the master and all seed clusters.

It uses [Prometheus](https://prometheus.io) and its [Alertmanager](https://prometheus.io/docs/alerting/alertmanager/) for monitoring and alerting. The logging stack consists of [Promtail](https://grafana.com/docs/loki/latest/send-data/promtail/) and [Grafana Loki](https://grafana.com/oss/loki/). Visualization is done with [Grafana](https://grafana.com) dashboards. More information can be found in the [Architecture]({{< relref "../../../../architecture/monitoring-logging-alerting/master-seed/" >}}) document.

## Installation

Make sure you have a kubeconfig for the desired Master/Seed Cluster available. It needs to have `cluster-admin` permissions on that cluster to install all Master/Seed MLA stack components.

The installer will use the `KUBECONFIG` environment variable to pick up the right kubeconfig to access the designated Master/Seed Cluster. Ensure that you have exported it, for example like this (on Linux and macOS):

```bash
export KUBECONFIG=/path/to/kubeconfig
```

### Download the Installer

Download the [release archive from our GitHub release page](https://github.com/kubermatic/kubermatic/releases/) (e.g. `kubermatic-ce-X.Y-linux-amd64.tar.gz`) containing the Kubermatic Installer and the required Helm charts for your operating system and extract it locally.

{{< tabs name="Download the installer" >}}
{{% tab name="Linux" %}}
```bash
# For latest version:
VERSION=$(curl -w '%{url_effective}' -I -L -s -S https://github.com/kubermatic/kubermatic/releases/latest -o /dev/null | sed -e 's|.*/v||')
# For specific version set it explicitly:
# VERSION=2.25.x
wget https://github.com/kubermatic/kubermatic/releases/download/v${VERSION}/kubermatic-ce-v${VERSION}-linux-amd64.tar.gz
tar -xzvf kubermatic-ce-v${VERSION}-linux-amd64.tar.gz
```
{{% /tab %}}
{{% tab name="MacOS" %}}
```bash
# Determine your macOS processor architecture type
# Replace 'amd64' with 'arm64' if using an Apple Silicon (M1) Mac.
export ARCH=amd64
# For latest version:
VERSION=$(curl -w '%{url_effective}' -I -L -s -S https://github.com/kubermatic/kubermatic/releases/latest -o /dev/null | sed -e 's|.*/v||')
# For specific version set it explicitly:
# VERSION=2.25.x
wget "https://github.com/kubermatic/kubermatic/releases/download/v${VERSION}/kubermatic-ce-v${VERSION}-darwin-${ARCH}.tar.gz"
tar -xzvf "kubermatic-ce-v${VERSION}-darwin-${ARCH}.tar.gz"
```
{{% /tab %}}
{{< /tabs >}}

### Install the Master/Seed MLA stack

As with KKP itself, it's recommended to use a single `values.yaml` to configure all Helm charts. There are a few important options you might want to override for your setup:

* `prometheus.host` is used for the external URL in Prometheus, e.g. `prometheus.kkp.example.com`.
* `alertmanager.host` is used for the external URL in Alertmanager, e.g. `alertmanager.kkp.example.com`.
* `prometheus.storageSize` (default: `100Gi`) controls the volume size for each Prometheus replica; this should be large enough to hold all data as per your retention time (see next option). Long-term storage for Prometheus blocks is provided by Thanos, an optional extension to the Prometheus chart.
* `prometheus.tsdb.retentionTime` (default: `15d`) controls how long metrics are stored in Prometheus before they are deleted. Larger retention times require more disk space. Long-term storage is accomplished by Thanos, so the retention time for Prometheus itself should not be set to extremely large values (like multiple months).
* `prometheus.ruleFiles` is a list of Prometheus alerting rule files to load. Depending on whether or not the target cluster is a master or seed, the `/etc/prometheus/rules/kubermatic-master-*.yaml` entry should be removed in order to not trigger bogus alerts.
* `prometheus.blackboxExporter.enabled` is used to enable integration between Prometheus and Blackbox Exporter, used for monitoring of API endpoints of user clusters created on the seed. `prometheus.blackboxExporter.url` should be adjusted accordingly (default value would be `blackbox-exporter:9115`)
* `grafana.user` and `grafana.password` should be set with custom values if no identity-aware proxy is configured. In this case, `grafana.provisioning.configuration.disable_login_form` should be set to `false` so that a manual login is possible.
* `loki.persistence.size` (default: `10Gi`) controls the volume size for the Loki pods.
* `promtail.scrapeConfigs` controls for which pods the logs are collected. The default configuration should be sufficient for most cases, but adjustment can be made.
* `promtail.tolerations` might need to be extended to deploy a Promtail pod on every node in the cluster. By default, master-node NoSchedule taints are ignored.

An example `values.yaml` could look like this if all options mentioned above are customized:

```yaml
prometheus:
  host: prometheus.kkp.example.com
  storageSize: '250Gi'
  tsdb:
    retentionTime: '30d'
  # only load the KKP-master alerts, as this cluster is not a shared master/seed
  ruleFiles:
  - /etc/prometheus/rules/general-*.yaml
  - /etc/prometheus/rules/kubermatic-master-*.yaml
  - /etc/prometheus/rules/managed-*.yaml

alertmanager:
  host: alertmanager.kkp.example.com

grafana:
  user: admin
  password: adm1n
  provisioning:
    configuration:
      disable_login_form: false

loki:
  persistence:
    size: '100Gi'

promtail:
  scrapeConfigs:
  - ...
```

With this file prepared, we can now install all required charts:

**Kubermatic Installer**

```bash
./kubermatic-installer deploy seed-mla --helm-values values.yaml
```

Output will be similar to this:
```bash
INFO[0000] 🚀 Initializing installer…                     edition="Community Edition" version=X.Y
INFO[0000] 🚦 Validating the provided configuration…     
INFO[0000] ✅ Provided configuration is valid.           
INFO[0000] 🚦 Validating existing installation…          
INFO[0000] ✅ Existing installation is valid.            
INFO[0000] 🛫 Deploying KKP Seed MLA Stack…              
INFO[0000]    📦 Deploying Node Exporter ...             
INFO[0006]    ✅ Success.                                
INFO[0006]    📦 Deploying Kube State Metrics…           
INFO[0022]    ✅ Success.                                
INFO[0022]    📦 Deploying Grafana…                      
INFO[0055]    ✅ Success.                                
INFO[0055]    📦 Deploying Blackbox Exporter…            
INFO[0064]    ✅ Success.                                
INFO[0064]    📦 Deploying Alert Manager…                
INFO[0074]    ✅ Success.                                
INFO[0074]    📦 Deploying Prometheus…                   
INFO[0075]    ✅ Success.                                
INFO[0075]    📦 Deploying Helm Exporter…                
INFO[0076]    ✅ Success.                                
INFO[0076]    📦 Deploying Karma…                        
INFO[0078]    ✅ Success.                                
INFO[0078]    📦 Deploying Loki…                         
INFO[0164]    ✅ Success.                                
INFO[0164]    📦 Deploying Promtail…                     
INFO[0166]    ✅ Success.                                
INFO[0166] 🛬 Installation completed successfully. Time for a break, maybe? ☺ 
```

### Going Further

- To expose Prometheus, Alertmanager and other services installed via the steps above, follow [Securing System Services]({{< relref "../../../../architecture/concept/kkp-concepts/kkp-security/securing-system-services/" >}}).
- The charts have a lot more options to tweak, like `alertmanager.config` or `karma.config` to control how and which alerts are sent where. Likewise, when your cluster grows, you most likely want to adjust the resource requirements in `prometheus.containers.prometheus.resources` and others. You can find more information on the [Monitoring, Logging & Alerting Customization]({{< relref "../customization" >}}) page.
