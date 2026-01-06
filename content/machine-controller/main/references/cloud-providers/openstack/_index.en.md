+++
title = "OpenStack"
date = 2024-05-31T07:00:00+02:00
+++

## Configuration Options

An example `MachineDeployment` can be found here:
[examples/openstack-machinedeployment.yaml](https://github.com/kubermatic/machine-controller/blob/main/examples/openstack-machinedeployment.yaml)

{{%expand "Sample machinedeployment.yaml"%}}
```yaml
{{< render_external_code "https://raw.githubusercontent.com/kubermatic/machine-controller/main/examples/openstack-machinedeployment.yaml" >}}
```
{{%/expand%}}

## Provider configuration

The OpenStack provider accepts the following configuration parameters:

```yaml
# identity endpoint of your openstack installation
identityEndpoint: ""
# application Credential ID and Secret can be used in place of username, password, tenantName/tenantID, and domainName.
# application credentials ID
applicationCredentialID: ""
# application credentials secret
applicationCredentialSecret: ""
# your openstack username
username: ""
# your openstack password
password: ""
# the openstack domain
domainName: "default"
# project name
projectName: ""
# project id
projectID: ""
# tenant name (deprecated, should use projectName)
tenantName: ""
# tenant Id (deprecated, should use projectID)
tenantID: ""
# image to use
image: "Ubuntu 18.04 amd64"
# instance flavor
flavor: ""
# UUID of the server group
# used to configure affinity or anti-affinity of the VM instances relative to hypervisor
serverGroup: ""
# additional security groups.
# a default security group will be created for node-to-node communication
securityGroups:
  - "external-ssh"
# the name of the subnet to use
subnet: ""
# the floating IP pool to use. When set a floating IP will be assigned to the instance
floatingIpPool: ""
# the availability zone to create the instance in
availabilityZone: ""
# the region to operate in
region: ""
# the name of the network to use
network: ""
# compute microversion
computeAPIVersion: ""
# set trust-device-path flag for kubelet
trustDevicePath: false
# Optional, if set, the rootDisk will be a volume. If not, the rootDisk
# will be on ephemeral storage and its size will be derived from the flavor
rootDiskSizeGB: 50
# Optional, only applied if rootDiskSizeGB is set.
# Sets the volume type of the root disk.
rootDiskVolumeType: ""
# set node-volume-attach-limit flag for cloud-config
nodeVolumeAttachLimit: 20
# the list of tags you would like to attach to the instance
tags:
  tagKey: tagValue
```

### Multiple Networks

Instances can be attached to multiple networks by specifying a list under the `networks` key.

```yaml
networks:
  - core-network
  - secondary-network
```

The first entry in the list is treated as the **primary network**, which is used for associating Floating IPs.

Alternatively, you can configure it like this:

```yaml
network: core-network
networks:
  - secondary-network
```

## Upload supported images to OpenStack

There is a script in the machine-controller repository to upload all supported
images to OpenStack.

```bash
./hack/setup-openstack-images.sh
```

By default all images will be named `machine-controller-${OS_NAME}`. The image
names can be overwritten using environment variables:

```bash
UBUNTU_IMAGE_NAME="ubuntu" ./hack/setup-openstack-images.sh
```
