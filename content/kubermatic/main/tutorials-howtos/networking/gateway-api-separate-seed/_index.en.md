+++
linkTitle = "Gateway API on Separate Seed Clusters"
title = "Gateway API on Separate Seed Clusters"
date = 2026-08-25T00:00:00+00:00
weight = 156
+++

# Gateway API on Separate Seed Clusters

## Overview

When the master and seed clusters are separate clusters, `kubermatic-installer deploy kubermatic-seed --separate-seed` installs the Gateway API Custom Resource Definitions on the seed cluster and deploys the `envoy-gateway-controller` Helm chart, which creates the GatewayClass `kubermatic-envoy-gateway`.

The `Gateway` object itself is not created by KKP on a separate seed. On the master cluster (and on shared master/seed installations) the kubermatic-operator creates and manages the Gateway from `spec.ingress.gateway` in the `KubermaticConfiguration`, unless `spec.ingress.gateway.externalGateway` is configured. This automation does not extend to separate seed clusters: there the Gateway is created and managed by the administrator.

This page describes how to create the seed Gateway, how TLS works on the seed, and how to verify the setup. It applies to KKP 2.31 and later.

## What the Installer Does and Does Not Do

With `--separate-seed`, the installer:

- installs the Gateway API Custom Resource Definitions on the seed cluster,
- deploys the bundled `envoy-gateway-controller` Helm release, which creates the GatewayClass `kubermatic-envoy-gateway`.

It does not:

- create a `Gateway` object,
- deploy cert-manager,
- run the HTTPRoute-to-Gateway listener sync on the seed (the `HTTPRouteGatewaySync` feature gate has no effect on the seed-controller-manager; the sync controller runs only in the master-controller-manager).

The `kubermatic-seed` stack also deploys MinIO and the S3 exporter; this happens with or without `--separate-seed`.

The seed-scoped HTTPRoutes are created by the IAP chart when you run:

```bash
kubermatic-installer deploy seed-mla --mla-include-iap ...
kubermatic-installer deploy usercluster-mla --mla-include-iap ...
```

The same commands label the namespaces that receive the routes: `deploy seed-mla --mla-include-iap` labels `monitoring`, `deploy usercluster-mla --mla-include-iap` labels `mla`, both with `kubermatic.io/gateway-access=true`. Without the `--mla-include-iap` flag, neither the HTTPRoutes nor the labels are created.

The routes attach to the Gateway configured in the seed Helm values. Without that Gateway, every route stays with an empty `status.parents` and serves no traffic.

