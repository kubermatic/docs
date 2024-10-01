+++
title = "Nutanix"
date = 2024-05-31T07:00:00+02:00
+++

Currently the machine-controller implementation of Nutanix supports the [Prism v3 API][1] to
create `Machines`.

## Prerequisites

The `nutanix` provider assumes several things to be pre-existing. You need:

- Credentials and access information for a Nutanix Prism Central instance (endpoint, port, username
  and password).
- The name of a Nutanix cluster to create the VMs for Machines on.
- The name of a subnet on the given Nutanix cluster that the VMs' network interfaces will be created
  on.
- An image name that will be used to create the VM for (must match the configured operating system).
- **Optional**: The name of a project that the given credentials have access to, to create the VMs
  in. If none is provided, the VMs are created without a project.

## Configuration Options

An example `MachineDeployment` can be found [here][2].

{{%expand "Sample machinedeployment.yaml"%}}
```yaml
{{< render_external_code "https://raw.githubusercontent.com/kubermatic/machine-controller/main/examples/nutanix-machinedeployment.yaml" >}}
```
{{%/expand%}}

[1]: https://www.nutanix.dev/reference/prism_central/v3/
[2]: https://github.com/kubermatic/machine-controller/blob/main/examples/nutanix-machinedeployment.yaml
