+++
title = "Using Static Workers"
date = 2020-04-15T12:00:00+02:00
+++

Starting with version `v1.0.0` (currently unreleased, need to build from master) , KubeOne Added support for provisioning Kubernetes clusters with static worker nodes.

This is useful in cases where the infrastructure provider is not supported by [machine-controller][1]. In this case, KubeOne will use the static worker nodes provided in the cluster configuration.


Static workers are defined similarly to the control plane hosts, but they have their own API field `staticWorkers`:

```yaml
# The list of nodes can be overwritten by providing Terraform output.
# You are strongly encouraged to provide an odd number of nodes and
# have at least three of them.
# Remember to only specify your *master* nodes.
controlPlane:
  hosts:
  - publicAddress: '1.2.3.4'
    privateAddress: '172.18.0.1'
    bastion: '4.3.2.1'
    bastionPort: 22  # can be left out if using the default (22)
    bastionUser: 'root'  # can be left out if using the default ('root')
    sshPort: 22 # can be left out if using the default (22)
    sshUsername: ubuntu
    # You usually want to configure either a private key OR an
    # agent socket, but never both. The socket value can be
    # prefixed with "env:" to refer to an environment variable.
    sshPrivateKeyFile: '/home/me/.ssh/id_rsa'
    sshAgentSocket: 'env:SSH_AUTH_SOCK'
    # Taints is used to apply taints to the node.
    # If not provided defaults to TaintEffectNoSchedule, with key
    # node-role.kubernetes.io/master for control plane nodes.
    # Explicitly empty (i.e. taints: {}) means no taints will be applied.
    taints:
    - key: "node-role.kubernetes.io/master"
      effect: "NoSchedule"

# A list of static workers, not managed by MachineController.
# The list of nodes can be overwritten by providing Terraform output.
staticWorkers:
  hosts:
  - publicAddress: '1.2.3.5'
    privateAddress: '172.18.0.2'
    bastion: '4.3.2.1'
    bastionPort: 22  # can be left out if using the default (22)
    bastionUser: 'root'  # can be left out if using the default ('root')
    sshPort: 22 # can be left out if using the default (22)
    sshUsername: ubuntu
    # You usually want to configure either a private key OR an
    # agent socket, but never both. The socket value can be
    # prefixed with "env:" to refer to an environment variable.
    sshPrivateKeyFile: '/home/me/.ssh/id_rsa'
    sshAgentSocket: 'env:SSH_AUTH_SOCK'
    # Taints is used to apply taints to the node.
    # Explicitly empty (i.e. taints: {}) means no taints will be applied.
    # taints:
    # - key: ""
    #   effect: ""
```

[1]: https://github.com/kubermatic/machine-controller
