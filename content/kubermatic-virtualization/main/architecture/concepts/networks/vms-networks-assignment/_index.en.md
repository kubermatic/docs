+++
title = "VMs Network Assignment"
date = 2025-07-18T16:06:34+02:00
weight = 15
+++

Assigning a Virtual Machine (VM) to a VPC and Subnet involves integrating the VM's network interface using
Multus CNI with the NetworkAttachmentDefinition (NAD) that KubeV creates for each subnet. The dashboard does all of
this when you pick a VPC and a subnet for a VM's network interface. With `kubectl`, it takes a few steps.

The examples use the namespace `vm-namespace`, the VPC `my-vpc` and the subnet `my-vm-subnet`.

### 1. Create a Kubernetes Namespace (if it doesn't exist):

VPCs, subnets and the VMs that use them live in the same Namespace.
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: vm-namespace
```

---

### 2. Define or use an existing VPC:

If you require isolated network spaces for different tenants or environments, you'll first define a VPC resource.
This acts as a logical router for your Subnets.
```yaml
apiVersion: virtualization.k8c.io/v1alpha1
kind: VPC
metadata:
  name: my-vpc # Name of your VPC
  namespace: vm-namespace
spec: {}
```
---

### 3. Define or use an existing Subnet:

Next, you create a Subnet resource in the same Namespace, associating it with your VPC, and define its CIDR range.
```yaml
apiVersion: virtualization.k8c.io/v1alpha1
kind: Subnet
metadata:
  name: my-vm-subnet # Name of your Subnet
  namespace: vm-namespace
spec:
  vpcRef: my-vpc # The VPC this subnet belongs to, in the same namespace
  cidrBlock: 10.10.0.0/24 # The IP range for this subnet
  gateway: 10.10.0.1 # The gateway IP for this subnet
```

Wait until the subnet is `Ready`, and note its real name:

```bash
kubectl get subnets.virtualization.k8c.io -n vm-namespace my-vm-subnet \
  -o jsonpath='{.status.phase} {.status.realName}{"\n"}'
```
```
Ready vm-namespace-my-vm-subnet-sn
```

---

### 4. Find the subnet's NetworkAttachmentDefinition:

You don't create the NAD yourself. Once the subnet is `Ready`, KubeV creates one in the subnet's Namespace, named after
the subnet's real name:

```bash
kubectl get network-attachment-definitions -n vm-namespace
```
```
NAME                           AGE
vm-namespace-my-vm-subnet-sn   1m
```

Its Kube-OVN provider is `<NAD name>.<namespace>.ovn`, here `vm-namespace-my-vm-subnet-sn.vm-namespace.ovn`. The
VM's annotations below start with it.

---

### 5. Assign the KubeVirt Virtual Machine to the Subnet:

Create the `VirtualMachine` in the same Namespace. Each network interface names the subnet's NAD as its Multus
network, and the pod template names the subnet with Kube-OVN's per-network annotations.

```yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: my-vm
  namespace: vm-namespace
spec:
  runStrategy: Always
  template:
    metadata:
      annotations:
        # Reference the NetworkAttachmentDefinition for the primary interface
        # The format is <namespace>/<nad-name>
        k8s.v1.cni.cncf.io/networks: vm-namespace/vm-network
        # Optional: pins this workload to a specific logical switch (Subnet),
        # overriding the Namespace's default subnet binding.
        # ovn.kubernetes.io/logical_switch: my-vm-subnet
        # Optional: static IP assignment from the subnet -- must also be listed
        # in my-vm-subnet's spec.excludeIps so Kube-OVN's own IPAM skips it.
        # ovn.kubernetes.io/ip_address: 10.10.0.10
    spec:
      domain:
        devices:
          disks:
            - name: containerdisk
              disk:
                bus: virtio
            - name: cloudinitdisk
              disk:
                bus: virtio
          interfaces:
            - name: net0
              bridge: {}
        resources:
          requests:
            memory: 2Gi
      networks:
        - name: net0
          multus:
            # <namespace>/<NAD name>
            networkName: vm-namespace/vm-namespace-my-vm-subnet-sn
            # The first interface replaces the pod network as the VM's primary network
            default: true
      volumes:
        - name: containerdisk
          containerDisk:
            image: kubevirt/fedora-cloud-container-disk-demo
        - name: cloudinitdisk
          cloudInitNoCloud:
            userData: |
              #cloud-config
```

For a second interface on another subnet, add an entry to `interfaces` and `networks` with that subnet's NAD, without
`default: true`, and a `logical_switch` annotation with that subnet's provider.

Kube-OVN annotations for VMs, each prefixed with the provider of the subnet's NAD:

- `<provider>.kubernetes.io/logical_switch`: The subnet the interface attaches to, by its real name.

- `<provider>.kubernetes.io/ip_address`: Assigns a specific static IP address from the subnet. Make sure this IP is
excluded from the subnet's dynamic IP range (`excludeIPs` in the Subnet definition) to avoid conflicts.

- `ovn.kubernetes.io/network_attachment`: When using Multus, this annotation on the `NetworkAttachmentDefinition`'s config 
can specify the Kube-OVN provider or other details if you have multiple Kube-OVN deployments or specific requirements.

---

### 6. Attaching a VM directly to an underlay VLAN (`UnderlaySubnet`)

Everything above assigns a VM to an **overlay** Subnet — one routed through a `Vpc`, reachable only through
whatever routing (an `AZEdgeRouter`, NAT gateway, etc.) that VPC has. Some VMs instead need a NIC directly on a
physical/external VLAN: a nested hypervisor that needs its own routable address, an appliance being bridged in,
or a VM that has to be reachable without going through any VPC's router at all. `UnderlaySubnet.virtualization.k8c.io`
is the CRD for that case — it provisions everything needed to expose one VLAN as a Multus network, without a `Vpc`
or `Vpc`-scoped `Subnet` involved.

```yaml
apiVersion: virtualization.k8c.io/v1alpha1
kind: UnderlaySubnet
metadata:
  name: underlay-vlan18
  namespace: tenant-a
