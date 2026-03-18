+++
title = "Quickstart"
weight = 1
+++

This quickstart provides the steps to install the Kubermatic Developer Platform (KDP) on an existing Kubernetes cluster.
You'll use Helm to deploy KDP and its core components, including Dex for user authentication and kcp as central control plane.
You will also set up automated TLS certificate management with cert-manager and Let's Encrypt.
By the end, you will have a fully functional KDP installation, accessible through the KDP dashboard as well as directly with kubectl.

## Prerequisites

{{% notice note %}}
At the moment, you need to be invited to get access to Kubermatic's Docker repository before you can install the Kubermatic Developer Platform.
Please [contact sales](mailto:sales@kubermatic.com) to receive your credentials.
{{% /notice %}}

To follow this guide, you need:

- an existing Kubernetes cluster with at least 3 nodes
- a running CSI driver with a default storage class
- a running [cert-manager][cert-manager/docs/installation] installation
- a running ingress controller or Gateway API implementation (this guide uses the [NGINX ingress controller][ingress-nginx/docs/installation], but a [Gateway API][gateway-api/docs] controller like [Envoy Gateway][envoy-gateway/docs] or [Contour][contour/docs] is also supported)
- [kubectl][k8s/docs/tools/installation] and [Helm][helm/docs/installation] (version 3) installed locally

## Installation

The installation is divided into six main steps, each deploying a core component of KDP.
You will perform the following tasks:

- **Set up certificates**: First, you will configure a cert-manager issuer to automatically obtain and renew TLS certificates from Let's Encrypt.

- **Deploy an identity provider**: Next, you will deploy Dex to handle user authentication, creating a central login service for both the KDP dashboard and command-line access.

- **Deploy kcp**: You will deploy kcp, the core engine that enables multi-tenancy by providing isolated, secure workspaces for your users. This includes bundling the client CA certificates so that the kcp front-proxy trusts client certificates issued by the KDP controller manager.

- **Deploy KDP**: Afterwards, you will install the main KDP controllers that connect to kcp and manage the platform's resources.

- **Launch the KDP dashboard**: You will deploy the KDP dashboard, the primary graphical interface for developers to interact with the platform and manage their service objects.

- **Deploy the KDP AI Agent**: Finally, you will deploy the AI Agent, which provides AI-powered features within the dashboard — generating Kubernetes resource specs and customizing resource creation forms from natural language prompts.

Throughout this guide, you will need to replace several placeholder variables in the Helm values files.
Below is a description of each value you need to provide.

- `<EMAIL_ADDRESS>`: Your email address, used by Let's Encrypt to send notifications about your TLS certificate status.
- `<PULL_CREDENTIALS>`: A base64-encoded password or token for the quay.io container registry. This is required for you to get access to the KDP Helm charts and container images.
- `<DOMAIN>`: The primary public domain name you will use to access your KDP installation (e.g., kdp.my-company.com). You must own this domain and be able to configure its DNS records.
- `<ADMIN_PASSWORD_HASH>`: A generated bcrypt hash of the password you choose for the initial admin user.
- `<OIDC_CLIENT_SECRET>`: A randomly generated, secure string that acts as a password for the KDP dashboard to authenticate with the Dex identity provider.
- `<SESSION_ENCRYPTION_KEY>`: A second, unique random string used by the KDP dashboard itself to encrypt user session cookies, adding another layer of security.
- `<OPENAI_API_KEY>`: An API key from OpenAI, required by the KDP AI Agent for its AI-powered features (spec generation and UI schema generation).

### Create ClusterIssuer

First, you need to create a _ClusterIssuer_ named `letsencrypt-prod` for cert-manager.
This automates the process of obtaining and renewing TLS certificates from Let's Encrypt, ensuring all web-facing components like the Dex login page and the KDP dashboard are served securely over HTTPS.

Save the following content to a file named `cluster-issuer.yaml`, and change the value of the `email` field to your email address:

```yaml
{{< readfile "developer-platform/setup/quickstart/data/letsencrypt.cluster-issuer.yaml" >}}
```

