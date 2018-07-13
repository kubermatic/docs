+++
title = "Kubermatic Offline Mode"
date = 2018-04-28T12:07:15+02:00
weight = 5
pre = "<b></b>"
+++

### Kubermatic offline mode

## Download all required images

To aid in downloading all required images, Kubermatic provides the `image-loader` CLI utility. It can be used like
this:

```bash
image-loader -logtostderr -v 2 -registry-name registry.corp.com [-version $KUBERNETES_VERSION]
```
