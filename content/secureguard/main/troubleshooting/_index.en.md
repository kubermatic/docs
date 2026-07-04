+++
title = "Troubleshooting & FAQ"
date = 2026-06-13T09:00:00+02:00
weight = 11
description = "Common operational issues and resolutions for SecureGuard — dashboard access, authentication, OpenBao sealing, ESO sync errors, proxy 403s, and multi-cluster connectivity."
sitemapexclude = true
searchexclude = true
private = true
+++

Managing a distributed secret synchronization engine involves dealing with network connectivity, authentication tokens, and vault states. This guide covers common operational issues and how to resolve them.

## General Issues

### The Dashboard is Inaccessible or Returns 502 Bad Gateway
- **Cause**: The Backend Proxy is not running or cannot reach the upstream Dex/OpenBao instances, OR the ingress path is misconfigured.
- **Resolution**:
  1. Check the proxy logs: `kubectl logs -l app.kubernetes.io/name=secureguard-proxy -n secureguard-system`
  2. Verify Dex is running and reachable by the proxy.
  3. Ensure your Ingress controller is correctly routing traffic to the `secureguard-ui` service.

### Cannot Log In (Authentication Failed)
- **Cause**: Usually a misconfiguration in the OIDC issuer URL or client secrets.
- **Resolution**:
  1. Check Dex logs: `kubectl logs -l app.kubernetes.io/name=dex -n secureguard-system`
  2. Ensure the `redirect_uri` configured in your IDP (GitHub, Google, etc.) exactly matches the Dex callback URL.
  3. Verify that clock drift hasn't caused token validation failures (ensure NTP is synced across nodes).

### Proxy Pod Crash-Loops on Startup (`OIDC_ISSUER_URL is required`)
- **Cause**: Authentication is mandatory — the proxy refuses to start without an OIDC issuer. There is no "auth disabled" mode (the old `AUTH_ENABLED` flag was removed).
- **Resolution**: Set `OIDC_ISSUER_URL` (and the other `OIDC_*` / `SESSION_SECRET` env) on the proxy. With the bundled Dex, this is the in-cluster issuer, e.g. `http://<release>-dex.<namespace>.svc.cluster.local:5556/dex`.

