+++
title = "Application Definition"
date = 2023-01-27T14:07:15+02:00
weight = 1

+++

An `ApplicationDefinition` represents a single Application and contains all its versions. It holds the necessary information to install an application.
Two types of information are required to install an application:
* How to download the application's source (i.e Kubernetes manifest, helm chart...). We refer to this as `source`.
* How to render (i.e. templating) the application's source to install it into user-cluster. We refer to this as`templating method`.

Each version can have a different `source` (`.spec.version[].template.source`) but share the same `templating method` (`.spec.method`).  
Here is the minimal example of `ApplicationDefinition`. More advanced configurations are described in subsequent paragraphs.

```yaml
apiVersion: apps.kubermatic.k8c.io/v1
kind: ApplicationDefinition
metadata:
  name: apache
spec:
  description: Apache HTTP Server is an open-source HTTP server for modern operating systems
  method: helm
  versions:
    - template:
        source:
          helm:
            chartName: apache
            chartVersion: 9.2.9
            url: https://charts.bitnami.com/bitnami
      version: 9.2.9
    - template:
        source:
          git:
            path: bitnami/apache
            ref:
              branch: main
            remote: https://github.com/bitnami/charts.git
      version: 2.4.55-git
```

In this example, the `ApplicationDefinition` allows the installation of two versions of apache using the [helm method](#helm-method). Notice that one source originates from a [Helm repository](#helm-source) and the other from a [git repository](#git-source)

## Templating Method
Templating Method describes how the Kubernetes manifests are being packaged and rendered.

### Helm Method
This method use [Helm](https://helm.sh/docs/) to install, upgrade and uninstall the application into the user-cluster.

## Templating Source
### Helm Source
The Helm Source allows downloading the application's source from a Helm [HTTP repository](https://helm.sh/docs/topics/chart_repository/) or an [OCI repository](https://helm.sh/blog/storing-charts-in-oci/#helm).
The following parameters are required:

- `url` ->  URL to a [helm chart repository](https://helm.sh/docs/topics/chart_repository/); If you are unsure about a server, you can always double-check if "\<your-url\>/index.yaml" returns a valid index
- `chartName` -> Name of the chart within the repository
- `chartVersion` -> Version of the chart; corresponds to the chartVersion field


**Example of Helm source with HTTP repository:**
```yaml
- template:
    source:
      helm:
        chartName: prometheus
        chartVersion: 15.10.4
        url: https://prometheus-community.github.io/helm-charts
```

**Example of Helm source with OCI repository:**
```yaml
- template:
    source:
      helm:
        chartName: cilium
        chartVersion: 1.13.0-rc5
        url: oci://quay.io/kubermatic/helm-charts
```
For private git repositories, please check the [working with private registries](#working-with-private-registries) section.

Currently, the best way to obtain `chartName` and `chartVersion` for an HTTP repository is to make use of `helm search`:

```sh
# initial preparation
helm repo add <repo-name> <repo-url>
helm repo update

# listing the names of all charts in a repository
helm search repo <repo-name>

# listing versions of a chart
helm search repo <repo-name>/<chart-name> --versions

# you can also filter for versions. For example, if you want to list all Prometheus helm charts with a chart version of 15 or greater, you can run
helm search repo prometheus-community/prometheus --versions --version ">=15"
```

For OCI repositories, there is currently [no native helm search](https://github.com/helm/helm/issues/9983). Instead, you have to rely on the capabilities of your OCI registry. For example, harbor supports searching for helm-charts directly [in their UI](https://goharbor.io/docs/2.4.0/working-with-projects/working-with-images/managing-helm-charts/#list-charts).

### Git Source
The Git source allows you to download the application's source from a Git repository.

**Example of Git Source:**
```yaml
- template:
    source:
      git:
      path: bitnami/apache
      ref:
        branch: main
      remote: https://github.com/bitnami/charts.git
```

- `path` -> path where all manifests are stored; In case of the helm templating method, each chart should be inside its own subdirectory inside path
- `remote` -> url to the repository
- `ref`
    - `branch` -> branch from which the chart should be pulled
    - `tag` -> git tag from which the chart should be pulled; Can not be used in conjunction with commit or branch
    - `commit` -> sha of a commit from which the chart should be pulled; Must be used in conjunction with a branch to ensure shallow cloning

For private git repositories, please check the [working with private registries](#working-with-private-registries) section.


## Working With Private Registries

For private registries, the Applications Feature supports storing credentials in Kubernetes secrets in the KKP master and referencing the secrets in your ApplicationDefinitions.
A KKP controller will ensure that the required secrets are synced to your seed clusters. 

{{% notice note %}}
In order for the controller to sync your secrets, they must be annotated with `apps.kubermatic.k8c.io/secret-type` and be created in the namespace that KKP is installed in (unless changed, this defaults to `kubermatic`).
{{% /notice %}}

### Git Repositories

KKP supports three types of authentication for git repositories: Userpass, Token, and SSH-Key.
Their setup is comparable:

1. Create a secret containing our credentials

```sh
# inside KKP master

# user-pass
kubectl create secret -n <kkp-install-namespace> generic --from-literal=pass=<password> --from-literal=user=<username> <secret-name>

# token
kubectl create secret -n <kkp-install-namespace> generic --from-literal=token=<token> <secret-name>

# ssh-key
kubectl create secret -n <kkp-install-namespace> generic --from-literal=sshKey=<private-ssh-key> <secret-name>

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

### Helm OCI Registries

[Helm OCI registries](https://helm.sh/docs/topics/registries/#enabling-oci-support) are being accessed using a JSON configuration similar to the `~/.docker/config.json` on the local machine. It should be noted, that all OCI server urls need to be prefixed with `oci://`.

1. Create a secret containing our credentials

```sh
# inside KKP master
kubectl create secret -n <kkp-install-namespace> docker-registry  --docker-server=<server> --docker-username=<user> --docker-password=<password> <secret-name>
kubectl annotate secret <secret-name> apps.kubermatic.k8c.io/secret-type="helm"

# example
kubectl create secret -n kubermatic docker-registry --docker-server=harbor.example.com/my-project --docker-username=someuser --docker-password=somepaswword oci-cred
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
kubectl create secret -n <kkp-install-namespace> generic --from-literal=pass=<password> --from-literal=user=<username> <secret-name>
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

### Templating Credentials
There is a particular case where credentials may be needed at the templating stage to render the manifests. For example, if the template method is `helm` and the source is git. To install the chart into the user cluster, we have to build the chart dependencies.
These dependencies may be hosted on a private registry requiring authentication.

You can specify the templating credentials by settings `.spec.version[].template.templateCredentials`. It works the same way as source credentials.

**Example of template credentials:**
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
        templateCredentials:
          helm: # this the same struct as .spec.versions[].template.source.helm.credentials
            password:
              key: pass
              name: <secret-name>
            username:
              key: user
              name: <secret-name>
```

## Advanced Configuration
### Default Values
The `.spec.defaultValues` describe overrides for manifest-rendering in UI when creating an application. (e.g. if the method is Helm, then this field contains the Helm values.).

### Customize Deployment
You can tune how the application will be installed by setting `.spec.defaultDeployOptions`.
The options depend on the template method (i.e. `.spec.method`).

*note: `defaultDeployOptions` can be overridden at `ApplicationInstallation` level by settings `.spec.deployOptions`*

#### Customize Deployment For Helm Method
You may tune how Helm deploys the application with the following options:

* `atomic`: corresponds to the `--atomic` flag on Helm CLI. If set, the installation process deletes the installation on failure; the upgrade process rolls back changes made in case of failed upgrade.
* `wait`: corresponds to the `--wait` flag on Helm CLI. If set, will wait until all Pods, PVCs, Services, and minimum number of Pods of a Deployment, StatefulSet, or ReplicaSet are in a ready state before marking the release as successful. It will wait for as long as `--timeout`
* `timeout`: corresponds to the `--timeout` flag on Helm CLI. It's time to wait for any individual Kubernetes operation.

Example:
```yaml
apiVersion: apps.kubermatic.k8c.io/v1
kind: ApplicationDefinition
metadata:
  name: apache
spec:
  defaultDeployOptions:
    helm:
      atomic: true
      wait: true
      timeout: "5m"
```

*note: if `atomic` is true, then wait must be true. If `wait` is true then `timeout` must be defined.*


## ApplicationDefinition Reference
**The following is an example of ApplicationDefinition, showing all the possible options**.

```yaml
{{< readfile "kubermatic/main/data/applicationDefinition.yaml" >}}
```