spec:
  vlanID: 18
  cidrBlock: 192.168.200.0/24
  excludeIPs:
    - 192.168.200.1     # physical gateway
    - 192.168.200.164   # a statically-addressed nested VM, kept out of kube-ovn's own IPAM
```

#### Kube-OVN resources an `UnderlaySubnet` manages

One `UnderlaySubnet` CR creates and owns all of the following (all named from
`<namespace>-<name>`, abbreviated below as `<ns>-<name>`):

| Resource | Name | Purpose |
|----------|------|---------|
| `ProviderNetwork.kubeovn.io` | shared per VLAN-capable physical uplink | Binds the VLAN to the node NICs that carry it |
| `Vlan.kubeovn.io` | `<providerNetwork>-v<vlanID>` | One `Vlan` object per VLAN ID on a given `ProviderNetwork` — **not** one per `UnderlaySubnet` |
| `Subnet.kubeovn.io` | `usn-<ns>-<name>` | The actual logical switch/CIDR VMs attach to |
| `NetworkAttachmentDefinition` | `usn-<ns>-<name>` (same namespace) | What a VM's `k8s.v1.cni.cncf.io/networks` annotation references |

A VM attaches to it exactly like the NAD-based flow in step 4/5 above — reference
`k8s.v1.cni.cncf.io/networks: usn-<ns>-<name>` (or pick it from the dashboard's NIC-selection **Underlay** tab,
which lists `UnderlaySubnet`s the same way it lists VPC subnets) — the only difference is which controller
produced the NAD it points at. Unlike a VPC subnet, an underlay NIC has no VPC router to hand it a default route,
so a route into the VLAN needs its own **per-NAD Kube-OVN annotation**, keyed by that NAD's provider name
(`<nadName>.<namespace>.ovn.kubernetes.io/routes`):

```yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: my-underlay-vm
  namespace: tenant-a
spec:
  runStrategy: Always
  template:
    metadata:
      annotations:
        # Selects the UnderlaySubnet's NAD for this interface (Multus)
        k8s.v1.cni.cncf.io/networks: |
          [{"name":"usn-tenant-a-underlay-vlan18","namespace":"tenant-a","interface":"net1"}]
        # Kube-OVN route(s) for THIS NAD specifically -- the annotation key is
        # derived from the NAD's provider name (<nadName>.<namespace>.ovn),
        # not a fixed key, since a VM can have routes on more than one NAD.
        usn-tenant-a-underlay-vlan18.tenant-a.ovn.kubernetes.io/routes: |
          [{"dst":"0.0.0.0/0","gw":"192.168.200.161"}]
      labels:
        kubevirt.io/name: my-underlay-vm
    spec:
      domain:
        devices:
          interfaces:
            - name: external-vlan
              bridge: {}
        resources:
          requests:
            memory: 2Gi
      networks:
        - name: external-vlan
          multus:
            networkName: tenant-a/usn-tenant-a-underlay-vlan18
```

Without the `routes` annotation the interface still comes up and gets an address from the `UnderlaySubnet`'s
IPAM, but nothing outside its own subnet is reachable — there's no VPC router to fall back on the way there is
for an overlay Subnet.

{{% notice warning %}}
Only **one `Vlan` object per VLAN ID per `ProviderNetwork`** is valid. If a VLAN ID is already owned by something
else on that `ProviderNetwork` — another `UnderlaySubnet`, or a hand-created `Vlan` — Kube-OVN marks one of the two
`CONFLICT` and neither gets a working logical switch. Reusing a VLAN ID means fully deleting whatever owned it
first, not just creating the new `UnderlaySubnet`.
{{% /notice %}}

A few things that are easy to miss when using an `UnderlaySubnet`:

- **No built-in DHCP.** The generated `Subnet` comes up with `enableDHCP` unset — fine for anything Kube-OVN
  itself assigns an address to, but anything else on the VLAN that needs to self-configure (a device behind a
  nested hypervisor, for example) needs either `enableDHCP: true` patched onto the generated `Subnet` directly, or
  a static address of its own.
- **Static addresses need `excludeIPs`.** Anything statically addressed on the VLAN outside Kube-OVN's own IPAM
  must go in `spec.excludeIPs` (shown above) — otherwise Kube-OVN can hand that same address to a pod it manages,
  and that pod's CNI `ADD` fails with `IP address ... has already been used by host with MAC ...` until the
  conflict is cleared. The field exists on the CRD and is wired through to the generated `Subnet`, but the
  dashboard's create/edit form for `UnderlaySubnet` doesn't expose it — set it via `kubectl`/YAML.
- **Everything referencing an `UnderlaySubnet` resolves in its own namespace.** There's no cross-namespace lookup
  for `UnderlaySubnet` names — a consumer (like `AZEdgeRouter`'s `spec.perVRFTransit.vpcVLANs[].underlaySubnet`)
  must live in the same namespace as the `UnderlaySubnet` it names.

- `<provider>.kubernetes.io/routes`: Extra routes for the interface, as a JSON list of `dst` and `gw` entries, such as
`[{"dst":"192.168.50.0/24","gw":"10.10.0.254"}]`.

{{% notice note %}}
In a KDP project, create VMs from the KubeV dashboard. The subnet's NAD is created in the project's namespace on the
KubeV cluster, not in the namespace you see in KDP, and the dashboard fills in the right names.
{{% /notice %}}
