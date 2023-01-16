
+++
title = "Support Policy"
date = 2021-04-20T12:11:35+02:00
weight = 4

+++

## Supported KKP Versions

KKP versions are expressed as x.y.z, where x is the **major** version, y is the
**minor** version, and z is the **patch** version.

KKP follows the Kubernetes release model and cycle, though for practical reasons
releases are a bit delayed to ensure compatibility with Kubernetes. In general,
the latest three minor versions of KKP are supported, i.e. 2.22, 2.21 and 2.20.
With the release of a new minor KKP version, support for the oldest supported
KKP version is dropped.

## Release Cycle

New KKP [versions](https://github.com/kubermatic/kubermatic/releases) are released in
a semi-fixed cadence. Actual release dates might vary due to a lack of changes to warrant a release
or due to urgent fixes that cannot wait for the next release window. As such,
the following release rhythms are given as orientation only and do not constitute guaranteed release dates.

* Patch releases are scheduled **monthly**.
* Minor releases are scheduled **triannual**.
* Major releases have no fixed schedule and will only happen when KKP changes in a substantial way.
