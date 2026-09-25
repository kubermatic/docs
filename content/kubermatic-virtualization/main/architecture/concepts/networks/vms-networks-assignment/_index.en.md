+++
title = "VMs Network Assignment"
date = 2025-07-18T16:06:34+02:00
weight = 15
+++

Assigning a Virtual Machine (VM) to a VPC and Subnet typically involves integrating VM’s network interface using 
Multus CNI with a Kube-OVN network attachment definition (NAD). Assigning a Virtual Machine (VM) to a VPC and
Subnet involves a few key steps:

### 1. Define or use an existing VPC:

If you require isolated network spaces for different tenants or environments, you'll first define a Vpc resource. 
This acts as a logical router for your Subnets.
```yaml
apiVersion: kubeovn.io/v1
kind: Vpc
metadata:
  name: my-vpc # Name of your VPC
spec:
  # Optional: You can specify which namespaces are allowed to use this VPC.
  # If left empty, all namespaces can use it.
  # namespaces:
  #   - my-namespace
  #   - my-namespace-1
```
---

### 2. Define or use an existing Subnet:

Next, you create a Subnet resource, associating it with your Vpc (or the default ovn-cluster VPC if you're not using a 
custom VPC). You also define the CIDR range and, crucially, the Namespaces that will use this Subnet.
```yaml
apiVersion: kubeovn.io/v1
kind: Subnet
metadata:
  name: my-vm-subnet # Name of your Subnet
spec:
  # Associate this subnet with your VPC. If omitted, it defaults to 'ovn-cluster'.
  vpc: my-vpc
  cidrBlock: 10.10.0.0/24 # The IP range for this subnet
  gateway: 10.10.0.1 # The gateway IP for this subnet (Kube-OVN often sets this automatically)
  namespaces:
    - vm-namespace # The Namespace where your VMs will reside
```

---
### 3. Create a Kubernetes Namespace (if it doesn't exist):

Ensure the Namespace you defined in your Subnet exists.
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: vm-namespace
```

---

### 4. Define a NetworkAttachmentDefinition:

While Kube-OVN can work directly by binding a Namespace to a Subnet, using a NetworkAttachmentDefinition (NAD) with 
Multus provides more explicit control, especially if your VM needs multiple network interfaces or a specific CNI configuration.

```yaml
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  name: vm-network # Name of the NAD
  namespace: vm-namespace # Must be in the same namespace as the VMs using it
spec:
  config: |
    {
      "cniVersion": "0.3.1",
      "name": "vm-network",
      "type": "kube-ovn",
      "server_socker": "/run/openvswitch/kube-ovn-daemon.sock",
      "netAttachDefName": "vm-namespace/vm-network"
    }
```
{{% notice note %}}
Note: For a VM to automatically pick up the correct Subnet via the Namespace binding, you often don't strictly
need a `NetworkAttachmentDefinition` for the primary interface if the Namespace is directly linked to the Subnet. However, 
it's crucial for secondary interfaces or explicit network definitions.
{{% /notice %}}

---

### 5. Assign the KubeVirt Virtual Machine to the Subnet/VPC:

When defining your `VirtualMachine` (or `VirtualMachinePool`), you ensure it's created in the `vm-namespace` that is 
bound to your `my-vm-subnet`.

#### Option 1: Relying on Namespace-Subnet Binding (Simplest)

If your `vm-namespace` is explicitly listed in the `spec.namespaces` of `my-vm-subnet`, any `VM` (or `Pod`) created in 
`vm-namespace` will automatically get an IP from `my-vm-subnet`.

#### Option 2: Explicitly Specifying the Subnet/NAD via Annotations (For Multiple NICs or Specificity)

If you're using a `NetworkAttachmentDefinition` (`NAD`) or need to explicitly control which subnet is used, especially 
for secondary interfaces, you'd use Multus annotations on your `VM` definition.

{{% notice warning %}}
Kube-OVN and Multus annotations configure the VM's **launcher pod**, not the `VirtualMachine` object itself — they
must go on `spec.template.metadata.annotations`, not the top-level `metadata.annotations`. An annotation on the
`VirtualMachine` object is silently ignored for networking purposes.
{{% /notice %}}

```yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: my-kubeovn-vm-multus
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
            - name: primary-nic
              # This interface will use the network defined by the NAD
              bridge: {} # Or masquerade: {}
            # Example for a secondary NIC on a different Kube-OVN Subnet/NAD
            # - name: secondary-nic
            #   bridge: {}
        resources:
          requests:
            memory: 2Gi
      volumes:
        - name: containerdisk
          containerDisk:
            image: kubevirt/fedora-cloud-container-disk-demo
        - name: cloudinitdisk
          cloudInitNoCloud:
            userData: |
              #cloud-config

```
Important Kube-OVN Annotations for VMs/Pods:

- `ovn.kubernetes.io/logical_switch`: Explicitly assigns the workload to a specific Kube-OVN logical switch (which 
corresponds to a Subnet). This overrides the Namespace's default subnet.

- `ovn.kubernetes.io/ip_address`: Assigns a specific static IP address from the subnet. Make sure this IP is excluded from 
the subnet's dynamic IP range (excludeIps in the Subnet definition) to avoid conflicts.

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