If the seed Helm values contain `httpRoute.externalGateway: true`, the installer treats the seed Gateway as bring-your-own and only ensures the CRDs, without deploying the bundled Envoy Gateway controller. In that mode the Gateway controller and data plane are operated entirely outside of KKP; see the [external Gateway section](../gateway-api-migration/#using-a-user-managed-gateway) of the migration guide.

## Configure the Seed Helm Values

The IAP chart defaults its Gateway reference to `kubermatic`/`kubermatic` and a request timeout of `3600s`. Override these in the seed values file only if your Gateway uses a different name or namespace, or you want a different timeout:

```yaml
httpRoute:
  gatewayName: kubermatic
  gatewayNamespace: kubermatic
  timeout: 3600s
```

These values are not defaulted from the master `spec.ingress.gateway.externalGateway`; the seed Gateway is a separate object on a separate cluster.

The hostname of each HTTPRoute comes from the per-deployment `iap.deployments.<name>.ingress.host` value. Set one hostname per exposed IAP deployment, typically following the seed DNS pattern `<service>.<seed-name>.<spec.ingress.domain>`:

```yaml
iap:
  deployments:
    - name: grafana
      ingress:
        host: grafana.seed1.kkp.example.com
```

If you use the bundled Envoy Gateway chart, also point its traffic policies at the seed Gateway. The `ClientTrafficPolicy` (connection buffer limits for large LDAP/SAML headers) and `BackendTrafficPolicy` (request size limits) shipped with the chart target a specific Gateway and default to the policy's own namespace, which does not match a Gateway in the `kubermatic` namespace:

```yaml
clientTrafficPolicy:
  targetGateway:
    name: kubermatic
    namespace: kubermatic
backendTrafficPolicy:
  targetGateway:
    name: kubermatic
    namespace: kubermatic
```

Without these values, the buffer and request size limits do not apply to the seed Gateway.

## Create the Gateway

Create the Gateway referenced by `httpRoute.gatewayName`/`httpRoute.gatewayNamespace` on the seed cluster. The following example uses the bundled GatewayClass and an HTTP listener that accepts routes from labeled namespaces.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  gatewayClassName: kubermatic-envoy-gateway
  listeners:
    - name: http
      protocol: HTTP
      port: 80
      allowedRoutes:
        namespaces:
          from: Selector
          selector:
            matchLabels:
              kubermatic.io/gateway-access: "true"
```

Only the `monitoring` and `mla` namespaces carry seed-scoped HTTPRoutes (the IAP routes created by `deploy seed-mla` and `deploy usercluster-mla`). The installer labels both automatically, so the selector above works without further action. If you add HTTPRoutes in other namespaces, label those namespaces as well:

```bash
kubectl label namespace <namespace> kubermatic.io/gateway-access=true --overwrite
```

Alternatively, allow routes from all namespaces. This removes the labeling requirement at the cost of allowing any namespace to attach routes to the Gateway:

```yaml
      allowedRoutes:
        namespaces:
          from: All
```

## TLS

Two things differ from the master cluster:

- The seed stack does not include cert-manager.
- The HTTPRoute-to-Gateway listener sync (`HTTPRouteGatewaySync`) runs only on the master. On the seed, HTTPS listeners are not created from HTTPRoute hostnames automatically.

You are therefore responsible for the HTTPS listeners and the TLS secrets.

### Static TLS Secret

The simplest setup is an existing certificate covering the seed hostnames, for example a wildcard certificate for `*.<seed-name>.<spec.ingress.domain>` issued outside the cluster. Create the secret in the Gateway namespace, then add one HTTPS listener per hostname. The secret must live in the same namespace as the Gateway; certificateRefs cannot reference secrets in other namespaces (unless a ReferenceGrant allows it).

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: kubermatic-tls
  namespace: kubermatic
type: kubernetes.io/tls
stringData:
  tls.crt: ...
  tls.key: ...
```

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  gatewayClassName: kubermatic-envoy-gateway
  listeners:
    - name: http
      protocol: HTTP
      port: 80
      allowedRoutes:
        namespaces:
          from: Selector
          selector:
            matchLabels:
              kubermatic.io/gateway-access: "true"
    - name: https-grafana
      protocol: HTTPS
      port: 443
      hostname: grafana.seed1.kkp.example.com
      allowedRoutes:
        namespaces:
          from: Selector
          selector:
            matchLabels:
              kubermatic.io/gateway-access: "true"
      tls:
        mode: Terminate
        certificateRefs:
          - name: kubermatic-tls
    - name: https-alertmanager
      protocol: HTTPS
      port: 443
      hostname: alertmanager.seed1.kkp.example.com
      allowedRoutes:
        namespaces:
          from: Selector
          selector:
            matchLabels:
              kubermatic.io/gateway-access: "true"
      tls:
        mode: Terminate
        certificateRefs:
          - name: kubermatic-tls
```

Add one listener per IAP hostname you expose. Each listener, including the HTTPS ones, needs its own `allowedRoutes` policy: without it, routes are restricted to the Gateway's namespace and the IAP routes from `monitoring` and `mla` are rejected. Because the listener sync does not run on the seed, listeners do not update automatically when you add or rename IAP deployments in the `seed-mla` or `usercluster-mla` values; adjust the Gateway manually whenever the hostnames change.

### Certificates via cert-manager

If you prefer issuance inside the seed cluster, install cert-manager there yourself and create a `Certificate` for each hostname. The Certificate must live in the Gateway's namespace, because the resulting secret is referenced by the Gateway listeners:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: grafana-seed1
  namespace: kubermatic
spec:
  secretName: grafana-seed1-tls
  dnsNames:
    - grafana.seed1.kkp.example.com
  issuerRef:
    name: letsencrypt-production
    kind: ClusterIssuer
```

Reference the resulting secret in the listener's `certificateRefs`. Wildcard hostnames require a DNS01 challenge solver; HTTP01 cannot issue wildcard certificates, see the note in the [migration guide](../gateway-api-migration/#automatic-certificate-provisioning).

## DNS

Point the seed hostnames at the seed Gateway address. Read the address from the Gateway status or the Envoy data plane service:

```bash
kubectl --context seed -n kubermatic get gateway kubermatic -o jsonpath='{.status.addresses}'
kubectl --context seed -n envoy-gateway-controller get svc
```

Create the records for the seed domain, for example `*.seed1.kkp.example.com` pointing at the address above.

Note that the installer's DNS hint for separate seeds points the wildcard `*.<seed-name>.<spec.ingress.domain>` at the nodeport-proxy LoadBalancer, which serves the user cluster API endpoints. A single wildcard record cannot point at both the nodeport proxy and the seed Gateway. Either create specific records for each IAP hostname pointing at the Gateway address, or place the IAP hostnames under a different subdomain than the user cluster API endpoints.

## Verification

Check that the Gateway exists and is programmed:

```bash
kubectl --context seed get gateway -A
kubectl --context seed -n kubermatic get gateway kubermatic -o jsonpath='{.status.conditions[?(@.type=="Programmed")].status}'
```

Check that the IAP HTTPRoutes are attached and accepted:

```bash
kubectl --context seed get httproute -A
```

Each route must show the Gateway in `status.parents` with `Accepted=True`. Finally test one of the exposed endpoints:

```bash
curl -I https://grafana.seed1.kkp.example.com/
```

## Troubleshooting

- HTTPRoutes exist but `status.parents` is empty: the referenced Gateway does not exist (or `gatewayName`/`gatewayNamespace` in the seed values do not match it). This is the expected symptom when the Gateway has not been created yet.
- Routes are accepted on the `http` listener but HTTPS fails: the per-hostname HTTPS listeners are missing. Add them as described under [TLS](#tls).
- HTTPS listeners show `ResolvedRefs=False`: the referenced TLS secret does not exist or is in a different namespace than the Gateway.
- Routes are not accepted at all: check the listener `allowedRoutes` policy and the namespace labels.

## Outlook

Automating seed Gateway creation and extending the listener sync to the seed-controller-manager are tracked in [kubermatic/kubermatic#16302](https://github.com/kubermatic/kubermatic/issues/16302). Until then, the administrator-managed workflow described on this page is the supported path for separate seed clusters.
