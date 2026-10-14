+++
title = "Release Notes"
date = 2026-08-20T21:00:00+02:00
weight = 70
+++


### Breaking Changes

This release contains changes that require additional attention, please read the following items carefully.

- `networkConfiguration.serviceCIDR` is no longer ignored. Existing clusters run `10.96.0.0/12`: if your `cluster.yaml` sets another range, change it to `10.96.0.0/12`, or `apply` stops 
- Pre-flight checks require a top-level `imagePullSecret` (or `KUBEV_USERNAME`/`KUBEV_PASSWORD`) and fail early instead of leaving the controller-manager in ImagePullBackOff. Air-gapped installs that use `offlineSettings` are exempt. `kubermatic-virtualization config print --full` documents the field 
- The `kubevirt` block of `cluster.yaml` was silently dropped and is now applied, including `enforceRegionalScheduling`, `developerConfiguration`, `migrations`, `commonInstancetypesDeployment` and `permittedHostDevices`. Every generated `cluster.yaml` sets `kubevirt.developerConfiguration.featureGates`, so the next `apply` updates the KubeVirt CR on practically every cluster. The block is now also validated, and an invalid one fails at load: review it before upgrading 
- NAT gateway rules follow each gateway's spec: on upgrade, rules removed from the spec earlier are deleted and earlier edits take effect. Check your NAT gateway specs before upgrading 
### New Features

#### VM Migration from VMware vSphere

- Migrate VMs from vSphere to KubeV with Forklift v2.12.1, which the installer installs and manages. `migration.enabled: false` skips it, and `migration.vddk` sets a VDDK image and pull secret for the whole platform 
- Create and edit migration plans on a single page. A plan detail page shows the run history, and plans can be edited until they run
- The machine picker pages and filters on the server, so large vCenter inventories load one page at a time, and it explains why a machine cannot be selected, for example when Changed Block Tracking is off for a warm migration 
- vSphere providers have a detail page for editing the VDDK image, SDK endpoint and vCenter credentials 
- VM NICs can be mapped to UnderlaySubnet networks, besides Pod, VPC subnet and Ignore 
- VAAI XCOPY copy offload to NetApp ONTAP, behind the `CopyOffload` feature gate in `KubeVCluster.spec.featureGates` (off by default). Providers expose the ESXi clone method (SSH or VIB) 
#### Edge Routing

- New `AZEdgeRouter`: a regional BGP gateway that serves several VPCs from one FRR StatefulSet, in `evpn` or `bgp-per-vrf` transit mode. `EVPNRouteReflector` and `EVPNPolicy` add EVPN Type 5 routing between regions. The types are in the new `routing.virtualization.k8c.io` API group and are installed with the edge-router-manager chart 
- In `bgp-per-vrf` mode, each VPC can have separate service and workload fabric peers, its own BGP ASN and per-subnet egress SNAT, and VPCs can share one advertisement VLAN. Fabric sessions accept no routes until `perVRFTransit.acceptPrefixes` (or a per-VPC or per-VLAN override) is set
- An AZEdgeRouter can attach VPCs from other namespaces: `spec.vpcs.namespaces` selects them (`*` for all) and VPC references accept `namespace/name`
- AZEdgeRouters report a `Ready` condition, failure events and BGP session state in `status.bgpSessions`. `kubectl get` shows ReadyReplicas and Ready, and Reason with `-o wide`
- Admins can see AZ edge routers from all namespaces in the dashboard, with their VPCs, learned routes and per-peer BGP state, and manage their VPC, VLAN and subnet attachments and fabric peers 

#### VM Backup and Restore

- Back up VMs to S3-compatible storage and restore them (`VMBackup`, `VMRestore`, `BackupStorageLocation`). This was left out of v1.2.0 
- Every cluster gets the CSI snapshot components, and Longhorn clusters a VolumeSnapshotClass, so running VMs can be backed up. Other CSI drivers need their own VolumeSnapshotClass; until one exists, backups take the offline path and the VM says which driver needs it
- VMs whose disks are standalone DataVolumes, as the dashboard creates them, can be backed up. A VM restored from such a backup owns its disks, so deleting it deletes them 
- A backup details page shows the backed-up volumes, the underlying resources and events

#### Dashboard

