+++
title = "Firewall Rules"
date = 2026-08-25T00:00:00+00:00
weight = 1
+++

This guide explains how firewall rules control network access to and from virtual
machines in Kubermatic Virtualization, and how to manage them from the dashboard.

## Overview

A firewall rule controls which traffic may reach a virtual machine, and which traffic that
machine may send. Every rule sets four things:

| Part | What it sets |
| --- | --- |
| **Direction** | Inbound or outbound. |
| **Target** | The VM or VM pool the rule applies to. |
| **Source** / **Destination** | Where the traffic comes from, or goes to. |
| **Ports and protocols** | What the rule permits. |

Manage rules from the **Firewalls** page. Each VM also lists the rules that apply to it on
its own **Networking** tab.

Behind each rule is a Kubernetes `NetworkPolicy` in the VM's namespace, labelled
`kubevirt-manager.io/managed=true`. The Firewalls list shows the policies carrying that
label, including ones too detailed for the form — see
[Rules that open as YAML](#rules-that-open-as-yaml).

## How rules combine

Two things matter more than any individual setting:

**Rules allow traffic.** There is no deny rule. You open what you need, and everything else
stays closed.

**Rules are additive.** When several rules target the same VM, traffic is permitted if
*any* of them allows it. Adding a rule opens more traffic, never less.

So to restrict a VM, turn its firewall on and then add rules for what you want to permit.
The switch covers inbound traffic; for the other direction see
[Outbound rules and DNS](#outbound-rules-and-dns).

## Turning a VM's firewall on and off

Open the VM, go to the **Networking** tab, and use the **Firewall** switch.

| Switch | What it means |
| --- | --- |
| **Off** | The VM accepts all inbound traffic. This is the default for a new VM. |
| **On** | Inbound traffic is blocked unless one of the VM's rules allows it. |
| **Unavailable** | The VM was created outside this dashboard, so it does not carry the label firewall rules select on. See [Which VMs can be targeted](#which-vms-can-be-targeted). |

Switching it on creates a policy named `<vm-name>-vm-default-deny`, listed under
**Firewalls** as **Default deny**. Switching it off deletes that policy again, and so does
deleting the row from the Firewalls list. The delete dialog tells you what to expect first:
either the VM opens to all inbound traffic, or it stays closed because other inbound rules
still apply.

The switch covers **inbound** traffic only. What the VM sends stays unrestricted until you
add an outbound rule.

{{% notice note %}}
A VM also closes as soon as you add its first inbound rule, even with the switch off — that
is how Kubernetes network policies work. The **Networking** tab tells you when a VM is closed
this way, and deleting that last rule opens it again. Use the switch when you want the VM
closed deliberately and kept that way, whatever happens to its rules.
{{% /notice %}}

## Creating a rule

Go to **Firewalls** and choose **New Firewall Rule**.

| Field | What it does |
| --- | --- |
| **Name** | Identifies the rule. Lowercase letters, numbers and hyphens, fixed once created. Names ending in `-default-deny` or `-allow-dns` are reserved for the policies the platform manages. |
| **Direction** | **Inbound** controls traffic arriving at the target. **Outbound** controls traffic the target sends. |
| **Target Type** / **Target** | The VM or VM pool the rule applies to: the receiver for an inbound rule, the sender for an outbound one. |
| **Source** / **Destination** | Where the traffic comes from or goes to. See the table below. |
| **All ports** | Allow every port for the chosen peer, instead of listing them. |
| **From port** / **To port** / **Protocol** | The ports to permit. Leave **To port** empty for a single port, or set it for a range. |
| **Strict enforcement** | See [Ping and DHCP](#ping-and-dhcp). Leave this off unless you need full isolation. |
| **Labels** | Optional labels for your own grouping. The `fw.kubevirt-manager.io/` prefix is reserved for the platform. |

The source or destination can be:

| Type | Matches |
| --- | --- |
| **IP range** | A CIDR, such as `10.0.0.0/8` or `2001:db8::/32`. |
| **Virtual Machine** / **VM Pool** | Another VM or pool in the same namespace. |
| **Namespace** | Every workload in the named namespace. |
| **Anywhere** | Any address. Use this to open a port to the world. |

When a rule is the one that closes its target, the form says so before you save: the target
*"allows all inbound traffic today"* (or outbound), and afterwards anything not listed below
is blocked. A target already closed in that direction — by the Firewall switch, or by an
earlier rule — needs no such warning, so you do not see it again.

### Port ranges

Set **From port** and **To port** for a contiguous range, for example `30000` to `32767`
for Kubernetes NodePorts. Leave **To port** empty for a single port.

Add a row for each further port or protocol, up to eight rows per rule. Need more? Put them
in a second rule against the same target — rules are additive, so the two add up.

## Ping and DHCP

New rules use a relaxed enforcement mode, which filters `TCP`, `UDP` and `SCTP` and lets
other IP traffic through. That keeps **ping and DHCP working** on a firewalled VM whatever
the rules say, which is almost always what you want:

* Kubernetes network policies name only `TCP`, `UDP` and `SCTP`, so no port row can describe
  ping.
* A VM whose DHCP traffic is blocked cannot renew its address lease.

Tick **Strict enforcement** when you need complete isolation. It blocks every IP protocol
except what the rules permit, ping and DHCP included.

| Mode | Enforces | Stored as |
| --- | --- | --- |
| Relaxed (default) | The rules, on `TCP`, `UDP` and `SCTP`. Other IP traffic — ping included — is allowed. | Annotation `ovn.kubernetes.io/network_policy_enforcement: "lax"` on the policy |
| Strict | The rules alone, on every IP protocol | No such annotation |

{{% notice note %}}
Relaxed and strict are a Kube-OVN feature. What a policy without the annotation means is set
cluster-wide by the Kube-OVN controller's `--np-enforcement` flag, which defaults to
`standard` — the setting that makes such a rule strict. Confirm it before relying on a strict
rule for isolation:

```bash
kubectl -n kube-system get deploy kube-ovn-controller \
  -o jsonpath='{.spec.template.spec.containers[0].args}' | tr ',' '\n' | grep np-enforcement
```
{{% /notice %}}

## Outbound rules and DNS

An outbound rule permits what it lists and closes everything else the target sends — DNS
queries included, which would leave the VM unable to resolve names. So the first outbound
rule you create for a target comes with a companion policy that keeps DNS working, named
`<vm-name>-vm-allow-dns` (or `<pool-name>-pool-allow-dns` for a pool) and listed as
**System DNS**.

The platform maintains it for you, and **View YAML** shows what it allows. Deleting the
target's last outbound rule removes it automatically. You can also delete it from the
Firewalls list yourself, where the dialog tells you what the removal will do.

## Editing and deleting rules

Use the actions menu on any rule to edit it in the form, view or edit its YAML, or delete
it. System rows — **Default deny** and **System DNS** — offer **View YAML** and **Delete**,
since the platform keeps their contents in step with your rules.

A rule's **name, direction and target are fixed** once created. Opening a rule for editing
shows those fields greyed out, and the form says why: *"Name, direction and target identify a
rule and cannot be changed. Delete this rule and create a new one to move it."* To rename or
retarget a rule, create a replacement and delete the original.

Deleting tells you what will change before you confirm — that a VM will accept all inbound
traffic again because this was its last inbound rule, for example, or that a system DNS
allowance goes with the outbound rule that needed it.

{{% notice note %}}
Saving the form rebuilds the policy from the fields on screen, and what you see is the whole
rule: the port rows and the one source or destination are all of it. Labels and annotations
already on the policy are carried over.

Both editors work from the version they fetched when you opened the rule, so a rule someone
changed in the meantime is never silently overwritten. The form reports *"This rule changed
since you opened it — reload and reapply your edit"*. The YAML editor offers a **Load latest
version** button, which re-fetches the rule so you can redo your change on top of it.
{{% /notice %}}

## Rules that open as YAML

The form covers one direction, one target, one peer and a list of ports — what the Firewalls
table can display accurately. A rule beyond that opens in the YAML editor instead: several
sources in one rule, several rule blocks, `ipBlock` exceptions, or named ports. The cluster
enforces those policies as usual, the list keeps showing them, and the YAML editor is where
you change them.

Because rules are additive, anything you can express as several simple rules is best written
that way.

## Verifying a rule

To confirm a rule is enforced, send traffic from a source that should be allowed and from
one that should not, then check the policy behind it:

```bash
kubectl -n <namespace> get networkpolicy <rule-name> -o yaml
```

A rule that matches no VM is still created, and then has nothing to act on. The form tells
you which case you are in while you are still filling it in, underneath the **Target** field:

| Message | Meaning |
| --- | --- |
| *"Applies to 1 virtual machine."* | The rule will be enforced. |
| *"Matches no virtual machine — this rule will have no effect until one exists."* | No VM of that name exists in the namespace yet. Check the name for a typo. |
| *"This virtual machine cannot be targeted by a firewall rule: it was not created here, so it does not carry the label rules select on."* | See [Which VMs can be targeted](#which-vms-can-be-targeted). |

This line covers **Virtual Machine** targets. For a VM pool, check the pool name as you type
it and confirm the policy afterwards with the `kubectl` command above.

### Which VMs can be targeted

A firewall rule selects VMs by the label `fw.kubevirt-manager.io/vm-name`, whose value is the
VM's own name. The dashboard sets it on `spec.template.metadata.labels`, so the VM's pod
carries it and a policy's `podSelector` matches. A VM created another way — by `kubectl`, a
manifest, or an import — has no such label yet, and its **Firewall** switch reads
**Unavailable**.

Add the label to bring such a VM into scope:

```bash
kubectl -n <namespace> patch virtualmachine <vm-name> --type=merge \
  -p '{"spec":{"template":{"metadata":{"labels":{"fw.kubevirt-manager.io/vm-name":"<vm-name>"}}}}}'
```

The value has to equal the VM's name, since that is what a rule's selector is built from. The
label lands on the pod template, so restart the VM for its running pod to pick it up.

VM pools work the same way, with `fw.kubevirt-manager.io/pool-name` carrying the pool's name.
For a pool the label belongs on `spec.virtualMachineTemplate.spec.template.metadata.labels`.
