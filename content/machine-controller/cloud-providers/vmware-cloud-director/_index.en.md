+++
title = "VMware Cloud Director"
date = 2024-05-31T07:00:00+02:00
+++

## Prerequisites

The following things should be configured before managing machines on VMware Cloud Director:

- Dedicated Organization VDC has been created.
- Required catalog and templates for creating VMs have been added to the organization VDC.
- VApp has been created that will be used to encapsulate all the VMs.
- Direct, routed or isolated network has been created. And the virtual machines within the vApp can
  communicate over that network.

## Configuration Options

An example `MachineDeployment` can be found [here][1].

{{%expand "Sample machinedeployment.yaml"%}}
```yaml
{{< render_external_code "https://raw.githubusercontent.com/kubermatic/machine-controller/main/examples/vmware-cloud-director-machinedeployment.yaml" >}}
```
{{%/expand%}}

[1]: https://github.com/kubermatic/machine-controller/blob/main/examples/vmware-cloud-director-machinedeployment.yaml
