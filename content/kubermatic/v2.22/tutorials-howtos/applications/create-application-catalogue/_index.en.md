+++
title = "Creating An Application Catalogue"
date =  2022-08-03T16:27:43+02:00
weight = 1
+++

This guide targets KKP Admins and details adding Applications to a catalogue, so they can be installed by Cluster Admins.
Create permissions on the KKP master cluster are required to complete it.

Before an Application is available for install, its installation- and metadata need to be added to the KKP Master Cluster. From the master, they will be automatically replicated to all KKP Seed Clusters.

![Example of a populated catalogue](/img/kubermatic/common/applications/application-catalogue.png "Example of a populated catalogue")

To organize its catalogue, KKP makes use of a Custom Kubernetes Resource Type called `ApplicationDefinition`. This ensures Kubernetes-native management and full GitOps compatibility.
Additionally this mechanism can be used to ensure that only approved Applications can be deployed into a cluster.

## Creating an ApplicationDefinition

An ApplicationDefinition represents a single Application and contains all of its versions.
Each ApplicationDefinition maps to one Application in the UI.
Currently ApplicationDefinitions need to be created by hand, but we plan to include a UI importer in an upcoming release.

```yaml
# Example of an ApplicationDefinition
apiVersion: apps.kubermatic.k8c.io/v1
kind: ApplicationDefinition
metadata:
  name: prometheus
spec:
  description: Prometheus is a monitoring system and time series database.
  method: helm
  versions:
  - template:
      source:
        helm:
          chartName: prometheus
          chartVersion: 15.10.4
          url: https://prometheus-community.github.io/helm-charts
    version: 2.36.2
  - template:
      source:
        git:
          path: charts/prometheus
          ref:
            branch: master
          remote: https://github.com/prometheus-community/helm-charts
    version: 0.0.0-dev
```

The example defines the application `prometheus` with two versions. To learn more about the ApplicationDefinition's configuration please refer to the [ApplicationDefinition Reference]({{< ref "../../../architecture/concept/kkp-concepts/applications/application-definition" >}})

### Applying the ApplicationDefinition

After creating an ApplicationDefinition file, you can simply apply it using kubectl in the KKP master cluster.

```sh
# Inside KKP master
kubectl apply -f my-appdef.yml
```

A KKP controller will afterwards ensure that your definition is synced to all KKP Seed Clusters. The application automatically be available ont the dashboard.

## Edit Application Catalogue

Please refer to [Add or Remove an  Application Version]({{< ref "../add-remove-application-version/" >}})
