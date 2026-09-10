+++
title = "Firewall Rules"
date = 2026-08-25T00:00:00+00:00
weight = 1
+++

This guide explains how firewall rules control network access to and from virtual
machines in Kubermatic Virtualization, and how to manage them from the dashboard.

## Overview

A firewall rule controls which traffic is allowed to reach a virtual machine, and
which traffic that machine is allowed to send. Each rule names:

* a **direction**, inbound or outbound,
* a **target**, the VM or VM pool the rule applies to,
* a **source** (inbound) or **destination** (outbound),
* the **ports and protocols** the rule permits.

Rules are managed from **Firewalls** in the dashboard. Each VM also shows the rules
that apply to it on its own **Networking** tab.

Under the hood a firewall rule is a Kubernetes `NetworkPolicy` in the same namespace
as the VM. Kubermatic Virtualization labels the policies it manages with
`kubevirt-manager.io/managed=true`, and the Firewalls list shows only those. Write a
policy by hand and the cluster still enforces it, but it stays out of the list until it
carries that label. Complex policies that do carry the label are listed, and
[Rules the form cannot express](#rules-the-form-cannot-express) covers what happens then.

## How rules combine

Two properties of firewall rules matter more than any individual setting:

**Rules only ever allow traffic.** There is no "deny" rule. You cannot write a rule
that blocks one particular address while leaving everything else open.

**Rules are additive.** When several rules target the same VM, traffic is permitted
if *any* of them allows it. Adding a rule can only ever open more traffic, never less.

To block traffic, turn the firewall on. That closes the VM to **inbound** traffic by
default, and you then add rules for whatever you want to permit. Nothing about the switch
restricts what the VM sends; for that, see
[Outbound rules and DNS](#outbound-rules-and-dns).

## Turning a VM's firewall on and off

Open the VM, go to the **Networking** tab, and use the **Firewall** switch.

* **Off**: the VM accepts all inbound traffic. This is the default for a new VM.
* **On**: inbound traffic is blocked unless one of the VM's rules allows it.
* **Unavailable**: the switch is greyed out. The VM was not created through this
  dashboard, so it does not carry the label firewall rules select on, and no rule can be
  enforced against it. See [Which VMs can be targeted](#which-vms-can-be-targeted).

Turning the firewall on creates a policy named `<vm-name>-vm-default-deny`. The `vm` part
is in the name because a VM and a VM pool can share a name in one namespace, and each type
needs its own system policy. For a pool the name is `<pool-name>-pool-default-deny`.

The policy appears in the Firewalls list marked **Default deny**, and it is managed for
you, so the actions menu offers **View YAML** but not **Edit** or **Edit YAML**. Turning
the switch back off removes it. So does deleting it from the Firewalls list, and the
delete dialog says which outcome to expect. Either the VM accepts all inbound traffic
again, or it stays closed because other inbound rules still apply.

The switch affects **inbound** traffic only. The VM's own outbound traffic stays
unrestricted until you add an outbound rule.

{{% notice note %}}
Adding an inbound rule also closes the VM, even with the switch off. That is how
Kubernetes network policies work. The switch is there to make the VM's posture explicit
and visible, instead of leaving it to depend on whether some rule happens to exist. When
a VM is closed only by its rules, the Networking tab says so, and deleting the last rule
reopens it.
{{% /notice %}}

## Creating a rule

Go to **Firewalls** and choose **New Firewall Rule**.

| Field | What it does |
| --- | --- |
| **Name** | Identifies the rule. Lowercase letters, numbers and hyphens. Cannot be changed later. |
| **Direction** | **Inbound** controls traffic arriving at the target. **Outbound** controls traffic the target sends. |
| **Target Type** / **Target** | The virtual machine or VM pool the rule applies to: the receiver for an inbound rule, the sender for an outbound one. |
| **Source** / **Destination** | Where the traffic comes from or goes to. See below. |
| **All ports** | Allow every port for the chosen peer, instead of listing them. |
| **From port** / **To port** / **Protocol** | The ports to permit. Leave **To port** empty for a single port, or set it to allow a range. |
| **Strict enforcement** | See [Ping and DHCP](#ping-and-dhcp). Leave this off unless you need full isolation. |
| **Labels** | Optional labels for your own grouping. |

The source or destination can be:

* **IP range**: a CIDR such as `10.0.0.0/8` or `2001:db8::/32`.
* **Virtual Machine** or **VM Pool**: another VM or pool in the same namespace.
* **Namespace**: every workload in the named namespace.
* **Anywhere**: any address. Use this to open a port to the world.

The first rule of a given direction for a target gets a warning. The form says the
target *"allows all inbound traffic today"* (or outbound), and that after saving,
anything not listed below is blocked. That warning shows up only while the target is
still open in that direction, so it marks the moment its posture flips from open to
closed.

### Port ranges

Set **From port** and **To port** to allow a contiguous range, for example `30000` to
`32767` for Kubernetes NodePorts. Leave **To port** empty to allow a single port.

For ports that are not contiguous, or that use a different protocol, add more rows. Eight
is the limit. Once you reach it the button to add another disappears, so put any further
ports in a second rule against the same target, which works because rules are additive.

## Ping and DHCP

By default, rules are created in a relaxed enforcement mode that keeps **ICMP (ping)
and DHCP working** on a firewalled VM, no matter what the rules say. This is almost
always what you want:

* Kubernetes network policies cannot express ICMP at all. `TCP`, `UDP` and `SCTP` are
  the only protocols allowed. Under full enforcement a firewalled VM loses ping
  permanently, and no rule can bring it back.
* A VM whose DHCP traffic is blocked cannot renew its address lease.

Ticking **Strict enforcement** removes that allowance and blocks every IP protocol
except what the rules permit. Use it only when you need complete isolation and have
accounted for losing ping and DHCP on that VM.

## Outbound rules and DNS

The first outbound rule you create for a target automatically creates a second policy
named `<vm-name>-vm-allow-dns`, or `<pool-name>-pool-allow-dns` when the target is a
VM pool. It is listed as **System DNS**.

Without it the VM could not resolve names. An outbound rule blocks all other outbound
traffic, and that includes DNS queries to the cluster's DNS service. A VM in that state
usually looks broken with no obvious cause.

Like the baseline, this one is managed for you, so the actions menu drops **Edit** and
**Edit YAML** and leaves **View YAML**. Deleting the last outbound rule for the target
removes it automatically. You can also delete it yourself from the Firewalls list, where
the dialog tells you what the removal will do before you confirm.

## Editing and deleting rules

Use the actions menu on any rule to edit it in the form, view its YAML, edit its YAML, or
delete it. System rows, meaning **Default deny** and **System DNS**, offer only **View YAML** and
**Delete**.

A rule's **name, direction and target cannot be changed** after creation. Opening a rule for
editing shows the **Name**, **Direction**, **Target Type** and **Target** fields greyed out,
and the form explains why: *"Name, direction and target identify a rule and cannot be
changed. Delete this rule and create a new one to move it."*

To rename or retarget a rule, create a replacement and delete the original.

Deleting tells you what the change will do before you confirm. For example, that a VM
will accept all inbound traffic again because you are removing its last inbound rule, or
that a system DNS allowance is being removed alongside the outbound rule that needed it.

{{% notice warning %}}
Editing a rule replaces the whole policy. Changes made outside the dashboard to the same
rule, such as extra ports or additional sources, are lost when you save the form. If a rule is
too complex for the form to represent, the dashboard says so and opens the YAML editor
instead of showing you a simplified version it would then destroy.

The YAML editor behaves differently. It submits the exact version you opened, so if the
rule changed underneath you the save is refused with *"This rule changed since you opened
it — reload and reapply your edit"* instead of overwriting. The form carries no such
check, which is why concurrent edits are lost there but rejected here.
{{% /notice %}}

## Rules the form cannot express

By design the form covers one direction, one target, one peer and a list of ports, which
is what the Firewalls table can display accurately. Anything beyond that opens in the YAML
editor instead, whether that is several sources in one rule, several rule blocks,
`ipBlock` exceptions, or named ports. The cluster still enforces those policies and the
list still shows them. You just cannot edit them through the form.

Because rules are additive, anything expressible as several simple rules is best written
that way.

## Verifying a rule

To confirm a rule is being enforced, send traffic from a source that should be allowed
and from one that should not, and check the underlying policy:

```bash
kubectl -n <namespace> get networkpolicy <rule-name> -o yaml
```

Nothing rejects a policy that matches no VM. It is created cleanly and then does nothing,
so the form tells you while you are still filling it in, underneath the **Target** field:

* *"Applies to 1 virtual machine."* means the rule will be enforced. The number is a real
  count, so a pool rule reports how many machines it selects, for example *"Applies to 4
  virtual machines."*
* *"Matches no virtual machine — this rule will have no effect until one exists."* means no VM of
  that name exists in the namespace yet. Check the name for a typo.
* *"This virtual machine cannot be targeted by a firewall rule: it was not created here, so it
  does not carry the label rules select on."* See below.

### Which VMs can be targeted

A firewall rule selects VMs by a label that this dashboard applies when it creates a VM.
Nothing back-fills that label, so a VM created another way, whether by `kubectl`, a YAML
manifest, or an import, cannot be targeted by a rule. The API server accepts such a rule and it then
programs nothing. On those VMs the **Firewall** switch reads **Unavailable**.
