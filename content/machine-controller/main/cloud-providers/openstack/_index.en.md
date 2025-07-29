+++
title = "OpenStack"
date = 2024-05-31T07:00:00+02:00
+++

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
# image to use (currently only ubuntu is supported)
image: "Ubuntu 18.04 amd64"
# instance flavor
flavor: ""
# additional security groups.
# a default security group will be created which node-to-node communication
securityGroups:
  - "external-ssh"
# the name of the subnet to use
subnet: ""
# [not implemented] the floating ip pool to use. When set a floating ip will be assigned o the instance
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
# set root disk size
rootDiskSizeGB: 50
# set root disk volume type
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
UBUNTU_IMAGE_NAME="ubuntu"./hack/setup-openstack-images.sh
```