- Kubernetes events and failure details for VMs, VM pools, disks, load balancers, VPCs, subnets and the whole environment 
- View, edit and download any resource as YAML 
- Admins see and manage VMs, VM pools, VPCs, subnets, disks, images, SSH keys, load balancers, firewall rules, autoscalers and events in all namespaces; other users stay in the deployment namespace. The load balancer and autoscaler pages list only entries that belong to VMs or VM pools
- VM and VM pool creation adds OS presets, cluster-aware disk defaults, a sortable instance type list, custom NIC routes, a YAML mode, custom cloud-init user and network data, and GPU configuration 
- A VM NIC can attach directly to an UnderlaySubnet from a new Underlay tab, and the subnet page lists the VMs on an underlay subnet 
- VMs and VM pools have a full edit page instead of the small edit dialog. VMs owned by a pool are edited through the pool 
- Create and edit firewall rules, including port ranges and IPv6 sources, and turn a VM's firewall on or off from its Networking tab
- Manage NAT gateways, elastic IPs, and VPC routes, peerings and BFD 
- Deleting a VM offers to delete its disks too, and flags disks other VMs use 
- The dashboard explains why a VM cannot be scheduled, and warns before creating or starting a VM whose instance type fits no node 
- The VM list refreshes on its own 
- Tables have rows-per-page and page numbers, and card views keep a readable width on wide screens 
- Create pages and form dialogs ask before discarding unsaved edits 
- The admin panel has its own sidebar 
- The footer shows the KubeV version, and an About dialog lists the build and component versions 

#### Networking

- Existing Kube-OVN VPCs, subnets and VLAN-backed subnets are adopted as `virtualization.k8c.io` VPCs, Subnets and UnderlaySubnets and show up in the dashboard. Adopted objects are read-only and never deleted unless the native Kube-OVN object is annotated `virtualization.k8c.io/adopt-writable` or `virtualization.k8c.io/adopt-deletable`
- `kubevirt.enforceRegionalScheduling` makes VMs run in the region set by their subnet's region label. With `false`, region-aware scheduling is still available but not enforced
- `networkConfiguration.dnsServerIP` accepts several DNS servers, separated by commas or space

#### Installer

