+++
title = "Configuring SSH"
date = 2020-07-29T12:00:00+02:00
weight = 2
enableToc = true
+++

KubeOne connects to the instances over SSH in order to execute tasks, such
as install or upgrade binaries, run kubeadm, deploy manifests, and more.

As SSH access to instances is required, SSH public/private keys should be
handled somehow. KubeOne doesn't handle decryption of private SSH keys but
instead rely on `ssh-agent`. In the most of cases, we recommend using
`ssh-agent` as the easiest way to have your SSH keys encrypted at rest and
still useful for KubeOne.

## Creating SSH key

If you don't have an SSH key, you can generate it using `ssh-keygen` on Linux
and macOS. If you already have an SSH key, skip this step.

`ssh-keygen` will ask you to provide the path where the key will be stored and
the passphrase to encrypt the key.

## Configuring ssh-agent

If your operating system doesn't automatically setup ssh-agent, you can run the
following command:

```bash
eval `ssh-agent`
```

With ssh-agent in the place, make sure to add your private key to the agent
using `ssh-add` command in order to cache it in ssh-agent memory for later use.

```bash
ssh-add ~/.ssh/my_cool_custom_private_key
```

KubeOne is able to contact ssh-agent via socket (environment variable
`SSH_AUTH_SOCK`) and ask for authentication without getting unencrypted private
key.

## Providing SSH private keys directly, without ssh-agent

In rare case when it's not possible to use ssh-agent, you can provide private
key directly to KubeOne. The caveat is that private SSH key should be
unencrypted and thus we do **NOT** recommend this.

### Option 1: Specify Private Key in the Configuration Manifest

You can point KubeOne to the unencrypted private SSH key via the configuration
manifest.

```yaml
controlPlane:
  hosts:
  - publicAddress: '1.2.3.4'
    ...
    sshPrivateKeyFile: '/home/me/.ssh/my_cleantext_private_key'
```

### Option 2: Specify Private Key in the Terraform Output

You can also provide unencrypted private SSH key using the Terraform
integration.

```terraform
output "kubeone_hosts" {
  value = {
    control_plane = {
      public_address       = my_vm_provider_server.control_plane.*.ipv4_address
      ...
      ssh_private_key_file = "/home/me/.ssh/my_cleantext_private_key"
    }
  }
}
```

## Using gpg-agent

It's possible to use GnuPG agent (`gpg-agent`) in replace of `ssh-agent`.
It has number of advantages, but it's also more complicated to setup.

Add the following two lines to your `.bash_profile`:

```bash
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
```

See more info about how to setup your SSH keys in GnuPG:
* https://opensource.com/article/19/4/gpg-subkeys-ssh
* https://opensource.com/article/19/4/gpg-subkeys-ssh-multiples


## sshd requirements on instances

KubeOne actively uses tunneling features of the SSH protocol. The following
list demonstrates what options of the `sshd` are expected on the control plane
instances and bastion host:

* `AllowTcpForwarding` is either not present or set to `yes`
* `PermitOpen` is either not present or set to `any`
* `PermitTunnel` is either not present or set to `yes`
