+++
linkTitle = "Gateway API Migration"
title = "Gateway API Migration Guide"
date = 2026-01-15T16:30:00+01:00
weight = 155
+++

# Gateway API Migration Guide

## Overview

Kubermatic Kubernetes Platform is transitioning from the nginx-ingress-controller to the Gateway API with Envoy Gateway. This document explains what this means for your deployment, why we are making this change, and how to migrate when you are ready.

This migration affects how traffic reaches the Kubermatic dashboard and API. The external behavior remains the same, but the underlying implementation changes to use modern Kubernetes standards.

## What is Changing

The current implementation uses `nginx-ingress-controller`, which has been the standard way to expose HTTP services in Kubernetes for several years.
However, the Kubernetes project has announced the retirement of the community-maintained Ingress NGINX controller, with end of maintenance scheduled for March 2026.

When you migrate, instead of creating Ingress resources, Kubermatic will create Gateway and HTTPRoute resources.
These are part of the official Gateway API specification from the Kubernetes community.
Envoy Gateway serves as the implementation that processes these resources and actually handles the traffic.

From your perspective as a user, nothing changes in how you access Kubermatic.
The same domain names continue to work and traffic flows to the same services. The difference is entirely in the cluster infrastructure.

## What Actually Changes in Your Cluster

BEFORE migration:
- `nginx-ingress-controller` Helm release installed
- Kubermatic Ingress resource
- Traffic flows: `nginx-ingress-controller` → Kubermatic services

AFTER migration (before uninstalling nginx):
- `envoy-gateway-controller` Helm release installed
- `nginx-ingress-controller` Helm release STILL INSTALLED
- Kubermatic Gateway and HTTPRoute resources
- Traffic flows: `envoy-gateway-controller` → Kubermatic services

AFTER migration (after uninstalling nginx):
- `envoy-gateway-controller` Helm release installed
- Kubermatic Gateway and HTTPRoute resources
- Traffic flows: `envoy-gateway-controller` → Kubermatic services

The `nginx-ingress-controller` pods remain running after migration but have no effect because the Ingress resource is deleted.
Kubermatic is not going to delete Ingress LoadBalancer service from the cluster, instead it will only delete Ingress resources during migration.

## How the Migration Works

The migration is designed to be explicit and safe. There is no automatic switching that could surprise you during an upgrade.
Instead, you make a conscious decision to migrate by setting a flag during deployment.

### The Migration Flag

The migration is controlled by two parameters: a Helm value called `migrateGatewayAPI` and the `--migrate-gateway-api` flag in kubermatic-installer.

By default, a Helm Chart configuration `migrateGatewayAPI` is set to `false` in KKP v2.30, meaning your cluster continues using `nginx-ingress-controller` as it always has.
When you are ready to migrate, you set this to true and redeploy Kubermatic via kubermatic-installer, by providing `--migrate-gateway-api` flag.

> Note that if `kubermatic-installer` is not being used for Kubermatic installation and upgrade,
> you need to manually provide `-enable-gateway-api` flag to `kubermatic-operator`.

### What Happens During Migration

When you enable the migration, the following sequence occurs:

1. `kubermatic-installer` deploys the Envoy Gateway controller and its Custom Resource Definitions using Helm.

2. `kubermatic-operator` is deployed with the `-enable-gateway-api` startup flag, which allows `kubermatic-operator` to manage Gateway and HTTPRoute resources instead of Ingress resources.

3. `kubermatic-operator` creates Gateway and HTTPRoute resources. Envoy Proxy begins handling traffic.

4. `kubermatic-installer` verifies that the Gateway is fully operational:
   - Gateway has valid addresses assigned
   - Gateway is in Programmed status
   - All listeners are programmed
   - HTTPRoutes are attached to listeners
   This verification ensures the new Gateway is ready to serve traffic before proceeding.

5. Once the Gateway is ready, the `kubermatic-installer` removes Ingress resources to prevent conflicts between the old Ingress and the new Gateway resources:
   - Deletes the Kubermatic Ingress resource (`kubermatic/kubermatic`)
   - Deletes the Dex Ingress resource (`dex/dex`) if it exists

IMPORTANT: The installer does NOT uninstall the `nginx-ingress-controller` Helm release.
After migration, both `nginx-ingress-controller` and `envoy-gateway-controller` will be running in your cluster.
You must manually uninstall nginx-ingress-controller when you are ready. Only Ingress resources (`kubermatic/kubermatic` and `dex/dex`) are deleted.

### The Operator Behavior

The kubermatic-operator runs in one of two modes depending on the startup flag.
If the flag (`-enable-gateway-api`) is not set, it creates and manages Ingress resources. If the flag is set, it creates and manages Gateway and HTTPRoute resources instead.

Importantly, the operator does not clean up resources from the other mode.
This is a safety feature.
If the operator automatically deleted Gateway resources when running in Ingress mode, or vice versa, it could break cluster access unexpectedly.
Instead, we handle cleanup explicitly during the migration process.

Also, when kubermatic-operator starts with the Gateway API flag enabled, it checks that the Gateway API Custom Resource Definitions exist in the cluster.
If they do not exist, the operator refuses to start and provides a clear error message. This fail-fast behavior prevents the operator from starting in a broken state where it cannot function properly.