Create the _ClusterIssuer_ by applying the manifest:

```bash
kubectl apply -f ./cluster-issuer.yaml
```

{{% notice tip %}}
**Gateway API alternative:** If you use a Gateway API controller (e.g. [Envoy Gateway][envoy-gateway/docs] or [Contour][contour/docs]) instead of NGINX Ingress, you need to make three changes:

**1. Enable Gateway API support in cert-manager.** When installing cert-manager, set `enableGatewayAPI: true` in its controller configuration so it can manage TLS certificates for Gateway listeners:

```yaml
# cert-manager Helm values
config:
  enableGatewayAPI: true
```

**2. Replace the `http01` solver with a `gatewayHTTPRoute` solver** in the ClusterIssuer, pointing to your Gateway:

```yaml
solvers:
  - http01:
      gatewayHTTPRoute:
        parentRefs:
          - name: shared-gateway
            namespace: <GATEWAY_NAMESPACE>
        serviceType: ClusterIP
```

**3. Deploy Dex and the Dashboard without their built-in Ingress resources** and create `HTTPRoute` resources instead.
Since neither the Dex nor the KDP Dashboard Helm chart natively creates `HTTPRoute` resources, you must disable their Ingress and provide the routing yourself.

Disable Ingress in the Dex values:

```yaml
# dex.values.yaml
ingress:
  enabled: false
```

Disable Ingress in the KDP Dashboard values:

```yaml
# kdp-dashboard.values.yaml
dashboard:
  ingress:
    create: false
```

Then create a `Gateway` with HTTPS listeners for each hostname, annotated so cert-manager provisions the TLS certificates automatically.
Save the following content to a file named `gateway.yaml`:

```yaml
{{< readfile "developer-platform/setup/quickstart/data/gateway.yaml" >}}
```

Replace `<GATEWAY_NAMESPACE>`, `<GATEWAY_CLASS>`, and `<DOMAIN>` with your values, then apply:

```bash
kubectl apply -f ./gateway.yaml
```

Finally, create `HTTPRoute` resources to route traffic to Dex and the Dashboard.
Save the following content to a file named `http-routes.yaml`:

```yaml
{{< readfile "developer-platform/setup/quickstart/data/http-routes.yaml" >}}
```

Replace `<GATEWAY_NAMESPACE>` and `<DOMAIN>`, then apply:

```bash
kubectl apply -f ./http-routes.yaml
```

Note that the kcp API (`internal.<DOMAIN>`) is **not** routed through the Gateway — it uses its own dedicated `LoadBalancer` service and does not need an HTTPRoute.

The public API endpoint (`api.<DOMAIN>`) is handled separately: the KDP chart creates an NGINX Ingress for it by default. If you are fully replacing NGINX Ingress with a Gateway API controller, you should disable the KDP chart's built-in Ingress (set `kdp.frontProxy.publicDomain` to empty) and create an additional Gateway HTTPS listener and HTTPRoute for `api.<DOMAIN>` pointing to `kcp-front-proxy:8443`, along with a `BackendTLSPolicy` for the TLS backend connection.

For the DNS records step, point `login.<DOMAIN>`, `api.<DOMAIN>`, and `dashboard.<DOMAIN>` to the Gateway's load balancer IP instead of the NGINX ingress controller.

{{% /notice %}}

### Deploy Dex

Now, you'll deploy Dex as the platform's central identity provider.
It handles all user logins and authentication.
The provided configuration creates an initial admin user and prepares Dex for the integration with the KDP dashboard and [kubelogin][kubelogin/src/readme] for a seamless user authentication.

Save the following content to a file named `dex.values.yaml`:

```yaml
{{< readfile "developer-platform/setup/quickstart/data/dex.values.yaml" >}}
```

Before deploying Dex, you need to replace the following placeholder variables in the `dex.values.yaml` file with your own values:

- `<DOMAIN>`
- `<ADMIN_PASSWORD_HASH>`
- `<OIDC_CLIENT_SECRET>`

