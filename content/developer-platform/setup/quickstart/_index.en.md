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

* an existing Kubernetes cluster with at least 3 nodes
* a running CSI driver with a default storage class
* a running [cert-manager][cert-manager/docs/installation] installation
* an running ingress controller (for this guide, the [NGINX ingress controller][ingress-nginx/docs/installation] is required)
* [kubectl][k8s/docs/tools/installation] and [Helm][helm/docs/installation] (version 3) installed locally

## Installation

The installation is divided into five main steps, each deploying a core component of KDP.
You will perform the following tasks:

* **Set up certificates**: First, you will configure a cert-manager issuer to automatically obtain and renew TLS certificates from Let's Encrypt.

* **Deploy an identity provider**: Next, you will deploy Dex to handle user authentication, creating a central login service for both the KDP dashboard and command-line access.

* **Deploy kcp**: You will deploy kcp, the core engine that enables multi-tenancy by providing isolated, secure workspaces for your users.

* **Deploy KDP**: Afterwards, you will install the main KDP controllers that connect to kcp and manage the platform's resources.

* **Launch the KDP dashboard**: Finally, you will deploy the KDP dashboard, the primary graphical interface for developers to interact with the platform and manage their service objects.

Throughout this guide, you will need to replace several placeholder variables in the Helm values files. 
Below is a description of each value you need to provide.

* `<EMAIL_ADDRESS>`: Your email address, used by Let's Encrypt to send notifications about your TLS certificate status.
* `<PULL_CREDENTIALS>`: A base64-encoded password or token for the quay.io container registry. This is required for you to get access to the KDP Helm charts and container images.
* `<DOMAIN>`: The primary public domain name you will use to access your KDP installation (e.g., kdp.my-company.com). You must own this domain and be able to configure its DNS records.
* `<OIDC_CLIENT_SECRET>`: A randomly generated, secure string that acts as a password for the KDP dashboard to authenticate with the Dex identity provider.
* `<SESSION_ENCRYPTION_KEY>`: A second, unique random string used by the KDP dashboard itself to encrypt user session cookies, adding another layer of security.

### Create ClusterIssuer

First, you need to create a _ClusterIssuer_ named `letsencrypt-prod` for cert-manager.
This automates the process of obtaining and renewing TLS certificates from Let's Encrypt, ensuring all web-facing components like the Dex login page and the KDP dashboard are served securely over HTTPS.

Save the following content to a file named `cluster-issuer.yaml`, and change the value of the `email` field to your email address:

```yaml
{{< readfile "developer-platform/setup/quickstart/data/letsencrypt.cluster-issuer.yaml" >}}
```

Create the _ClusterIssuer_ by applying the manifest:

```bash
$ kubectl apply -f ./cluster-issuer.yaml
```

### Deploy Dex

Now, you'll deploy Dex as the platform's central identity provider.
It handles all user logins and authentication.
The provided configuration creates an initial admin user and prepares Dex for the integration with the KDP dashboard and [kubelogin][kubelogin/src/readme] for a seamless user authentication.

Save the following content to a file named `dex.values.yaml`:

```yaml
{{< readfile "developer-platform/setup/quickstart/data/dex.values.yaml" >}}
```

Before deploying Dex, you need to replace the following placeholder variables in the `dex.values.yaml` file with your own values:

* `<DOMAIN>`
* `<OIDC_CLIENT_SECRET>`

The `<OIDC_CLIENT_SECRET>` placeholder must be replaced with a long, random string that the KDP dashboard and kubelogin use to securely communicate with Dex.
You can generate a secure, random string with the following command:

```bash
$ cat /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c32
```

This will output a random string that you can copy and paste as the value for `<OIDC_CLIENT_SECRET>`.
Save the value for later use when you deploy the KDP dashboard.

Once you've replaced all placeholders, deploy the Dex Helm chart:

```bash
$ helm upgrade --install dex dex \
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

* `<DOMAIN>`

After you've replaced all the placeholders, deploy the kcp Helm chart:

```bash
$ helm upgrade --install kcp kcp \
    --repo=https://kcp-dev.github.io/helm-charts \
    --version=0.11.1 \
    --create-namespace \
    --namespace=kdp-system \
    --values=kcp.values.yaml
