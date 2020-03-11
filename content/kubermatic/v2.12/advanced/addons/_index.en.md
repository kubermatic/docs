+++
title = "Kubermatic Addons"
date = 2018-06-21T14:07:15+02:00
weight = 8
pre = "<b></b>"
+++

### Kubermatic addons

Addons are specific services and tools extending functionality of Kubernetes. In Kubermatic we have a set of default addons installed on each user-cluster. The default addons are:

* [Canal](https://github.com/projectcalico/canal): policy based networking for cloud native applications
* [Dashboard](https://github.com/kubernetes/dashboard): General-purpose web UI for Kubernetes clusters
* [DNS](https://github.com/coredns/coredns): Kubernetes DNS service
* [kube-proxy](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/): Kubernetes network proxy
* [rbac](https://kubernetes.io/docs/reference/access-authn-authz/rbac/): Kubernetes Role-Based Access Control, needed for [TLS node bootstrapping](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet-tls-bootstrapping/)
* [OpenVPN client](https://openvpn.net/index.php/open-source/overview.html): virtual private network (VPN). Lets the control plan access the Pod & Service network. Required for functionality like `kubectl proxy` & `kubectl port-forward`.
* [node-exporter](https://github.com/prometheus/node_exporter): Exports metrics from the node
* default-storage-class: A cloud provider specific StorageClass
* kubelet-configmap: A set of ConfigMaps used by kubeadm

Installation and configuration of these addons is done by 2 controllers which are part of the Kubermatic controller-manager:

* `addon-installer-controller`: Ensures a given set of addons will be installed in all clusters
* `addon-controller`: Templates the addons & applies the manifests in the user clusters

#### Configuration

To configure which addons shall be installed in all user clusters, set the following settings in the `values.yaml` for the kubermatic chart:

```yaml
kubermatic:
  controller:
    addons:
      kubernetes:
        defaultAddons:
        - canal
        - dashboard
        - dns
        - kube-proxy
        - openvpn
        - rbac
        - kubelet-configmap
        - default-storage-class
        - node-exporter
        image:
          repository: "quay.io/kubermatic/addons"
          tag: "v0.2.9"
          pullPolicy: "IfNotPresent"
```

To deploy the changes:

```bash
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace kubermatic kubermatic charts/kubermatic
```

##### Setting a custom docker registry

In case you want to set a custom registry for all addons, you can specify the `-overwrideRegistry` flag on the `kubermatic-controller-manager` or via the helm setting `kubermatic.controller.overwriteRegistry`.
It will set the specified registry on all control plane components & addons.

### How to add a custom addon

1. All manifests and config files for the default addons are stored in the `quay.io/kubermatic/addons` image. Use this image as a base image and copy configs and manifests for all custom addons to `/addons` folder.

    Custom addon with manifest

   ```plaintext
   .
   ├── Dockerfile
   └── foo
       └── deployment.yaml
   ```

    Dockerfile for custom addons:

   ```dockerfile
   FROM quay.io/kubermatic/addons:v0.0.1

   ADD ./ /addons/
   ```

    Release the image with custom addon

   ```bash
   export TAG=v1.0
   docker build -t customer/addons:${TAG} .
   docker push customer/addons:${TAG}
   ```

1. Edit `values.yaml` you are using for the installation of Kubermatic. Change the path to the addons repository

   ```yaml
   kubermatic:
     controller:
       addons:
         kubernetes:
           image:
             repository: "quay.io/customer/addons" # <-- add your repo here
   ```

1. Add your addon to the list of default addons in `values.yaml`:

   ```yaml
   kubermatic:
     controller:
       addons:
         kubernetes
           # list of addons to install into every user-cluster. All need to exist in the addons image
           defaultAddons:
           - foo # <-- add your addon here
           - canal
           - dashboard
           - dns
           - kube-proxy
           - openvpn
           - rbac
   ```

1. Update the installation of Kubermatic

   ```bash
   helm upgrade --install --wait --timeout 300 --values values.yaml --namespace kubermatic kubermatic charts/kubermatic
   ```

#### Template variables

All cluster object variables can be used in all addon manifests. Specific template variables and functions used in default templates:

* `{{first .Cluster.Spec.ClusterNetwork.Pods.CIDRBlocks}}`: will render an IP block of the cluster
* `{{.DNSClusterIP}}`: will render the IP address of the DNS server
* `image: {{ Registry quay.io }}/some-org/some-app:v1.0`: Will use quay.io as registry or the overwrite registry if specified