- `kubermatic-virtualization offline pull` downloads a release's offline bundle (images, Helm charts and OS packages) for air-gapped installs
- `apply --force-upgrade` runs the Kubernetes upgrade even when every node already has the target version, to resume an upgrade that stopped after the control plane or to renew control plane certificates
- Dashboard chart values (Service type and port, replicas, resources, scheduling, pod annotations, security contexts and more) can be set under `dashboard` in the cluster config. A NodePort or LoadBalancer dashboard with `auth: none` needs `dashboard.service.allowUnauthenticated: true` ([#768](https://github.com/kubermatic/kubermatic-virtualization/pull/768))
- `certManager.gatewayAPI: true` lets cert-manager issue certificates for Gateway API gateways. Install the Gateway API CRDs first
- The controller-manager chart can reuse an existing image pull Secret
- Basic auth accepts bcrypt-hashed passwords; plaintext passwords keep working

### Integration Features

KubeV integrates with KDP (Kubermatic Developer Platform): KDP organizations and projects are KubeV's tenants, and kcp authorizes every request.

- Three setups: an existing KDP (`kdp.external`), KDP installed next to KubeV (same-layer), and KDP in a nested cluster. The installer deploys KDP 1.2.1
- `kubermatic-virtualization kdp connect` registers KubeV in an existing KDP from a kcp admin kubeconfig 
- KDP's "Open in KubeV" button opens the project in KubeV, signed in through Dex as the user who clicked. Dex password logins (email, LDAP) ask for the password on each click. In same-layer mode, setting `dashboard.auth.oidc.connectors` skips Dex's login chooser. KDP installs must set `dashboard.dashboardURL`
- The dashboard works in the project KDP opened (`/projects/<org>:<project>/`) and has no organization or project picker. Organizations, projects, members and roles are managed in KDP: KubeV's built-in roles appear in KDP's member dialog, and KDP's Developer and Member roles cover KubeV resources
- In same-layer mode, every KDP project gets the KubeV service automatically. Every signed-in KDP user sees KubeV in the service catalog, and what they can do depends on their project roles. KDP refuses KubeV resources in organizations
- Projects support VMs, VM pools, disks, load balancers, firewalls, autoscalers, events and the VM console (VNC and serial, which needs `update` on the VM). Create forms pick one of the project's namespaces
- VM backups and restores run in projects. Backup target credentials and CA bundles sync from KDP to the host, and the backup Job's pull Secret is copied to the project's host namespace (`backupUploader.copyPullSecretToKDPNamespaces` in the controller-manager chart turns this off)
- VM migration from vSphere works in projects, including warm migration with the platform VDDK image. Forklift objects stay in the project's namespace, and an admission policy refuses hooks, LUKS keys, customization scripts, transfer networks, custom images, service accounts, copy offload, providers other than vSphere and the local cluster, and vCenter addresses inside the platform
- Host namespaces are named `kv-<hash>-<hash>` and labelled with their organization, project and namespace, so KDP names have no length or character limits
- KDP logins get no access to the host cluster, and host reads need a KubeV role in the project. A project's VMs, disks, backups and migrations cannot reach networks, nodes or internal services outside it, and objects the host would refuse are refused when they are created. Edge routers are not published to projects; platform admins create them on the host
- A project's subnets cannot attach to another project's network or adopt other networks, and its UnderlaySubnets cannot use a ProviderNetwork or VLAN that another tenant or the platform runs. `kdp.tenantUnderlayInterfaces` lists the NICs projects may use for underlay subnets: until it is set, project underlay subnets are refused, and a project underlay subnet on a NIC outside the list is removed
- Nested KDP needs `dashboard.enabled: false`, and the installer prints the full Dex client settings. The admin password is in the `kubev-kdp-dex-admin` Secret, each install gets its own Dex client secret, and the nested cluster's log goes to the installer's `--log-file`

### API Changes

- The new optional `offlineSettings.packageRepositoryKeyFingerprint` makes Ubuntu nodes accept only that package signing key, so offline clusters can upgrade from a newer release's mirror that is signed with a different key. The package repository step stops if the repository index cannot be refreshed and verified

### Bugfixes

- Workers that run VMs which cannot live-migrate, such as VMs on ReadWriteOnce disks, are upgraded in place and their VMs keep running, instead of the upgrade hanging. A control plane node that runs such a VM stops the upgrade before anything changes
- Upgrades update Kubernetes on all nodes before the platform components, and live migrations auto-converge by default (`kubevirt.migrations.allowAutoConverge`), so node drains no longer get stuck on VM migrations
- The installer applies the KubeV CRDs itself before the Helm releases, so upgrades update CRD schemas instead of pruning new fields. Helm installs CRDs only on first install
- Offline installs pull from docker.io, quay.io, ghcr.io, registry.k8s.io and reg.kyverno.io through the mirror. containerd's `*` wildcard mirror never applied, so pulls went to the public registry and timed out 
- `mirror-images` also copies images that start on demand or come from hooks, ConfigMaps and flags (CDI importer, VM export server, Forklift, edge router, NAT gateway, Kyverno upgrade hook, Longhorn backing images)
- The offline apt repository ships packages and their dependencies at their newest Ubuntu 24.04 version, so offline node installs no longer fail on version conflicts
- The default Longhorn storage class supports live migration
- The controller-manager no longer crash-loops on clusters without KubeVirt
- Fix the VM serial console, which rendered the dashboard instead of a terminal
- Fix VM and VM pool edits being rejected when switching between an instance type and custom sizing
- Fix disk edits dropping disk settings and hotplugged disks being templated. Bus options are limited to what the device supports
- VM pools keep user labels editable and roll out one machine at a time
- Removing a VM from a pool clears its pool labels and no longer pins a stopped VM to a placeholder node. Create forms refuse system-owned labels 
- VMs and VM pools show the CPU and memory they run with, also for namespaced instance types 
- An SSH key no longer overwrites a Secret it does not own
- Failed logins return to the login page with an error message
- Node details no longer show healthy pressure and network conditions as errors
- Searchable dropdowns no longer scroll the page when opened, and Escape in a dropdown inside a dialog closes only the dropdown
- Resource cards can be opened from the keyboard, and screen readers announce status icons
- The dashboard image pins noVNC v1.7.0 instead of building from noVNC's main branch

### Cleanups

- The controller-manager ClusterRole is generated from RBAC markers and drops rights the controllers do not use: cluster-scoped RBAC writes, NetworkPolicies, KubeVirt VM deletion and VMI access, Deployments, Namespaces, ResourceQuotas, cluster-wide Leases, and Secret patch and delete. `bind` and `escalate` on Roles are limited to the release namespace. Automation that reused the controller-manager ServiceAccount for these rights needs its own RBAC 
- The installer's help and examples use `kubermatic-virtualization`, the name of the downloaded binary, instead of `kubev` 

### Updates

- Update Kubernetes to v1.34.11 
- Update KubeVirt to v1.7.4 
- Update CDI to v1.65.0 
- Update cert-manager to v1.21.2, MetalLB to v0.16.1, Longhorn to v1.10.2 and Kyverno to v1.16.4 
- Update Go to 1.26.7

