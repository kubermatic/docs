+++
title = "Using KubeV in a KDP Project"
date = 2026-10-12T00:00:00+00:00
weight = 4
+++

This guide is for members of a KDP project who create virtual machines with KubeV. It covers
how to open KubeV from KDP, and what works differently from a standalone KubeV installation.
Everything else, from creating a VM to setting up firewall rules, works as described in the
rest of this documentation.

## Before you start

You need:

- a role in a KDP project that lets you work with KubeV, such as **Developer** or **Owner**.
  See [Roles in a project]({{< ref "../access-control#roles-in-a-project" >}});
- the KubeV service enabled in that project. On platforms that install KDP together with KubeV,
  every project has it. Otherwise, a project owner or service manager enables
  **KubeV Virtualization** on the project's **Services** page in KDP.

Ask your KDP administrator if you have neither.

## Opening KubeV

1. In the KDP dashboard, open your project.
2. Go to **Services** and choose **Open KubeV Virtualization**.

KubeV opens in that project and signs you in with your KDP account. Depending on how you log
in, you may be asked to pick your login or enter your password once more; see
[Signing in]({{< ref "../access-control#signing-in" >}}). The button on an organization's page
opens KubeV's **Select a project** page instead: KubeV always works in one project at a time.

Every KubeV address names its project, for example
`https://kubev.example.com/projects/acme:dev/virtual-machines`. You can bookmark it, share it,
or open it in a second tab. KubeV has no project switcher: to work in another project, open it
from KDP.

### When KubeV doesn't open the project

| KubeV shows | What it means |
| --- | --- |
| **Select a project** | The address names no project, or only an organization. Open a project from KDP. |
| **Project not available** | The project doesn't exist, you have no role in it, or KubeV isn't enabled in it. Ask one of its owners. |
| **Organization not available** | The address names an organization you have no access to. |
| **KubeV can't use this project** | The organization or project name breaks a rule KubeV needs, such as its length. See [Names KubeV can use]({{< ref "../operations#names-kubev-can-use" >}}). Organizations and projects can't be renamed, so the one that breaks the rule has to be recreated with an allowed name. Ask your KDP administrator. |
| **You don't have access to any organization yet** | You signed in, but have no role anywhere in KDP. Ask an administrator to add you to a project. |

## Namespaces

A KDP project has namespaces, like a Kubernetes cluster. KubeV lists the objects of every
namespace in the project. New objects go to the `default` namespace, unless you pick another one
in the form.

To use more namespaces, create them in the project, on the **Namespaces** page in KDP or with
`kubectl`; see [kcp on the Command Line](/developer-platform/v1.2/tutorials/kcp-command-line/)
in the KDP documentation. A namespace name may have up to 27 characters and must not contain
`--`.
KubeV lists namespaces that break this rule, but you can't pick them, since nothing created
in them would reach the platform.

## What works differently

| Feature | In a KDP project |
| --- | --- |
| **Start, stop** | Work, by setting the VM's run strategy to `Always` or `Halted`. A VM with another run strategy has `Always` after you stop and start it. |
| **Restart** | Works, also **Save and restart** on the edit page, but your browser carries it out: KubeV stops the VM, waits until it is off and starts it again. **Keep the tab open** until the VM runs. If you close it halfway, the VM stays stopped; start it again. |
| **Console** (VNC and serial) | Works for users who may change the VM. KubeV checks that again every five minutes, and closes the console once you lose that permission or your sign-in expires. |
| **VMs of a VM pool** | Listed with the project's other VMs. You can start, stop and restart them and open their consoles. Make other changes on the pool. |
| **Pause, live migration, adding or removing disks on a running VM** | The dashboard doesn't offer them. |
| **Node placement** | VMs can't be pinned to nodes, or carry tolerations, affinity or a scheduler of their own. Saving a VM on the edit page removes these settings, with a warning. |
| **Networks** | Every network interface must be on a subnet of the project. The platform's pod network is not available. |
| **Underlay subnets** | Only on the network interfaces your platform administrator allows. An underlay subnet on another interface, or created while none is allowed, is marked **Failed** with the reason. |
| **Images** | Each project has its own. A disk image URL must point outside the platform: when a disk is created from it, addresses such as `localhost`, `*.svc`, `*.cluster.local` or names without a dot are refused. Docker Hub short names such as `docker://ubuntu:22.04` work. |
| **Instance types** | Shared by the whole platform, and read-only. |
| **Edge routers** | Run by the platform administrator for your project. You can't create or change them. |
| **Kubeconfig download** | Not available. Use KDP's command-line access for `kubectl`. |
| **Administration pages** | Not available. Members and roles are managed in KDP. |

