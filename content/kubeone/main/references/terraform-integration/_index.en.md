+++
title = "Terraform Integration"
date = 2021-02-10T12:00:00+02:00
weight = 2
+++

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
#   https://docs.kubermatic.com/kubeone/main/architecture/concepts/#kubermatic-machine-controller
# Example MachineDeployment manifests for each supported provider can be found
# in the machine-controller repository:
#   https://github.com/kubermatic/machine-controller/tree/main/examples
output "kubeone_workers" {}

# Contains optional information about static workers hosts, such as IP addresses,
# hostnames, and SSH parameters
output "kubeone_static_workers" {}

# Contains optional information about the proxy to configure
output "proxy" {}
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

### `kubeone_hosts` Reference

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
      #   https://docs.kubermatic.com/kubeone/main/architecture/compatibility/
      # The cloud provider name is defined by the KubeOne API.
      # You can run kubeone config print --full and refer to the
      # cloudProvider section for the list of cloud provider names
      cloud_provider       = "aws"
      # Removes any taints from control plane nodes
      untaint              = true
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
      bastion_host_key     = var.bastion_host_key
      labels               = var.control_plane_labels
      # uncomment to following to set those kubelet parameters. More into at:
      # https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/
      # kubelet            = {
      #   system_reserved = "cpu=200m,memory=200Mi"
      #   kube_reserved   = "cpu=200m,memory=300Mi"
      #   eviction_hard   = ""
      #   max_pods        = 110
      # }
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
        # Settings this will set metadata.annotations to the Node object
        annotations = {}
        # Settings this will set metadata.labels to the Node object
        labels = {}
        # Settings this will set spec.taints to the Node object
        # See more https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#taint-v1-core
        taints = []
        # Information about SSH keys and operating system are common for
        # all providers.
        sshPublicKeys   = [aws_key_pair.deployer.public_key]
        operatingSystem = local.worker_os
        operatingSystemSpec = {
          distUpgradeOnBoot = false
        }
        # machineObjectAnnotations are applied on resulting Machine objects
        # uncomment to following to set those kubelet parameters. More into at:
        # https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/
        # machineObjectAnnotations = {
        #   "v1.kubelet-config.machine-controller.kubermatic.io/SystemReserved" = "cpu=200m,memory=200Mi"
        #   "v1.kubelet-config.machine-controller.kubermatic.io/KubeReserved"   = "cpu=200m,memory=300Mi"
        #   "v1.kubelet-config.machine-controller.kubermatic.io/EvictionHard"   = ""
        #   "v1.kubelet-config.machine-controller.kubermatic.io/MaxPods"        = "110"
        # }
        # CloudProviderSpec is provider-specific. The following example is an
        # AWS CloudProviderSpec.
        # In the machine-controller repository, you can find example manifests
        # from where you can take cloudProviderSpec:
        #   https://github.com/kubermatic/machine-controller/tree/main/examples
        # You shouldn't include the information about credentials
        # as credentials are configured automatically by KubeOne as environment
        # variables in the machine-controller pod.
        cloudProviderSpec = {
          # provider specific fields:
          # see example under `cloudProviderSpec` section at:
          # https://github.com/kubermatic/machine-controller/blob/main/examples/aws-machinedeployment.yaml
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

### `kubeone_static_workers` Reference

The `kubeone_static_workers` section includes the following information:

* public and private IP addresses
* instance hostnames
* SSH parameters
* optionally, parameters for bastion/jump host if such is used

```terraform
output "kubeone_static_workers" {
  description = "Static worker config"

  value = {
    # Name of the group, has no meaning besides for convenience
    workers1 = {
      # Arrays containing public, private IP addresses, and hostnames.
      # Order of instances must be same across all three arrays.
      # Public addresses are not used in default AWS configs, instead
      # we access instances over the bastion host defined below
      # public_address     = <public-addresses>
      private_address      = aws_instance.static_workers1.*.private_ip
      hostnames            = aws_instance.static_workers1.*.private_dns
      # SSH parameters.
      # Path to SSH agent socket. Usually, value of this parameter is
      # env:SSH_AUTH_SOCK (value of the SSH_AUTH_SOCK environment variable)
      ssh_agent_socket     = var.ssh_agent_socket
      ssh_port             = var.ssh_port
      ssh_private_key_file = var.ssh_private_key_file
      ssh_user             = var.ssh_username
      # The bastion host can be used if the instances are not publicly exposed
      # on the Internet.
      # The following variables can be omitted if bastion/jump host is not used
      bastion              = aws_instance.bastion.public_ip
      bastion_port         = var.bastion_port
      bastion_user         = var.bastion_user
      bastion_host_key     = var.bastion_host_key
      labels               = var.control_plane_labels
      # uncomment to following to set those kubelet parameters. More into at:
      # https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/
      # kubelet            = {
      #   system_reserved = "cpu=200m,memory=200Mi"
      #   kube_reserved   = "cpu=200m,memory=300Mi"
      #   eviction_hard   = ""
      #   max_pods        = 110
      # }
    }
  }
}
```

### `proxy` Reference

```terraform
output "proxy" {
  description = "Proxy info"

  value = {
    # Indicate HTTP proxy (corresponds HTTP_PROXY environment variable)
    http    = ""
    # Indicate HTTPS proxy (corresponds HTTPS_PROXY environment variable)
    https   = ""
    # Indicate hosts to not proxy (corresponds NO_PROXY environment variable)
    noProxy = ""
  }
}
```

[terraform-configs-github]: https://github.com/kubermatic/kubeone/tree/mai/examples/terraform
[concepts-mc]: {{< ref "../../architecture/concepts#kubermatic-machine-controller" >}}