For the initial admin user, you must provide your own password as bcrypt hash in `<ADMIN_PASSWORD_HASH>`.
To create this hash, you can use the `htpasswd` utility, which is part of the Apache web server tools and available on most Linux distributions (you may need to install a package like "apache2-utils" or "httpd-tools").

Choose a strong password and run the following command in your terminal, replacing YOUR_PASSWORD with the password you've selected:

```bash
echo 'YOUR_PASSWORD' | htpasswd -inBC 10 admin | cut -d: -f2
```

Copy the entire output string (it will start with `$2a$` or `$2y$`) and paste it as the value for `<ADMIN_PASSWORD_HASH>` in your `dex.values.yaml` file.
Remember to save the plain-text password you chose in a secure location, as you will need it to log in to the KDP dashboard.

The `<OIDC_CLIENT_SECRET>` placeholder must be replaced with a long, random string that the KDP dashboard and kubelogin use to securely communicate with Dex.
You can generate a secure, random string with the following command:

```bash
cat /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c32
```

This will output a random string that you can copy and paste as the value for `<OIDC_CLIENT_SECRET>`.
Save the value for later use when you deploy the KDP dashboard.

Once you've replaced all placeholders, deploy the Dex Helm chart:

```bash
helm upgrade --install dex dex \
    --repo=https://charts.dexidp.io \
    --version=0.23.0 \
    --create-namespace \
    --namespace=kdp-system \
    --values=dex.values.yaml
```

### Deploy kcp

Next, you'll install kcp.
It acts as the central control plane for KDP that provides and manages the isolated workspaces for each user or team, ensuring resources are kept separate and secure.
It's configured to use Dex for authenticating user requests.

Save the following content to a file named `kcp.values.yaml`:

```yaml
{{< readfile "developer-platform/setup/quickstart/data/kcp.values.yaml" >}}
```

Before deploying kcp, you need to replace the following placeholder variables in the `kcp.values.yaml` file with your own values:

- `<DOMAIN>`

After you've replaced all the placeholders, deploy the kcp Helm chart:

```bash
helm upgrade --install kcp kcp \
    --repo=https://kcp-dev.github.io/helm-charts \
    --version=0.14.0 \
    --create-namespace \
    --namespace=kdp-system \
    --values=kcp.values.yaml
```

#### Bundle the front-proxy client CAs

The KDP controller manager authenticates to kcp using client certificates signed by the `kcp-client-ca` Certificate Authority.
By default, the kcp front-proxy only trusts its own `kcp-front-proxy-client-ca`.
You need to create a combined CA bundle so that the front-proxy trusts certificates from both CAs.

Both CA cert-manager `Certificate` resources (`kcp-front-proxy-client-ca` and `kcp-client-ca`) and their corresponding Secrets are created by the kcp Helm chart you just installed.
Wait for the Certificates to become Ready, then read their Secrets and combine the CA data into a single Secret:

```bash
kubectl --namespace=kdp-system wait --timeout=120s --for=condition=Ready \
    certificates kcp-front-proxy-client-ca kcp-client-ca

FP_CLIENT_CA=$(kubectl --namespace=kdp-system \
  get secret kcp-front-proxy-client-ca -o jsonpath='{.data.tls\.crt}' | base64 -d)
KCP_CLIENT_CA=$(kubectl --namespace=kdp-system \
  get secret kcp-client-ca -o jsonpath='{.data.tls\.crt}' | base64 -d)

COMBINED_CA=$(printf '%s\n%s' "$FP_CLIENT_CA" "$KCP_CLIENT_CA")
kubectl --namespace=kdp-system \
  create secret generic kcp-front-proxy-combined-client-ca \
  --from-literal=tls.crt="$COMBINED_CA" \
  --dry-run=client -o yaml | kubectl apply -f -
```

Now update the `kcpFrontProxy` section in your `kcp.values.yaml` to mount the combined CA and override the client CA file.
Add `extraVolumes`, `extraVolumeMounts`, and the `--client-ca-file` flag to your existing `extraFlags`:

