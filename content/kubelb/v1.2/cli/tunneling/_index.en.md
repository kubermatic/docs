+++
title = "Tunneling"
date = 2025-08-27T00:00:00+01:00
weight = 10
enterprise = true
+++

Tunneling allows users to tunnel locally running applications on their workstations or inside VMs and expose them over the internet without worrying about firewalls, NAT, DNS, and certificate issues. It is a great way to expose your local services to the internet without having to worry about the complexities of setting up a load balancer and a DNS record.

KubeLB CLI will expose the workload on secure tunnel with TLS certificates and a DNS record.

These tunnels are designed to be reusable and hence have their own dedicated API type in KubeLB i.e. `Tunnel`. Once a tunnel is created, it's registered with the KubeLB management cluster and can be connected to using the `kubelb tunnel connect` command.

## Tunnels

### Tunnel Configuration

To enable tunneling, you need to configure KubeLB management cluster to expose connection management API. The values.yaml file can be modified like this:

```yaml
kubelb:
  enableGatewayAPI: true
  debug: true
  envoyProxy:
    # -- Topology defines the deployment topology for Envoy Proxy. Valid values are: shared, dedicated, and global.
    topology: shared
    # -- The number of replicas for the Envoy Proxy deployment.
    replicas: 1
  # -- Propagate all annotations from the LB resource to the LB service.
  propagateAllAnnotations: true

  # Tunnel configuration
  tunnel:
    enabled: true
    connectionManager:
      httpRoute:
        enabled: true
        domain: "connection-manager.example.com"
        gatewayName: "default"
        gatewayNamespace: "kubelb"
        annotations:
          external-dns.alpha.kubernetes.io/hostname: "*.apps.example.com,connection-manager.example.com"
          external-dns.alpha.kubernetes.io/ttl: "300"
          cert-manager.io/cluster-issuer: "letsencrypt-production-dns"
      ingress:
        enabled: false
        className: "nginx"
        annotations:
          cert-manager.io/cluster-issuer: "letsencrypt-production-dns"
          nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
          nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
          external-dns.alpha.kubernetes.io/hostname: connection-manager-ingress.example.com
          external-dns.alpha.kubernetes.io/ttl: "10"
          nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
        hosts:
          - host: connection-manager-ingress.example.com
            paths:
              - path: /tunnel
                pathType: Prefix
              - path: /health
                pathType: Prefix
        tls:
          - secretName: connection-manager-tls
            hosts:
              - connection-manager-ingress.example.com
```

You can either use Ingress or HTTPRoute to expose the connection management API. Gateway API is the preferred way to expose the API. In this example `*.apps.example.com` is used as a wildard domain for these tunnels, you can use any other domain you want.

Afterwards, you need to configure the connection manager URL at the Config or Tenant level:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  ingress:
    class: "nginx"
  gatewayAPI:
    class: "eg"
  loadBalancer:
    limit: 15
  certificates:
    defaultClusterIssuer: letsencrypt-staging-dns
  tunnel:
    connectionManagerURL: "https://connection-manager.example.com"
```

### Provisioning Tunnels

Tunnels are created either using the `kubelb expose 1313` command or the `kubelb tunnel create` command.

```bash
kubelb expose 1313
```

![Demo animation](/img/kubelb/v1.2/tunneling.gif?classes=shadow,border "Tunneling Demo")

This will create a tunnel with a generated hostname and will forward traffic to the port `1313` on the local machine. The Ingress point for this traffic is KubeLB's management cluster and hence the traffic is secure and encrypted.

An alternative way to create a tunnel is to use the `kubelb tunnel create` command.

```bash
kubelb tunnel create my-app --port 1313
```

This will create a tunnel with a generated hostname and can be used through the `kubelb tunnel connect` command.

```bash
kubelb tunnel connect my-app --port 1313
```

This will connect to the tunnel and forward traffic to the port `1313` on the local machine. The Ingress point for this traffic is KubeLB's management cluster and hence the traffic is secure and encrypted.

## Further actions

Further actions include:

- Deleting the tunnel
- Getting the tunnel details
- Listing all the tunnels

For more information, please refer to the [Tunnel API](../../references/api/tunnel/) documentation.
