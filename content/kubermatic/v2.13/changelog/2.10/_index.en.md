+++
title = "Changelog for Kubermatic 2.10"
date = 2018-10-23T12:07:15+02:00
publishDate = 2019-03-30T00:00:00+00:00
weight = 210
pre = "<b></b>"
+++

## v2.10.3

Supported Kubernetes versions:

- `1.13.10`
- `1.14.6`

**Changes:**

- Kubernetes 1.11 which is end-of-life has been removed.
- Kubernetes 1.12 which is end-of-life has been removed.
- Kubernetes versions affected by CVE-2019-11247 and CVE-2019-11249 have been dropped
- Kubernetes versions affected by CVE-2019-9512 and CVE-2019-9514 have been dropped
- Updated Envoy to 1.11.1

## v2.10.2

**Dashboard:**

- Updated Dashboard to `v1.2.2`
  - Missing parameters for OIDC providers have been added.
  - `containerRuntimeVersion` and `kernelVersion` are now displayed on NodeDeployment detail page
  - Fixed changing default OpenStack image on Operating System change
  - The OIDC provider URL is now configurable via `oidc_provider_url` variable.

**Misc:**

- Insecure Kubernetes versions v1.13.6 and v1.14.2 have been disabled.

## v2.10.1

**Bugfix:**

- A bug that caused errors on very big addon manifests was fixed
- fixed kube-state-metrics in user-clusters not being scraped
- Updated the machine-controller to fix the wrong CentOS image for AWS instances
- vSphere VMs are cleaned up on ISO failure.

**Misc:**

- updated Prometheus to `v2.9.2`
- Draining of nodes now times out after 2h
- the API stops creating an initial node deployment for new cluster for KubeAdm providers.
- More details are shown when using `kubectl get machine/machineset/machinedeployment`
- Pod AntiAffinity and PDBs were added to the Kubermatic control plane components and the monitoring stack to spread them out if possible and reduce the chance of unavailability
- Support for Kubernetes 1.11.10 was added

## v2.10.0

### Features

#### Kubermatic Core

- *ACTION REQUIRED:* Change config option `Values.kubermatic.rbac` to `Values.kubermatic.masterController`
- Add user cluster controller manager: It is deployed within the cluster namespace in the seed and takes care of reconciling all resources that are inside the user cluster
- Add feature gate to enable etcd corruption check
- Remove Kubernetes 1.10 as officially supported version from Kubermatic as it is EOL
- Add short names to the ClusterAPI CRDs to allow using `kubectl get md` for `machinedeployments`, `kubectl get ms` for `machinesets` and `kubectl get ma` to get `machines`
- Update canal to v2.6.12, Kubernetes Dashboard to v1.10.1 and replace kube-dns with CoreDNS 1.3.1
- Update Vertical Pod Autoscaler to v0.5
- Stop using the name "kubermatic" for cloud provider resources visible to end users
- Deploy the node-exporter by default as an addon into user clusters to provide Grafana dashboards for user cluster resource usage
- Make the default AMI's for AWS instances configurable via the `datacenters.yaml`
- Stop deploying Vertical Pod Autoscaler by default
- Create initial node deployments inside the same API call as the cluster to fix spurious issues where the creation didn't happen
- Create events on the object for errors when reconciling MachineDeployments and MachineSets
- Filter out not valid VM types for azure provider
- Mark cluster upgrades as restricted if kubelet version is incompatible
- Enable automatic detection of the OpenStack BlockStorage API version within the cloud config
- Add the ContainerLinuxUpdateOperator to all clusters that use ContainerLinux nodes
- Enable the configuration of trust-device-path cloud config property of Openstack clusters via `datacenters.yaml`.
- Set AntiAffinity for pods to prevent situations where the API servers of all clusters got scheduled on a single node
- Set resource requests and limits for all addons
- Add Kubernetes v1.14.1 to the list of supported versions
- Ensure reservation of a small amount of resources on each node for the kubelet and system services
- Update etcd to v3.3.12
- Update the metrics-server to v0.3.2
- Update the user cluster Prometheus to v2.9.1
- Enable the scaling of MachineDeployments and MachineSets via `kubectl scale`

### Dashboard

- Change the color scheme
- Enable the editing of the project name in UI
- Refine nodes and node deployments statuses
- Redesign DigitalOcean sizes and OpenStack flavors option pickers
- Smooth operation on bad network connection by changes in asset caching
- Add a flag allowing to change the default number of nodes created with clusters
- Allow setting of OpenStack tags for instances via UI
- Allow node deployment naming
- Enable adding multiple owners to a project via UI
- Allow specifying kubelet version for Node Deployments
- Display events related to the Nodes in the Node Deployment details view
- Show project owners in project list view
- Add possibility to assign labels to nodes
- Update AWS instance types
- Add option to include custom links into the application
- Remove AWS instance types t3.nano & t3.micro as they are too small to schedule any workload on them
- Redesign the application sidebar

#### Logging & Monitoring Stack

- Update fluent-bit to 1.0.6
- Add elasticsearch-exporter to logging stack to improve monitoring
- Create alerts for cert-manager created certificates about to expire
- Add blackbox-exporter chart
- Update Elasticsearch to 6.6.2
- Add Grafana dashboards for kubelet metrics
- Update Prometheus to 2.8.1 (Alertmanager 0.16.2) and Grafana to 6.1.3
- Allow configuration of Alertmanager PVC size
- Add lifecycle hooks to the Elasticsearch StatefulSet to make starting/stopping more graceful
- Stop logging pod annotations in Elasticsearch
- Improve Prometheus backups in high traffic environments
- Fix VolumeSnapshotLocations for Ark configuration
- Stop exposting `node-exporter` on all host interfaces
- Improve Kibana usability by auto-provisioning index patterns
- Add configurable Prometheus backup timeout to accomodate larger seed clusters

#### Other

- **ACTION REQUIRED:** update from Ark 0.10 to Velero 0.11
- Replace handwritten go tcp proxy with Envoy within the nodeport-proxy
- Update `cert-manager` to 0.7.0, Dex to 2.15.0, Minio to RELEASE.2019-04-09T01-22-30Z
- Update nginx-ingress-controller to 0.24.1
- Allow scheduling Helm charts using affinities, node selectors and tolerations for more stable clusters
- Allow defining configurable resource constraints for Helm charts
- Improve Helm charts metadata to make Helm-based workflows easier and aid in cluster updates
- Enable configuration of `dex` keys expirations in helm chart
- Update the nodeport-proxy Envoy to v1.10

### Bugfixes

- Fix invalid variable caching in Grafana dashboards
- Fix reload behaviour of OpenStack setting fields
- Fix a bug with the missing version in the footer
- Fix display number of replicas if the field is empty (0 replicas)
