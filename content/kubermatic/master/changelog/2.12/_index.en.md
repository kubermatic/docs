+++
title = "Changelog for Kubermatic 2.12"
date = 2019-09-18T00:07:15+02:00
publishDate = 2019-07-12T00:00:00+00:00
weight = 20
pre = "<b></b>"
+++

## v2.12.3

- Fixed extended cluster options not being properly applied
- A panic that could occur on clusters that lack both credentials and a credentialsSecret was fixed.

## v2.12.1

- VSphere: Fixed a bug that resulted in a faulty cloud config when using a non-default port
- Fixed master-controller failing to create project-label-synchronizer controllers.
- Fixed broken NodePort-Proxy for user clusters with LoadBalancer expose strategy.

## v2.12.0

Supported Kubernetes versions:

- `1.14.8`
- `1.15.5`
- `1.16.2`
- Openshift `v4.1.18` preview

**Major new features:**

- Kubernetes 1.16 support was added
- It is now possible to also configure automatic node updates by setting `automaticNodeUpdate: true` in the `updates.yaml`. This option implies `automatic: true` as node versions must not be newer than the version of the corresponding controlplane.
- Cloud credentials can now be configured as presets
- Access to datacenters can now be restricted based on the user&#39;s email domain.
- It is now possible to open the Kubernetes Dashboard from the Kubermatic UI.
- An option to use AWS Route53 DNS validation was added to the `certs` chart.
- Added possibility to add labels to projects and clusters and have these labels inherited by node objects.
- Added support for Kubernetes audit logging
- Connect button on cluster details will now open Kubernetes Dashboard/Openshift Console
- Pod Security Policies can now be enabled
- Added support for optional cluster addons

**Installation and updating:**

- **ACTION REQUIRED:** the `zone_character` field must be removed from all AWS datacenters in `datacenters.yaml`
- **ACTION REQUIRED:** The default number of apiserver replicas was increased to 2. You can revert to the old behavior by setting `.Kubermatic.apiserverDefaultReplicas` in the `values.yaml`
- **ACTION REQUIRED:** The literal credentials on the `Cluster` object are being deprecated in favor of storing them in a secret. If you have addons that use credentials, replace `.Cluster.Spec.Cloud` with `.Credentials`.
- **ACTION REQUIRED:** Kubermatic now doesn&#39;t accept unknown keys in its config files anymore and will crash if an unknown key is present
- **ACTION REQUIRED:** BYO datacenters now need to be specific in the `datacenters.yaml` with a value of `{}`, e.G `bringyourown: {}`
- **ACTION REQUIRED:** Velero does not backup Prometheus, Elasticsearch and Minio by default anymore.
- **ACTION REQUIRED:** On AWS, the nodeport-proxy will be recreated as NLB. DNS entries must be updated to point to the new LB.
- The deprecated nodePortPoxy key for Helm values has been removed.
- Support setting oidc authentication settings on cluster
- The worker-count of controller-manager and master-controller are now configurable
- master-controller-manager can now be deployed with multiple replicas
- It is now possible to configure an http proxy on a Seed. This will result in the proxy being used for all control plane pods in that seed that talk to a cloudprovider and for all machines in that Seed, unless its overriden on Datacenter level.
- The cert-manager Helm chart now allows configuring extra values for its controllers args and env vars.
- A fix for CVE-2019-11253 for clusters that were created with a Kubernetes version &lt; 1.14 was deployed
- The memory requests and limits of the Kubermatic API were increased, because the port-fowarding used for the Kubernetes Dashboard and Openshift Console is very memory-intensive

**Monitoring and logging:**

- Alertmanager&#39;s inhibition feature is now used to hide consequential alerts.
- Removed cluster owner name and email labels from kubermatic_cluster_info metric to prevent leaking PII
- New Prometheus metrics kubermatic_addon_created kubermatic_addon_deleted
- New alert KubermaticAddonDeletionTakesTooLong
- FluentBit will now collect the journald logs
- FluentBit can now collect the kernel messages
- FluentBit now always sets the node name in logs
- Added new KubermaticClusterPaused alert with &#34;none&#34; severity for inhibiting alerts from paused clusters
- Removed Helm-based templating in Grafana dashboards
- Added type label (kubernetes/openshift) to kubermatic_cluster_info metric.
- Added metrics endpoint for cluster control plane:GET /api/v1/projects/{project_id}/dc/{dc}/clusters/{cluster_id}/metrics
- Added a new endpoint for node deployment metrics:GET /api/v1/projects/{project_id}/dc/{dc}/clusters/{cluster_id}/nodedeployments/{nodedeployment_id}/metrics

