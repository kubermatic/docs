+++
title = "Running behind a proxy"
date = 2024-05-31T07:00:00+02:00
+++

If nodes only have access via a HTTP proxy, you can let the machine-controller configure all new
nodes to use this proxy. For this the following flag must be set on the machine-controller side:

```bash
-node-http-proxy="http://192.168.1.1:3128"
```

This will set the following environment variables via `/etc/environment` on all nodes
(lower & uppercase):

- `HTTP_PROXY`
- `HTTPS_PROXY`

`NO_PROXY` can be configured using a dedicated flag:

```bash
-node-no-proxy="10.0.0.1"
```

`-node-http-proxy` & `-node-no-proxy` must only contain IP addresses and/or domain names.