```yaml
# Add these keys to the existing kcpFrontProxy section in kcp.values.yaml
kcpFrontProxy:
  extraVolumes:
    - name: combined-client-ca
      secret:
        secretName: kcp-front-proxy-combined-client-ca
  extraVolumeMounts:
    - name: combined-client-ca
      mountPath: /etc/kcp-front-proxy/combined-client-ca
  extraFlags:
    # ... keep your existing extraFlags and add:
    - '--client-ca-file=/etc/kcp-front-proxy/combined-client-ca/tls.crt'
```

Upgrade kcp with the updated values:

```bash
helm upgrade --install kcp kcp \
    --repo=https://kcp-dev.github.io/helm-charts \
    --version=0.14.0 \
    --namespace=kdp-system \
    --values=kcp.values.yaml
```

Wait for the front-proxy pods to become ready before proceeding:

```bash
kubectl --namespace=kdp-system wait --timeout=120s --for=condition=Ready \
    --selector=app.kubernetes.io/component=front-proxy,app.kubernetes.io/name=kcp pods
```

{{% notice note %}}
If the CA certificates are ever rotated (e.g., after a kcp reinstall), you need to re-create the combined CA Secret and restart the front-proxy pods.
{{% /notice %}}

### Deploy KDP

Next, you'll deploy the main KDP application.
It connects to the kcp control plane and includes a one-time bootstrap job that grants the admin user full administrative rights, allowing them to manage the entire platform.

Save the following content to a file named `kdp.values.yaml`:

```yaml
{{< readfile "developer-platform/setup/quickstart/data/kdp.values.yaml" >}}
```

Before deploying KDP, you need to replace the following placeholder variables in the `kdp.values.yaml` file with your own values:

- `<PULL_CREDENTIALS>`
- `<DOMAIN>`

With all placeholders replaced, deploy the KDP Helm chart.
Use your email address as the username and the license key you received as the password to log into the Helm registry.

```bash
helm registry login quay.io
helm upgrade --install kdp \
    oci://quay.io/kubermatic/helm-charts/developer-platform \
    --version=0.9.0 \
    --create-namespace \
    --namespace=kdp-system \
    --values=kdp.values.yaml
```

### Deploy KDP dashboard

Last but not least, you'll deploy the KDP's web-based dashboard, which serves as the primary user interface.
It's configured to use Dex for user login and connects to kcp, providing developers with a graphical interface to create and manage their service objects.

Save the following content to a file named `kdp-dashboard.values.yaml`:

```yaml
{{< readfile "developer-platform/setup/quickstart/data/kdp-dashboard.values.yaml" >}}
```

Before deploying the KDP dashboard, you need to replace the following placeholder variables in the `kdp-dashboard.values.yaml` file with your own values:

- `<PULL_CREDENTIALS>`
- `<DOMAIN>`
- `<OIDC_CLIENT_SECRET>`
- `<SESSION_ENCRYPTION_KEY>`

The `<OIDC_CLIENT_SECRET>` placeholder **must** be replaced with the value generated in step "Deploy Dex" and configured in the `dex.values.yaml` file.

The `<SESSION_ENCRYPTION_KEY>` placeholder must - similar to the OIDC client secret - be replaced with a long, random string that the KDP dashboard uses to protect user sessions.
You can use the same command, to generate a secure, random string:

```bash
cat /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c32
```

Copy and paste the output as the value for `<SESSION_ENCRYPTION_KEY>`.

Now that all placeholders are replaced, deploy the KDP dashboard Helm chart.
To log into the Helm registry, again use your email address as the username and the license key you received as the password.

```bash
helm registry login quay.io
helm upgrade --install kdp-dashboard \
    oci://quay.io/kubermatic/helm-charts/developer-platform-dashboard \
    --version=0.9.0 \
    --create-namespace \
    --namespace=kdp-system \
    --values=kdp-dashboard.values.yaml
```

### Deploy KDP AI Agent

