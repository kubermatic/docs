+++
title = "Setting up Alertmanager with Slack Notifications"
date = 2021-08-06T11:58:00+02:00
weight = 3
+++

This tutorial will show you how to set up Alertmanager in KKP User Cluster MLA and receive alert notifications in your Slack workspace.

{{< table_of_contents >}}

## Setting up Slack Incoming Webhooks

If you want to receive alert notifications via Slack, you need to be in a Slack workspace, if you are not in any Slack 
workspace, please create one Slack workspace [here](https://slack.com/create).

You will need a Slack Webhook URL in order to receive alerting notifications. Please go to **Slack** -> 
**Administration** -> **Manage apps** as shown below:

![Slack Workspace](/img/kubermatic/v2.18/monitoring/user_cluster/slack_dashboard.png?height=500px&classes=shadow,border, "Slack Workspace")

In the **Manage apps** directory, search for **Incoming Webhooks** and add it to your Slack workspace as shown below:

![Slack Manage Apps](/img/kubermatic/v2.18/monitoring/user_cluster/slack_incoming_webhook.png?height=400px&classes=shadow,border, "Slack Manage Apps")

After you click the **Add to Slack** button as shown above, you will be directed to the configuration page. 
Please select the channel that you would like to receive notifications from Alertmanager, in this example, we will use 
a channel called "#test-alerts":

![Slack Config Channel](/img/kubermatic/v2.18/monitoring/user_cluster/slack_config_channel.png?height=700px&classes=shadow,border, "Slack Channel Config")

Then click the **Add Incoming WebHooks integration** button, and the Slack Webhook URL will be generated and displayed 
in the **Setup Instructions** page as shown below:

![Slack Webhook URL](/img/kubermatic/v2.18/monitoring/user_cluster/slack_webhook_url.png?height=350px&classes=shadow,border, "Slack Setup Instructions")

Make sure to copy that, and it will be used in the next step where we will configure Alertmanager.

## Configuring Alertmanager in User Cluster MLA

After Slack Incoming Webhook is enabled, you will need to configure Alertmanager to send alerts to Slack for your KKP user cluster.

Make sure that your cluster has User Cluster Logging and User Cluster Monitoring enabled (If you don’t know how to 
do that, please refer to [Enabling Monitoring & Logging in User Cluster]({{< relref "../user_guide/#enabling-monitoring--logging-in-a-user-cluster" >}})  
for more details). Go to the cluster details page, and click the **Monitoring, Logging & Alerting** tab to add the following configuration:

```yaml
template_files: {}
alertmanager_config: |
  global:
    resolve_timeout: 5m
    slack_api_url: '<YOUR SLACK WEBHOOK URL>'

  route:
    receiver: 'slack-notifications'
    repeat_interval: 1s

  receivers:
  - name: 'slack-notifications'
    slack_configs:
    - channel: '#test-alerts'
      send_resolved: true
      title: "{{ range .Alerts }}{{ .Annotations.summary }}\n{{ end }}"
      text: "{{ range .Alerts }}{{ .Annotations.description }}\n{{ end }}"
```
Don’t forget to add the Slack Webhook URL that you have generated in the previous setup to `slack_api_url`, 
change the slack channel under `slack_configs` to the channel that you are going to use and save it by clicking **Edit** button: 

![Slack Alertmanager Config](/img/kubermatic/v2.18/monitoring/user_cluster/slack_alertmanager_config.png?height=700px&classes=shadow,border, "Alertmanager Configuration")

Wait until the configuration takes effect. It can be verified in Alertmanager UI: Click **Open Alertmanager UI** in the
**Monitoring, Logging & Alerting** tab, in the UI, go to **Status** page and check if the config is applied in the **Config** section as shown in below screenshot:

![Alertmanager Status](/img/kubermatic/v2.18/monitoring/user_cluster/alertmanager_status.png?height=800px&classes=shadow,border, "Alertmanager Status")

If the configuration is applied to Alertmanager, it is ready to send notifications to Slack. In the next step, we will
create some alerting rules to generate alerts from metrics and logs.

## Creating Alerting Rules

Let’s create two Alerting Rule Groups to generate alerts from metrics and logs. Go to the **Monitoring, Logging & Alerting** tab,
and click **+ Add Rule Group**, and add the following rule group with type `Metric` in order to generate alerts from metrics:

```yaml
name: instance-is-down
rules:
- alert: InstanceDown
  expr: up == 0
  for: 1m
  annotations:
    title: 'Instance {{ $labels.instance }} down'
    summary: '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minute.'
  labels:
    severity: 'critical'
```

![Metrics Rule Group](/img/kubermatic/v2.18/monitoring/user_cluster/create_metrics_alert_rule.png?height=700px&classes=shadow,border, "Creating Rule Group with type Metrics")

Add another one with type `Logs` to generate alerts for logs:

```yaml
name: high-throughput-log-streams
rules:
- alert: HighThroughputLogStreams
  expr: sum by(container)(rate({job=~"kube-system/.*"}[1m])) >= 50
  for: 1m
  labels:
    severity: critical
  annotations:
    title: "log stream is high"
    summary: "log stream is high"
```

![Logs Rule Group](/img/kubermatic/v2.18/monitoring/user_cluster/create_logs_alert_rule.png?height=700px&classes=shadow,border, "Creating Rule Group with type Logs")

After those Rule Groups are created, you will be able to to receive alert notifications in your Slack channel like the following:

![Slack Alerts](/img/kubermatic/v2.18/monitoring/user_cluster/slack_alerts.png?height=300px&classes=shadow,border, "Slack Alert Notifications")

That’s it! If you want to configure Alertmanager with more alerts receivers, please check [Prometheus Alertmanager Configuration](https://prometheus.io/docs/alerting/latest/configuration/),
and if you want to create more useful alerting rules, please check [KKP User Cluster MLA Alerting & Recording Rules]({{< relref "../user_guide/#recording-rules--alerting-rules" >}}), [Prometheus Alerting Rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)
and [Awesome Prometheus Alerts](https://awesome-prometheus-alerts.grep.to/).
