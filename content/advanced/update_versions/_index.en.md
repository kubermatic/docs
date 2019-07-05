+++
title = "Update list of selectable Kubernetes versions"
date = 2019-07-05T10:45:00+02:00
weight = 6
pre = "<b></b>"
+++

### Update list of selectable Kubernetes versions

The list of selectable versions when [specifying cluster name and Kubernetes version](/getting_started/create_cluster/#step-2-specify-the-cluster-name-and-kubernetes-version)
is defined in the file `versions.yaml`. You find it in your installer clone located as part of the
Kubermatic helm chart at `${KUBERMATIC_INSTALLER}/charts/kubermatic/static/master/`. 

Inside the versions file you'll find the supported releases of Kubernetes as well a flag which one
should be taken as default.

```yaml
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

As you can see insecure versions are listed too. They are commented out and contain a link to the
according issue. This way you can see why several version aren't listed in the selection dialog.

{{% notice note %}}
**Note:** Try to keep this tradition when you're adding new Kubernetes releases to the list. This
way potential later addings don't add these releases by accident.
{{% /notice %}}

As *default version* normally the latest patch of the predecessor subversion is taken. So you manually
still can select a newer release while Kubermatic recommends the most mature version.

After editing the list Kubermatic has to be upgraded using `helm`.

```bash
$ cd ${KUBERMATIC_INSTALLER}/charts/kubermatic
$ helm upgrade kubermatic .
```
