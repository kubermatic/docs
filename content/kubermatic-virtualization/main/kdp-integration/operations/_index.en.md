+++
title = "Operating the Platform"
date = 2026-10-12T00:00:00+00:00
weight = 5
+++

This page is for platform administrators. It covers where project objects live on the KubeV
cluster, the rules and limits that come with KDP mode, the settings that keep projects apart,
and how to troubleshoot synchronization.

## Where project objects live

The api-syncagent copies each object from a KDP project to the KubeV cluster, into a namespace
named after the organization, the project and the object's namespace in the project:

```text
<organization>--<project>--<namespace>
```

| Object in KDP | Namespace on the KubeV cluster |
| --- | --- |
| `default/web-vm` in project `root:acme:prod` | `acme--prod--default/web-vm` |
| `team-a/my-vpc` in project `root:acme:dev` | `acme--dev--team-a/my-vpc` |

Objects keep their names, so references between them, such as a subnet's VPC or a VM's SSH key,
work on the KubeV cluster too. Every object the agent manages carries the label
`syncagent.kcp.io/agent-name`. To find a project's namespaces, and what runs in one of them:

```bash
kubectl get namespaces | grep -- '^acme--prod--'
kubectl -n acme--prod--default get virtualmachines,datavolumes,vpcs.virtualization.k8c.io
```

The api-syncagent creates a host namespace when the first object of a new project namespace
arrives. Status, and the Secrets KubeV generates, such as an SSH key's, flow back to the project.

## Names KubeV can use

A Kubernetes namespace name has at most 63 characters, and no two projects may map to the same
host namespace. So KubeV can only use a project when its names follow these rules:

| Name | Rule |
| --- | --- |
| **Organization** | At most 16 characters: lowercase letters, digits and `-`. Doesn't start or end with `-`, contains no `--`, doesn't start with `usn-`. |
| **Project** | The same rules as the organization. |
| **Namespace in the project** | At most 27 characters. Doesn't start or end with `-`, contains no `--`. |
| **Workspace** | Exactly `root:<organization>:<project>`. Workspaces nested below a project can't use KubeV. |

KDP doesn't check these rules when a project is created, and a workspace can't be renamed. Tell
your users before they create organizations and projects. When a project breaks a rule:

- the KubeV dashboard shows **KubeV can't use this project**, naming the rule;
- the api-syncagent doesn't copy its objects, logs the rule for each of them, and puts a warning
  event on each object in the project;
- the fix is a new project with allowed names.

## What the platform enforces

Admission policies keep each project's objects inside the project. The installer applies them on
the KubeV cluster, and the same rules in the provider workspace in kcp. kcp then refuses an object
when it is saved, with a message that names the setting. The checks that need the KubeV cluster run
there only.

For **virtual machines, VM pools, disks and backup targets**, a project can't:

- attach a VM to a network outside the project, or to the platform's pod network;
- set annotations that pick networks, sidecars or security profiles for the VM's pod, except
  Kube-OVN settings that name the project's own networks, subnets and security groups;
- mount a service account token into a VM;
- choose nodes: node selectors, tolerations, affinity, another scheduler, a `system-*` priority
  class, or a probe that names a host;
- import a disk, or reach a backup target, at an address inside the platform: `localhost`,
  `*.svc`, `*.cluster.local`, names without a dot, loopback and link-local addresses;
- clone a disk from another namespace, or use a VDDK image of its own.

For **VM migration**, a project can only migrate from vSphere into its own namespace. Hooks,
custom conversion images, transfer networks, copy offload and service accounts are refused, and
the vCenter address must be `https` with a fully qualified name or an IP address.

