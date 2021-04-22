+++
title = "Dynamic Kubelet configuration"
date = 2020-04-01T12:00:00+02:00
weight = 100

+++

Dynamic kubelet configuration allows for live reconfiguration of some or all nodes' kubelet options.

### See Also
* https://kubernetes.io/blog/2018/07/11/dynamic-kubelet-configuration/</li>
* https://kubernetes.io/docs/tasks/administer-cluster/reconfigure-kubelet/</li>
* https://github.com/kubernetes/enhancements/issues/281</li>

### Enabling

To enable dynamic kubelet configuration, mark the `Dynamic kubelet config` checkbox when creating a Machine Deployment. Nodes created by such a deployment will be automatically configured to look for a configmap named `kubelet-config-<k8s-version>` (e.g. `kubelet-config-1.17`) in the `kube-system` namespace.

![Add Machine Deployment](/img/kubermatic/v2.17/ui/md_add.png?classes=shadow,border "Add Machine Deployment")

Normally these configmaps for different versions are created with a set of healthy default options by Kubermatic Kubernetes Platform's (KKP) default `kubelet-configmap` addon. However, if you want to customize the settings, you can replace the default addon with your own. You can also alter the `configSource` parameter of the Machine Deployment to point the kubelet to another config map - that way you can have multiple configurations for multiple sets of nodes.

{{% notice warning %}}
The dynamic kubelet configuration is a beta feature in both Kubernetes and KKP. Refer to the Kubenetes documentation for more information.
{{% /notice %}}
