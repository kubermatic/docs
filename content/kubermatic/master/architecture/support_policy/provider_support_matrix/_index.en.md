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
* GCP (excluding GovCloud and China Cloud)
* vSphere beginning with v6.5
* OpenStack (Releases with maintenance or extended maintenance)
* KubeVirt

**Tier 2**
* OTC (Open Telekom Cloud)
* Bare metal via KubeVirt
* Hetzner

**Tier 3**
* Alibaba Cloud
* DigitalOcean
* Equinix Metal

Please note that the vendors of the software or the cloud provider may change functions or features on their own accord. Kubermatic does not guarantee any particular compatibility with a certain feature. Tier 1 has full support of the providers capabilities (but only up to our knowledge), these providers are included in our regular end-to-end tests. Tier 2 has the support for all needed functions that are consumed, but some deeper integrations might not be available. Tier 3 means that it works for the stated releases but we do not do extensive end to end tests.

See detail pages for specific requirements of the cloud providers.

### Periodic Reconciliation of Infrastructure

Some cloud providers supported by the Kubermatic Kubernetes Platform support periodic reconciliation of cloud infrastructure resources created by KKP (for example, subnets or firewall/security group rules). KKP uses a timestamp in `LastProviderReconciliation` on the cluster status to trigger a reconciliation after the cluster was set up initially. This defaults to six hours and can be changed on a datacenter level by setting `ProviderReconciliationInterval`.

Currently, KKP periodicially reconciles the following providers:

* AWS
* Azure
