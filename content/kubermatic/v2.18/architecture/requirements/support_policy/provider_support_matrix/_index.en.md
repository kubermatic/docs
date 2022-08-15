+++
title = "Cloud Provider"
date = 2018-07-04T12:07:15+02:00
weight = 20

+++

## Infrastructure Support

Kubermatic Kubernetes Platform supports a multitude of different cloud providers. In order to ensure the best integration possible Kubermatic has a tiered approach towards the providers.Currently supported are the following infrastructures and cloud providers:

**Tier 1**
* AWS (excluding AWS GovCloud and China Cloud)
* Azure (excluding GovCloud and China Cloud)
* Equinix Metal
* GCP (excluding GovCloud and China Cloud)
* vSphere beginning with v6.5
* OpenStack (Releases with maintenance or extended maintenance)
* KubeVirt (technology preview)

**Tier 2**
* OTC (Open Telekom Cloud)
* Bare metal via KubeVirt
* Hetzner

**Tier 3**
* Alibaba Cloud
* DigitalOcean

Note: KubeVirt cloud provider is under heavy development. There is no guarantee that user clusters created on the KubeVirt cloud provider will perform well after the upgrade to the newer KKP version.

Please note that the vendors of the software or the cloud provider may change functions or features on their own accord. Kubermatic does not guarantee any particular compatibility with a certain feature. Tier 1 has full support of the providers capabilities (but only up to our knowledge), these providers are included in our regular end-to-end tests. Tier 2 has the support for all needed functions that are consumed, but some deeper integrations might not be available. Tier 3 means that it works for the stated releases but we do not do extensive end to end tests.


See detail pages for specific requirements of the cloud providers.