{{% notice note %}}
These checks block the obvious ways out of a project, but they can't tell every internal address
from an external one: a private IP of a node, or a name that cluster DNS resolves, such as
`kubernetes.default`, passes them. Add the network policies in
[Network hardening](#network-hardening) as a second line.
{{% /notice %}}

A project can change the NetworkPolicies of its own host namespaces, through the **Firewalls**
page. They are not the boundary between projects: the project's VPCs and subnets are.

## Underlay networks for projects

An underlay subnet puts VMs directly on a physical network of the hosts, through a network
interface and a VLAN. In a project, that is limited to the interfaces you allow in
`kdp.tenantUnderlayInterfaces`, as exact names or globs:

```yaml
kdp:
  tenantUnderlayInterfaces:
    - "ens[0-9]*"
    - "eth2"
```

- **While the list is empty**, new underlay subnets from projects are refused. Ones that already
  run keep running, and get a warning event, `InterfaceNotListed`.
- **Once the list is set**, an underlay subnet from a project on an interface that isn't listed is
  refused and removed, even one that ran before. Its network attachment goes at once, and its
  subnet a few seconds later, even while VMs use it. List every interface that running project
  underlay networks use before you set the field.
- Never list the management or overlay interface, a bond member or a VLAN sub-interface.

Projects can share an interface the platform uses for its own underlay subnets, on VLANs the
platform doesn't use, when the interface is on the list and KubeV created the platform's provider
network on it. An underlay subnet from a project is refused when it would take a VLAN the platform
or another project already uses. Underlay subnets the platform creates are not affected by the
list.

## Limiting elastic IPs and NAT gateways

Elastic IPs come from the platform's external network, which all projects share, and each NAT
gateway uses an external address. KubeV sets no limit per project. Set a ResourceQuota in each host
namespace of a project:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: kubev-network
  namespace: acme--prod--default
spec:
  hard:
    count/elasticips.virtualization.k8c.io: "4"
    count/natgateways.virtualization.k8c.io: "1"
```

The quota applies on the KubeV cluster. When a project goes over it, its new object stays in the
project without a status, with a warning event. Each project namespace has its own host
namespace, so add the quota for new ones too.

## Edge routers for projects

Projects can't create edge routers: an edge router runs privileged routing pods on the hosts. To
route a project's VPCs, create an `AZEdgeRouter` with `kubectl` on the KubeV cluster, in the
project's host namespace, for example `acme--prod--default`. It serves the VPCs of that namespace
that it selects, by name or by label, and no VPCs of other namespaces.

## Network hardening

Add these to a production platform. Write the network policies in the system namespaces, where no
project can change them, and test them before you enforce them.

- **Egress of the KubeV API server and Forklift.** A vSphere provider makes Forklift connect to
  the address a user gives, and the KubeV API server's **Test Connection** dials it on the user's
  behalf. Allow the pods in `kubermatic-virtualization` and `konveyor-forklift` to reach DNS, your
  vCenters and what they need in the cluster: the Kubernetes API, and for the API server also kcp,
  Dex and Forklift's inventory. Block the rest of the pod and Service networks, the node network
  and `169.254.0.0/16`.
- **Egress of disk imports and backups.** CDI's importer, upload and clone pods, and KubeV's
  backup jobs, run in project namespaces and connect to addresses users give. Restrict their
  egress at the cluster level, for example with Kube-OVN ACLs or an `AdminNetworkPolicy`, to keep
  them away from the metadata address, the node, pod and Service networks and other internal
  ranges.
- **HSTS.** Have the ingress or load balancer that terminates TLS for KubeV send a
  `Strict-Transport-Security` header, for example `max-age=31536000`.
- **A pull-only registry token.** KubeV copies its registry pull Secret into each project namespace
  that runs a backup, where the project's VMs could read it. Use registry credentials that can
  only pull.

## Troubleshooting

Start with the api-syncagent's log on the KubeV cluster. It names the object, the project and the
reason for anything it can't copy:

```bash
kubectl -n kubev-syncagent logs deployment/kubev-api-syncagent
```

| Symptom | Cause and fix |
| --- | --- |
| An object stays **Pending** in a project, with only a warning event *a provider-side issue has occurred*. | The KubeV cluster refused the copy, or a quota was exceeded. The agent's log has the reason. |
| No object of a project reaches the KubeV cluster; the agent logs *longer than 16 characters*, *may not contain --* or *is not a project*. | The project's names break a rule KubeV needs. See [Names KubeV can use](#names-kubev-can-use). |
| A resource type is missing in projects. | Its PublishedResource has no schema. List them with `kubectl get publishedresources.syncagent.kcp.io`, and check that the resource's CRD is installed. |
| KDP pages don't load in the browser, or `kubectl` reports an unknown certificate authority for kcp. | The user's machine doesn't trust kcp's CA. See [Publish the KDP dashboard and kcp]({{< ref "../installation#publish-the-kdp-dashboard-and-kcp" >}}). |
| Every KubeV page of a project fails, and the API server logs *kcp is unreachable until its CA can be read*. | The kcp CA Secret is missing from the `kubermatic-virtualization` namespace: the one named in `external.caSecretName` or `kdp.kcpCASecretName`, or else `kubev-kcp-front-proxy-ca`. |
| Users don't see KubeV in KDP's catalog. | They may not bind KubeV's API. In external mode, see [Let users see KubeV]({{< ref "../external-kdp#step-6-let-users-see-kubev" >}}). |
| A backup target with a CA bundle stays **Failed** with `CA bundle configmap <name> not found`. | The project hasn't granted KubeV access to its ConfigMaps. Grant `configmaps` with **Update Permissions** on the KubeV service's card in KDP. |
| An underlay subnet from a project is **Failed**, or has the warning event `InterfaceNotListed`. | Its interface isn't in `kdp.tenantUnderlayInterfaces`, or its interface or VLAN is already taken. The reason is in a warning event on its copy on the KubeV cluster. See [Underlay networks for projects](#underlay-networks-for-projects). |
