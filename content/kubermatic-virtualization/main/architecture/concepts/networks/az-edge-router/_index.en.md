+++
title = "AZ Edge Router"
date = 2026-09-08T00:00:00+00:00
weight = 20
+++

Kubermatic Virtualization isolates every tenant into its own Kube-OVN VPC — its own routing
domain, with no data path to another VPC or to the node network by default. That isolation is
the point, but it leaves an open question: how does a VPC's workloads reach the outside world,
and how does traffic move between VPCs that live in different regions or availability zones?

The **`AZEdgeRouter`** answers that. It is a single custom resource that provisions a
multi-homed FRR gateway serving **many** tenant VPCs at once — one gateway per region/AZ,
rather than one gateway per VPC. Each VPC it serves gets its own dedicated transit interface
and its own isolated FRR VRF, so tenants stay isolated from each other end to end even though
they share one router.

## Why one router per region, not one per VPC

A gateway scoped to a single VPC is simple to isolate but does not scale operationally — every
new tenant needs its own router deployment, its own BGP session, its own set of external
addresses. `AZEdgeRouter` inverts that: one `AZEdgeRouter` custom resource per region serves
every VPC the operator discovers (by label selector) or is told to attach (an explicit list),
and isolation between those VPCs is enforced by Linux VRFs inside the router pod rather than by
having separate router deployments.

This matches how isolation already works one layer down: a Kube-OVN VPC *is* its own logical
router — a separate routing domain with no default path to another VPC, enforced by the switch
fabric itself. A VRF is the same idea (a separate routing domain, no default path across it)
applied inside the router pod, so the isolation primitive stays the same end to end instead of
switching to a different one (a Kubernetes pod, and so a separate network namespace, per VPC)
at just this one layer.

That alternative — one router pod per VPC, since a pod is already its own network namespace —
would still isolate correctly, but at a real cost that grows with tenant count rather than
staying flat:

- **Per-VPC pod overhead.** Every additional VPC would mean another FRR pod: another image
  pull, another scheduling decision, another process's worth of baseline memory, another set of
  objects for the operator (and whoever operates the cluster) to reconcile and watch. A VRF
  is a route table and a couple of interfaces — cheap to add to a pod that is already running.
- **External session count multiplies with tenant count.** One `AZEdgeRouter` replica holds one
  set of BGP/EVPN sessions per region to the external fabric, no matter how many VPCs it serves.
  One pod per VPC would need that many *times* the sessions to the *same* fabric peers — more
  RIB/FIB state for the fabric side to hold too, and BGP peer/session limits become a real
  constraint well before VRF limits would.
- **Onboarding a VPC is cheaper.** Attaching an existing VPC to a running router is a VRF
  creation, a transit NIC attach, and an FRR config reload. Standing up a whole new pod means
  scheduling, image pull, and a full BGP/EVPN session establishment from cold before that VPC
  has any connectivity at all.

## Regional topology

In a multi-region deployment, each region runs its own `AZEdgeRouter`. A tenant VPC typically
exists in more than one region (a management VPC plus one or more tenant VPCs, replicated per
region), and each region's router only ever advertises the VPCs pinned to its own zone —
`spec.vpcs.subnetLabelSelector` filters a shared VPC down to the subnets that belong to that
router's region, so multiple regional routers can serve the same logical VPC without
double-advertising each other's subnets.

Cross-region reachability between two instances of the same VPC is carried by the routers'
own external advertisement plane (EVPN Type-5 routes, or per-VRF BGP — see below), not by
joining the VPCs directly. Intra-region, intra-VPC traffic never leaves the OVN overlay at all
— it is only inter-region traffic, or traffic destined outside the platform, that transits an
edge router.

## Router pod architecture

Each `AZEdgeRouter` produces a `StatefulSet` of FRR pods. Every replica is multi-homed:

- **`eth0`** — the management VPC, the router's own control-plane attachment.
- **The external plane** (`net1`, and in `bgp-per-vrf` mode, additional per-VPC VLAN NICs) —
  where the router talks to the fabric.
