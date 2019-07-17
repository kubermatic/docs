+++
title = "Changelog for Kubermatic 2.11"
date = 2019-07-12T00:07:15+02:00
publishDate = 2019-07-12T00:00:00+00:00
weight = 20
pre = "<b></b>"
+++

## v2.11.0

Supported Kubernetes versions:

- `1.11.5-10`
- `1.12.3-10`
- `1.13.0-5`
- `1.13.7`
- `1.14.0-1`
- `1.14.3-4`
- `1.15.0`


**Cloud providers:**

- It is now possible to create Kubermatic-managed clusters on Packet.
- It is now possible to create Kubermatic-managed clusters on GCP.
- the API stops creating an initial node deployment for new cluster for KubeAdm providers.
- Openstack: datacenter can be configured with minimum required CPU and memory for nodes
- vsphere: root disk size is now configurable
- Azure: fixed failure to provision on new regions due to lower number of fault domains


**Monitoring:**

- [ACTION REQUIRED] refactored Alertmanager Helm chart for master-cluster monitoring, see documentation for migration notes 
- cAdvisor metrics are now being scraped for user clusters
- fixed kube-state-metrics in user-clusters not being scraped
- Improved debugging of resource leftovers through new etcd Object Count dashboard
- New Grafana dashboards for monitoring Elasticsearch
- Added optional Thanos integration to Prometheus for better long-term metrics storage


**Misc:**

- [ACTION REQUIRED] nodePortPoxy Helm values has been renamed to nodePortProxy, old root key is now deprecated; please update your Helm values
- Service accounts have been implemented.
- Support for Kubernetes 1.15 was added
- More details are shown when using `kubectl get machine/machineset/machinedeployment`
- The resiliency of in-cluster DNS was greatly improved by adding the nodelocal-dns-cache addon, which runs a DNS cache on each node, avoiding the need to use NAT for DNS queries
- Added containerRuntimeVersion and kernelVersion to NodeInfo
- It is now possible to configure Kubermatic to create one service of type LoadBalancer per user cluster instead of exposing all of them via the nodeport-proxy on one central LoadBalancer service
- Pod AntiAffinity and PDBs were added to the Kubermatic control plane components,the monitoring stack and the logging stack to spread them out if possible and reduce the chance of unavailability
- Reduced API latency for loading Nodes & NodeDeployments
- replace gambol99/keycloak-proxy 2.3.0 with official keycloak-gatekeeper 6.0.1
- More additional printer columns for kubermatic crds
- Insecure Kubernetes versions v1.13.6 and v1.14.2 have been disabled.
- Kubermatic now supports running in environments where the Internet can only be accessed via a http proxy
- ICMP traffic to clusters is now always permitted to allow MTU discovery
- A bug that caused errors on very big addon manifests was fixed
- Updated Prometheus to 2.10.0
- Updated cert-manager to 0.8.0
- Updated Minio to RELEASE.2019-06-11T00-44-33Z
- Updated Grafana to 6.2.1
- Updated kube-state-metrics to 1.6.0
- Updated Dex to 2.16.0
- Updated Alertmanager to 0.17.0, deprecate version field in favor of image.tag in Helm values.yaml
- Updated `machine-controller` to `v1.4.2`.
- Updated node-exporter to 0.18.1
- Updated fluent-bit to 1.1.2
- Updated Velero to 1.0


**Dashboard:**

- The project menu has been redesigned.
- Fixed changing default OpenStack image on operating system change
- `containerRuntimeVersion` and `kernelVersion` are now displayed on NodeDeployment detail page
- Custom links can now be added to the footer.
- The OIDC provider URL is now configurable via &#34;oidc_provider_url&#34; variable.
- The application logo has been changed.
- The breadcrumbs component has been removed. The dialogs and buttons have been redesigned.
- Packet cloud provider is now supported.
- Tables have been redesigned.
- Added option to specify taints when creating/updating NodeDeployments
- Styling of the cluster details view has been improved.
- Missing parameters for OIDC providers have been added.
- Dates are now displayed using relative format, i.e. 3 days ago.
- Redesigned dialogs and cluster details page.
- Add provider GCP to UI
- Redesigned notifications.
- The Instance Profile Name for AWS could be specified in UI.
- Redesigned node deployment view.
- Redesigned cluster details page.