### Changes the platform refuses

The platform keeps each project's VMs inside the project. You get an error when you save an
object that would reach outside it, for example a VM on the pod network or with a node selector.
The message says which setting is refused.

A few checks can only run on the KubeV cluster, for example whether a VM's network belongs to
the project. An object refused there is saved in your project but never runs, and KubeV shows no
status for it. If an object gets no status, check its network settings and the namespaces it
refers to, or ask your platform administrator, who can see the reason in the api-syncagent's
log.

## Backups

Backup targets, backups and restores work as in standalone mode, with two differences.

**The backup target must have an address outside the platform.** The platform's backup and
restore jobs run in your project's namespace and connect to the target's endpoint. Use a fully
qualified host name, or an IP address. An endpoint such as `minio.minio.svc`, a name ending in
`.svc` or `.cluster.local`, or a name without a dot is refused, and an existing target with such
an endpoint is marked **Failed** with *this endpoint is inside the platform; KDP projects must use
an external address*. For storage that runs inside the cluster, such as MinIO, use its external
address.

**Restored VMs are created by the dashboard.** Once a restore has prepared its VM, KubeV creates
the VM in the project the next time someone who may create VMs opens **VM Restores** or the
restore's page. The restore then imports the disks. Open one of these pages after starting a
restore: a restore whose VM isn't created within a day fails.

A backup target that names a CA bundle waits up to two minutes for the bundle's ConfigMap, then
turns **Failed** with `CA bundle configmap <name> not found`. Check that the ConfigMap exists in
the target's namespace. If it does, the project hasn't granted KubeV access to its ConfigMaps: a
project owner or service manager chooses **Update Permissions** in the menu of the KubeV
service's card in KDP and grants `configmaps`.

## Migrating VMs from vSphere

The **Migration** section works in KDP projects, with these differences:

- **Your role.** The section shows when you may view migration providers. Adding a provider
  also needs permission to create Secrets in the project: see
  [What Developer and Member don't cover]({{< ref "../access-control#what-developer-and-member-dont-cover" >}}).
- **One namespace.** Providers, plans and the migrated VMs all live in the project's `default`
  namespace.
- **The vCenter address** must use `https`, with a fully qualified host name such as
  `vcenter.example.com` or an IP address. Short names such as `https://vcenter` are refused.
- **Cold migration only.** VDDK, warm migration, copy offload and a transfer network are not
  available. Disks are copied over the vCenter's HTTPS datastore path, and VMs on vSAN storage
  can't be migrated.
- **The vCenter login** is stored as a Secret, `<provider>-vsphere-creds`, in the project. Anyone
  who may read Secrets there can read it, so use a vCenter account with only the rights a
  migration needs.

### Getting migrated VMs into the project

Forklift creates each migrated VM on the platform first. The KubeV dashboard then adds it to your
project:

- The plan's page adds each VM as soon as its migration succeeds, and the **Migration Plans** list
  does the same for every plan.
- This happens only while someone who may create VMs has one of these pages open. Keep the plan
  open until the run is done, or open the list later.
- **Don't delete a plan before its VMs are in the project.** They would stay on the platform,
  outside your project.

The plan's page names each VM it could not add, and why:

| The plan says | What to do |
| --- | --- |
| *could not be added to the project: another virtual machine there already has that name* | The migrated VM wasn't added. Ask your platform administrator before you delete either VM. |
| *cannot be added to the project*, followed by a reason | The VM has settings the platform refuses in a project, such as the pod network or a node selector. Ask your platform administrator. |
| *migrated, but no virtual machine of it was found in this namespace* | Forklift reports the VM migrated, but it isn't on the platform. Ask your platform administrator. |
| *could not be added to the project. Reload the page to try again.* | KDP didn't accept the VM, for example because of a quota. Reload the page: adding it again is safe. |

Once added, a migrated VM is a normal VM of the project. Deleting it also deletes its disks.
