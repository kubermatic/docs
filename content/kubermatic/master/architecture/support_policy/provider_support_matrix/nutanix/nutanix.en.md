+++
title = "Nutanix"
date = 2022-03-02T12:00:00+02:00
weight = 7
+++

KKP supports creating user clusters on [Nutanix&trade;](https://www.nutanix.com/) hyper-converged infrastructure. To use the Nutanix integration, a [Nutanix Prism Central](https://www.nutanix.com/products/prism) installation that exposes the [Prism Central v3 API](https://www.nutanix.dev/api_references/prism-central-v3/#/) is required.

Configuration of Nutanix credentials can be done through [Presets]({{< ref "../../../../tutorials_howtos/administration/admin_panel/presets_management" >}}) or by providing them during the cluster creation wizard, same as with other providers.

## Features

- [CSI driver for Nutanix Volumes and Nutanix Files](https://portal.nutanix.com/page/documents/details?targetId=CSI-Volume-Driver-v2_5:csi-csi-plugin-overview-c.html) will be installed onto the user cluster.

## VM Images

Images to create VMs from need to be provided and can be configured in the datacenter spec when configuring a `Seed` to include a Nutanix `Datacenter`. The following OS images are tested and supported:

- [Ubuntu 20.04 (focal)](https://cloud-images.ubuntu.com/focal/current/)
- [CentOS 7](https://cloud.centos.org/centos/7/images/)

## Credentials and Permissions

A Nutanix user cluster in KKP requires two sets of credentials:

- Prism Central credentials for management of infrastructure resources and VMs
- Prism Element credentials for configuring and using the CSI driver

During cluster creation or in a Preset, you will be prompted to configure a Nutanix target cluster. Make sure that your Prism Element credentials match the Nutanix cluster that you are planning to use.

### Prism Central

The credentials to access Prism Central require the `Prism Central Admin` role, due to its management of [categories](https://portal.nutanix.com/page/documents/details?targetId=SSP-Admin-Guide-v6_0:ssp-category-management-c.html) to group resources.

### Prism Element

Due to requirements by the CSI driver, the Prism Element credentials require the `Cluster Admin` role.