- **One dedicated transit NIC per served VPC** — a Multus interface into that VPC's own
  Kube-OVN logical router, enslaved to a matching FRR VRF. Every VRF lives inside the *same*
  pod network namespace and is served by the *same* FRR process (see [above](#why-one-router-per-region-not-one-per-vpc)
  for why that, rather than one namespace per VPC, is the design).

Because a VRF has no path to another VRF by default, two tenant VPCs served by the same
`AZEdgeRouter` replica stay isolated from each other even though they share a pod — including
when their address ranges overlap. No route leaking is configured or expected between VPC VRFs
on the same router; that is a separate concern from `bgp-per-vrf`'s own per-region VRF at the
external fabric layer, which *does* leak deliberately for cross-region reachability.

## Two transit modes for the external plane

`spec.ovnTransitMode` selects how a VPC's OVN subnets are advertised to the external fabric.
This choice does not affect VPC isolation (VRFs handle that either way) — it is about how the
external plane scales and what it costs on the wire.

### `evpn` (the default)

All VPCs share **one** external NIC (`net1`) acting as a VXLAN VTEP. Each VPC's subnets are
advertised as EVPN Type-5 (IP-prefix) routes carrying that VPC's own VNI, and an EVPN
relay/route-reflector distributes them between regions. Because isolation rides on the VNI
(24-bit — roughly 16 million tenants) rather than a NIC, adding another VPC costs nothing on
the external side; the router's NIC count only grows for the internal transit NIC each VPC
still needs.

This mode is backed by two additional CRDs, neither of which a tenant ever touches directly:

- **`EVPNPolicy`** — an admin-managed object that overrides the VNI/RD/import-export Route
  Targets an `AZEdgeRouter` VPC would otherwise auto-derive as a symmetric `<ASN>:<VNI>`.
  `spec.targets[].azEdgeRouterRef` binds it to one VPC (VRF) on one named `AZEdgeRouter`; the AZ
  controller resolves it directly into that VPC's `status.resolvedAZVPCs[]` entry — there is no
  separate `EVPNPolicy` controller. Reach for one only when two VPCs need asymmetric or
  hand-picked RTs (e.g. a one-way import from a shared services VPC); the auto-derived default
  is a correct, symmetric policy on its own.
- **`EVPNRouteReflector`** — a separate, admin-deployed FRR pod (or pods) that relays EVPN Type-5
  routes between every `AZEdgeRouter` matched by `spec.azEdgeRouterSelector`, using
  `bgp listen range` (`spec.peerListenRanges`) since AZ router pod IPs are dynamically
  IPAM-assigned rather than static. It writes its own replica IPs into each matched router's
  `status.resolvedEVPNPeers`, which `frr-config-watcher` merges in as EVPN-only neighbors — no
  manual peer configuration on the `AZEdgeRouter` side. This is the "operator-managed route
  reflector" referenced under [Choosing between them](#choosing-between-them) below; an
  externally-managed RR (a fabric device instead) is the other option and needs neither CRD.

### `bgp-per-vrf`

Each VPC gets its **own** underlay VLAN, attached as a dedicated external NIC and enslaved to
that VPC's VRF. FRR runs a per-VRF BGP session over it, advertising the VPC's subnets as plain
IPv4 unicast — no VXLAN encapsulation, routed natively on the wire. This trades the EVPN
control plane for simplicity, at the cost of one VLAN (and one NIC) per VPC on the external
side, capped by the platform's VLAN space per router.

Multiple VPCs can share a single advertisement VLAN in `bgp-per-vrf` mode when they don't need
separate external identities, each still keeping its own BGP AS number if required
(`spec.perVRFTransit.vpcVLANs[].localASN`) — so the one-VLAN-per-VPC cost is a default, not a
hard requirement.

#### External VLANs: `UnderlaySubnet` and the same-namespace rule

The usual way to give a VPC its external VLAN in `bgp-per-vrf` mode is
`spec.perVRFTransit.vpcVLANs[].underlaySubnet`, naming an `UnderlaySubnet` object rather than a
NAD directly. An `UnderlaySubnet` bundles a kube-ovn `ProviderNetwork` + `Vlan` + `Subnet` and the
Multus NAD attached to them into one CR, keyed by `spec.vlanID` and `spec.cidrBlock`; the operator
reads the VLAN tag authoritatively off `UnderlaySubnet.spec.vlanID`, so `vpcVLANs[].vlanID` only
matters for the alternate `nadName` form (an already-existing NAD instead of an `UnderlaySubnet`).

**This resolves in the `AZEdgeRouter`'s own namespace — the same rule already noted above for
`spec.vpcs.list`/`labelSelector`, extended to every other object the router reads.** There is no
cross-namespace reference anywhere in this operator: the `UnderlaySubnet`s named in `vpcVLANs`,
`spec.managementSubnet`, and every `VPC` the router discovers or lists must all live in the
`AZEdgeRouter`'s own namespace. Nothing here is namespace-qualifiable today — plan tenant/router
namespace layout around that rather than around it becoming configurable later.

A few things about `UnderlaySubnet` that are easy to get wrong when wiring up a new external VLAN
this way:

- **One VLAN ID per `ProviderNetwork`.** Each `UnderlaySubnet` creates a `Vlan` object scoped to
  its `ProviderNetwork`. Reusing a VLAN ID that's already owned by something else on that same
  `ProviderNetwork` — another `UnderlaySubnet`, or a hand-created `Vlan` — leaves one of the two in
  `CONFLICT`, and the VPC never gets a working logical switch on that VLAN. Repurposing an old
  VLAN means fully deleting whatever owned it first, not just adding the new object.
- **No built-in DHCP.** The `UnderlaySubnet` CRD has no DHCP field, and its generated kube-ovn
  `Subnet` comes up with DHCP off. That's irrelevant to the router itself (its `localIPs` are
  assigned directly), but matters for anything else that needs to self-configure on the same VLAN
  — a device with no annotation-based IPAM needs either `enableDHCP: true` patched onto the
  generated `Subnet` directly, or a static address of its own.
