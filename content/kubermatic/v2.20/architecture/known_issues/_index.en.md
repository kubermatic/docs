+++
title = "Known Issues"
date = 2022-07-20T12:22:15+02:00
weight = 25

+++

## Overview

This page documents the list of known issues and possible work arounds/solutions.

### 1. OIDC user authentication issue

**Problem** 

[OIDC]({{< ref "../../tutorials_howtos/oidc_provider_configuration/share _clusters_via_delegated_OIDC_authentication" >}}) user is denied to access the user cluster in the KKP with K8s version of 1.20 and below. Refer the github issue [Bug: OIDC authentication...](https://github.com/kubermatic/kubermatic/issues/9908) for detailed problem description. Example logs look like below,

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
 
The KKP [API Server network policy]({{< ref "../../tutorials_howtos/networking/apiserver_policies" >}}) is relying on the namespace label `kubernetes.io/metadata.name` which is automatically present on K8s 1.21 and above versions, but missing on K8s versions below 1.21. Due to the mismatch in the label selector, the access is denied.

**Solution**

As the issue is seen only with older versions of K8s which have reached end of life, the preferred solution is to upgrade the K8s to 1.21 or the latest version. 
In the case where upgrade is not desirable then a work around can be applied by adding a label to the `nginx-ingress-controller` namespace as shown below.

`kubectl label ns nginx-ingress-controller "kubernetes.io/metadata.name=nginx-ingress-controller"`

### 2. Connectivity issue in pod-to-NodePort service in Cilium + IPVS proxy mode

**Problem**

In a KKP user cluster with Cilium CNI and IPVS kube-proxy mode, the connectivity between the NodePort service and client pod does not work when the service is load balanced to a pod running on a remote node. For the detailed description and the steps to reproduce the problem, refer issue [#8767](https://github.com/kubermatic/kubermatic/issues/8767).

**Root Cause**

IPVS kube-proxy mode is not really supported by Cilium as mentioned in the Cilium issue [#18610](https://github.com/cilium/cilium/issues/18610).

**Solution**

We do not recommend to configure the Cilium with IPVS kube-proxy mode and this option has been removed from the KKP UI as part of the issue [#4687](https://github.com/kubermatic/dashboard/issues/4687).