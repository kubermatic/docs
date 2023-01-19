+++
title = "KubeOne Terraform Integration"
date = 2020-04-01T12:00:00+02:00
weight = 3
+++

KubeOne integrates with Terraform by reading the Terraform state for the
information about the cluster including:

* the Kubernetes API server load balancer endpoint
* nodes' public and private IP addresses, and hostnames
* SSH parameters (username, port, key)
* bastion/jump host parameters if the bastion host is used
* information needed to generate the [MachineDeployment objects][concepts-mc]
  which define worker nodes

To use the integration, users need to generate a Terraform state file using the
`terraform output` command. KubeOne consumes the generated Terraform state file
and reads the needed information. Therefore, the generated file **must**
strictly follow the format used by KubeOne. To accomplish this, users must have
the appropriate `output.tf` file co-located with other Terraform files. The
`output.tf` file defines the template for generating the state file, including
where to look for the information when generating the file.

{{% notice note %}}
The needed `output.tf` file already comes with all our
[example Terraform configs]({{< ref "./terraform_configs" >}}).
{{% /notice %}}

This document serves as a reference for the `output.tf` file (i.e. the
Terraform Integration API). You can also find `output.tf` files in our
[example configs][terraform-configs-github].

## `output.tf` Reference

The `output.tf` file has the three top level sections defining the Kubernetes
API server load balancer endpoint, the information about control plane hosts,
and the information used to generate the MachineDeployments manifest.

```terraform
# Contains the Load Balancer endpoint pointing to the Kubernetes API
output "kubeone_api" {}

# Contains information about control plane hosts, such as IP addresses,
# hostnames, and SSH parameters
output "kubeone_hosts" {}

# Contains templates for generating the MachineDeployment objects.
# More information about Cluster-API, machine-controller, and
# MachineDeployments can be found in the Concepts document:
#   http://docs.kubermatic.com/kubeone/master/concepts/#kubermatic-machine-controller
# Example MachineDeployment manifests for each supported provider can be found
# in the machine-controller repository:
#   https://github.com/kubermatic/machine-controller/tree/master/examples
output "kubeone_workers" {}
```

### `kubeone_api` Reference

The `kubeone_api` section defines the endpoint of the load balancer pointing
to the Kubernetes API server.

```terraform
output "kubeone_api" {
  description = "kube-apiserver LB endpoint"

  value = {
    endpoint = aws_elb.control_plane.dns_name
  }
}
```

### `kubeone_hosts` reference

The `kubeone_hosts` section includes the following information:

* public and private IP addresses
* instance hostnames
* SSH parameters
* optionally, parameters for bastion/jump host if such is used

```terraform
output "kubeone_hosts" {
  description = "Control plane endpoints to SSH to"

  value = {
    control_plane = {
      # Name of the cluster
      cluster_name         = var.cluster_name
      # Cloud provider name.
      # KubeOne Terraform integration works only for natively-supported
      # providers:
      #   http://docs.kubermatic.com/kubeone/master/compatibility_info/
      # The cloud provider name is defined by the KubeOne API.
      # You can run kubeone config print --full and refer to the
      # cloudProvider section for the list of cloud provider names
      cloud_provider       = "aws"
      # Arrays containing public, private IP addresses, and hostnames.
      # Order of instances must be same across all three arrays.
      # Public addresses are not used in default AWS configs, instead
      # we access instances over the bastion host defined below
      # public_address     = <public-addresses>
      private_address      = aws_instance.control_plane.*.private_ip
      hostnames            = aws_instance.control_plane.*.private_dns
      # SSH parameters.
      # Path to SSH agent socket. Usually, value of this parameter is
      # env:SSH_AUTH_SOCK (value of the SSH_AUTH_SOCK environment variable)
      ssh_agent_socket     = var.ssh_agent_socket
      ssh_port             = var.ssh_port
      ssh_private_key_file = var.ssh_private_key_file
      ssh_user             = var.ssh_username
      # Information about the bastion host instance.
      # The bastion host can be used if the instances are not publicly exposed
      # on the Internet.
      # The following variables can be omitted if bastion/jump host is not used
      bastion              = aws_instance.bastion.public_ip
      bastion_port         = var.bastion_port
      bastion_user         = var.bastion_user
    }
  }
}
```

### `kubeone_workers` Reference

The `kubeone_workers` section defines the template used for generating the
MachineDeployments object. Generally, it's defined such as:

```terraform
output "kubeone_workers" {
  description = "Workers definitions, that will be transformed into MachineDeployment object"

  value = {
    # Following outputs will be parsed by KubeOne and automatically merged into
    # corresponding (by name) worker definitions (MachineDeployments)
    "${var.cluster_name}-${local.zoneA}" = {
      # Defines number of replicas
      replicas = var.initial_machinedeployment_replicas
      # ProviderSpec includes information needed to create instances
      providerSpec = {
        # Information about SSH keys and operating system are common for
        # all providers.
        sshPublicKeys   = [aws_key_pair.deployer.public_key]
        operatingSystem = local.worker_os
        operatingSystemSpec = {
          distUpgradeOnBoot = false
        }
        # CloudProviderSpec is provider-specific. The following example is an
        # AWS CloudProviderSpec.
        # In the machine-controller repository, you can find example manifests
        # from where you can take cloudProviderSpec:
        #   https://github.com/kubermatic/machine-controller/tree/master/examples
        # You shouldn't include the information about credentials
        # as credentials are configured automatically by KubeOne as environment
        # variables in the machine-controller pod.
        cloudProviderSpec = {
          # provider specific fields:
          # see example under `cloudProviderSpec` section at:
          # https://github.com/kubermatic/machine-controller/blob/master/examples/aws-machinedeployment.yaml
          region           = var.aws_region
          ami              = local.ami
          availabilityZone = local.zoneA
          instanceProfile  = aws_iam_instance_profile.profile.name
          securityGroupIDs = [aws_security_group.common.id]
          vpcId            = data.aws_vpc.selected.id
          subnetId         = local.subnets[local.zoneA]
          instanceType     = var.worker_type
          assignPublicIP   = true
          diskSize         = 50
          diskType         = "gp2"
          ## Only applicable if diskType = io1
          diskIops           = 500
          isSpotInstance     = false
          ebsVolumeEncrypted = false
          tags = {
            "${var.cluster_name}-workers" = ""
          }
        }
      }
    }

    "${var.cluster_name}-${local.zoneB}" = {
      ...
    }

    "${var.cluster_name}-${local.zoneC}" = {
      ...
    }
  }
}
```

[terraform-configs-github]: https://github.com/kubermatic/kubeone/tree/master/examples/terraform
[concepts-mc]: {{< ref "../concepts#kubermatic-machine-controller" >}}
