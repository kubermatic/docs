+++
title = "Changelog for Kubermatic 2.10"
date = 2018-10-23T12:07:15+02:00
publishDate = 2019-03-30T00:00:00+00:00
weight = 13
pre = "<b></b>"
+++

## Features

### Kubermatic core

* *ACTION REQUIRED:* The config option `Values.kubermatic.rbac` changed to `Values.kubermatic.masterController`
* The user cluster controller manager was added. It is deployed within the cluster namespace in the seed and takes care of reconciling all resources that are inside the user cluster
* Add feature gate to enable etcd corruption check
* Kubernetes 1.10 was removed as officially supported version from Kubermatic as it's EOL
* Add short names to the ClusterAPI CRDs to allow using `kubectl get md` for `machinedeployments`, `kubectl get ms` for `machinesets` and `kubectl get ma` to get `machines`

* Update canal to v2.6.12, Kubernetes Dashboard to v1.10.1 and replace kube-dns with CoreDNS 1.3.1
* Update Vertical Pod Autoscaler to v0.5
* Avoid the name "kubermatic" for cloud provider resources visible by end users
* In order to provide Grafana dashboards for user cluster resource usage, the node-exporter is now deployed by default as an addon into user clusters.
* Make the default AMI's for AWS instances configurable via the `datacenters.yaml`
* Vertical Pod Autoscaler is not deployed by default anymore
* Initial node deployments are now created inside the same API call as the cluster, fixing spurious issues where the creation didn't happen
* Errors when reconciling MachineDeployments and MachineSets will now result in an event on the object
* Filter out not valid VM types for azure provider
* Mark cluster upgrades as restricted if kubelet version is incompatible.
* Enable automatic detection of the OpenStack BlockStorage API version within the cloud config
* Add the ContainerLinuxUpdateOperator to all clusters that use ContainerLinux nodes
* The trust-device-path cloud config property of Openstack clusters can be configured via `datacenters.yaml`.
* Set AntiAffinity for pods to prevent situations where the API servers of all clusters got scheduled on a single node
* Set resource requests & limits for all addons
* Add Kubernetes v1.14.1 to the list of supported versions
* A small amount of resources gets reserved on each node for the Kubelet and system services
* Update etcd to v3.3.12
* Update the metrics-server to v0.3.2
* Update the user cluster Prometheus to v2.9.1
* It is now possible to scale MachineDeployments and MachineSets via `kubectl scale`

## Dashboard

* The color scheme of the Dashboard was changed
* It is now possible to edit the project name in UI
* Made Nodes and Node Deployments statuses more accurate
* Redesign DigitalOcean sizes and OpenStack flavors option pickers
* Smoother operation on bad network connection thanks to changes in asset caching.
* Added a flag allowing to change the default number of nodes created with clusters.
* Setting openstack tags for instances is possible via UI now.
* Allowed Node Deployment naming.
* Adding multiple owners to a project is possible via UI now.
* Allowed specifying kubelet version for Node Deployments.
* Events related to the Nodes are now displayed in the Node Deployment details view.
* Fixed reload behaviour of openstack setting fields.
* Fixed a bug with the missing version in the footer.
* Project owners are now visible in project list view .
* Added possibility to assign labels to nodes.
* Updated AWS instance types.
* Fixed display number of replicas if the field is empty (0 replicas).
* Added an option to include custom links into the application.
* Remove AWS instance types t3.nano & t3.micro as they are too small to schedule any workload on them
* Redesigned the application sidebar.

### Logging & Monitoring stack

* Update fluent-bit to 1.0.6
* Add elasticsearch-exporter to logging stack to improve monitoring
* New alerts for cert-manager created certificates about to expire
* Add blackbox-exporter chart
* Update Elasticsearch to 6.6.2
* Add Grafana dashboards for kubelet metrics
* Prometheus was updated to 2.8.1 (Alertmanager 0.16.2), Grafana was updated to 6.1.3
* Alertmanager PVC size is configurable
* Add lifecycle hooks to the Elasticsearch StatefulSet to make starting/stopping more graceful
* Pod annotations are no longer logged in Elasticsearch
* Improve Prometheus backups in high traffic environments
* Fix VolumeSnapshotLocations for Ark configuration
* `node-exporter` is not exposed on all host interfaces anymore
* Improve Kibana usability by auto-provisioning index patterns
* Configurable Prometheus backup timeout to accomodate larger seed clusters

### Other

* **ACTION REQUIRED:** update from Ark 0.10 to Velero 0.11
* Replace hand written go tcp proxy with Envoy within the nodeport-proxy
* `cert-manager` was updated to 0.7.0, Dex was updated to 2.15.0,Minio was updated to RELEASE.2019-04-09T01-22-30Z
* Update nginx-ingress-controller to 0.24.1
* Allow scheduling Helm charts using affinities, node selectors and tolerations for more stable clusters
* Helm charts: Define configurable resource constraints
* Improve Helm charts metadata to make Helm-based workflows easier and aid in cluster updates
* `dex` keys expirations can now be configured in helm chart
* Update the nodeport-proxy Envoy to v1.10

## Bugfixes

* Fixed invalid variable caching in Grafana dashboards