**Cloud providers:**

- Openstack: A bug that could result in many securtiy groups being created when the creation of security group rules failed was fixed
- Openstack: Fixed a bug preventing an interrupted cluster creation from being resumed.
- Openstack: Disk size of nodes is now configurable
- Openstack: Added a security group API compatibility workaround for very old versions of Openstack.
- Openstack: Fixed fetching the list of tenants on some OpenStack configurations with one region
- Openstack: Added support for Project ID to the wizard
- Openstack: The project name can now be provided manually
- Openstack: Fixed API usage for datacenters with only one region
- Openstack: Fixed a bug that resulted in the router not being attached to the subnet when the subnet was manually created
- AWS: MachineDeployments can now be created in any availability zone of the cluster&#39;s region
- AWS: Reduced the role permissions for the control-plane &amp; worker role to the minimum
- AWS: The subnet can now be selected
- AWS: Setting `Control plane role (ARN)` now is possible
- AWS: VM sizes are fetched from the API now.
- AWS: Worker nodes can now be provisioned without a public IP.
- GCP: machine and disk types are now fetched from GCP.
- vSphere: the VM folder can now be configured
- Added support for KubeVirt provider.

**Bugfixes:**

- A bug that sometimes resulted in the creation of the initial NodeDeployment failing was fixed
- `kubeadm join` has been fixed for v1.15 clusters
- Fixed a bug that could cause intermittent delays when using kubectl logs/exec with `exposeStrategy: LoadBalancer`
- A bug that prevented node Labels, Taints and Annotations from getting applied correctly was fixed.
- Fixed worker nodes provisioning for instances with a Kernel &gt;= 4.19
- Fixed an issue that kept clusters stuck if their creation didn&#39;t succeed and they got deleted with LB and/or PV cleanup enabled
- Fixed an issue where deleted project owners would come back after a while
- Enabling the OIDC feature flag in clusters has been fixed.

**Misc:**

- The share cluster feature now allows to use groups, if passed by the IDP. All groups are prefixed with `oidc:`
- The kube-proxy mode (ipvs/iptables) can now be configured. If not specified, it defaults to ipvs.
- Addons can now read the AWS region  from the `kubermatic.io/aws-region` annotation on the cluster
- Allow disabling of apiserver endpoint reconciling.
- Allow cluster owner to manage RBACs from Kubermatic API
- The default service CIDR for new clusters was increased and changed from 10.10.10.0/24 to 10.240.16.0/20
- Retries of the initial node deployment creation do not create an event anymore but continue to be logged at debug level.
- Added option to enforce cluster cleanup in UI
- Support PodSecurityPolicies in addons
- Kubernetes versions affected by CVE-2019-9512 and CVE-2019-9514 have been dropped
- Kubernetes versions affected by CVE-2019-11247 and CVE-2019-11249 have been dropped
- Kubernetes 1.13 which is end-of-life has been removed.
- Updated Alertmanager to 0.19
- Updated blackbox-exporter to 0.15.1
- Updated Canal to v3.8
- Updated cert-manager to 0.10.1
- Updated Dex to 2.19
- Updated Envoy to 1.11.1
- Updated etcd to 3.3.15
- Updated FluentBit to v1.2.2
- Updated Grafana to 6.3.5
- Updated helm-exporter to 0.4.2
- Updated kube-state-metrics to 1.7.2
- Updated Minio to 2019-09-18T21-55-05Z
- Updated machine-controller to v1.5.6
- Updated nginx-ingress-controller to 0.26.1
- Updated Prometheus to 2.12.0
- Updated Velero to v1.1.0

**Dashboard:**

- Added Swagger UI for Kubermatic API
- Redesign dialog to manage SSH keys on cluster
- GCP zones are now fetched from API.
- Redesign Wizard: Summary
- Cluster type toggle in wizard is now hidden if only one cluster type is active
- Disabled the possibility of adding new node deployments until the cluster is fully ready.
- The cluster name is now editable from the dashboard
- Added warning about node deployment changes that will recreate all nodes.
- OIDC client id is now configurable
- Replaced particles with a static background.
- Pod Security Policy can now be activated from the wizard.
- Redesigned extended options in wizard
- Various security improvements in authentication
- Various other visual improvements
