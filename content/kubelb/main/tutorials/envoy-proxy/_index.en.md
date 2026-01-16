+++
title = "Envoy Proxy Configuration"
linkTitle = "Envoy Proxy"
date = 2025-01-16T10:00:00+02:00
weight = 9
+++

KubeLB uses [Envoy](https://www.envoyproxy.io/) as its data plane to handle traffic routing, load balancing, and protocol management. The Envoy proxy instances are automatically deployed and configured by KubeLB based on your service requirements.

This section covers advanced Envoy proxy configurations that can be applied through the global `Config` CRD in the management cluster. These settings allow you to fine-tune Envoy's behavior for production workloads.

## Table of Content

{{% children depth=5 %}}
{{% /children %}}
