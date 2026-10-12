+++
title = "KDP Integration"
date = 2026-10-12T00:00:00+00:00
weight = 7
+++

Kubermatic Virtualization (KubeV) can run as a service of the
[Kubermatic Developer Platform](/developer-platform/v1.2/) (KDP). Teams then get virtual
machines, networks, disks and backups in their own KDP projects, from the same catalog as
every other service on the platform, while KubeV keeps running them on its own cluster.

This section is for two audiences:

- **Platform administrators**, who install KubeV with KDP and run the platform. Start with
  [How it works](#how-it-works), then [Installing KubeV with KDP]({{< ref "./installation" >}}).
- **Project users**, who create virtual machines in a KDP project. Start with
  [Using KubeV in a KDP Project]({{< ref "./using-kubev" >}}).

## Pages

{{% children depth=1 %}}
{{% /children %}}

## What changes in KDP mode

In a standalone installation, KubeV manages its own users, roles and namespaces. With KDP,
KDP takes those over:

| | Standalone | With KDP |
| --- | --- | --- |
| **Tenancy** | Namespaces on the KubeV cluster. | KDP organizations and projects. Each project is isolated from the others. |
| **Users and roles** | KubeV `User`, `KubeVRole` and `KubeVRoleBinding` objects, managed in the KubeV dashboard. | KDP members and roles, managed in the KDP dashboard. KubeV has no IAM pages. |
| **Who decides what a user may do** | The KubeV API server. | kcp, the control plane behind KDP. KubeV forwards each request with the user's own token. |
| **Where users start** | The KubeV dashboard. | The KDP dashboard. Its **Open KubeV Virtualization** button opens KubeV in the project. |
| **Sign-in** | Basic, OIDC or none. | OIDC only, through the identity provider that KDP and KubeV share. |

The virtual machines themselves, their networks and their storage run on the KubeV cluster
in both modes. KDP never hosts workloads.

## How it works

KDP is built on [kcp](https://kcp.io), which gives every organization and project its own
Kubernetes-like API, called a workspace. KubeV plugs into it as a KDP **service provider**:

```text
 KDP project (kcp workspace)                       KubeV cluster
 ---------------------------                       -------------
 VirtualMachine, VPC, Subnet, ...   <-- sync -->    api-syncagent
   created by users in KubeV or kubectl              |
                                                     v
                                        namespace <org>--<project>--<namespace>
                                          KubeVirt, Kube-OVN and the KubeV
                                          controllers run the objects, and
                                          their status flows back to the project
```

1. KubeV registers a KDP service, `virtualization.k8c.io`, in its own provider workspace
   (`root:kubev` by default). The service publishes KubeV's resource types to KDP.
2. A project enables the service. KubeV's resource types then appear in the project, as if
   they were built into it.
3. Users create virtual machines, networks and other resources in the project, through the
   KubeV dashboard or with `kubectl`.
4. The [api-syncagent](/developer-platform/v1.2/service-providers/api-syncagent/) on the
   KubeV cluster copies each object to the KubeV cluster, in a namespace of its own for each
   project namespace, and copies its status back.

Because every project lands in its own namespaces on the KubeV cluster, objects in different
projects can have the same names without touching each other. Admission policies on the KubeV
cluster and in kcp keep each project's VMs on its own networks, and away from the platform's
nodes and internal services. See
[What the platform enforces]({{< ref "./operations#what-the-platform-enforces" >}}).

## Deployment modes

The installer supports two ways to run KubeV with KDP:

| Mode | What the installer does | Use when |
| --- | --- | --- |
| **Same-layer** (default) | Installs kcp and KDP on the KubeV cluster, registers the KubeV service, deploys the api-syncagent and enables KubeV in every project. | You want one platform that runs both KDP and KubeV. |
| **External** | Connects the KubeV dashboard to a KDP you already run. Installs nothing on the KDP side. | You already operate KDP and want to add KubeV to it. |

A third mode, which runs KDP in its own cluster on KubeVirt VMs on the KubeV cluster, is
experimental. It doesn't support the KubeV dashboard, and this section doesn't cover it.

## What a project gets

Once KubeV is enabled in a project, the project serves these resources:

| Area | Resources |
| --- | --- |
| **Compute** | `VirtualMachine`, `VirtualMachineInstance`, `VirtualMachineInstanceMigration` (`kubevirt.io`), `VirtualMachinePool` (`pool.kubevirt.io`) |
| **Storage** | `DataVolume` (`cdi.kubevirt.io`), `Image` |
| **Networking** | `VPC`, `Subnet`, `UnderlaySubnet`, `SecurityGroup`, `NATGateway`, `ElasticIP` |
| **Access** | `SSHKey` |
| **Data protection** | `BackupStorageLocation`, `VMBackup`, `VMRestore` |
| **Migration** | `Provider`, `NetworkMap`, `StorageMap`, `Plan`, `Migration` (`forklift.konveyor.io`) |

Resources without an API group in brackets belong to `virtualization.k8c.io`.

Only the platform administrator manages these:

- edge routers (`AZEdgeRouter`, `EVPNPolicy`, `EVPNRouteReflector`), which projects can't
  create or change;
- cluster instance types and preferences, storage classes, priority classes and nodes, which
  projects can read but not change.

KubeV's own IAM objects (`User`, `KubeVRole`, `KubeVRoleBinding`) are not used in KDP mode.

## Requirements

- KubeV 1.3 or newer.
- For external mode, KDP 1.2.1 or newer. Older releases don't show the button that opens
  KubeV.
- An OIDC provider that KDP and KubeV share. The installer can deploy Dex for you.
- If you deploy the KubeV dashboard, OIDC sign-in. KDP mode doesn't support basic or no
  authentication.
