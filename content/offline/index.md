# Kubermatic offline mode

## Download all required images

To aid in downloading all required images, Kubermatic provides the `image-loader` cli utility. It can be used like
this:

`image-loader -logtostderr -v 2 -registry-name registry.corp.com [-version $KUBERNETES_VERSION]`
