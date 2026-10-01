+++
title = "Regional Scheduling"
date = 2026-09-11T00:00:00+00:00
weight = 17
+++

VMs on a multi-region cluster generally need to run in the same region as the Kube-OVN Subnet they're attached to
— a VM scheduled to a node in the wrong region can end up with a network path that has to cross regions just to
reach its own gateway. `enforceRegionalScheduling` is an opt-in installer setting that has Kubermatic-Virtualization
enforce this automatically, without every workload having to set its own `nodeSelector`.

### Enabling it

Set `kubevirt.enforceRegionalScheduling: true` in the installer config:

```yaml
kubevirt:
  enforceRegionalScheduling: true
```

This deploys one Kyverno `ClusterPolicy` (`enforce-vm-regional-scheduling`) plus the RBAC it needs
(`kyverno:subnet-reader`, bound to both the Kyverno admission and background controller service accounts — Kyverno
3.x splits these into separate controllers with separate SAs, and the `apiCall` context lookup below needs both).

### How it decides where a VM belongs

The policy is opt-in **per Subnet**, not cluster-wide: it only acts on a VM if the `Subnet` its NIC references
carries a `topology.kubernetes.io/region` label.

```yaml
apiVersion: kubeovn.io/v1
kind: Subnet
metadata:
  name: my-vm-subnet
  labels:
    topology.kubernetes.io/region: region-a
spec:
  cidrBlock: 10.10.0.0/24
  namespaces:
    - vm-namespace
```

A Subnet with no `topology.kubernetes.io/region` label is invisible to this policy — VMs on it are scheduled
freely, as if `enforceRegionalScheduling` were off. This is what makes the feature safe to turn on cluster-wide:
only the subnets an operator has explicitly labeled start enforcing regional placement.

For a VM on that Subnet, Kyverno mutates it on `CREATE`, injecting:

```yaml
spec:
  template:
    spec:
      nodeSelector:
        topology.kubernetes.io/region: region-a   # copied from the Subnet's label
```

Nodes need the matching `topology.kubernetes.io/region` label themselves — usually already set by whatever
provisioned the cluster (a per-region kubeone/KKP node label), not something this feature applies for you. Without
a matching node, an otherwise-valid VM just goes `Pending` with an unsatisfiable node selector.

### The annotation has to be in two places

{{% notice warning %}}
`ovn.kubernetes.io/logical_switch` must be set on **both** the `VirtualMachine`'s own `metadata.annotations`
**and** `spec.template.metadata.annotations` — setting it in only one place makes the policy silently skip the VM
(no error, no mutation, no nodeSelector applied).
{{% /notice %}}

This isn't a redundant restatement — the two copies do different jobs, and Kyverno reads them from different
places:

- **`metadata.annotations`** (the `VirtualMachine` object's own annotations) is what the policy's `match` block
  checks to decide whether this rule applies to the VM at all.
- **`spec.template.metadata.annotations`** (the pod template — the same place every other Kube-OVN/Multus
  annotation from [VMs Network Assignment]({{% relref "../vms-networks-assignment" %}}) has to live) is what the
  policy's `apiCall` context reads to look up the actual `Subnet` object and its region label.

```yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: my-regional-vm
  namespace: vm-namespace
  annotations:
    ovn.kubernetes.io/logical_switch: my-vm-subnet   # (1) triggers the policy's match
spec:
  runStrategy: Always
  template:
    metadata:
      annotations:
        ovn.kubernetes.io/logical_switch: my-vm-subnet   # (2) resolves the Subnet + region label
    spec:
      domain:
        resources:
          requests:
            memory: 2Gi
```

If a VM instead reaches its Subnet purely through namespace binding (Option 1 in
[VMs Network Assignment]({{% relref "../vms-networks-assignment" %}})) rather than an explicit
`ovn.kubernetes.io/logical_switch` annotation, the policy has nothing to match on and does not pin it — the
annotation is required for regional scheduling even if it wouldn't otherwise be needed to reach the right Subnet.
