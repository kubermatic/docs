+++
title = "Creating An Application Catalogue"
date =  2022-08-03T16:27:43+02:00
weight = 1
+++

{{< toc >}}

## Introduction

This guide targets KKP Admins and details adding Applications to a catalogue, so they can be installed by Cluster Admins.
For a more details on Applications refer to our [Applications Primer](../).
Create permissions on the KKP master cluster are required to complete it.

Before an Application is available for install, its installation- and metadata need to be added to the KKP Master Cluster. From the master, they will be automatically replicated to all KKP Seed Clusters.

![Example of a populated catalogue](/img/kubermatic/common/applications/application-catalogue.png "Example of a populated catalogue")

To organize its catalogue, KKP makes use of a Custom Kubernetes Resource Type called `ApplicationDefinition`. This ensures Kubernetes-native management and full GitOps compatibility.
Additionally this mechanism can be used to ensure that only approved Applications can be deployed into a cluster.

## Creating an ApplicationDefinition

An ApplicationDefinition represents a single Application and contains all of its versions.
Each ApplicationDefinition maps to one Application in the UI.
It consists of three parts: metadata on the Application itself, templating method, and the templating source.
These will be described in more detail in the subsequent paragraphs; For a complete reference, refer to the  [ApplicationDefinition Reference](#applicationdefinition-reference) section.
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

### Application Metadata

Application Metadata is mainly used for presentation and does not affect how an application is deployed:

- `metadata.name` -> name of the application which will be displayed in the UI
- `spec.versions[].version` -> Version which is displayed in the UI; Each entry of this field must be unique. We strongly recommend to set this to the version of the Application itself not of the chart.

### Templating Method

A Templating Method describes how the Kubernetes manifests are being packaged and rendered. Currently [helm](https://helm.sh/docs/) templating is supported exclusively. Integrations with other templating engines are planned.

### Templating Source

Source of the Manifests that should be installed. This controls from where your Application manifests should be fetched. You can combine multiple sources (e.g. helm & git) within one ApplicationDefinition.
A common use-case for combining is to make stable versions (via helm) and a development version (via git) available at the same time.

#### Helm Source

The Helm Source allows downloading from a Helm [HTTP repository](https://helm.sh/docs/topics/chart_repository/) or an [OCI repository](https://helm.sh/blog/storing-charts-in-oci/#helm).
The following parameters are required:

- `url` ->  URL to a [helm chart repository](https://helm.sh/docs/topics/chart_repository/); If you are unsure about a server, you can always double check if "\<your-url\>/index.yaml" returns a valid index
- `chartName` -> Name of the chart within the repository
- `chartVersion` -> Version of the chart; corresponds to the chartVersion field

Currently the best way to obtain `chartName` and `chartVersion` for an HTTP repository is to make use of `helm search`:

```sh
# initial preparation
helm repo add <repo-name> <repo-url>
helm repo update

# listing the names of all charts in a repository
helm search repo <repo-name>

# listing versions of a chart
helm search repo <repo-name>/<chart-name> --versions

# you can also filter for versions. For example if you want to list all prometheus helm charts with a chartversion of 15 or greater, you can run
helm search repo prometheus-community/prometheus --versions --version ">=15"
```

For OCI repositories, there is currently [no helm native search](https://github.com/helm/helm/issues/9983). Instead you have to rely on the capabilities of your OCI registry (for example harbor supports searching for helm-charts directly [in their UI](https://goharbor.io/docs/2.4.0/working-with-projects/working-with-images/managing-helm-charts/#list-charts)).

For private registries, please check the [working with private registries](#working-with-private-registries) section.

#### Git Source

- `path` -> path where all manifests are stored; In case of the helm templating method, each chart should be inside its own subdirectory inside path
- `remote` -> url to the repository
- `ref`
  - `branch` -> branch from which the chart should be pulled
  - `tag` -> git tag from which the chart should be pulled; Can not be used in conjunction with commit or branch
  - `commit` -> sha of a commit from which the chart should be pulled; Must be used in conjunction with a branch to ensure shallow cloning

For private git repositories, please check the [working with private registries](#working-with-private-registries) section.

### Applying the ApplicationDefinition

After creating an ApplicationDefinition file, you can simply apply it using kubectl in the KKP master cluster. A KKP controller will afterwards ensure that your definition is synched to all KKP Seed Clusters.

```sh
# Inside KKP master
kubectl apply -f my-appdef.yml
```

## Working With Private Registries

For working with private registries, the Applications Feature supports storing credentials in Kubernetes secrets in the KKP master and referencing the secrets in your ApplicationDefinitions.
A KKP controller will ensure that the required secrets are synched to your seed clusters. In order for the controller to sync your secrets, they must be annotated with `apps.kubermatic.k8c.io/secret-type` and be created in the namespace that KKP is installed in (unless changed, this defaults to "kubermatic").

### Helm OCI Registries

[Helm OCI registries](https://helm.sh/docs/topics/registries/#enabling-oci-support) are being accessed by using a json configuration similar to the `~/.docker/config.json` on the local machine. It should be noted, that all oci server urls need to be prefixed with `oci://`.

1. Create a secret containing our credentials

```sh
# inside KKP master
kubectl create secret -n <kkp-install-namespace> docker-registry <secret-name> --docker-server=<server> --docker-username=<user> --docker-password=<password>
kubectl annotate secret <secret-name> apps.kubermatic.k8c.io/secret-type="helm"

# example
kubectl create secret -n kubermatic docker-registry oci-cred --docker-server=harbor.example.com/my-project --docker-username=someuser --docker-password=somepaswword
kubectl annotate secret oci-cred apps.kubermatic.k8c.io/secret-type="helm"
```

2. Reference the secret in the ApplicationDefinition

```yaml
spec:
  versions:
    - template:
        source:
          helm:
            chartName: examplechart
            chartVersion: 0.1.0
            credentials:
              registryConfigFile:
                key: .dockerconfigjson # `kubectl create secret docker-registry` stores by default the creds under this key
                name: <secret-name>
            url: <server>
```

### Helm Userpass Registries

To use KKP Applications with a helm [userpass auth](https://helm.sh/docs/topics/registries/#auth) registry, you can configure the following:

1. Create a secret containing our credentials

```sh
# inside KKP master
kubectl create secret -n <kkp-install-namespace> generic <secret-name> --from-literal=pass=<password> --from-literal=user=<username>
kubectl annotate secret <secret-name> apps.kubermatic.k8c.io/secret-type="helm"
```

2. Reference the secret in the ApplicationDefinition

```yaml
spec:
  versions:
    - template:
        source:
          helm:
            chartName: examplechart
            chartVersion: 0.1.0
            credentials:
              password:
                key: pass
                name: <secret-name>
              username:
                key: user
                name: <secret-name>
            url: <server>
```

### Git Repositories

KKP supports three types of authentication for git repositories: Userpass, Token, and SSH-Key.
Their setup is comparable:

1. Create a secret containing our credentials

```sh
# inside KKP master

# user-pass
kubectl create secret -n <kkp-install-namespace> generic <secret-name> --from-literal=pass=<password> --from-literal=user=<username>

# token
kubectl create secret -n <kkp-install-namespace> generic <secret-name> --from-literal=token=<token>

# ssh-key
kubectl create secret -n <kkp-install-namespace> generic <secret-name> --from-literal=sshKey=<private-ssh-key>

# after creation, annotate
kubectl annotate secret <secret-name> apps.kubermatic.k8c.io/secret-type="git"
```

2. Reference the secret in the ApplicationDefinition

```yaml
spec:
  versions:
    - template:
        source:
          git:
            path: <path-inside-git-repo>
            ref:
              branch: <branch>
            remote: <server-url> # for ssh-key, an ssh url must be chosen (e.g. git@example.com/repo.git)
            credentials:
              method: <password || token || ssh-key>
              # user-pass
              username:
                key: user
                name: <secret-name>
              password:
                key: pass
                name: <secret-name>
              # token
              token:
                key: token
                name: <secret-name>
              # ssh-key
              sshKey:
                key: sshKey
                name: <secret-name>
```

## ApplicationDefinition Reference
**The following is an example of ApplicationDefinition, showing all the possible options**.

```yaml
{{< readfile "kubermatic/master/data/applicationDefinition.yaml" >}}
```
