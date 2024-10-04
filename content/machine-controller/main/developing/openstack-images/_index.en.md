+++
title = "OpenStack Images"
date = 2024-05-31T07:00:00+02:00
+++

## Upload supported images to OpenStack

There is a script in the machine-controller repository to upload all supported
images to OpenStack.

```bash
./hack/setup-openstack-images.sh
```

By default all images will be named `machine-controller-${OS_NAME}`. The image
names can be overwritten using environment variables:

```bash
UBUNTU_IMAGE_NAME="ubuntu" CENTOS_IMAGE_NAME="centos" ./hack/setup-openstack-images.sh
```
