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
- **Node Subnet:** Depends on the subnet used by the underlying Kubernetes cluster. For example,

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
