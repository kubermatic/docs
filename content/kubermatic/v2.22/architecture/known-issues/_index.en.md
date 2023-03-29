+++
title = "Known Issues"
date = 2022-07-22T12:22:15+02:00
weight = 25

+++

## Overview

This page documents the list of known issues and possible work arounds/solutions.

### 1. OIDC User Authentication Issue

**Problem** 

[OIDC]({{< ref "../../tutorials-howtos/oidc-provider-configuration/share-clusters-via-delegated-OIDC-authentication" >}}) user is denied to access the user cluster in the KKP with K8s version of 1.20 and below. Refer the github issue [Bug: OIDC authentication...](https://github.com/kubermatic/kubermatic/issues/9908) for detailed problem description. Example logs look like below,

Kubectl output

```
kubectl get nodes
error: You must be logged in to the server (Unauthorized)
```

API server logs

```
2022-05-26T11:46:11.269134597Z stderr F E0526 11:46:11.267368       1 authentication.go:63] "Unable to authenticate the request" err="[invalid bearer token, oidc: authenticator not initialized]"
2022-05-26 13:46:11	
2022-05-26T11:46:11.200645694Z stderr F E0526 11:46:11.200494       1 authentication.go:63] "Unable to authenticate the request" err="[invalid bearer token, oidc: authenticator not initialized]"
2022-05-26 13:46:10	
2022-05-26T11:46:10.282230799Z stderr F E0526 11:46:10.282080       1 oidc.go:224] oidc authenticator: initializing plugin: Get "https://<your-kkp.domain>/dex/.well-known/openid-configuration": net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)

```


**Root cause**
 
The KKP [API Server network policy]({{< ref "../../tutorials-howtos/networking/apiserver-policies" >}}) is relying on the namespace label `kubernetes.io/metadata.name` which is automatically present on K8s 1.21 and above versions, but missing on K8s versions below 1.21. Due to the mismatch in the label selector, the access is denied.

**Solution**

As the issue is seen only with older versions of K8s which have reached end of life, the preferred solution is to upgrade the K8s to 1.21 or the latest version. 
In the case where upgrade is not desirable then a work around can be applied by adding a label to the `nginx-ingress-controller` namespace as shown below.

`kubectl label ns nginx-ingress-controller "kubernetes.io/metadata.name=nginx-ingress-controller"`

### 2. Connectivity Issue in Pod-to-NodePort Service in Cilium + IPVS Proxy Mode

**Problem**

In a KKP user cluster with Cilium CNI and IPVS kube-proxy mode, the connectivity between the NodePort service and client pod does not work when the service is load balanced to a pod running on a remote node. For the detailed description and the steps to reproduce the problem, refer issue [#8767](https://github.com/kubermatic/kubermatic/issues/8767).

**Root Cause**

IPVS kube-proxy mode is not really supported by Cilium as mentioned in the Cilium issue [#18610](https://github.com/cilium/cilium/issues/18610).

**Solution**

We do not recommend to configure the Cilium with IPVS kube-proxy mode and this option has been removed from the KKP UI as part of the issue [#4687](https://github.com/kubermatic/dashboard/issues/4687).


### 3. Networking issues with Cilium and Systemd based distributions

**Problem**

In KKP user clusters with Cilium CNI running on a systemd based distribution the network can become unstable.

We do not necessarily meet the [requirements for systemd based distribution](https://docs.cilium.io/en/v1.13/operations/system_requirements/#systemd-based-distributions) by default nor does KKP change os/systemd settings based on CNI.

**Root Cause**

An update of systemd caused an incompatibility with cilium. With that change systemd is managing external routes by default. 
On a change in the network this can cause systemd to delete cilium owned resources.

**Solution**

* Adjust systemd manually based on the [cilium requirements](https://docs.cilium.io/en/v1.13/operations/system_requirements/#systemd-based-distributions).

* Use a custom OSP and configure systemd: 

````yaml
apiVersion: operatingsystemmanager.k8c.io/v1alpha1
kind: CustomOperatingSystemProfile
metadata:
  name: cilium-ubuntu
  namespace: kubermatic
spec:
  bootstrapConfig:
    files:
      - content:
          inline:
            data: |
              [Network]
              ManageForeignRoutes=no
              ManageForeignRoutingPolicyRules=no
            encoding: b64
        path: /etc/systemd/networkd.conf
        permissions: 644
    modules:
      runcmd:
        - systemctl reload systemd-networkd.service
````
