+++
title = "Using HTTP Proxy with KKP"
date = 2024-04-24T12:00:00+00:00
weight = 120
+++

This is a guide for setting up an HTTP proxy for Kubermatic Kubernetes Platform (KKP) to allow the platform to access the internet and other services via a proxy server.

## Prerequisites

The most important prerequisite is to determine the values for proxy and no-proxy configuration. The proxy settings include the proxy server's IP address or hostname and the port number, if required. The no-proxy settings include the list of IP addresses, hostnames, or domain names that should bypass the proxy server.

For demonstration purposes, going forward, we would assume that the proxy server is running at <http://server-proxy.local:8080>.

The following is a list of values that need to be ignored by the proxy server:

- **Kubernetes:** 127.0.0.1,localhost,.local,.local.,kubernetes,.default,.svc
- **Domain:** kkp.example.com (replace with your domain)
- **Node Subnet:** Depends on the subnet used by the underlying Kubernetes cluster.

From KKP:

- **NodeLocal DNSCache:** 169.254.20.10
- **Pod CIDR:** 172.25.0.0/16, fd01::/48 (only required when using IPv6)
- **Service CIDR:** 10.240.16.0/20, fd02::/120 (only required when using IPv6)

**NOTE: The values for pod and service CIDR are the defaults from KKP and in case you have changed them, you need to update the no-proxy settings accordingly.**

## Configuring KKP to use the Proxy

Based on requirements and networking architecture, a KKP admin can configure the proxy settings at different levels:

### Master Components

This configures the KKP master components such as API, Dashboard, and other services to use the proxy server.

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  proxy:
    http: "http://server-proxy.local:8080"
    https: "http://server-proxy.local:8080"
    noProxy: "127.0.0.1,localhost,.local,.local.,kubernetes,.default,.svc, 169.254.20.10, 172.25.0.0/16, 10.240.16.0/20, kkp.example.com"
```

### Seed Components

This configures the KKP seed components such as Seed Controller, API server for the user clusters, and most importantitly, the user cluster controller for each user cluster to use the proxy server. In case of using KKP Applications features or Cilium CNI, the proxy settings are required for the user cluster controller to pull the source (helm/git) of those applications from upstream.

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Seed
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  # these two fields are only informational
  country: FR
  location: Paris

  proxySettings:
    # If set, this proxy will be configured for both HTTP and HTTPS.
    httpProxy: "http://server-proxy.local:8080"
    noProxy: "127.0.0.1,localhost,.local,.local.,kubernetes,.default,.svc, 169.254.20.10, 172.25.0.0/16, 10.240.16.0/20, kkp.example.com"
```

### Nodes for the User Clusters

This configures the worker nodes for the user cluster to use the proxy server. This is required for the nodes to pull the container images from the internet and other services.

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Seed
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  # these two fields are only informational
  country: FR
  location: Paris

  # List of datacenters where this seed cluster is allowed to create clusters.
  datacenters:
    vsphere-de:
      country: DE
      location: Hamburg
      spec:
        vsphere:
          endpoint: "https://vsphere.hamburg.example.com"
      node:
        # If set, this proxy will be configured for both HTTP and HTTPS.
        httpProxy: "http://server-proxy.local:8080"
        noProxy: "127.0.0.1,localhost,.local,.local.,kubernetes,.default,.svc, 169.254.20.10, 172.25.0.0/16, 10.240.16.0/20, kkp.example.com"
```

### User Cluster

For more granular control, proxy settings can be configured at a user cluster level. This allows overriding the more general proxy settings defined at the seed's datacenter level for a specific cluster.

This is particularly useful when a specific cluster requires different proxy rules than the default ones applied to all other clusters in the same datacenter.

**Note** that the cluster-level proxy configuration takes precedence over the node-level settings for the OSM component.

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Cluster
metadata:
  name: my-user-cluster
spec:
  # ... other cluster specifications
  componentsOverride:
    operatingSystemManager:
      proxy:
        httpProxy: "http://proxy.corp.example.com:8080"
        noProxy: ".internal.corp,192.168.0.0/16,localhost"
  # ... other cluster specifications
```

## Configuring the Per-Cluster Proxy from the Dashboard

The same per-cluster proxy can be configured from the KKP dashboard, so that cluster owners do not need direct access to the `Cluster` object. In the UI the two fields are grouped in a **Node Egress Proxy** section:

| UI field | Cluster spec field | Description |
| --- | --- | --- |
| **HTTP(S) Proxy** | `spec.componentsOverride.operatingSystemManager.proxy.httpProxy` | Proxy endpoint used for both HTTP and HTTPS egress from the cluster nodes, for example `http://proxy.corp.example.com:3128`. |
| **No Proxy** | `spec.componentsOverride.operatingSystemManager.proxy.noProxy` | List of destinations that bypass the proxy, for example `.internal.corp`, `192.168.0.0/16` or `localhost`. The entries are stored as a single comma-separated string in the `Cluster` object. |

These values set the `HTTP_PROXY`, `HTTPS_PROXY` and `NO_PROXY` environment variables on the worker nodes. They are used for node egress such as container image pulls and package downloads, and they do not affect control plane traffic to the cloud provider.

### Cluster Wizard

In the cluster creation wizard, open the **Cluster** step and expand the **ADVANCED NETWORK CONFIGURATION** panel. The **Node Egress Proxy** section is located at the bottom of that panel.

![Node Egress Proxy in the cluster wizard](images/wizard-proxy-settings.png?classes=shadow,border "Node Egress Proxy in the cluster wizard")


The configured values are shown in the **NETWORK CONFIGURATION** part of the wizard summary step before the cluster is created.

![Proxy settings in the cluster summary](images/cluster-summary-proxy.png?classes=shadow,border "Proxy settings in the cluster summary")



{{% notice info %}}
**Accepted values.** Both fields are validated in the dashboard and again by the KKP API.

- **HTTP(S) Proxy** must be an `http://` or `https://` URL with a host, for example `http://proxy.corp.example.com:3128`.
- **No Proxy** takes hostnames, leading-dot domain suffixes, IP addresses or CIDR ranges, for example `.cluster.local`.
{{% /notice %}}

![Validation of the proxy settings](images/proxy-validation.png?classes=shadow,border "Validation of the proxy settings")

### Existing Clusters

The proxy settings can also be changed after the cluster has been created. Open the cluster details page, choose **Edit Cluster** and update the **Node Egress Proxy** fields.

![Node Egress Proxy in the edit cluster dialog](images/edit-cluster-proxy.png?classes=shadow,border "Node Egress Proxy in the edit cluster dialog")



### Cluster Templates

The **Node Egress Proxy** fields are part of the cluster wizard, so they are also stored in cluster templates created from it. Clusters created from such a template inherit the proxy configuration from the template's `spec.componentsOverride.operatingSystemManager.proxy`.

![Proxy settings persisted in a cluster template](images/cluster-template-proxy.png?classes=shadow,border "Proxy settings persisted in a cluster template")



{{% notice note %}}
Leaving both fields empty means the cluster inherits the proxy settings of its datacenter/seed. Setting them overrides those defaults for this cluster only. Clearing both fields again on an existing cluster removes the override, and the cluster re-inherits the datacenter/seed proxy settings.
{{% /notice %}}
