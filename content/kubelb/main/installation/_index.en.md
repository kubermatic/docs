+++
title = "Installation"
date = 2026-07-29T00:00:00+02:00
description = "Install KubeLB on the management cluster and connect tenant clusters, with paths for standard, air-gapped, and KKP-integrated setups."
weight = 15
+++

Pick the path that matches your environment. For a standard installation, set up the management cluster first, then register each tenant cluster. For environments without internet access, follow the [air-gapped installation]({{< relref "./air-gap" >}}) guide, available in the Enterprise Edition. If you run Kubermatic Kubernetes Platform, use the [KKP integration]({{< relref "./kkp" >}}) to let KKP configure KubeLB for your user clusters. Read the [architecture documentation]({{< ref "../architecture/" >}}) first if you are new to KubeLB.

## Table of Contents

{{% children depth=5 %}}
{{% /children %}}