- **Static addresses need `excludeIPs`.** Anything statically addressed on the VLAN outside the
  `UnderlaySubnet`'s own IPAM should go in `spec.excludeIPs` — otherwise kube-ovn can hand that
  same address to a pod it manages, and that pod's CNI ADD fails with `IP address ... has already
  been used by host with MAC ...` until the conflict is cleared. The field is on the CRD, but the
  dashboard's `UnderlaySubnet` form doesn't expose it — set it via `kubectl`/YAML.

### Choosing between them

`evpn` is the right default when a router manages many VPCs, or when avoiding per-tenant
external VLAN/VRF wiring on the fabric matters — its EVPN relay can be an in-cluster,
operator-managed route reflector, with no dependency on external fabric configuration.
`bgp-per-vrf` is simpler to reason about (no encapsulation) and fits a small, fixed set of
VPCs where the fabric already has VLAN capacity to spare. Both modes give the same isolation
guarantees, including for VPCs with overlapping address ranges.

## The virtual-IP (anycast) plane

Independent of which transit mode is active, `AZEdgeRouter` carries a second advertisement
plane for service virtual IPs. In-VPC speakers (for example MetalLB or FRR) advertise static
anycast blocks into the router's per-VPC VRF; the router re-advertises them, region-local, to
a **separate** external peer than the one carrying OVN subnets — so a VIP advertised in one
region is never confused with the same VIP's advertisement in another. This plane, and how it
is filtered so a region only ever advertises its own VIPs, works identically in both transit
modes.

## Per-VPC egress control

### Whether a VPC gets egress at all (`bgp-per-vrf`)

In `bgp-per-vrf` mode, egress is not a separate toggle — it falls out of which fabric peer(s) on
a VPC's own VLAN are marked as **default-route candidates**
(`spec.perVRFTransit.vpcVLANs[].peers[].defaultRoute`). A peer defaults to being a candidate
unless explicitly set `false`; every candidate gets installed as an ECMP default route inside the
VPC's VRF. Setting `defaultRoute: false` on **every** peer for a VPC means no default route is
ever installed, so there is no egress path at all for that VPC — nothing to masquerade or SNAT
against, deliberately. This is the receive-only / transit-only shape: a VPC that only needs its
subnets or anycast blocks advertised outward, with no path back to the internet.

`defaultRoute` is independent from `advertiseOVNSubnets` / `advertiseAnycast` on purpose: a
**SNAT-only transit peer** — one that advertises neither the VPC's subnets nor its anycast
blocks, but is still the default-route candidate — is a real, supported shape (egress works,
nothing about the VPC is reachable from the fabric), and is exactly as valid as the more common
"advertises everything and is the default route" peer. The three axes (`advertiseOVNSubnets`,
`advertiseAnycast`, `defaultRoute`) are set independently per peer, so a VPC can mix a transit
peer, a service peer, a receive-only peer, and a SNAT-only peer on the same shared VLAN as
needed — see [Choosing between them](#choosing-between-them) and the
[`bgp-per-vrf`](#bgp-per-vrf) section above for the shared-VLAN mechanics this builds on.

### Which source address egress uses

A VPC's outbound traffic normally leaves masqueraded to the router's own address (whichever peer
carries the default route). Two optional overrides narrow that further — orthogonal to whether
egress exists at all, above; these only matter once it does:

- **`spec.vpcs.list[].egressToSource`** — a single fixed source IP for the whole VPC.
- **`spec.vpcs.list[].egressToSourceBySubnet`** — a distinct source IP **per subnet**, with one
  address per router replica. This is the one to reach for once a router runs more than one
  replica: because a flow's request and its reply are not guaranteed to land on the same
  replica, a single shared address cannot always be un-NATed correctly on return — a per-replica
  address can.

## Regional topology, visualized

The diagram below shows a two-region `bgp-per-vrf` deployment: two `AZEdgeRouter` instances
(one per region), each serving three VPCs over their own dedicated external VLAN and internal
transit VRF, plus the external/inter-region peers each router advertises to.

![AZ Edge Router: bgp-per-vrf, two regions, per-VPC VRFs](kubev-az-edge-router.png)

## MetalLB + external fabric peering, visualized

The diagram below zooms into one VPC (`tenant-a`) on one `AZEdgeRouter`, in `bgp-per-vrf` mode,
to show how the two BGP planes described above actually share one VLAN and one VRF: a MetalLB
speaker inside the VPC advertises an anycast VIP over an in-VPC iBGP session into the router's
`VRF: tenant-a`, and the router re-advertises it — separately from the VPC's OVN subnets — to two
external fabric peers on the *same* underlay VLAN, split purely by the peer's
`advertiseOVNSubnets` / `advertiseAnycast` flags (`spec.perVRFTransit.vpcVLANs[].peers[]`).

![AZEdgeRouter: MetalLB VIP advertisement and external fabric peering, one VPC, one VRF](az-edge-router-metallb-fabric-peering.png)

## Configuration examples (k8c backend)

The examples below use the `virtualization.k8c.io` wrapper `VPC` object (the k8c backend) —
`spec.vpcs.list[].name` and `spec.vpcs.labelSelector` resolve directly against `VPC` objects
in the **same namespace** as the `AZEdgeRouter` itself; there is no name translation to worry
about.

### VPC discovery: auto-discovery vs. an explicit list

**Auto-discovery** attaches every `VPC` matching a label selector, so onboarding a new tenant
is just labeling its `VPC` object — no `AZEdgeRouter` edit required:

```yaml
apiVersion: routing.virtualization.k8c.io/v1alpha1
kind: AZEdgeRouter
metadata:
  name: az-edge-router-region-a
  namespace: edge-frr
