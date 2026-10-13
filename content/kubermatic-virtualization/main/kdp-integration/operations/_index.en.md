+++
title = "Operating the Platform"
date = 2026-10-12T00:00:00+00:00
weight = 7
+++

This page is for platform administrators. It covers the settings that keep projects apart and
within limits, the hardening a production platform needs, and how to troubleshoot synchronization.
For how projects map to the KubeV cluster and what the platform enforces, see
[How It Works]({{< ref "../how-it-works" >}}).

## Finding a project's objects

Each project namespace has a host namespace on the KubeV cluster, named
`kv-<project hash>-<namespace hash>`; see
[Where the objects run]({{< ref "../how-it-works#where-the-objects-run" >}}). The name says nothing
about the project, so find host namespaces by their labels and annotations:

| Key | Kind | Value |
| --- | --- | --- |
| `kdp.kubev.k8c.io/organization` | label | The organization's name. |
| `kdp.kubev.k8c.io/project` | label | The project's name. |
| `kdp.kubev.k8c.io/namespace` | label | The namespace in the project. |
| `kdp.kubev.k8c.io/project-hash` | label | The project hash, the 16 characters after `kv-`. Every host namespace has it. |
| `kdp.kubev.k8c.io/project-path` | annotation | `<organization>/<project>` |
| `kdp.kubev.k8c.io/namespace-path` | annotation | `<organization>/<project>/<namespace>` |

The api-syncagent creates a host namespace when the first object of a project namespace arrives, and
KubeV labels it moments later. Every object the api-syncagent manages there carries the label
`syncagent.kcp.io/agent-name`. To find a project's host namespaces, and what runs in one of them:

```bash
# Every host namespace, with the project namespace it holds:
kubectl get namespaces -l kdp.kubev.k8c.io/project-hash \
  -L kdp.kubev.k8c.io/organization,kdp.kubev.k8c.io/project,kdp.kubev.k8c.io/namespace
# The host namespaces of project prod in organization acme:
kubectl get namespaces -l kdp.kubev.k8c.io/organization=acme,kdp.kubev.k8c.io/project=prod
# What runs in the host namespace of its namespace default:
kubectl -n kv-c21432a31b80a04f-7b59e6651cd6 get virtualmachines,datavolumes,vpcs.virtualization.k8c.io
```

Look, but change things in the project instead: the api-syncagent applies the project's objects to
these copies. The exceptions are what only a platform administrator does on the KubeV cluster, such
as the quotas and edge routers below.

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
  namespace: kv-c21432a31b80a04f-7b59e6651cd6   # acme:prod, namespace default
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
project's host namespace, for example `kv-c21432a31b80a04f-7b59e6651cd6`. It serves the VPCs of
that namespace that it selects, by name or by label.

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
| No object of a project reaches the KubeV cluster; the agent logs *is not a project*. | The objects were created in an organization or in a workspace below a project, where KubeV doesn't work. See [Where KubeV works]({{< ref "../how-it-works#where-kubev-works" >}}). |
| A resource type is missing in projects. | Its PublishedResource has no schema. List them with `kubectl get publishedresources.syncagent.kcp.io`, and check that the resource's CRD is installed. |
| KDP pages don't load in the browser, or `kubectl` reports an unknown certificate authority for kcp. | The user's machine doesn't trust kcp's CA. See [Publish the KDP dashboard and kcp]({{< ref "../installation/same-layer#step-6-trust-kcps-certificate" >}}). |
| Every KubeV page of a project fails, and the API server logs *kcp is unreachable until its CA can be read*. | The kcp CA Secret is missing from the `kubermatic-virtualization` namespace: the one named in `external.caSecretName` or `kdp.kcpCASecretName`, or else `kubev-kcp-front-proxy-ca`. |
| Users don't see KubeV in KDP's catalog. | They may not bind KubeV's API: the ClusterRoleBinding `kubev:virtualization:consumers` in the provider workspace is missing. Run the installer again, or `kdp connect` with your own KDP. |
| A backup target with a CA bundle stays **Failed** with `CA bundle configmap <name> not found`. | The project hasn't granted KubeV access to its ConfigMaps. Grant `configmaps` with **Update Permissions** on the KubeV service's card in KDP. |
| An underlay subnet from a project is **Failed**, or has the warning event `InterfaceNotListed`. | Its interface isn't in `kdp.tenantUnderlayInterfaces`, or its interface or VLAN is already taken. The reason is in a warning event on its copy on the KubeV cluster. See [Underlay networks for projects](#underlay-networks-for-projects). |
