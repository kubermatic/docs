+++
title = "Security Hardening Guide"
date = 2026-06-13T09:00:00+02:00
weight = 9
description = "Production security best practices for SecureGuard — TLS, OIDC/Dex hardening, RBAC via impersonation, network policies, container security, CSP, and supply-chain controls."
sitemapexclude = true
searchexclude = true
private = true
+++

This guide covers security best practices for deploying SecureGuard in production environments. SecureGuard manages Kubernetes Secrets and external secret provider credentials — a security lapse can expose API keys, database passwords, TLS certificates, and cloud provider credentials.

## Core Security Model

SecureGuard operates on a **zero-knowledge** principle for secret values:

- The **Backend Proxy** redacts all secret values (`.data` and `.stringData`) before responses reach the browser
- The **frontend never receives** actual secret content — only metadata (names, namespaces, keys, sync status)
- All secret value fields display `••••••••` unconditionally — there is no "reveal" mechanism
- All mutating API calls go through the proxy — the browser never contacts the Kubernetes API server directly

## TLS Configuration

### Ingress TLS

Always terminate TLS at the ingress layer. Use cert-manager for automatic certificate provisioning:

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  hosts:
    - host: secureguard.yourdomain.com
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: secureguard-tls
      hosts:
        - secureguard.yourdomain.com
```

### Internal TLS

For environments requiring end-to-end encryption:
- Configure OpenBao with TLS certificates for API communication
- Use the `caBundle` field in `SecretStore` resources when OpenBao uses a private CA
- Ensure Dex is served over HTTPS with valid certificates

## OIDC / Dex Hardening

### Static Admin User

The default Helm deployment provisions a built-in static Dex admin user (`dex.staticAdmin.enabled: true`). By default its email is `admin@secureguard.local` and its **password is randomly auto-generated** (16 characters) and stored in the `<release>-dex-admin` Secret — there is no hardcoded password in the Helm path. Retrieve it with:

```bash
kubectl get secret <release>-dex-admin -n <namespace> -o jsonpath='{.data.password}' | base64 -d
```

{{% notice warning %}}
**Local development and CI only:** the raw dev manifest [`k8s/dex.yaml`](https://github.com/kubermatic/secureguard/blob/main/k8s/dex.yaml) hardcodes static passwords for `admin@secureguard.local` and `viewer@secureguard.local` (bcrypt hash of `admin`). These credentials exist **solely for kind-based local development and CI** (`scripts/deploy-dev-dashboard.sh`) and are **never** used by the Helm chart. Do not deploy `k8s/dex.yaml` to any shared or production cluster.
{{% /notice %}}

For any non-local deployment, either set a strong `dex.staticAdmin.password` explicitly, or disable the static admin entirely (`dex.staticAdmin.enabled: false`) and federate to a production IDP (see below).

### Configure a Production IDP

Federate authentication to your organization's identity provider:

```yaml
dex:
  config:
    connectors:
    - type: oidc
      id: corporate-sso
      name: "Corporate SSO"
      config:
        issuer: https://sso.yourcompany.com
        clientID: secureguard
        clientSecret: $DEX_CLIENT_SECRET
        redirectURI: https://dex.secureguard.yourdomain.com/callback
```

### Session Security

The proxy uses HTTP-only, SameSite=Lax session cookies with 8-hour expiry. For enhanced security:

- Set a strong `SESSION_SECRET` (minimum 32 bytes of cryptographically random data)
- Do not enable "remember me" functionality — this is a secrets dashboard
- Ensure cookies are marked `Secure` (requires HTTPS)

## RBAC Configuration

### Authorization is per-user (impersonation)

SecureGuard does **not** grant its own service account broad access to your secrets. On every Kubernetes API request the proxy impersonates the logged-in user (`Impersonate-User` = email claim, `Impersonate-Group` = groups claim), so **access is decided by the RBAC you bind to your users and OIDC groups**. The proxy's own permissions are limited to impersonation plus a few internal bookkeeping operations.

{{% notice note %}}
A user with no RBAC bindings can log in but gets `403 Forbidden` on every resource. Grant access explicitly — see [Advanced Configuration → User Authorization]({{< ref "../advanced-configuration/#user-authorization-rbac-via-impersonation" >}}) for group- and email-based binding examples and `kubectl auth can-i --as` verification.
{{% /notice %}}

### Least-privilege service accounts

The proxy and the SG Agent run under **separate** service accounts (see [`k8s/rbac.yaml`](https://github.com/kubermatic/secureguard/blob/main/k8s/rbac.yaml) / [`charts/secureguard/templates/rbac.yaml`](https://github.com/kubermatic/secureguard/blob/main/charts/secureguard/templates/rbac.yaml)):

```yaml
# Proxy: only impersonation + SGAgent registration (per-cluster kubeconfig
# Secret access is a namespaced Role, not shown here).
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: secureguard-proxy
rules:
  - apiGroups: [""]
    resources: ["users", "groups"]
    verbs: ["impersonate"]
  - apiGroups: ["agent.secureguard.io"]
    resources: ["sgagents"]
    verbs: ["create"]
