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

```yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: my-kubeovn-vm-multus
  namespace: vm-namespace
  annotations:
    # Reference the NetworkAttachmentDefinition for the primary interface
    # The format is <namespace>/<nad-name>
    k8s.v1.cni.cncf.io/networks: vm-network
    # Optional: For static IP assignment from the subnet
    # ovn.kubernetes.io/ip_address: 10.10.0.10
spec:
  runStrategy: Always
  template:
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