## What You Need to Know

### Two Controllers Will Run Temporarily

When you migrate with `--migrate-gateway-api`, the `kubermatic-installer` deploys Envoy Gateway but does NOT remove `nginx-ingress-controller`. Both controllers will run in your cluster simultaneously.

This is intentional. The installer removes the Kubermatic and Dex Ingress resources to prevent routing conflicts. The `nginx-ingress-controller` pods continue running, but they have no Ingress resources to process (except possibly non-KKP Ingress resources you may have).

After you verify the migration is successful, you should manually uninstall `nginx-ingress-controller` to free up cluster resources:

```bash
helm uninstall nginx-ingress-controller -n nginx-ingress-controller
```

### Cleanup of Old Resources


The `kubermatic-installer` handles cleanup during the migration process.

> Please note that `kubermatic-operator` does not automatically delete resources from the other mode at runtime.
The deletion of old resources are being handled by `kubermatic-installer` at deployment time.
If the installar is not used to manage Kubermatic operations, old resources need to be deleted manually.

By default, the installer performs the following cleanup steps:

1. **Verifies Gateway readiness**: When migrating to Gateway API, the installer waits up to 5 minutes for the Gateway to become fully operational before removing old resources. This verification includes:
   - Gateway has valid addresses assigned
   - Gateway is in Programmed status (confirming Envoy has successfully configured it)
   - All Gateway listeners are programmed and ready
   - At least one HTTPRoute is attached to each listener

2. **Deletes Ingress resources**: When migrating to Gateway API, the installer deletes the following Ingress resources:
   - Kubermatic Ingress (`kubermatic/kubermatic`)
   - Dex Ingress (`dex/dex`)

This cleanup prevents routing conflicts between old and new resources.

You can control this behavior with the `--skip-ingress-cleanup` flag.
When set, the installer will not try to delete old resources, allowing you to manually verify the migration before cleanup.

**Important**: If you use `--skip-ingress-cleanup`, both Kubermatic and Dex Ingress resources will remain. You must manually delete them afterward:

```bash
kubectl delete ingress -n kubermatic kubermatic
kubectl delete ingress -n dex dex
```

## Migration Steps

To migrate from nginx-ingress-controller to Gateway API:

**Step 1: Update your Helm values file**
```yaml
migrateGatewayAPI: true
dex:
  ingress:
    enabled: true
```

**Step 2: Run the kubermatic-installer with the migration flag**
```bash
kubermatic-installer deploy master --migrate-gateway-api [other options]
```

_Conditional step_, by default, `kubermatic-installer` automatically deletes the old Ingress resource after migration to prevent conflicts.
If you want to skip this automatic cleanup (for example, to manually verify before cleanup), use the `--skip-ingress-cleanup` flag:

```bash
kubermatic-installer deploy master --migrate-gateway-api --skip-ingress-cleanup [other options]
```

When cleanup is skipped, both Ingress and Gateway resources will coexist. You can manually delete the Ingress resources to prevent routing conflicts:

```bash
# beforehand, please verify the migration at Step 3
kubectl delete ingress -n kubermatic kubermatic
kubectl delete ingress -n dex dex
```

**Step 3: Verify the migration**

```bash
kubectl get gateway -n kubermatic -o yaml
kubectl get httproute -n kubermatic -o yaml
```

The Gateway resource should show the following status indicators:

- **Programmed**: `true` in status.conditions (Gateway is fully configured by Envoy)
- **Listeners**: Each listener shows `Programmed: true` in its conditions
- **Attached Routes**: Each listener reports at least one attached route

The HTTPRoute should display:

- **Accepted**: `true` in status.parents[].conditions (route is accepted by the Gateway)
- **Parent Reference**: Correctly references the Gateway name and namespace

These confirm that the Gateway is operational and actively routing traffic through the defined HTTPRoutes.

**Step 4: Test access to the Kubermatic dashboard and API**
Verify that everything works as before.

**Step 5: Uninstall `nginx-ingress-controller` (optional but recommended)**
```bash
helm uninstall nginx-ingress-controller -n nginx-ingress-controller
```

Please note that both `nginx-ingress-controller` and `envoy-gateway-controller` are running - so, if `nginx-ingress-controller` is not being used, consider uninstalling it.

The Gateway API mode can be configured through the KubermaticConfiguration resource.
Under the `ingress` section, there is a `gateway` subsection where you can specify the GatewayClass to use.
The default value is `kubermatic-envoy-gateway`, which corresponds to the GatewayClass installed by the Envoy Gateway chart.

Most installations will not need to change this setting. However, if you have a custom GatewayClass or want to use a different implementation of Gateway API, you can specify it here.

## Traffic Policy Configuration

The Envoy Gateway Helm chart includes several traffic policy resources that control how traffic is handled. These policies replace the nginx annotation-based configuration.

The `ClientTrafficPolicy` controls connection buffer limits. This is set to 256 kilobytes by default, which matches the previous nginx configuration and ensures large headers from LDAP or SAML authentication work properly.

