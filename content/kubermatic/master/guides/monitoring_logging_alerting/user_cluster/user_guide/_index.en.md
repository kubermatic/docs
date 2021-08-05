+++
linkTitle = "User Guide"
title = "User Guide of the User Cluster MLA Stack"
date = 2020-02-14T12:07:15+02:00
weight = 10
enableToc = true
+++

This page contains a user guide for the [User Cluster MLA Stack]({{< relref "../../../../architecture/monitoring_logging_alerting/user_cluster/" >}}).

## Enabling Monitoring & Logging in a User Cluster

Once the User Cluster MLA feature is enabled in KKP, user can enable monitoring and logging for a user cluster via the KKP UI as shown below:

![MLA UI - Cluster Create](/img/kubermatic/master/monitoring/user_cluster/ui_cluster_create.png)

Users can enable monitoring and logging independently, and also can disable or enable them after the cluster is created.

## Exposing Application Metrics

User Cluster MLA stack defines some common scrape targets for Prometheus by default. On top of that, it is possible to add custom metrics scrape targets for any applications running in user clusters.

### Adding Scrape Annotations to Your Applications

In order to expose Prometheus metrics of any application, add Prometheus scraping annotations to its pod specification, for example:

```yaml
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/path: /metrics
    prometheus.io/port: "8080"
```

Those metrics will be automatically discovered by the User Cluster Prometheus and made available in the MLA Grafana UI without any further configuration. For more details, please check [Scraping Pod Metrics via Annotations](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus#scraping-pod-metrics-via-annotations) documentation.

## Accessing Metrics & Logs in Grafana

Once monitoring and/or logging are enabled for a user cluster, users can access the Grafana UI to see metrics and logs of this user cluster.

### Switching between Grafana Organizations

Every KKP Project is mapped to a Grafana Organization with name of `<project-name>- <project-id>` respectively, and if users want to access metrics and logs of different user clusters which belong to different KKP Projects, they can navigate between different Grafana Organizations as shown below (in the bottom left corner of Grafana UI, navigate to your profile icon - > Current Org. -> Switch):

![Grafana UI - Organizations](/img/kubermatic/master/monitoring/user_cluster/ui_grafana_orgs.png)

![Grafana UI - Organizations](/img/kubermatic/master/monitoring/user_cluster/ui_grafana_orgs2.png)

User’s permission in Grafana Organization is tied to the role in the KKP Project. The table below demonstrates the mapping between KKP role and Grafana Organization role:

| KKP Role        | Grafana Organization Role |
| --------------- | ------------------------- |
| Project Owner   | Organization Editor       |
| Project Editor  | Organization Editor       |
| Project Viewer  | Organization Viewer       |

For more details about what a user is allowed to do in Grafana Organization, please check the [Grafana Organization role documentation](https://grafana.com/docs/grafana/latest/permissions/organization_roles/).

### Grafana Datasources of User Clusters

For every user cluster with MLA enabled, corresponding Grafana Datasources will be automatically created within the Grafana Organization:

- A Datasource with the name `Loki <cluster-name>` is created for accessing logs data if User Cluster Logging is enabled.
- A Datasource with the name `Prometheus <cluster-name>` is created for accessing metrics data if User Cluster Monitoring is enabled.

![Grafana UI - Datasources](/img/kubermatic/master/monitoring/user_cluster/ui_grafana_datasources.png)

### Grafana Dashboards

There are some pre-installed Grafana Dashboards which can be found in Grafana UI under Dashboards -> Manage:

![Grafana UI - Dashboards](/img/kubermatic/master/monitoring/user_cluster/ui_grafana_dashboards.png)

KKP administrators can configure the set of Dashboards deployed for each user cluster - see the Manage Grafana Dashboard section of the Admin guide.

Users can also add their own custom Dashboards for more data visualization via Grafana UI, please check [Grafana Dashboards documentation](https://grafana.com/docs/grafana/latest/dashboards/) for more details. Please note that these will be deleted if the Grafana Organization is deleted, or if Grafana persistent volume is deleted.

## Alertmanager

KKP provides API and UI to allow users to configure Alertmanager on a per user cluster basis. A “User Cluster Alertmanager” tab will be visible if monitoring or logging is enabled for the user cluster:

![KKP UI - Alertmanager](/img/kubermatic/master/monitoring/user_cluster/ui_alertmanager.png)

There will be a default Alertmanager configuration which is created by KKP, and users can click “Open Alertmanager UI” to navigate to the Alertmanager UI.

Users can configure Alertmanager configuration with customized receivers and templates, as shown below. For details, please check the [Cortex Alertmanager example](https://cortexmetrics.io/docs/api/#example-request-body) and [Prometheus Alertmanager Configuration](https://prometheus.io/docs/alerting/latest/configuration/) documentation.

## Recording Rules & Alerting Rules

KKP User Cluster MLA supports Prometheus-compatible rules for metrics and logs. The table on the “User Cluster Prometheus Rules” tab can be used to manage both recording rules and alerting rules:

![KKP UI - Alerting Rules](/img/kubermatic/master/monitoring/user_cluster/ui_alert_rules.png)

It supports rules for both metrics and logs. For adding a new rule group, click on the “+ Add Rule Group” button, select the rule type and fill the “Data” input with rule group in YAML format:

![KKP UI - Alerting Rules Data](/img/kubermatic/master/monitoring/user_cluster/ui_alert_rules_data.png)

For more information about Prometheus rules, please check [Prometheus Recording Rules](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/) and [Prometheus Alerting Rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/).
