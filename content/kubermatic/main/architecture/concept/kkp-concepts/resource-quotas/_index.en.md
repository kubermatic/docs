+++
title = "Resource Quotas"
date = 2022-08-16T14:07:15+02:00
weight = 20
enterprise = true

+++

Resource Quotas in KKP allow administrators to set quotas on the amount of resources a subject can use. For now the only
subject which is supported is Project, so the resource quotas currently limit the amount of resources that can be used project-wide.

The resources in question are the resources of the user cluster:
- CPU - the cumulated CPU used by the nodes on all clusters.
- Memory - the cumulated RAM used by the nodes on all clusters.
- Storage - the cumulated disk size of the nodes on all clusters.

This feature is available in the EE edition only.

{{% notice note %}}
**Note:** Do not confuse with the Resource Filter setting in the `Defaults And Limits` admin panel page.
That one just controls the size of the machines suggested to users in the KKP Dashboard during the cluster creation.
{{% /notice %}}


## Setting up Resource Quotas

The resource quotas are managed by administrators either through the KKP UI/API or through the Resource Quota CRDs.

Example ResourceQuota:
```yaml
apiVersion: kubermatic.k8c.io/v1
kind: ResourceQuota
metadata:
  name: project-tjqjkphnm6
spec:
  quota:
    cpu: "100"
    memory: 500G
    storage: 350G
  subject:
    kind: project
    name: tjqjkphnm6
```

The quota fields use the [ResourceQuantity](https://kubernetes.io/docs/reference/kubernetes-api/common-definitions/quantity) to
represent the values. One note is that CPU is denoted in single integer numbers.

![Manage Quotas](@/images/main/architecture/concepts/resource-quotas/quota-menu.png?classes=shadow,border "Manage Quotas")

To simplify matters the UI uses GB as representation for Memory and Storage. The conversion from any value
set in the ResourceQuota is done automatically by the API.

## Calculating Quota Usage

The ResourceQuota has 2 status fields:
- `globalUsage` which shows the resource usage across all seeds
- `localUsage` which shows the resource usage on the local seed

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: ResourceQuota
metadata:
  name: project-tjqjkphnm6
...
status:
  globalUsage:
    cpu: "2"
    memory: 35G
    storage: 127G
  localUsage:
    cpu: "1"
    memory: 17G
    storage: 100G
```

Each seed cluster has a controller which calculates the `localUsage` by calculating the Machine resource usage
across all the user clusters that belong to a subject (for now only project).

The master cluster has a controller which calculates the `globalUsage` by adding up all `localUsage` across the Seeds.

The Machine(Node) resource usage is calculated depending on the provider in question, the table below shows
some details from where the resources are taken. The goal was to have the calculated resource the same as the
resulting K8s Node `.status.capacity`.

| Provider              | CPU                                                                                    | Memory                                                                                  | Storage                                                |
|-----------------------|----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|--------------------------------------------------------|
| Alibaba               | CpuCoreCount (query to provider)                                                       | MemorySize (query to provider)                                                          | Set in Machine spec by user                            |
| AWS                   | VCPUs (loaded from AWS instance lib)                                                   | Memory (loaded from AWS instance lib)                                                   | Set in Machine spec by user                            |
| Azure                 | NumberOfCores (query to provider)                                                      | MemoryInMB (query to provider)                                                          | Set in Machine spec by user                            |
| DigitalOcean          | Vcpus (query to provider)                                                              | Memory (query to provider)                                                              | Disk (query to provider)                               |
| GCP                   | VCPUs (query to provider)                                                              | Memory (query to provider)                                                              | Set in Machine spec by user                            |
| Hetzner               | Cores (query to provider)                                                              | Memory (query to provider)                                                              | Disk (query to provider)                               |
| Openstack             | VCPUs (query to provider)                                                              | Memory (query to provider)                                                              | Disk (query to provider)                               |
| KubeVirt              | If flavor set: calculate from the provider flavor, otherwise get from the Machine spec | If flavor set: calculate from the provider flavor, otherwise get from the Machine spec  | Add up Primary and Secondary disks (from Machine spec) |
| Nutanix               | CPU * CPUCores (Machine spec)                                                          | MemoryMB (from Machine spec)                                                            | DiskSize (from Machine spec)                           |
| Equinox               | Add up all CPUs (query to provider)                                                    | Memory.Total (query to provider)                                                        | Add up all Drives (query to provider)                  |
| vSphere               | CPUs (set in Machine spec)                                                             | MemoryMB (from Machine spec)                                                            | DiskSizeGB (from Machine spec)                         |
| Anexia                | CPUs (set in Machine spec)                                                             | Memory  (from Machine spec)                                                             | DiskSize  (from Machine spec)                          |
| VMWare Cloud Director | CPU * CPUCores (Machine spec)                                                          | MemoryMB (from Machine spec)                                                            | DiskSizeGB (from Machine spec)                         |


## Enforcing Quotas

The quotas are enforced through a validating webhook on Machine resources in the user clusters. This means that the quota validation
takes place after the MachineDeployment is created, and if quota is exceeded, the creation of the Machines(Nodes) will be blocked.

Users can observe the quotas being enforced (with a message stating why) on the User clusters Machine Deployment, in the form
of Events.

![Enforced Quota](@/images/main/architecture/concepts/resource-quotas/enforced.png?classes=shadow,border "Enforced Quota")

Furthermore, a project quota widget of the active project is visible in the dashboard, which shows what is the quota usage.

![Quota Widget](@/images/main/architecture/concepts/resource-quotas/widget.png?classes=shadow,border "Quota Widget")

## Some Additional Information

{{% notice note %}}
**Note:** If multiple nodes are created in the same time there is a possibility of a race happening and the quota being exceeded.
As an example, there is a quota which CPU is filled 3/5, a user creates a cluster with 2 nodes, both using 2 CPU. There is a possibility
of a race happening between calculating and adding the quota for the first machine and the second machine being created. So
the end result could be that both nodes get created, and the quota ends up exceeded 7/5.
This is planned to be fixed in the next KKP releases.
{{% /notice %}}

If the quota is exceeded, be it due to the quota being set on a project with active clusters, or due to a race, this feature
will just block new Machines from being provisioned, it won't clean up/remove cluster resources to get below the quota. This
is something that should be agreed upon between the KKP admin and users.

The storage quota just affects the local node storage. It doesn't monitor various provider PV that users can provision.

The quotas don't support external clusters.

The quotas won't restrict the usage of resources for the control plane on the seed cluster.

Nodes which join the cluster using other means than through KKP are not supported in the quotas.

## Default Project Resource Quotas

It is possible to set the a default resource quota for all projects which do not have a quota already set.

In the KKP's KubermaticSettings `globalsettings` resource, there is a field in `spec.defaultQuota` through which
default project resource quotas can be managed:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticSettings
metadata:
  name: globalsettings
...
spec:
  defaultQuota:
    quota:
      cpu: "2"
      memory: 35G
      storage: 127G
```

If the `spec.defaultQuota` is set, a controller will create a default ResourceQuota for all projects which do
not have a ResourceQuota already. And if the field is updated, the default ResourceQuota's will be updated as well.
Unsetting this field will delete all the default ResourceQuotas.

To distinguish a ResourceQuota from a default ResourceQuota, the label `"kkp-default-resource-quota": "true"` is set on the
default ResourceQuotas. To mark the ResourceQuota as non-default, just remove the label. When a default ResourceQuota is
edited through the UI/API, this will be done automatically.