### Logged In, but Everything Shows `403 Forbidden`
- **Cause**: Access is enforced per user — the proxy impersonates the logged-in user, so the request is evaluated against *your* Kubernetes RBAC, not the proxy's. A user with no RBAC bindings can authenticate but is denied every resource.
- **Resolution**:
  1. Bind a Role/ClusterRole to your user's email or an OIDC group — see [User Authorization]({{< ref "../advanced-configuration/#user-authorization-rbac-via-impersonation" >}}) for examples.
  2. Confirm the binding mirrors what the proxy does:
     ```bash
     kubectl auth can-i list externalsecrets.external-secrets.io \
       --namespace <ns> --as <your-email> --as-group <your-group>
     ```
  3. Ensure Dex emits a `groups` claim if you bind to groups (group-based RBAC won't work otherwise).
  4. Verify the proxy's own service account holds the `impersonate` verb on `users`/`groups` (included in `k8s/rbac.yaml` and the Helm chart); without it, impersonation itself returns `403`.

## OpenBao Issues

### OpenBao Pods are Running but Not Ready
- **Cause**: By default in production, OpenBao starts in a sealed state and cannot read or write data until unsealed.
- **Resolution**:
  1. Check the vault status:
     ```bash
     kubectl exec -it secureguard-openbao-0 -n secureguard-system -- bao status
     ```
  2. Look for `Sealed: true`.
  3. If you do not have Auto-Unseal configured, you must manually provide the unseal keys generated during initialization:
     ```bash
     kubectl exec -it secureguard-openbao-0 -n secureguard-system -- bao operator unseal <key_1>
     kubectl exec -it secureguard-openbao-0 -n secureguard-system -- bao operator unseal <key_2>
     kubectl exec -it secureguard-openbao-0 -n secureguard-system -- bao operator unseal <key_3>
     ```
  4. Once the threshold is met, the pod will become ready. It is strongly recommended to configure [Auto-Unseal]({{< ref "../installation/#automatic-unsealing" >}}) for production.

## ESO Synchronization Issues

When an `ExternalSecret` fails to sync, ESO will update the `status` block of the Custom Resource with detailed condition messages. You can view these directly in the SecureGuard UI or via `kubectl`.

### Error: `SecretStoreNotFound`
- **Cause**: The `ExternalSecret` references a `SecretStore` or `ClusterSecretStore` that does not exist or is in the wrong namespace.
- **Resolution**: Verify the spelling of the `secretStoreRef.name` and the `secretStoreRef.kind` in your `ExternalSecret` manifest.

### Error: `SecretStoreNotReady`
- **Cause**: ESO cannot authenticate against the OpenBao backend defined in the `SecretStore`.
- **Resolution**:
  1. This usually indicates an authentication failure (e.g., the Kubernetes Service Account token used by ESO is rejected by OpenBao).
  2. Check the OpenBao auth logs. Ensure the `kubernetes` auth method is enabled on OpenBao and that the role bound to the ESO service account exists and has the correct policies attached.
  3. Verify TLS certificates. If OpenBao uses a self-signed cert, the `SecretStore` must contain the `caBundle`.

### Error: `SecretSyncedError`
- **Cause**: ESO authenticated successfully, but could not retrieve the specific secret value.
- **Resolution**:
   1. The secret path defined in `data[].remoteRef.key` does not exist in OpenBao.
   2. The OpenBao policy attached to the authentication role does not grant `read` access to that specific path.
   3. Verify the path manually using the OpenBao CLI or UI using the same credentials.

## Proxy Issues

### Error: 403 Forbidden from the Proxy
- **Cause**: The requested Kubernetes API path is not in the proxy's route allowlist.
- **Resolution**:
  1. The proxy only forwards explicitly listed K8s API paths. Check the allowlist in `proxy/internal/proxy/routes.go`.
  2. If you've added a new CRD and need API access, add the corresponding path patterns to `routes.go`.
  3. Common mistake: forgetting to add both list and individual resource paths (e.g., both `/apis/group/version/resources` and `/apis/group/version/namespaces/{ns}/resources/{name}`).

### Proxy Cannot Connect to Kubernetes API
- **Cause**: Invalid or expired kubeconfig, or the cluster is unreachable.
- **Resolution**:
  1. Check proxy logs: `kubectl logs -l app.kubernetes.io/name=secureguard-proxy -n secureguard-system`
  2. Verify the `KUBECONFIG` environment variable points to a valid kubeconfig file.
  3. For in-cluster deployments, ensure the ServiceAccount has the correct RBAC permissions (see `k8s/rbac.yaml`).

## Multi-Cluster Issues

### Cluster Shows as "Unhealthy" in the Dashboard
- **Cause**: The proxy cannot reach the target cluster's API server.
- **Resolution**:
  1. Verify network connectivity between the management cluster and the target cluster.
  2. Check that the kubeconfig context for the target cluster has valid, non-expired credentials.
  3. Use the health endpoint directly: `curl http://localhost:3001/api/clusters/{id}/health`

### Uploaded Kubeconfig Not Showing Clusters
- **Cause**: The kubeconfig upload succeeded but clusters aren't appearing.
- **Resolution**:
  1. Verify the upload response included the expected context names.
  2. Check proxy logs for errors during per-cluster Secret creation.
  3. Confirm the per-cluster Secret exists and carries the discovery label: `kubectl get secrets -n secureguard-system -l secureguard.io/cluster-kubeconfig=true`. In-cluster, the proxy watches these Secrets via an informer, so new registrations appear without a pod restart.

## Debugging Tips

- **Event Stream**: Use the Event Stream page in the dashboard to see real-time Kubernetes events across all managed resources.
- **Proxy Debug Logging**: Set the `LOG_LEVEL=debug` environment variable on the proxy for verbose output (structured JSON logs) — see [Proxy Configuration]({{< ref "../advanced-configuration/#environment-variables" >}}). The agent and federation broker have equivalent `logLevel` Helm values. Check pod logs with `kubectl logs`.
- **Sync Error Drawer**: Click on any failed ExternalSecret in the dashboard to open the Sync Error Drawer, which shows detailed error messages and remediation hints.
