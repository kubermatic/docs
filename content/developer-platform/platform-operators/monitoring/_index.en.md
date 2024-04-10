+++
title = "Monitoring"
weight = 1
+++

Monitoring for KDP is currently very basic. We deploy the
[kube-prometheus-stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack)
Helm chart from the infra repository (see
[folder for deployment logic](https://github.com/kubermatic/infra/tree/main/clusters/platform/dev)),
but it basically only deploys prometheus-operator and Grafana. Default rules and dashboards are
omitted.

## Accessing Grafana

Grafana is currently not exposed. You will need to use port-forwarding to access it.

```sh
$ kubectl -n monitoring port-forward svc/prometheus-grafana 8080:80
```

Now it's accessible from [localhost:8080](http://localhost:8080). A datasource called "KDP" is added
to the list of datasources on Grafana, you want to use _that_ one.

## Dashboards

Currently, KDP ships the following dashboards:

- **KDP / System / API Server**: Basic API server metrics for kcp.
