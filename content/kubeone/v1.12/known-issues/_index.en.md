+++
title = "Known Issues"
date = 2026-01-06T12:00:00+02:00
description = "Known Issues in Kubermatic KubeOne"
weight = 99
+++

This page documents the list of known issues in Kubermatic KubeOne along with possible workarounds and recommendations.

This list applies to KubeOne 1.12 release ONLY.

For KubeOne 1.11 see [Known Issues of v1.11][known-issues-1.11]. For changelog of 1.11 release, please consult the
[appropriate changelog][changelogs-1.11].

## Provider issues

`rocky-9` image on Hetzner doesn't work as of time of the release, since it only has IPv6 NS servers configured,
regardless of the stack.

[known-issues-1.11]: {{< ref "../../v1.11/known-issues" >}}
[changelogs-1.11]: https://github.com/kubermatic/kubeone/blob/main/CHANGELOG/CHANGELOG-1.11.md