spec:
  replicaCount: 2
  ovnTransitMode: bgp-per-vrf
  vpcs:
    autoDiscovery: true
    labelSelector:
      matchLabels:
        virtualization.k8c.io/az-router: "true"
    # Restrict which of each VPC's subnets THIS region's router advertises —
    # required whenever the same VPC is served by more than one regional router.
    subnetLabelSelector:
      matchLabels:
        topology.kubernetes.io/zone: region-a
  # ... perVRFTransit / transitSubnet / image, omitted for brevity
---
apiVersion: virtualization.k8c.io/v1alpha1
kind: VPC
metadata:
  name: tenant-a
  namespace: edge-frr
  labels:
    virtualization.k8c.io/az-router: "true"
spec: {}
```

**An explicit list** is the better fit when VPC attachment should be a deliberate, reviewed
change rather than implicit from a label — for example a small, fixed set of tenants:

```yaml
apiVersion: routing.virtualization.k8c.io/v1alpha1
kind: AZEdgeRouter
metadata:
  name: az-edge-router-region-a
  namespace: edge-frr
spec:
  replicaCount: 2
  ovnTransitMode: bgp-per-vrf
  vpcs:
    autoDiscovery: false
    list:
      - name: tenant-a
      - name: tenant-b
```

### Subnet discovery: `subnetLabelSelector`

VPC discovery decides *which VPCs* a router attaches to; `spec.vpcs.subnetLabelSelector`
decides *which of that VPC's subnets* the router actually advertises. The two are
independent — it applies the same way whether the VPC itself was found via
`autoDiscovery` or listed explicitly, and it is evaluated **per VPC, every reconcile**,
against the labels on each of that VPC's wrapper `Subnet` objects (in the same namespace
as the VPC).

This is what lets more than one regional `AZEdgeRouter` serve the *same* VPC without
double-advertising each other's routes: a VPC that spans two regions has some subnets
labelled `topology.kubernetes.io/zone: region-a` and others `region-b`; each region's
router only installs FRR static routes for the subnets matching its own
`subnetLabelSelector`, even though both routers resolve the VPC itself.

```yaml
apiVersion: routing.virtualization.k8c.io/v1alpha1
kind: AZEdgeRouter
metadata:
  name: az-edge-router-region-a
  namespace: edge-frr
