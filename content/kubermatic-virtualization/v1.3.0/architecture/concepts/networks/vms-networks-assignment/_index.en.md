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
        # <provider>.kubernetes.io/logical_switch names the subnet's real name
        vm-namespace-my-vm-subnet-sn.vm-namespace.ovn.kubernetes.io/logical_switch: vm-namespace-my-vm-subnet-sn
        # Optional: a static IP address from the subnet
        # vm-namespace-my-vm-subnet-sn.vm-namespace.ovn.kubernetes.io/ip_address: 10.10.0.10
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

- `<provider>.kubernetes.io/routes`: Extra routes for the interface, as a JSON list of `dst` and `gw` entries, such as
`[{"dst":"192.168.50.0/24","gw":"10.10.0.254"}]`.

---

### 6. Attaching a VM directly to an underlay VLAN (`UnderlaySubnet`)

Everything above assigns a VM to an **overlay** Subnet, routed through a `Vpc`. A VM that needs a NIC directly on a
physical VLAN, such as a nested hypervisor or a bridged appliance, attaches to an
[`UnderlaySubnet`](../vpc-subnets/underlay-subnet/) instead. It generates a NAD named `usn-<namespace>-<name>` in its own
namespace.

For an `UnderlaySubnet` named `underlay-vlan18` in `tenant-a`, a VM attaches exactly like the NAD-based flow in step 4/5
above, by referencing `usn-tenant-a-underlay-vlan18`. Unlike a VPC subnet, an underlay NIC has no VPC router to hand it a default route,
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
          [{"dst":"0.0.0.0/0","gw":"192.168.200.1"}]
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

See [Things that are easy to get wrong](../vpc-subnets/underlay-subnet/#things-that-are-easy-to-get-wrong) on the
`UnderlaySubnet` page for VLAN ID conflicts, DHCP and `excludeIPs`. Everything that references an `UnderlaySubnet`
by name, such as `AZEdgeRouter`'s `spec.perVRFTransit.vpcVLANs[].underlaySubnet`, resolves it in its own namespace.

{{% notice note %}}
In a KDP project, create VMs from the KubeV dashboard. The subnet's NAD is created in the project's namespace on the
KubeV cluster, not in the namespace you see in KDP, and the dashboard fills in the right names.
{{% /notice %}}
