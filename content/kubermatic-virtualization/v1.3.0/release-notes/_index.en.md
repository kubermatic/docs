+++
title = "Release Notes"
date = 2026-08-20T21:00:00+02:00
weight = 70
+++


### Breaking Changes

This release contains changes that require additional attention, please read the following items carefully.

- `networkConfiguration.serviceCIDR` is no longer ignored. Existing clusters run `10.96.0.0/12`: if your `cluster.yaml` sets another range, change it to `10.96.0.0/12`, or `apply` stops ([#775](https://github.com/kubermatic/kubermatic-virtualization/pull/775))
- Pre-flight checks require a top-level `imagePullSecret` (or `KUBEV_USERNAME`/`KUBEV_PASSWORD`) and fail early instead of leaving the controller-manager in ImagePullBackOff. Air-gapped installs that use `offlineSettings` are exempt. `kubermatic-virtualization config print --full` documents the field ([#370](https://github.com/kubermatic/kubermatic-virtualization/pull/370))
- The `kubevirt` block of `cluster.yaml` was silently dropped and is now applied, including `enforceRegionalScheduling`, `developerConfiguration`, `migrations`, `commonInstancetypesDeployment` and `permittedHostDevices`. Every generated `cluster.yaml` sets `kubevirt.developerConfiguration.featureGates`, so the next `apply` updates the KubeVirt CR on practically every cluster. The block is now also validated, and an invalid one fails at load: review it before upgrading ([#491](https://github.com/kubermatic/kubermatic-virtualization/pull/491))
- NAT gateway rules follow each gateway's spec: on upgrade, rules removed from the spec earlier are deleted and earlier edits take effect. Check your NAT gateway specs before upgrading ([#715](https://github.com/kubermatic/kubermatic-virtualization/pull/715))

### New Features

#### VM Migration from VMware vSphere

- Migrate VMs from vSphere to KubeV with Forklift v2.12.1, which the installer installs and manages. `migration.enabled: false` skips it, and `migration.vddk` sets a VDDK image and pull secret for the whole platform ([#436](https://github.com/kubermatic/kubermatic-virtualization/pull/436), [#437](https://github.com/kubermatic/kubermatic-virtualization/pull/437), [#449](https://github.com/kubermatic/kubermatic-virtualization/pull/449), [#753](https://github.com/kubermatic/kubermatic-virtualization/pull/753))
- Create and edit migration plans on a single page. A plan detail page shows the run history, and plans can be edited until they run ([#507](https://github.com/kubermatic/kubermatic-virtualization/pull/507), [#513](https://github.com/kubermatic/kubermatic-virtualization/pull/513), [#701](https://github.com/kubermatic/kubermatic-virtualization/pull/701))
- The machine picker pages and filters on the server, so large vCenter inventories load one page at a time, and it explains why a machine cannot be selected, for example when Changed Block Tracking is off for a warm migration ([#519](https://github.com/kubermatic/kubermatic-virtualization/pull/519), [#536](https://github.com/kubermatic/kubermatic-virtualization/pull/536), [#540](https://github.com/kubermatic/kubermatic-virtualization/pull/540), [#766](https://github.com/kubermatic/kubermatic-virtualization/pull/766))
- vSphere providers have a detail page for editing the VDDK image, SDK endpoint and vCenter credentials ([#562](https://github.com/kubermatic/kubermatic-virtualization/pull/562), [#566](https://github.com/kubermatic/kubermatic-virtualization/pull/566))
- VM NICs can be mapped to UnderlaySubnet networks, besides Pod, VPC subnet and Ignore ([#490](https://github.com/kubermatic/kubermatic-virtualization/pull/490), [#501](https://github.com/kubermatic/kubermatic-virtualization/pull/501))
- VAAI XCOPY copy offload to NetApp ONTAP, behind the `CopyOffload` feature gate in `KubeVCluster.spec.featureGates` (off by default). Providers expose the ESXi clone method (SSH or VIB) ([#492](https://github.com/kubermatic/kubermatic-virtualization/pull/492))

#### Edge Routing

- New `AZEdgeRouter`: a regional BGP gateway that serves several VPCs from one FRR StatefulSet, in `evpn` or `bgp-per-vrf` transit mode. `EVPNRouteReflector` and `EVPNPolicy` add EVPN Type 5 routing between regions. The types are in the new `routing.virtualization.k8c.io` API group and are installed with the edge-router-manager chart ([#469](https://github.com/kubermatic/kubermatic-virtualization/pull/469))
- In `bgp-per-vrf` mode, each VPC can have separate service and workload fabric peers, its own BGP ASN and per-subnet egress SNAT, and VPCs can share one advertisement VLAN. Fabric sessions accept no routes until `perVRFTransit.acceptPrefixes` (or a per-VPC or per-VLAN override) is set ([#442](https://github.com/kubermatic/kubermatic-virtualization/pull/442))
- An AZEdgeRouter can attach VPCs from other namespaces: `spec.vpcs.namespaces` selects them (`*` for all) and VPC references accept `namespace/name` ([#734](https://github.com/kubermatic/kubermatic-virtualization/pull/734))
- AZEdgeRouters report a `Ready` condition, failure events and BGP session state in `status.bgpSessions`. `kubectl get` shows ReadyReplicas and Ready, and Reason with `-o wide` ([#378](https://github.com/kubermatic/kubermatic-virtualization/pull/378), [#686](https://github.com/kubermatic/kubermatic-virtualization/pull/686))
- Admins can see AZ edge routers from all namespaces in the dashboard, with their VPCs, learned routes and per-peer BGP state, and manage their VPC, VLAN and subnet attachments and fabric peers ([#380](https://github.com/kubermatic/kubermatic-virtualization/pull/380), [#686](https://github.com/kubermatic/kubermatic-virtualization/pull/686), [#760](https://github.com/kubermatic/kubermatic-virtualization/pull/760))

#### VM Backup and Restore

- Back up VMs to S3-compatible storage and restore them (`VMBackup`, `VMRestore`, `BackupStorageLocation`). This was left out of v1.2.0 ([#441](https://github.com/kubermatic/kubermatic-virtualization/pull/441), [#446](https://github.com/kubermatic/kubermatic-virtualization/pull/446), [#447](https://github.com/kubermatic/kubermatic-virtualization/pull/447), [#462](https://github.com/kubermatic/kubermatic-virtualization/pull/462))
- Every cluster gets the CSI snapshot components, and Longhorn clusters a VolumeSnapshotClass, so running VMs can be backed up. Other CSI drivers need their own VolumeSnapshotClass; until one exists, backups take the offline path and the VM says which driver needs it ([#447](https://github.com/kubermatic/kubermatic-virtualization/pull/447))
- VMs whose disks are standalone DataVolumes, as the dashboard creates them, can be backed up. A VM restored from such a backup owns its disks, so deleting it deletes them ([#441](https://github.com/kubermatic/kubermatic-virtualization/pull/441))
- A backup details page shows the backed-up volumes, the underlying resources and events ([#446](https://github.com/kubermatic/kubermatic-virtualization/pull/446))

#### Dashboard

- Kubernetes events and failure details for VMs, VM pools, disks, load balancers, VPCs, subnets and the whole environment ([#332](https://github.com/kubermatic/kubermatic-virtualization/pull/332))
- View, edit and download any resource as YAML ([#362](https://github.com/kubermatic/kubermatic-virtualization/pull/362))
- Admins see and manage VMs, VM pools, VPCs, subnets, disks, images, SSH keys, load balancers, firewall rules, autoscalers and events in all namespaces; other users stay in the deployment namespace. The load balancer and autoscaler pages list only entries that belong to VMs or VM pools ([#349](https://github.com/kubermatic/kubermatic-virtualization/pull/349), [#422](https://github.com/kubermatic/kubermatic-virtualization/pull/422))
- VM and VM pool creation adds OS presets, cluster-aware disk defaults, a sortable instance type list, custom NIC routes, a YAML mode, custom cloud-init user and network data, and GPU configuration ([#337](https://github.com/kubermatic/kubermatic-virtualization/pull/337), [#367](https://github.com/kubermatic/kubermatic-virtualization/pull/367), [#373](https://github.com/kubermatic/kubermatic-virtualization/pull/373))
- A VM NIC can attach directly to an UnderlaySubnet from a new Underlay tab, and the subnet page lists the VMs on an underlay subnet ([#487](https://github.com/kubermatic/kubermatic-virtualization/pull/487), [#488](https://github.com/kubermatic/kubermatic-virtualization/pull/488), [#726](https://github.com/kubermatic/kubermatic-virtualization/pull/726))
- VMs and VM pools have a full edit page instead of the small edit dialog. VMs owned by a pool are edited through the pool ([#427](https://github.com/kubermatic/kubermatic-virtualization/pull/427), [#731](https://github.com/kubermatic/kubermatic-virtualization/pull/731))
- Create and edit firewall rules, including port ranges and IPv6 sources, and turn a VM's firewall on or off from its Networking tab ([#439](https://github.com/kubermatic/kubermatic-virtualization/pull/439))
- Manage NAT gateways, elastic IPs, and VPC routes, peerings and BFD ([#503](https://github.com/kubermatic/kubermatic-virtualization/pull/503), [#504](https://github.com/kubermatic/kubermatic-virtualization/pull/504), [#514](https://github.com/kubermatic/kubermatic-virtualization/pull/514))
- Deleting a VM offers to delete its disks too, and flags disks other VMs use ([#455](https://github.com/kubermatic/kubermatic-virtualization/pull/455))
- The dashboard explains why a VM cannot be scheduled, and warns before creating or starting a VM whose instance type fits no node ([#684](https://github.com/kubermatic/kubermatic-virtualization/pull/684))
- The VM list refreshes on its own ([#351](https://github.com/kubermatic/kubermatic-virtualization/pull/351))
- Tables have rows-per-page and page numbers, and card views keep a readable width on wide screens ([#519](https://github.com/kubermatic/kubermatic-virtualization/pull/519), [#528](https://github.com/kubermatic/kubermatic-virtualization/pull/528))
- Create pages and form dialogs ask before discarding unsaved edits ([#430](https://github.com/kubermatic/kubermatic-virtualization/pull/430), [#664](https://github.com/kubermatic/kubermatic-virtualization/pull/664), [#727](https://github.com/kubermatic/kubermatic-virtualization/pull/727))
- The admin panel has its own sidebar ([#327](https://github.com/kubermatic/kubermatic-virtualization/pull/327))
- The footer shows the KubeV version, and an About dialog lists the build and component versions ([#759](https://github.com/kubermatic/kubermatic-virtualization/pull/759))

#### Networking

- Existing Kube-OVN VPCs, subnets and VLAN-backed subnets are adopted as `virtualization.k8c.io` VPCs, Subnets and UnderlaySubnets and show up in the dashboard. Adopted objects are read-only and never deleted unless the native Kube-OVN object is annotated `virtualization.k8c.io/adopt-writable` or `virtualization.k8c.io/adopt-deletable` ([#420](https://github.com/kubermatic/kubermatic-virtualization/pull/420), [#556](https://github.com/kubermatic/kubermatic-virtualization/pull/556))
- `kubevirt.enforceRegionalScheduling` makes VMs run in the region set by their subnet's region label. With `false`, region-aware scheduling is still available but not enforced ([#261](https://github.com/kubermatic/kubermatic-virtualization/pull/261))
- `networkConfiguration.dnsServerIP` accepts several DNS servers, separated by commas or spaces ([#270](https://github.com/kubermatic/kubermatic-virtualization/pull/270))

#### Installer

- `kubermatic-virtualization offline pull` downloads a release's offline bundle (images, Helm charts and OS packages) for air-gapped installs ([#685](https://github.com/kubermatic/kubermatic-virtualization/pull/685))
- `apply --force-upgrade` runs the Kubernetes upgrade even when every node already has the target version, to resume an upgrade that stopped after the control plane or to renew control plane certificates ([#558](https://github.com/kubermatic/kubermatic-virtualization/pull/558))
- Dashboard chart values (Service type and port, replicas, resources, scheduling, pod annotations, security contexts and more) can be set under `dashboard` in the cluster config. A NodePort or LoadBalancer dashboard with `auth: none` needs `dashboard.service.allowUnauthenticated: true` ([#768](https://github.com/kubermatic/kubermatic-virtualization/pull/768))
- `certManager.gatewayAPI: true` lets cert-manager issue certificates for Gateway API gateways. Install the Gateway API CRDs first ([#748](https://github.com/kubermatic/kubermatic-virtualization/pull/748))
- The controller-manager chart can reuse an existing image pull Secret ([#465](https://github.com/kubermatic/kubermatic-virtualization/pull/465))
- Basic auth accepts bcrypt-hashed passwords; plaintext passwords keep working ([#356](https://github.com/kubermatic/kubermatic-virtualization/pull/356))

### Integration Features

KubeV integrates with KDP (Kubermatic Developer Platform): KDP organizations and projects are KubeV's tenants, and kcp authorizes every request.

- Three setups: an existing KDP (`kdp.external`), KDP installed next to KubeV (same-layer), and KDP in a nested cluster. The installer deploys KDP 1.2.1 ([#375](https://github.com/kubermatic/kubermatic-virtualization/pull/375), [#702](https://github.com/kubermatic/kubermatic-virtualization/pull/702))
- `kubermatic-virtualization kdp connect` registers KubeV in an existing KDP from a kcp admin kubeconfig ([#769](https://github.com/kubermatic/kubermatic-virtualization/pull/769))
- KDP's "Open in KubeV" button opens the project in KubeV, signed in through Dex as the user who clicked. Dex password logins (email, LDAP) ask for the password on each click. In same-layer mode, setting `dashboard.auth.oidc.connectors` skips Dex's login chooser. KDP installs must set `dashboard.dashboardURL` ([#604](https://github.com/kubermatic/kubermatic-virtualization/pull/604), [#618](https://github.com/kubermatic/kubermatic-virtualization/pull/618), [#619](https://github.com/kubermatic/kubermatic-virtualization/pull/619), [#644](https://github.com/kubermatic/kubermatic-virtualization/pull/644), [#711](https://github.com/kubermatic/kubermatic-virtualization/pull/711), [#742](https://github.com/kubermatic/kubermatic-virtualization/pull/742), [#764](https://github.com/kubermatic/kubermatic-virtualization/pull/764), [#767](https://github.com/kubermatic/kubermatic-virtualization/pull/767), [#770](https://github.com/kubermatic/kubermatic-virtualization/pull/770), [#774](https://github.com/kubermatic/kubermatic-virtualization/pull/774))
- The dashboard works in the project KDP opened (`/projects/<org>:<project>/`) and has no organization or project picker. Organizations, projects, members and roles are managed in KDP: KubeV's built-in roles appear in KDP's member dialog, and KDP's Developer and Member roles cover KubeV resources ([#611](https://github.com/kubermatic/kubermatic-virtualization/pull/611), [#636](https://github.com/kubermatic/kubermatic-virtualization/pull/636), [#640](https://github.com/kubermatic/kubermatic-virtualization/pull/640), [#641](https://github.com/kubermatic/kubermatic-virtualization/pull/641))
- In same-layer mode, every KDP project gets the KubeV service automatically. Every signed-in KDP user sees KubeV in the service catalog, and what they can do depends on their project roles. KDP refuses KubeV resources in organizations ([#742](https://github.com/kubermatic/kubermatic-virtualization/pull/742), [#746](https://github.com/kubermatic/kubermatic-virtualization/pull/746), [#747](https://github.com/kubermatic/kubermatic-virtualization/pull/747), [#754](https://github.com/kubermatic/kubermatic-virtualization/pull/754))
- Projects support VMs, VM pools, disks, load balancers, firewalls, autoscalers, events and the VM console (VNC and serial, which needs `update` on the VM). Create forms pick one of the project's namespaces ([#608](https://github.com/kubermatic/kubermatic-virtualization/pull/608), [#637](https://github.com/kubermatic/kubermatic-virtualization/pull/637), [#638](https://github.com/kubermatic/kubermatic-virtualization/pull/638), [#666](https://github.com/kubermatic/kubermatic-virtualization/pull/666), [#706](https://github.com/kubermatic/kubermatic-virtualization/pull/706), [#707](https://github.com/kubermatic/kubermatic-virtualization/pull/707), [#709](https://github.com/kubermatic/kubermatic-virtualization/pull/709), [#751](https://github.com/kubermatic/kubermatic-virtualization/pull/751))
- VM backups and restores run in projects. Backup target credentials and CA bundles sync from KDP to the host, and the backup Job's pull Secret is copied to the project's host namespace (`backupUploader.copyPullSecretToKDPNamespaces` in the controller-manager chart turns this off) ([#648](https://github.com/kubermatic/kubermatic-virtualization/pull/648), [#649](https://github.com/kubermatic/kubermatic-virtualization/pull/649), [#708](https://github.com/kubermatic/kubermatic-virtualization/pull/708), [#749](https://github.com/kubermatic/kubermatic-virtualization/pull/749))
- VM migration from vSphere works in projects, including warm migration with the platform VDDK image. Forklift objects stay in the project's namespace, and an admission policy refuses hooks, LUKS keys, customization scripts, transfer networks, custom images, service accounts, copy offload, providers other than vSphere and the local cluster, and vCenter addresses inside the platform ([#669](https://github.com/kubermatic/kubermatic-virtualization/pull/669), [#679](https://github.com/kubermatic/kubermatic-virtualization/pull/679), [#705](https://github.com/kubermatic/kubermatic-virtualization/pull/705), [#750](https://github.com/kubermatic/kubermatic-virtualization/pull/750))
- Host namespaces are named `kv-<hash>-<hash>` and labelled with their organization, project and namespace, so KDP names have no length or character limits ([#776](https://github.com/kubermatic/kubermatic-virtualization/pull/776))
- KDP logins get no access to the host cluster, and host reads need a KubeV role in the project. A project's VMs, disks, backups and migrations cannot reach networks, nodes or internal services outside it, and objects the host would refuse are refused when they are created. Edge routers are not published to projects; platform admins create them on the host ([#605](https://github.com/kubermatic/kubermatic-virtualization/pull/605), [#651](https://github.com/kubermatic/kubermatic-virtualization/pull/651), [#652](https://github.com/kubermatic/kubermatic-virtualization/pull/652), [#713](https://github.com/kubermatic/kubermatic-virtualization/pull/713), [#716](https://github.com/kubermatic/kubermatic-virtualization/pull/716), [#723](https://github.com/kubermatic/kubermatic-virtualization/pull/723), [#752](https://github.com/kubermatic/kubermatic-virtualization/pull/752))
- A project's subnets cannot attach to another project's network or adopt other networks, and its UnderlaySubnets cannot use a ProviderNetwork or VLAN that another tenant or the platform runs. `kdp.tenantUnderlayInterfaces` lists the NICs projects may use for underlay subnets: until it is set, project underlay subnets are refused, and a project underlay subnet on a NIC outside the list is removed ([#606](https://github.com/kubermatic/kubermatic-virtualization/pull/606), [#607](https://github.com/kubermatic/kubermatic-virtualization/pull/607), [#703](https://github.com/kubermatic/kubermatic-virtualization/pull/703), [#720](https://github.com/kubermatic/kubermatic-virtualization/pull/720))
- Nested KDP needs `dashboard.enabled: false`, and the installer prints the full Dex client settings. The admin password is in the `kubev-kdp-dex-admin` Secret, each install gets its own Dex client secret, and the nested cluster's log goes to the installer's `--log-file` ([#712](https://github.com/kubermatic/kubermatic-virtualization/pull/712), [#718](https://github.com/kubermatic/kubermatic-virtualization/pull/718), [#721](https://github.com/kubermatic/kubermatic-virtualization/pull/721), [#733](https://github.com/kubermatic/kubermatic-virtualization/pull/733))

### API Changes

- The new optional `offlineSettings.packageRepositoryKeyFingerprint` makes Ubuntu nodes accept only that package signing key, so offline clusters can upgrade from a newer release's mirror that is signed with a different key. The package repository step stops if the repository index cannot be refreshed and verified ([#657](https://github.com/kubermatic/kubermatic-virtualization/pull/657))

### Bugfixes

- Workers that run VMs which cannot live-migrate, such as VMs on ReadWriteOnce disks, are upgraded in place and their VMs keep running, instead of the upgrade hanging. A control plane node that runs such a VM stops the upgrade before anything changes ([#778](https://github.com/kubermatic/kubermatic-virtualization/pull/778))
- Upgrades update Kubernetes on all nodes before the platform components, and live migrations auto-converge by default (`kubevirt.migrations.allowAutoConverge`), so node drains no longer get stuck on VM migrations ([#563](https://github.com/kubermatic/kubermatic-virtualization/pull/563))
- The installer applies the KubeV CRDs itself before the Helm releases, so upgrades update CRD schemas instead of pruning new fields. Helm installs CRDs only on first install ([#700](https://github.com/kubermatic/kubermatic-virtualization/pull/700))
- Offline installs pull from docker.io, quay.io, ghcr.io, registry.k8s.io and reg.kyverno.io through the mirror. containerd's `*` wildcard mirror never applied, so pulls went to the public registry and timed out ([#469](https://github.com/kubermatic/kubermatic-virtualization/pull/469))
- `mirror-images` also copies images that start on demand or come from hooks, ConfigMaps and flags (CDI importer, VM export server, Forklift, edge router, NAT gateway, Kyverno upgrade hook, Longhorn backing images) ([#646](https://github.com/kubermatic/kubermatic-virtualization/pull/646))
- The offline apt repository ships packages and their dependencies at their newest Ubuntu 24.04 version, so offline node installs no longer fail on version conflicts ([#645](https://github.com/kubermatic/kubermatic-virtualization/pull/645))
- The default Longhorn storage class supports live migration ([#374](https://github.com/kubermatic/kubermatic-virtualization/pull/374))
- The controller-manager no longer crash-loops on clusters without KubeVirt ([#285](https://github.com/kubermatic/kubermatic-virtualization/pull/285))
- Fix the VM serial console, which rendered the dashboard instead of a terminal ([#353](https://github.com/kubermatic/kubermatic-virtualization/pull/353))
- Fix VM and VM pool edits being rejected when switching between an instance type and custom sizing ([#372](https://github.com/kubermatic/kubermatic-virtualization/pull/372))
- Fix disk edits dropping disk settings and hotplugged disks being templated. Bus options are limited to what the device supports ([#429](https://github.com/kubermatic/kubermatic-virtualization/pull/429))
- VM pools keep user labels editable and roll out one machine at a time ([#430](https://github.com/kubermatic/kubermatic-virtualization/pull/430))
- Removing a VM from a pool clears its pool labels and no longer pins a stopped VM to a placeholder node. Create forms refuse system-owned labels ([#422](https://github.com/kubermatic/kubermatic-virtualization/pull/422), [#724](https://github.com/kubermatic/kubermatic-virtualization/pull/724))
- VMs and VM pools show the CPU and memory they run with, also for namespaced instance types ([#719](https://github.com/kubermatic/kubermatic-virtualization/pull/719))
- An SSH key no longer overwrites a Secret it does not own ([#704](https://github.com/kubermatic/kubermatic-virtualization/pull/704))
- Failed logins return to the login page with an error message ([#717](https://github.com/kubermatic/kubermatic-virtualization/pull/717))
- Node details no longer show healthy pressure and network conditions as errors ([#663](https://github.com/kubermatic/kubermatic-virtualization/pull/663))
- Searchable dropdowns no longer scroll the page when opened, and Escape in a dropdown inside a dialog closes only the dropdown ([#756](https://github.com/kubermatic/kubermatic-virtualization/pull/756), [#757](https://github.com/kubermatic/kubermatic-virtualization/pull/757))
- Resource cards can be opened from the keyboard, and screen readers announce status icons ([#682](https://github.com/kubermatic/kubermatic-virtualization/pull/682), [#683](https://github.com/kubermatic/kubermatic-virtualization/pull/683))
- The dashboard image pins noVNC v1.7.0 instead of building from noVNC's main branch ([#725](https://github.com/kubermatic/kubermatic-virtualization/pull/725))

### Cleanups

- The controller-manager ClusterRole is generated from RBAC markers and drops rights the controllers do not use: cluster-scoped RBAC writes, NetworkPolicies, KubeVirt VM deletion and VMI access, Deployments, Namespaces, ResourceQuotas, cluster-wide Leases, and Secret patch and delete. `bind` and `escalate` on Roles are limited to the release namespace. Automation that reused the controller-manager ServiceAccount for these rights needs its own RBAC ([#478](https://github.com/kubermatic/kubermatic-virtualization/pull/478))
- The installer's help and examples use `kubermatic-virtualization`, the name of the downloaded binary, instead of `kubev` ([#510](https://github.com/kubermatic/kubermatic-virtualization/pull/510))

### Updates

- Update Kubernetes to v1.34.11 ([#551](https://github.com/kubermatic/kubermatic-virtualization/pull/551))
- Update KubeVirt to v1.7.4 ([#549](https://github.com/kubermatic/kubermatic-virtualization/pull/549))
- Update CDI to v1.65.0 ([#550](https://github.com/kubermatic/kubermatic-virtualization/pull/550))
- Update cert-manager to v1.21.2, MetalLB to v0.16.1, Longhorn to v1.10.2 and Kyverno to v1.16.4 ([#552](https://github.com/kubermatic/kubermatic-virtualization/pull/552))
- Update Go to 1.26.7 ([#412](https://github.com/kubermatic/kubermatic-virtualization/pull/412), [#587](https://github.com/kubermatic/kubermatic-virtualization/pull/587))

