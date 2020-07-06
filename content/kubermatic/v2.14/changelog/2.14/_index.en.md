+++
title = "Changelog for Kubermatic 2.14"
date = 2020-06-12T00:00:00+00:00
publishDate = 2020-06-12T00:00:00+00:00
weight = 214

+++

## v2.14.1

- Added missing Flatcar Linux handling in API.
- Fixed nodes sometimes not having the correct distribution label applied.
- Fixed missing Kubermatic Prometheus metrics.

## v2.14.0

Supported Kubernetes versions:

- `1.15.5`
- `1.15.6`
- `1.15.7`
- `1.15.9`
- `1.15.10`
- `1.15.11`
- `1.16.2`
- `1.16.3`
- `1.16.4`
- `1.16.6`
- `1.16.7`
- `1.16.9`
- `1.17.0`
- `1.17.2`
- `1.17.3`
- `1.17.5`
- `1.18.2`

#### Misc

- ACTION REQUIRED: The most recent backup for user clusters is kept when the cluster is deleted. Adjust the cleanup-container to get the old behaviour (delete all backups) back.
- ACTION REQUIRED: Addon manifest templating is now a stable API, but different to the old implicit data. Custom addons might need to be adjusted.
- Added Flatcar Linux as an Operating System option
- Added SLES as an Operating System option
- Audit logging can now be enforced in all clusters within a Datacenter.
- Added support for Kubernetes 1.18, drop support for Kubernetes &lt; 1.15.
- Administrators can now manage all projects and clusters
- Added admission plugins CRD support
- Added configurable time window for coreos-operator node reboots
- Created an hourly schedule Velero backup for all namespaces and cluster resources
- Added support for creating RBAC bindings to group subjects
- Added a configuration flag for seed-controller-manager to enforce default addons on userclusters. Enabled by default.
- TLS certificates for Kubermatic/IAP are now not managed by a shared `certs` chart anymore, but handled individually for each Ingress.
- kubelet sets intial machine taints via --register-with-taints
- Implement the NodeCSRApprover controller for automatically approving node serving certificates
- Updated blackbox-exporter to `v0.16.0`
- Updated cert-manager to `v0.13.0`
- Updated coredns to `v1.3.1`
- Updated Dex to `v2.22.0`
- Updated Elastic Stack to `v6.8.5` and mark it as deprecated.
- Updated Envoy in nodeport-proxy to `v1.13.0`
- Updated go-swagger to support go `v1.14`
- Updated Grafana to `v6.7.1`
- Updated helm-exporter to `v0.4.3`
- Updated karma to `v0.55`
- Updated Keycloak to `v7.0.0`
- Updated Kube-state-metrics to `v1.9.5`
- Updated Loki to `v1.3.0`
- Updated machine-controller to `v1.14.1`
- Updated metrics-server to `v0.3.6`
- Updated nginx-ingress-controller to `v0.29`
- Updated openvpn to `v2.4.8`
- Updated Prometheus to `v2.17.1` on user cluster
- Updated Thanos to `v0.11.0`
- Updated Velero to `v1.3.2`

#### Dashboard

- Added a dark theme and a selector to the user settings.
- Added possibility to define a default project in user settings. When a default project is choosen, the user will be automatically redirected to this project after login. Attention: One initial log in might be needed for the feature to take effect.
- Added UI support for dynamic kubelet config option
- Added paginators to all tables
- Added cluster metrics.
- Increased cpu &amp; memory defaults on vSphere
- Custom Presets are filtered by datacenter now
- Added notification panel.
- Added Pod Node Selector field.
- Operation Systems on VSphere for which no template is specified in datacenters are now hidden.
- Fixes issue that prevented creating Addons which had no AddonConfig deployed.
- Added possibility to collapse the sidenav.
- We now use WebSocket to get global settings.
- We now use `SameSite=Lax`
- AddonConfig&#39;s shortDescription field is now used in the accessible addons overview.
- Audit Logging will be enforced when specified in the datacenter.
- Added the option to use an OIDC provider for the kubeconfig download.
- Added support for creating RBAC bindings to group subjects
- Fixed custom links display on the frontpage.
- Moved project selector to the navigation bar. Redesigned the sidebar menu.
- Fixed missing pagination issue in the project list view.
- Added possibility to specify imageID for Azure node deployments (required for RHEL).
- Added possibility to specify customImage for GCP node deployments (required for RHEL).
- Fixed user settings layout on the smaller screens.
- Fixed loading Openstack flavors in add/edit node deployment dialog
- Fixed filter in combo dropdown
- Fixed node data dialog for vSphere clusters.
- Cluster creation time is now visible in the UI.
- Added info about end-of-life of Container Linux
- Enforcing pod security policy by the datacenter is now allowed.
- Introduced a number of responsiveness fixes to improve user experience on the smaller screens.

#### Cloud providers
- Added Alibaba cloud
- Azure: Added image ID property to clusters.
- Azure: Added multiple availability zones support
- Azure: Added support for configurable OS and Data disk sizes
- Digitalocean: Fixed and issue when there are more than 200 droplets in the same account.
- GCP: Added custom image property to clusters.
- GCP: Subnetworks are now fetched from API
- Openstack: fixed a bug preventing the usage of pre-existing subnets connected to distributed routers
- vSphere: datastore clusters can now be specified for VMs instead of singular datastores
- vSphere: Added ResourcePool support

#### Monitoring
- Grafana Loki replaces the ELK logging stack.

#### Bugfixes
- Fix bad apiserver Deployments when no Dex CA was configured.
- Fixed cluster credential Secrets not being reconciled properly.
- Fixed swagger and API client for ssh key creation.
- Fixed seed-proxy controller not being triggered.
- Fixed a bug in Kubernetes 1.17 on CoreOS that prevented the Kubelet from starting
