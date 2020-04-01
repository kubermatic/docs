+++
title = "Changelog for Kubermatic 2.13"
date = 2020-01-12T00:00:00+00:00
publishDate = 2020-01-12T00:00:00+00:00
weight = 213
pre = "<b></b>"
+++

## v2.13.1

- Fixed swagger and API client for ssh key creation.
- Added Kubernetes v1.15.10, v1.16.7, v1.17.3
- AddonConfig's shortDescription field is now used in the accessible addons overview.

## v2.13.0

Supported Kubernetes versions:

- `1.15.5`
- `1.15.6`
- `1.15.7`
- `1.15.9`
- `1.16.2`
- `1.16.3`
- `1.16.4`
- `1.16.6`
- `1.17.0`
- `1.17.2`
- Openshift `v4.1.18`

#### Major Changes

- End-of-Life Kubernetes v1.14 is no longer supported.
- The `authorized_keys` files on nodes are now updated whenever the SSH keys for a cluster are changed
- Added support for custom CA for OpenID provider in Kubermatic API.
- Added user settings panel.
- Added cluster addon UI
- MachineDeployments can now be configured to enable dynamic kubelet config
- Added RBAC management functionality to UI
- Added RedHat Enterprise Linux as an OS option (#669)
- Added SUSE Linux Enterprise Server as an OS option (#659)

#### Cloud Providers

- Openstack: A bug that caused cluster reconciliation to fail if the controller crashed at the wrong time was fixed
- Openstack: New Kubernetes 1.16&#43; clusters use the external Cloud Controller Manager and CSI by default
- vSphere: Fixed a bug that resulted in a faulty cloud config when using a non-default port
- vSphere: Fixed a bug which cased custom VM folder paths not to be put in cloud-configs
- vSphere: The robustness of machine reconciliation has been improved.
- vSphere: Added support for datastore clusters (#671)
- Azure: Node sizes are displayed in size dropdown when creating/updating a node deployment
- GCP: Networks are fetched from API now

#### Bugfixes

- Fixed parsing Kibana's logs in Fluent-Bit
- Fixed master-controller failing to create project-label-synchronizer controllers.
- Fixed broken NodePort-Proxy for user clusters with LoadBalancer expose strategy.
- Fixed cluster namespaces being stuck in Terminating state when deleting a cluster.
- Fixed Seed Validation Webhook rejecting new Seeds in certain situations
- A panic that could occur on clusters that lack both credentials and a credentialsSecret was fixed.
- A bug that occasionally resulted in a `Error: no matches for kind "MachineDeployment" in version "cluster.k8s.io/v1alpha1"` visible in the UI was fixed.
- A memory leak in the port-forwarding of the Kubernetes dashboard and Openshift console endpoints was fixed
- Fixed a bug that could result in 403 errors during cluster creation when using the BringYourOwn provider
- Fixed a bug that prevented clusters in working seeds from being listed in the dashboard if any other seed was unreachable.
- Prevented removing system labels during cluster edit
- Fixed FluentbitManyRetries Prometheus alert being too sensitive to harmless backpressure.
- Fixed deleting user-selectable addons from clusters.
- Fixed node name validation while creating clusters and node deployments

#### Ui

- ACTION REQUIRED: Added logos and descriptions for the addons. In order to see the logos and descriptions addons have to be configured with AddonConfig CRDs with the same names as addons.
- ACTION REQUIRED: Added application settings view. Some of the settings were moved from config map to the `KubermaticSettings` CRD. In order to use them in the UI it is required to manually update the CRD or do it from newly added UI.
- Fixed label form validator.
- Removed `Edit Settings` option from cluster detail view and instead combine everything under `Edit Cluster`.
- Enabled edit options for kubeAdm
- Switched flag proportions to 4:3.
- Added new project view
- Added custom links to admin settings.
- Blocked option to edit cluster labels inherited from the project.
- Moved pod security policy configuration to the edit cluster dialog.
- Restyled some elements in the admin panel.
- Added separate save indicators for custom links in the admin panel.

#### Addons

- The dashboard addon was removed as it's now deployed in the seed and can be used via its proxy endpoint
- Added default namespace/cluster roles for addons
- Introduced addon configurations.
- Fixed addon config get and list endpoints.
- Added forms for addon variables.

#### Misc

- ACTION REQUIRED: Updated cert-manager to 0.12.0. This requires a full reinstall of the chart. See https://cert-manager.io/docs/installation/upgrading/upgrading-0.10-0.11/
- Updated Alertmanager to 0.20.0
- Update Kubernetes Dashboard to v2.0.0-rc3
- Updated Dex to v2.12.0
- The envoy version used by the nodeport-proxy was updated to v1.12.2
- etcd was upgraded to 3.4 for 1.17&#43; clusters
- Updated Grafana to 6.5.2
- Updated karma to 0.52
- Updated kube-state-metrics to 1.8.0
- Updated machine-controller to v1.10.0
  - Added support for EBS volume encryption (#663)
  - kubelet sets intial machine taints via --register-with-taints (#664)
  - Moved deprecated kubelet flags into config file (#667)
  - Enabled swap accounting for Ubuntu deployments (#666)
- Updated nginx-ingress-controller to v0.28.0
- Updated Minio to RELEASE.2019-10-12T01-39-57Z
- Updated Prometheus to 2.14 in Seed and User clusters
- Updated Thanos to 0.8.1
- An email-restricted Datacenter can now have multiple email domains specified.
- Add fluent-bit Grafana dashboard
- Updated Dex page styling.
- Openshift: added metrics-server
- For new clusters, the kubelet port 12050 is not exposed publicly anymore
- The cert-manager Helm chart now creates global ClusterIssuers for Let's Encrypt.
- Added migration for cluster user labels
- Fixed seed-proxy controller not working in namespaces other than `kubermatic`.
- The docker logs on the nodes now get rotated via the new `logrotate` addon
- Made node-exporter an optional addon.
- Added parent cluster readable name to default worker names.
- The QPS settings of kubeletes can now be configured per-cluster using addon Variables
- Access to Kubernetes Dashboard can be now enabled/disabled by the global settings.
- Added support for dynamic presets
- Presets can now be filtered by datacenter
- Revoking the viewer token is possible via UI now.