```

The `secureguard-agent` account holds the controller/deployer permissions (SGAgent + ESODeployment reconcile, and the Deployments/ServiceAccounts/Namespaces/ClusterRoles/RoleBindings the deployer creates when installing ESO). It does **not** have impersonation rights, and the proxy does **not** have the agent's deploy rights.

{{% notice note %}}
**Note on impersonation rights:** `impersonate` on `users`/`groups` is a powerful grant — anyone able to use the proxy SA token can act as any user. Protect the proxy pod/SA token accordingly (no token mounting for other workloads, restricted node access), and prefer constraining impersonation to specific users/groups via a `resourceNames` allowlist if your user set is bounded.
{{% /notice %}}

### Namespace-Scoped Access

For multi-tenant environments, consider using namespaced Roles instead of ClusterRoles to restrict which namespaces the dashboard can access.

## Network Policies

Restrict pod-to-pod communication to only necessary paths:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: secureguard-proxy
spec:
  podSelector:
    matchLabels:
      app: secureguard-proxy
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: secureguard-ui
      ports:
        - port: 3001
  egress:
    # Allow access to Kubernetes API server
    - to: []
      ports:
        - port: 443
        - port: 6443
    # Allow access to Dex
    - to:
        - podSelector:
            matchLabels:
              app: dex
      ports:
        - port: 5556
```

The Helm chart includes a NetworkPolicy template that can be enabled via `networkPolicy.enabled: true` in your values file.

## Container Security

### Non-Root Execution

All SecureGuard containers run as non-root:
- **Dashboard (nginx)**: Runs as the nginx user
- **Proxy**: Uses `gcr.io/distroless/static-debian12:nonroot` (UID 65534)
- **Agent**: Uses `gcr.io/distroless/static-debian12:nonroot` (UID 65534)

### Read-Only Filesystem

Configure containers with read-only root filesystems where possible:

```yaml
securityContext:
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
```

### Resource Limits

Always set resource requests and limits to prevent resource exhaustion:

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi
```

### Image Pinning

Pin all base image versions in Dockerfiles. The project uses:
- `node:22-alpine` (not `:latest`)
- `golang:1.25-alpine` (not `:latest`)
- `gcr.io/distroless/static-debian12:nonroot` (specific tag)

## Content Security Policy

Configure CSP headers to prevent XSS and data exfiltration. When using nginx for the frontend:

```nginx
add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; connect-src 'self'; img-src 'self' data:; frame-ancestors 'none';" always;
```

## Supply Chain Security

### Dependency Auditing

- Run `npm audit` regularly and address critical/high findings before merge
- Run `go vet ./...` on both the proxy and agent modules
- The CI pipeline runs Trivy vulnerability scans on all Docker images

### Image Scanning

The CI/CD pipeline scans all three Docker images (dashboard, proxy, agent) with Trivy for CRITICAL and HIGH CVEs before any release. Images are only pushed to the registry if the scan passes.

## Operational Security

### Secret Rotation

- Rotate the `SESSION_SECRET` periodically (this will invalidate all active sessions)
- Rotate OIDC client secrets in coordination with your IDP
- If using per-cluster kubeconfig Secrets, rotate credentials when team members leave

### Audit Logging

- OpenBao provides comprehensive audit logging of all secret access
- Enable Kubernetes audit logging to track API server access
- Monitor proxy logs for unusual access patterns or repeated 403 errors

### Backup and Recovery

- **Always** take an OpenBao Raft snapshot before upgrades (see [Upgrade Guides]({{< ref "../upgrade-guides/" >}}))
- Store snapshots in encrypted, access-controlled cold storage
- Test restore procedures regularly