spec:
  vpcs:
    autoDiscovery: true
    labelSelector:
      matchLabels:
        virtualization.k8c.io/az-router: "true"
    subnetLabelSelector:
      matchLabels:
        topology.kubernetes.io/zone: region-a
---
apiVersion: virtualization.k8c.io/v1alpha1
kind: Subnet
metadata:
  name: tenant-a-workloads
  namespace: edge-frr
  labels:
    topology.kubernetes.io/zone: region-a   # advertised by az-edge-router-region-a
spec:
  vpc: tenant-a
---
apiVersion: virtualization.k8c.io/v1alpha1
kind: Subnet
metadata:
  name: tenant-a-workloads-b
  namespace: edge-frr
  labels:
    topology.kubernetes.io/zone: region-b   # NOT advertised by az-edge-router-region-a
spec:
  vpc: tenant-a
```

{{% notice info %}}
Omitting `subnetLabelSelector` entirely includes every subnet of the VPC — there is no implicit
"unset = advertise nothing" behavior, so a single-region deployment can simply leave it out.
{{% /notice %}}

{{% notice note %}}
A VPC with zero matching subnets still resolves. It still gets a transit `/30` (or larger, see
below) and a `status.resolvedAZVPCs` entry — the entry's `subnets` field is just empty. This is
deliberate: it keeps the transit NIC and VRF wiring in place even during a rollout where subnets
are being relabelled one at a time, rather than flapping the VPC's attachment.
{{% /notice %}}

The selector matches labels on the `Subnet` object itself, not on the VPC. Two subnets of the
same VPC can be labelled for different regions (as above) or left unlabelled to be picked up by
every router that has no `subnetLabelSelector` at all.

### Egress SNAT

By default a VPC's outbound traffic leaves masqueraded to the router replica's own address.
Two optional overrides narrow that, both set per VPC in `spec.vpcs.list[]`:

**`egressToSource`** — one fixed address for the whole VPC, identical on every replica.

{{% notice warning %}}
Only safe with `replicaCount: 1`. It is a plain secondary address assigned to an interface, not
a BGP-advertised route — with more than one replica, a reply is not guaranteed to land back on
the replica that sent the original request, and there is no routing mechanism to fix that up.
See [Per-VPC egress control](#per-vpc-egress-control) above, and prefer
`egressToSourceBySubnet` once `replicaCount > 1`.
{{% /notice %}}

```yaml
spec:
  vpcs:
    autoDiscovery: false
    list:
      - name: tenant-a
        egressToSource: "10.200.0.70"
```

**`egressToSourceBySubnet`** — a distinct source address **per subnet**, with one address per
replica, keyed by the subnet's own canonical CIDR. This is the compliance/allowlisting case: one
specific subnet needs a stable, distinct external identity without giving it its own dedicated
egress VLAN. With `replicaCount: 2`, each entry needs exactly two addresses:

```yaml
spec:
  replicaCount: 2
  vpcs:
    autoDiscovery: false
    list:
      - name: tenant-a
        egressToSourceBySubnet:
          "10.53.2.0/24":       # must be one of tenant-a's own subnets
            - "10.202.0.20"     # replica 0
            - "10.202.0.21"     # replica 1
```

{{% notice warning %}}
Every address used here must also be excluded from the relevant Subnet's own IPAM pool
(`spec.excludeIps`) so it can never be handed out to an unrelated NIC — the operator does not
do this for you.
{{% /notice %}}

## Where to go next

- The full field-by-field specification lives in the
  [CRD reference](../../../../references/crds/#azedgerouter).
- For the network models `AZEdgeRouter` builds on, see [VPCs and Subnets](../vpc-subnets/) and
  [VM Network Assignment](../vms-networks-assignment/).