```

### Deploy KDP

Finally, you'll deploy the main KDP application.
It connects to the kcp control plane and includes a one-time bootstrap job that grants the admin user full administrative rights, allowing them to manage the entire platform.

Save the following content to a file named `kdp.values.yaml`:

```yaml
{{< readfile "developer-platform/setup/quickstart/data/kdp.values.yaml" >}}
```

Before deploying KDP, you need to replace the following placeholder variables in the `kdp.values.yaml` file with your own values:

* `<PULL_CREDENTIALS>`
* `<DOMAIN>`

With all placeholders replaced, deploy the KDP Helm chart.
Use your email address as the username and the license key you received as the password to log into the Helm registry.

```bash
$ helm registry login quay.io
$ helm upgrade --install kdp \
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

* `<PULL_CREDENTIALS>`
* `<DOMAIN>`
* `<OIDC_CLIENT_SECRET>`
* `<SESSION_ENCRYPTION_KEY>`

The `<OIDC_CLIENT_SECRET>` placeholder **must** be replaced with the value generated in step "Deploy Dex" and configured in the `dex.values.yaml` file.

The `<SESSION_ENCRYPTION_KEY>` placeholder must - similar to the OIDC client secret - be replaced with a long, random string that the KDP dashboard uses to protect user sessions.
You can use the same command, to generate a secure, random string:

```bash
$ cat /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c32
```

Copy and paste the output as the value for `<SESSION_ENCRYPTION_KEY>`.

Now that all placeholders are replaced, deploy the KDP dashboard Helm chart.
To log into the Helm registry, again use your email address as the username and the license key you received as the password.

```bash
$ helm registry login quay.io
$ helm upgrade --install kdp-dashboard \
    oci://quay.io/kubermatic/helm-charts/developer-platform-dashboard \
    --version=0.9.0 \
    --create-namespace \
    --namespace=kdp-system \
    --values=kdp-dashboard.values.yaml
```

### Configure DNS records

In order to finalize the installation and make your KDP instance accessible, you must create four records in your DNS provider.
These records point the hostnames you configured earlier to the correct load balancers of your Kubernetes cluster.

First, create three DNS records that direct traffic for the Dex login page (`login.<DOMAIN>`), the public API endpoint (`api.<DOMAIN>`), and the KDP dashboard (`dashboard.<DOMAIN>`) to your cluster's NGINX ingress controller.

Assuming you installed the NGINX ingress controller into the `ingress-nginx` namespace, use the following command to the retrieve the external IP address or DNS name of the load balancer (in column "EXTERNAL-IP"):

```bash
$ kubectl --namespace=ingress-nginx get service ingress-nginx-controller
NAME                       TYPE           CLUSTER-IP      EXTERNAL-IP                                                    PORT(S)                      AGE
ingress-nginx-controller   LoadBalancer   10.47.248.232   4cdd93dfab834ed9a78858c7f2633380.eu-west-1.elb.amazonaws.com   80:30807/TCP,443:30184/TCP   449d
```
Second, create a DNS record specifically for kcp (`internal.<DOMAIN>`) that points to the external IP address or DNS name of the dedicated load balancer for the kcp _Service_.
Use the following command to the retrieve the external IP address or DNS name of kcp's load balancer:

```bash
$ kubectl --namespace=kdp-system get service kcp-front-proxy
NAME              TYPE           CLUSTER-IP      EXTERNAL-IP                                                    PORT(S)             AGE
kcp-front-proxy   LoadBalancer   10.240.20.65    99f1093e45d6482d95a0c22c4a2bd056.eu-west-1.elb.amazonaws.com   8443:30295/TCP      381d
```

### Access the dashboard

Congratulations, your KDP installation is now complete! Once your DNS records have propagated, you can access the dashboard by navigating your web browser to the URL you configured (`https://dashboard.<DOMAIN>`).

You will be redirected to the Dex login page and you can use the default administrative credentials that were created during the setup:

* **Username**: admin
* **Password**: password

After logging in, you will be taken to the KDP dashboard, where you can begin exploring your platform. Welcome to KDP!

[cert-manager/docs/installation]: https://cert-manager.io/docs/installation/helm/
[helm/docs/installation]: https://helm.sh/docs/intro/install/
[ingress-nginx/docs/installation]: https://kubernetes.github.io/ingress-nginx/deploy/
[k8s/docs/tools/installation]: https://kubernetes.io/docs/tasks/tools/#kubectl
[kcp/chart/readme]: https://github.com/kcp-dev/helm-charts/tree/main/charts/kcp
[kubelogin/src/readme]: https://github.com/int128/kubelogin
