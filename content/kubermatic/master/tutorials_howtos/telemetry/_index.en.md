+++
title = "Telemetry"
date = 2021-09-10T08:07:15+02:00
weight = 18

+++

Telemetry is an observability tool that can be used to track Kubermatic Kubernetes Platform and Kubernetes cluster usage. It collects anonymous data and helps us to improve KKP performance for large and scalable setups. The following guide explains how to enable and disable the Telemetry tool in your KKP installation, and what kind of data it collects.

Telemetry helm chart can be found in the [Kubermatic repository](https://github.com/kubermatic/kubermatic/tree/master/charts/telemetry), and since Telemetry is an open source tool, the code can be found in [Telemetry-Client repository](https://github.com/kubermatic/telemetry-client).

## Installation
### Kubermatic installer
Telemetry will be enabled by default if you use the Kubermatic installer to deploy KKP. For more information about how to use the Kubermatic installer to deploy KKP, please refer to the [installation guide]({{< relref "../../installation/" >}}).  
Kubermatic installer will use a `values.yaml` file to configure all Helm charts, including Telemetry. The following is an example of the configuration of the Telemetry tool:

```yaml
telemetry:
  uuid: <YOUR UUID>
  schedule: "0 0 * * *”
```

Telemetry uses anonymous UUIDs to identify user data, so it requires a generated UUID. You can use tools like `uuidgen` to generate the UUID.

The `schedule` is in Cron format, please check [Cron format](https://en.wikipedia.org/wiki/Cron) for more details, and it is used to configure the frequency of sending data from the Telemetry tool. If this is not configured, it will send data once per day.

Then you can use the Kubermatic installer to install KKP by using the following command:

```bash
./kubermatic-installer deploy --config kubermatic.yaml --helm-values values.yaml
```

After this command finishes, a CronJob will be created in the `telemetry-system` namespace on the master cluster. The CronJob includes the following components:
- Agents, including Kubermatic Agent and Kubernetes Agent. They will collect data based on the predefined report schema. Each agent will collect data as an initContainer and write data to local storage.
- Reporter. It will aggregate data that was collected by Agents from local storage, and send it to the public Telemetry endpoint (https://telemetry.k8c.io) based on the `schedule` you defined in the `values.yaml` (or once per day by default). 

### Helm Chart
Telemetry can also be installed by using Helm chart, which is included in the release, prepare a `values.yaml` as we mentioned in the previous section, and install it on the master cluster by using the following command:
```bash
helm --namespace telemetry-system upgrade --atomic --create-namespace --install telemetry /path/to/telemetry/chart --values values.yaml
```

## Disable Telemetry
If you don’t want to send usage data to us to improve our product, or your KKP will be running in offline mode which doesn’t have access to the public Telemetry endpoint, you can disable it by using `--disable-telemetry` flag as following:
```bash
./kubermatic-installer deploy --disable-telemetry --config kubermatic.yaml --helm-values values.yaml
```

## Data that Telemetry Collects
Telemetry tool collects the following metadata in an anonymous manner with UUIDs, the data schemas can be found in [Telemetry-Client repository](https://github.com/kubermatic/telemetry-client):
- For Kubermatic usage: [Kubermatic Record](https://github.com/kubermatic/telemetry-client/blob/release/v0.1/pkg/agent/kubermatic/v1/record.go)
- For Kubernetes usage: [Kubernetes Record](https://github.com/kubermatic/telemetry-client/blob/release/v0.1/pkg/agent/kubernetes/v1/record.go)


