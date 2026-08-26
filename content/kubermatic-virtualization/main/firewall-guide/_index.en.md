+++
title = "Firewall Rules"
date = 2026-08-25T00:00:00+00:00
weight = 6
+++

This guide explains how firewall rules control network access to and from virtual
machines in Kubermatic Virtualization, and how to manage them from the dashboard.

## Overview

A firewall rule controls which traffic is allowed to reach a virtual machine, and
which traffic that machine is allowed to send. Each rule names:

* a **direction** — inbound or outbound,
* a **target** — the VM or VM pool the rule protects,
* a **source** (inbound) or **destination** (outbound),
* the **ports and protocols** the rule permits.

Rules are managed from **Firewalls** in the dashboard. Each VM also shows the rules
that apply to it on its own **Networking** tab.

Under the hood a firewall rule is a Kubernetes `NetworkPolicy` in the same namespace
as the VM. Kubermatic Virtualization labels the policies it manages with
`kubevirt-manager.io/managed=true`, and only those appear in the dashboard. Policies
created by other means are still enforced by the cluster — they are simply not listed.

## How rules combine

Two properties of firewall rules matter more than any individual setting:

**Rules only ever allow traffic.** There is no "deny" rule. You cannot write a rule
that blocks one particular address while leaving everything else open.

**Rules are additive.** When several rules target the same VM, traffic is permitted
if *any* of them allows it. Adding a rule can only ever open more traffic, never less.

Blocking is expressed by turning the firewall on, which closes the VM by default, and
then adding rules for the traffic you want to permit.

## Turning a VM's firewall on and off

Open the VM, go to the **Networking** tab, and use the **Firewall** switch.

* **Off** — the VM accepts all inbound traffic. This is the default for a new VM.
* **On** — inbound traffic is blocked unless one of the VM's rules allows it.

Turning the firewall on creates a policy named `<vm-name>-default-deny`. It appears in
the Firewalls list marked **Default deny** and is managed for you: it cannot be edited
through the form, only removed by turning the switch back off.

The switch affects **inbound** traffic only. The VM's own outbound traffic stays
unrestricted until you add an outbound rule.

{{% notice note %}}
Adding an inbound rule also closes the VM, even with the switch off — that is how
Kubernetes network policies work. The switch exists so that the VM's posture is
something you set deliberately and can see, rather than a side effect of whether a
rule happens to exist. When a VM is closed only by its rules, the Networking tab says
so, and deleting the last rule will reopen it.
{{% /notice %}}

## Creating a rule

Go to **Firewalls** and choose **New Firewall Rule**.

| Field | What it does |
| --- | --- |
| **Name** | Identifies the rule. Lowercase letters, numbers and hyphens. Cannot be changed later. |
| **Direction** | **Inbound** controls traffic arriving at the target. **Outbound** controls traffic the target sends. |
| **Target Type** / **Target** | The virtual machine or VM pool this rule protects. |
| **Source** / **Destination** | Where the traffic comes from or goes to. See below. |
| **All ports** | Allow every port for the chosen peer, instead of listing them. |
| **From port** / **To port** / **Protocol** | The ports to permit. Leave **To port** empty for a single port, or set it to allow a range. |
| **Strict enforcement** | See [Ping and DHCP](#ping-and-dhcp). Leave this off unless you need full isolation. |
| **Labels** | Optional labels for your own grouping. |

The source or destination can be:

* **IP range** — a CIDR such as `10.0.0.0/8` or `2001:db8::/32`.
* **Virtual Machine** or **VM Pool** — another VM or pool in the same namespace.
* **Namespace** — every workload in the named namespace.
* **Anywhere** — any address. Use this to open a port to the world.

When the rule you are creating is the first one of its direction for that target, the
form warns you: after saving, anything not listed in the rule is blocked.

### Port ranges

Set **From port** and **To port** to allow a contiguous range — for example `30000` to
`32767` for Kubernetes NodePorts. Leave **To port** empty to allow a single port.

Add several rows to allow ports that are not contiguous, or that use different
protocols.

## Ping and DHCP

By default, rules are created in a relaxed enforcement mode that keeps **ICMP (ping)
and DHCP working** on a firewalled VM, no matter what the rules say. This is almost
always what you want:

* Kubernetes network policies cannot express ICMP at all — `TCP`, `UDP` and `SCTP` are
  the only protocols allowed. Under full enforcement a firewalled VM loses ping
  permanently, and no rule can bring it back.
* A VM whose DHCP traffic is blocked cannot renew its address lease.

Ticking **Strict enforcement** removes that allowance and blocks every IP protocol
except what the rules permit. Use it only when you need complete isolation and have
accounted for losing ping and DHCP on that VM.

## Outbound rules and DNS

The first outbound rule you create for a target automatically creates a second policy
named `<vm-name>-allow-dns`, listed as **System DNS**.

Without it the VM could not resolve names: an outbound rule blocks all other outbound
traffic, including DNS queries to the cluster's DNS service, and a VM that cannot
resolve names usually appears broken with no obvious cause.

This policy is managed for you. It cannot be edited through the form, and it is removed
automatically when you delete the last outbound rule for that target.

## Editing and deleting rules

Use the actions menu on any rule to edit, view its YAML, or delete it.

A rule's **name cannot be changed** after creation. To rename one, create a replacement
and delete the original.

Deleting tells you what the change will do before you confirm — for example, that a VM
will accept all inbound traffic again because you are removing its last inbound rule, or
that a system DNS allowance is being removed alongside the outbound rule that needed it.

{{% notice warning %}}
Editing a rule replaces the whole policy. Changes made outside the dashboard to the same
rule — extra ports, additional sources — are lost when you save the form. If a rule is
too complex for the form to represent, the dashboard says so and opens the YAML editor
instead of showing you a simplified version it would then destroy.
{{% /notice %}}

## Rules the form cannot express

The form deliberately covers one direction, one target, one peer and a list of ports,
which is what the Firewalls table can display accurately. A policy that goes beyond that
— several sources in one rule, several rule blocks, `ipBlock` exceptions, or named ports
— opens in the YAML editor instead. Such policies are still enforced and still listed;
they simply cannot be edited through the form.

Because rules are additive, anything expressible as several simple rules is best written
that way.

## Verifying a rule

To confirm a rule is being enforced, send traffic from a source that should be allowed
and from one that should not, and check the underlying policy:

```bash
kubectl -n <namespace> get networkpolicy <rule-name> -o yaml
```

A policy that matches no VM is created without error and does nothing. The form reports
this while you are filling it in — if the target shows *"Matches no virtual machine"*,
check the VM name.