The KDP AI Agent is a backend service that powers AI-driven features in the KDP dashboard.
It uses OpenAI to provide two capabilities: **spec generation**, which converts natural language prompts into properly structured Kubernetes resource YAML, and **UI schema generation**, which produces custom [RJSF](https://rjsf-team.github.io/react-jsonschema-form/) UI schemas that tailor the dashboard's resource creation forms based on a prompt.

Before proceeding, ensure you have an OpenAI API key.

Save the following content to a file named `ai-agent.values.yaml`:

```yaml
{{< readfile "developer-platform/setup/quickstart/data/ai-agent.values.yaml" >}}
```

Replace the following placeholder variables:

- `<PULL_CREDENTIALS>`
- `<DOMAIN>`
- `<OIDC_CLIENT_SECRET>` (same value as in the Dex and Dashboard configuration)
- `<OPENAI_API_KEY>`

Deploy the AI Agent Helm chart:

```bash
helm registry login quay.io
helm upgrade --install kdp-ai-agent \
    oci://quay.io/kubermatic/helm-charts/developer-platform-ai-agent \
    --version=0.9.0 \
    --create-namespace \
    --namespace=kdp-system \
    --values=ai-agent.values.yaml
```

The AI Agent is served under the same domain as the dashboard (`dashboard.<DOMAIN>/ai-agent/`) to avoid CORS issues.
The NGINX Ingress uses a regex path and rewrite rule to forward requests to the AI Agent service.

{{% notice tip %}}
**Gateway API alternative:** If you use a Gateway API controller, disable the AI Agent's built-in Ingress and create an `HTTPRoute` with a URL rewrite instead:

```yaml
# ai-agent.values.yaml
aiAgent:
  ingress:
    create: false
```

Then add the following `HTTPRoute` alongside your existing Dex and Dashboard routes.
Save the following content to a file named `ai-agent.http-route.yaml`:

```yaml
{{< readfile "developer-platform/setup/quickstart/data/ai-agent.http-route.yaml" >}}
```

Replace `<GATEWAY_NAMESPACE>` and `<DOMAIN>`, then apply:

```bash
kubectl apply -f ./ai-agent.http-route.yaml
```

This rewrites `/ai-agent/...` to `/...` before forwarding to the AI Agent service, matching the behavior of the NGINX rewrite rule.
{{% /notice %}}

For more details, see the [AI Agent documentation]({{< relref "../ai-agent" >}}).

### Configure DNS records

In order to finalize the installation and make your KDP instance accessible, you must create four DNS records in your DNS provider.
Each record points one of the hostnames you configured to the correct load balancer in your Kubernetes cluster.

The following table summarizes the records:

| Hostname             | Points to                       | Purpose                                                           |
| -------------------- | ------------------------------- | ----------------------------------------------------------------- |
| `login.<DOMAIN>`     | Ingress controller / Gateway LB | Dex identity provider login page                                  |
| `api.<DOMAIN>`       | Ingress controller / Gateway LB | Public API endpoint (reverse proxy to kcp, used by the dashboard) |
| `dashboard.<DOMAIN>` | Ingress controller / Gateway LB | KDP dashboard web interface                                       |
| `internal.<DOMAIN>`  | kcp `LoadBalancer` service      | Direct kcp API access (used by kubectl and the api-syncagent)     |

The first three records should all point to the same ingress controller or Gateway load balancer.
If you use the **NGINX ingress controller**, retrieve its external IP or DNS name (assuming it's installed into the `ingress-nginx` namespace):

```bash
kubectl --namespace=ingress-nginx get service ingress-nginx-controller
NAME                       TYPE           CLUSTER-IP      EXTERNAL-IP                                                    PORT(S)                      AGE
ingress-nginx-controller   LoadBalancer   10.47.248.232   4cdd93dfab834ed9a78858c7f2633380.eu-west-1.elb.amazonaws.com   80:30807/TCP,443:30184/TCP   449d
```

If you use a **Gateway API** controller instead, point `login.<DOMAIN>` and `dashboard.<DOMAIN>` to the external IP of your Gateway's load balancer service (e.g. `kubectl get service -n <gateway-namespace> <envoy-service>`).
Note that `api.<DOMAIN>` is created as an NGINX Ingress by the KDP chart.
If you are fully replacing NGINX Ingress with a Gateway API controller, you will need to disable the KDP chart's built-in Ingress (set `kdp.frontProxy.publicDomain` to empty) and create an additional Gateway listener and HTTPRoute for `api.<DOMAIN>` pointing to `kcp-front-proxy:8443`.

The fourth record, `internal.<DOMAIN>`, points to kcp's dedicated `LoadBalancer` service (not the ingress controller).
Use the following command to retrieve the external IP address or DNS name of kcp's load balancer:

```bash
kubectl --namespace=kdp-system get service kcp-front-proxy
NAME              TYPE           CLUSTER-IP      EXTERNAL-IP                                                    PORT(S)             AGE
kcp-front-proxy   LoadBalancer   10.240.20.65    99f1093e45d6482d95a0c22c4a2bd056.eu-west-1.elb.amazonaws.com   8443:30295/TCP      381d
```

### Verify the installation

Before accessing the dashboard, verify that all components are running:

```bash
kubectl --namespace=kdp-system get pods
```

You should see pods for `dex`, `kcp`, `kdp-controller-manager`, `kdp-virtual-workspaces`, `kdp-dashboard`, and `kdp-ai-agent` in a **Running** state.
The `kdp-bootstrap` job should show as **Completed**.
If any pod is stuck in `CrashLoopBackOff` or `Pending`, inspect its logs with `kubectl --namespace=kdp-system logs <pod-name>` for troubleshooting.

### Access the dashboard

Congratulations, your KDP installation is now complete! Once your DNS records have propagated, you can access the dashboard by navigating your web browser to the URL you configured (`https://dashboard.<DOMAIN>`).

You will be redirected to the Dex login page and you can use the administrative credentials that were created during the setup:

- **Username**: `admin`
- **Password**: The password you chose in step [Deploy Dex](#deploy-dex)

After logging in, you will be taken to the KDP dashboard, where you can begin exploring your platform. Welcome to KDP!

## Next steps

Now that your platform is running, here are a few things to try:

- **Use kubectl with kcp**: Download a kubeconfig from the dashboard (available in the workspace context menu) or set one up manually using the [kcp kubectl plugin](https://docs.kcp.io/kcp/v0.30/concepts/kubectl-kcp-plugin/). See [kcp on the Command Line]({{< relref "../../tutorials/kcp-command-line" >}}) for a walkthrough.
- **Create your first service**: Follow the [Your First Service]({{< relref "../../tutorials/your-first-service" >}}) tutorial to register a KDP Service and make custom APIs available to your users.
- **Add users and configure RBAC**: Invite team members via the dashboard and set up roles. See [RBAC in KDP]({{< relref "../../platform-users/rbac" >}}) for details on the role propagation model.
- **Set up the api-syncagent**: If you have external Kubernetes clusters with CRDs you want to expose in KDP, install the [api-syncagent]({{< relref "../../service-providers/api-syncagent" >}}) and define `PublishedResource` objects to start syncing.
- **Monitor KDP**: The KDP exporter exposes Prometheus metrics on port 8385 and supports `ServiceMonitor` for Prometheus Operator. Enable it via `kdp.exporter.serviceMonitor.enabled: true` in the KDP Helm values.

[cert-manager/docs/installation]: https://cert-manager.io/docs/installation/helm/
[helm/docs/installation]: https://helm.sh/docs/intro/install/
[ingress-nginx/docs/installation]: https://kubernetes.github.io/ingress-nginx/deploy/
[gateway-api/docs]: https://gateway-api.sigs.k8s.io/
[contour/docs]: https://projectcontour.io/docs/
[envoy-gateway/docs]: https://gateway.envoyproxy.io/
[k8s/docs/tools/installation]: https://kubernetes.io/docs/tasks/tools/#kubectl
[kcp/chart/readme]: https://github.com/kcp-dev/helm-charts/tree/main/charts/kcp
[kubelogin/src/readme]: https://github.com/int128/kubelogin
