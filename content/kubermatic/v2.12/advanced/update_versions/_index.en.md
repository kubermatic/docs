+++
title = "Update List of Selectable Kubernetes Versions"
date = 2019-07-05T10:45:00+02:00
weight = 6

+++

### Update List of Selectable Kubernetes Versions

The list of selectable versions when [specifying cluster name and Kubernetes version](../../getting_started/create_cluster/#step-2-specify-the-cluster-name-and-kubernetes-version) is defined in the file
`versions.yaml`. You'll find it in your KKP Kubernetes Platform(KKP) installer clone directory:

```bash
git clone git@github.com:kubermatic/kubermatic-installer.git
cd kubermatic-installer/
ls charts/kubermatic/static/master/
```

Inside the versions file the supported releases of Kubernetes as well as the selection of the default
one are defined. The file format is [YAML](https://yaml.org).

```yaml
versions:
# Kubernetes 1.14
- version: "v1.14.0"
  default: false
- version: "v1.14.1"
  default: false
# Insecure https://github.com/kubernetes/kubernetes/issues/78308
#- version: "v1.14.2"
#  default: false
- version: "v1.14.3"
  default: true
# Kubernetes 1.15
- version: "v1.15.0"
  default: false
```

As you can see it is a list containing the two keys `version` and `default`. Here the values of
`version` are the Kubernetes versions as string and prefixed by the letter "v". They correspondent
with the tags of the according versions of the Kubernetes repository. The possible values of `default`
are *true* or *false*, where only one of the versions can be marked as default.

We also list insecure versions, but they are commented out and contain a link to the according issue.
So they aren't listed in the selection dialog and you can see why.

{{% notice note %}}
**Note:** Try to keep this tradition when you're adding new Kubernetes releases to the list. This
way potential later addings don't add missing releases *by accident*.
{{% /notice %}}

As *default version* we normally choose the latest patch of the predecessor subversion. While you
manually still can select any other supported release KKP will recommend this way the most
mature version to you.

After editing the list KKP has to be upgraded by using `helm`.

```bash
cd kubermatic-installer/charts/kubermatic
vim static/master/versions.yaml
helm upgrade kubermatic .
```

Afterwards the new version settings are available.