The `BackendTrafficPolicy` controls request size limits. This is set to 100 megabytes by default. While nginx was configured with unlimited request size, Envoy Gateway requires a specific limit. The 100 megabyte value should be sufficient for most use cases.

If you need to adjust these values, you can modify them in the `envoy-gateway-controller` Helm chart values before installation.

## Scope of the Migration

The migration affects the following Ingress resources during migration:

- Kubermatic Ingress (`kubermatic/kubermatic`): Migrated to Gateway and HTTPRoute resources
- Dex Ingress (`dex/dex`): Deleted during migration to prevent conflicts

Other components that use Ingress resources are not affected at this time. This includes MLA monitoring components and IAP components. These will continue to use Ingress resources even after you enable Gateway API mode.

**Note**: Dex authentication is automatically migrated when you enable Gateway API mode. The Dex Helm chart creates an HTTPRoute resource instead of an Ingress resource when `migrateGatewayAPI: true` is set in the Helm values. This HTTPRoute references the Kubermatic Gateway, allowing Dex to remain accessible through the same domain.

Ensure your Dex deployment includes the following configuration:

- `migrateGatewayAPI: true` in Dex Helm values
- `ingress.enabled: false` (to avoid creating a conflicting Ingress)
- `httpRoute.gatewayName` and `httpRoute.gatewayNamespace` correctly reference the Kubermatic Gateway

## Rolling Back

To rollback to `nginx-ingress-controller`:

**Step 1: Update Helm values**
```yaml
# kubermatic-operator/values.yaml
migrateGatewayAPI: false

# for dex, also enable ingress
dex:
  ingress:
    enabled: true
```

**Step 2: Run installer without the migration flag**
```bash
kubermatic-installer deploy master [other options]
```

This will deploy `nginx-ingress-controller` (if it was uninstalled) and the operator will recreate the Ingress resource.

Note: Uninstall `envoy-gateway-controller` if you no longer need it:
```bash
helm uninstall envoy-gateway-controller -n envoy-gateway-controller
```

## Troubleshooting

If you encounter issues after migration, the first place to check is the Gateway resource itself. Use `kubectl get gateway -n kubermatic` to see the status.
A healthy Gateway should show as programmed and accepted.
If it shows as not accepted or has error conditions, check the Envoy Gateway logs for more details.

The HTTPRoute resource should also be checked to ensure it is properly attached to the Gateway.
Use `kubectl get httproute -n kubermatic` to verify its status.

If the Gateway shows as not ready, verify that the GatewayClass resource exists and that the Envoy Gateway controller pods are running.
The GatewayClass should be named `kubermatic-envoy-gateway` and should exist in the `envoy-gateway-controller` namespace.

If the migration times out or the Gateway appears stuck, verify each of the four readiness conditions individually:

1. **Check Gateway addresses**:

```bash
kubectl get gateway -n kubermatic -o jsonpath='{.status.addresses}'
```
Should return at least one IP address or hostname. If empty, your LoadBalancer may not have been provisioned yet (check with your cloud provider).

2. **Check Programmed status**:
```bash
kubectl get gateway -n kubermatic -o jsonpath='{.status.conditions[?(@.type=="Programmed")].status}'
```
Should return `True`. If `False`, review the Envoy Gateway controller logs for configuration errors.

3. **Check listener status**:
```bash
kubectl get gateway -n kubermatic -o jsonpath='{.status.listeners[*].conditions[?(@.type=="Programmed")].status}'
```
All listeners should return `True`. Listeners may fail to program if there are port conflicts or TLS certificate issues.

4. **Check attached routes**:
```bash
kubectl get gateway -n kubermatic -o jsonpath='{.status.listeners[*].attachedRoutes}'
```
Each listener should show at least `1` attached route. If zero, verify that HTTPRoute resources exist and have correct parent references to the Gateway.

If you experience issues with large headers, such as those from LDAP or SAML authentication, verify that the ClientTrafficPolicy exists and has the correct buffer limit set.
This policy should be in the envoy-gateway-controller namespace and should have a buffer limit of 256 kilobytes.

For routes that are not working as expected, verify that the Kubermatic namespace has the required label. The namespace should be labeled with `kubermatic.io/gateway-access: true`.
This label allows HTTPRoutes in that namespace to attach to the Gateway.

You should also verify that the backend services exist and are healthy. The kubermatic-api and kubermatic-dashboard services should both be present in the Kubermatic namespace.

## Quick Verification Commands

After migration, you can use these commands to verify your installation. To check all Gateway API resources, run `kubectl get gateway,httproute,gatewayclass -n kubermatic`. This should show one Gateway, one HTTPRoute, and the GatewayClass.

To check the Envoy Gateway control plane, run `kubectl get pods -n envoy-gateway-controller`. This should show the Envoy Gateway controller pods running.

To check the Envoy data plane pods, run `kubectl get pods -n envoy-gateway-controller -l app.kubernetes.io/name=envoy`. These are the pods that actually handle the traffic.

To check the traffic policies, run `kubectl get clienttrafficpolicy,backendtrafficpolicy -n envoy-gateway-controller`. This should show the policies that control connection and request behavior.
