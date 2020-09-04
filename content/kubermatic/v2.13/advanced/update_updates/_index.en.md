+++
title = "Update Kubernetes Upgrade Plan"
date = 2019-07-08T11:00:00+02:00
weight = 6

+++

### Update Kubernetes Upgrade Plan

Kubermatic Kubernetes Platform(KKP) provides [live updates of your Kubernetes cluster](operation/control-plane/upgrading/#upgrading-the-control-plane)
without disrupting your daily business. The allowed updates are defined in the file
`updates.yaml`. You find it in your KKP installer clone directory:

```bash
git clone git@github.com:kubermatic/kubermatic-installer.git
cd kubermatic-installer/
ls charts/kubermatic/static/master/
```

The file contains the supported upgrade paths for Kubernetes. The file format is
[YAML](https://yaml.org).

```yaml
updates:
# ======= 1.12 =======
# Allow to change to any patch version
- from: 1.12.*
  to: 1.12.*
  automatic: false
# CVE-2018-1002105
- from: <= 1.12.2, >= 1.12.0
  to: 1.12.3
  automatic: true
# Allow to next minor release
- from: 1.12.*
  to: 1.13.*
  automatic: false

# ======= 1.13 =======
# Allow to change to any patch version
- from: 1.13.*
  to: 1.13.*
  automatic: false
# Allow to next minor release
- from: 1.13.*
  to: 1.14.*
  automatic: false

# ======= 1.14 =======
# Allow to change to any patch version
- from: 1.14.*
  to: 1.14.*
  automatic: false
# Allow to next minor release
- from: 1.14.*
  to: 1.15.*
  automatic: false
```

As you can see it is a list containing the keys `from`, `to`, and `automatic`. The fields
`from` and `to` contain patterns describing the Kubernetes version numbers. These can be absolute,
contain wildcards, or be ranges. This way KKP can check which updates are allowed for
the current version.

The field `automatic` determines if an update has to be initiated manually or if the system will
do it immediately in case of a matching version path. So in case of the example above a cluster
running in any Kubernetes version from 1.12.0 to 1.12.2 would automatically upgrade to 1.12.3.
This way known vulnerabilities can be handled directly.

{{% notice note %}}
**Note:** The automatic update only updates the control plane. kubelets on the nodes still have
to be updated manually.
{{% /notice %}}

After editing the list KKP has to be upgraded by using `helm`.

```bash
cd kubermatic-installer/charts/kubermatic
vim static/master/updates.yaml
helm upgrade kubermatic .
```

Afterwards the new update paths are available.
