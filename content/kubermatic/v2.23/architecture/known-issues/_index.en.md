+++
title = "Known Issues"
date = 2022-07-22T12:22:15+02:00
weight = 25

+++

## Overview

This page documents the list of known issues and possible work arounds/solutions.

## Recent Ubuntu 22.04 Image Fails to Bootstrap on Azure

### Problem

When using a recent (beginning of May 2024) Ubuntu 22.04 image provided by Azure, user cluster nodes provisioned by machine-controller and operating-system-manager fail to bootstrap and never join the cluster. Instead, the `bootstrap.service` systemd unit is constantly looping.

### Root Cause

A recent change to the Ubuntu 22.04 image has modified the configuration for `cloud-init` and how it accesses its datasource in Azure. `cloud-init clean` (which is used to prepare the machine for configuration as Kubernetes node) removes files crucial to this new way of communicating with the datasource and requires an additional step to recreate the missing configuration files.

### Solution

A new operating-system-manager (OSM) version ([v1.3.6](https://github.com/kubermatic/operating-system-manager/releases/tag/v1.3.6)) has been released that can be configured into `KubermaticConfiguration`:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  userCluster:
    operatingSystemManager:
      imageTag: v1.3.6
[...]
```

The updated OSM version will be included in the next patch release (2.23.16).

For custom OSPs the following change is relevant:

```diff
diff --git a/deploy/osps/default/osp-ubuntu.yaml b/deploy/osps/default/osp-ubuntu.yaml
index 85e8942..353bded 100644
--- a/deploy/osps/default/osp-ubuntu.yaml
+++ b/deploy/osps/default/osp-ubuntu.yaml
@@ -102,6 +102,11 @@ spec:
               curl -s -k -v --header 'Authorization: Bearer {{ .Token }}'      {{ .ServerURL }}/api/v1/namespaces/cloud-init-settings/secrets/{{ .SecretName }} | jq '.data["cloud-config"]' -r| base64 -d > /etc/cloud/cloud.cfg.d/{{ .SecretName }}.cfg
               cloud-init clean

+              {{- /* Azure's cloud-init provider integration has changed recently (end of April 2024) and now requires us to run this command below once to set some files up that seem required for another cloud-init run. */}}
+              {{- if (eq .CloudProviderName "azure") }}
+              cloud-init init --local
+              {{- end }}
+
               {{- /* The default cloud-init configurations files have a bug on Digital Ocean that causes the machine to be in-accessible on the 2nd cloud-init and in case of Hetzner, ipv6 addresses are missing. Hence we disable network configuration. */}}
               {{- if (or (eq .CloudProviderName "digitalocean") (eq .CloudProviderName "hetzner")) }}
               rm /etc/netplan/50-cloud-init.yaml
```

{{% notice warning %}}
MachineDeployments using the affected OSP need to be [restarted]({{< ref "../../cheat-sheets/rollout-machinedeployment/" >}}) after updating OSM or the custom OSP.
{{% /notice %}}

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

### 3. Ubuntu 22.04 Cloud Image issue on VMware Cloud Director

**Problem**

The issue arises in Ubuntu 22.04 cloud image OVAs starting from version 20230602 when they are run on VMware Cloud Director. This problem disrupts the provisioning of new Kubernetes nodes using machine-controller due to interruptions caused by reboots.

**Root Cause**

The root cause of this issue can be traced back to a change in the default settings of open-vm-tools. These changes, in turn, affect the behavior of cloud-init during startup, leading to the disruptive behavior observed when provisioning new Kubernetes nodes. Specifically, the open-vm-tools.service starts before cloud-init, and it runs with the default timeout (30 seconds).

**Solution**

One interim [solution](https://github.com/canonical/cloud-init/issues/4188#issuecomment-1695041510) in this scenario is to create a custom Ubuntu 22.04 image with the following setting preconfigured
in /etc/vmware-tools/tools.conf file.
```
[deployPkg]
wait-cloudinit-timeout=0
```
This adjustment will help ensure that the issue no longer disrupts the provisioning of new Kubernetes nodes on the affected Ubuntu 22.04 cloud images running on VMware Cloud Director provider.

For additional details and discussions related to this issue, you can refer to the following GitHub issues:
- [open-vm-tools](https://github.com/vmware/open-vm-tools/issues/684).
- [cloud-init](https://github.com/canonical/cloud-init/issues/4188).
