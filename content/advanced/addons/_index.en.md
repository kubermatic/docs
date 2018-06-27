+++
title = "Kubermatic Addons"
date = 2018-06-21T14:07:15+02:00
weight = 6
pre = "<b></b>"
+++

### Kubermatic addons

Addons are specific services and tools extending functionality of kubernetes. In `kubermatic` we have a set of default addons installed on each user-cluster. The default addons are:

* [Canal](https://github.com/projectcalico/canal): policy based networking for cloud native applications
* [Dashboard](https://github.com/kubernetes/dashboard): General-purpose web UI for kubernetes clusters
* [DNS](https://github.com/kubernetes/dns): kubernetes DNS service
* [heapster](https://github.com/kubernetes/heapster): Compute Resource Usage Analysis and Monitoring of Container Clusters
* [kube-proxy](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/): kubernetes network proxy
* [rbac](https://kubernetes.io/docs/reference/access-authn-authz/rbac/): kubernetes Role-Based Access Control, needed for [TLS node bootstrapping](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet-tls-bootstrapping/)
* [OpenVPN client](https://openvpn.net/index.php/open-source/overview.html): virtual private network (VPN) implementation

Installation and configuration of this addons is done by the `addon-controller` which is part of `kubermatic`. Two components are responsible for the addons management:

* `kubermatic-controller-manager` is a wrapper for the `addon-controller` and provides a path to the addon manifests via flag `kubermatic-api -addons=/opt/addons`
* `kubermatic-api` controls which of the addons should be installed via flag `kubermatic-controller-manager -addons=dns,...`

#### Configuration

The configuration of `kubermatic-controller-manager` and `kubermatic-api` is done via flags. Deployment of this components is done via [helm](https://docs.helm.sh/using_helm/#using-helm). Helm charts for this components are stored in `charts/kubermatic/templates/` folder from the `kubermatic-installer` repository. You can find kubermatic-api chart  [here](https://github.com/kubermatic/kubermatic-installer/blob/release/v2.6/charts/kubermatic/templates/kubermatic-api-dep.yaml) and kubermatic-controller-manager chart  [here](https://github.com/kubermatic/kubermatic-installer/blob/release/v2.6/charts/kubermatic/templates/kubermatic-controller-manager-dep.yaml). Configuration of the charts can be done via the `values.yaml` file and applied with `helm upgrade`

```
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace kubermatic kubermatic charts/kubermatic
```

`kubermatic-api` controls which addons should be installed by default. `addon-manager` controls where to get the manifests for the addons and the installation process of the addons.

`kubermatic` is delivered with manifests for all default addons. Each addon is represented by manifest files in a sub-folder. All addons will be build into a docker container `kubermatic/addons` which the `addon-controller` uses to install addons. The docker image is freely accessible to let customers extend & modify this image for their own purpose. The addon-controller will read all addon manifests from a specified folder. The default folder for this is `/opt/addons` and it should contain sub-folders for each addon. This folder is created as a Volume during the container initialization process of `addon-manager` in the [init pod](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-initialization/) and is specified in [kubermatic-controller-manager-dep.yaml](https://github.com/kubermatic/kubermatic-installer/blob/release/v2.6/charts/kubermatic/templates/kubermatic-controller-manager-dep.yaml).


#### Install and run addons

`kubermatic-api` component will add all default addons (`canal,dashboard,dns,heapster,kube-proxy,openvpn,rbac`) to the user cluster. You can override the default plugins with the command line parameter `kubermatic-api -adons="canal,dns,heapster,kube-proxy,openvpn,rbac"` if you don't want to install `dashboard` addon. Or you can change a list of addons in `.Values.kubermatic.addons.defaultAddons` in the kubermatic `values.yaml` file before the installation.

#### Template variables

All cluster object variables can be used in all addon manifests:

Specific template variables used in default templates:
* `{{first .Cluster.Spec.ClusterNetwork.Pods.CIDRBlocks}}`:  will render a IP block of the cluster
* `{{default "k8s.gcr.io/" .OverwriteRegistry}}`: will give you a path to the alternative docker image registry. You can set this path with `kubermatic-controller-manager -overwrite-registry="..."` You can set this parameter in the helm chart for `kubermatic-controller-manager`
* `{{.DNSClusterIP}}`: will render IP address of the DNS server


### How to add a custom addon

1. All manifests and config for the default addons are stored `quay.io/kubermatic/addons` image. Use this image as a base image and copy configs and manifests for all custom addons to `/addons` folder.

Custom addon with manifest
```
.
├── Dockerfile
└── foo
    └── deployment.yaml
```

Dockerfile for custom addons:
```
FROM quay.io/kubermatic/addons:v0.0.1

ADD ./ /addons/
```

Release the image with custom addon
```
export TAG=v1.0
docker build -t customer/addons:${TAG} .
docker push customer/addons:${TAG}
```

2. Edit `values.yaml` you are using for the installation of kubermatic. Change the path to the addons repository

```
kubermatic:
  controller:
    addons:
      image:
        repository: "quay.io/customer/addons" # <-- add your repo here
```


3. Add your addon to the list of default addons in `values.yaml`:

```
kubermatic:
  docker:
  addons:
    # list of Addons to install into every user-cluster. All need to exist in the addons image
    defaultAddons:
    - foo # <-- add your addon here
    - canal
    - dashboard
    - dns
    - heapster
    - kube-proxy
    - openvpn
    - rbac
```

4. Update the installation of kubermatic
```
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace kubermatic kubermatic charts/kubermatic
```
