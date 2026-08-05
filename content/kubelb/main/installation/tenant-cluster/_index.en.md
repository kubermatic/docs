+++
title = "Install KubeLB CCM and set up the tenant cluster"
linkTitle = "Set Up Tenant Cluster"
date = 2023-10-27T10:07:15+02:00
weight = 20
+++

## Prerequisites

* Access to the Kubernetes API of the KubeLB management cluster.
* A tenant registered in the KubeLB management cluster.

See [Requirements]({{< relref "../requirements" >}}) for the full port and resource sizing reference.

* Create a `kubelb` namespace for KubeLB CCM.
* KubeLB CCM expects a Secret named `kubelb-cluster` by default. Its `kubelb` data key must contain the kubeconfig for the management cluster.
  * First register the tenant by following the [tenant registration]({{< relref "../../tutorials/tenants">}}) guide.
  * Fetch the generated kubeconfig from the management cluster, switch to the tenant cluster, and create the Secret:

  ```sh
  # Replace with the tenant cluster kubeconfig path
  TENANT_KUBECONFIG=~/.kube/<tenant-cluster>
  # Replace with the tenant name
  TENANT_NAME=tenant-shroud
  KUBELB_KUBECONFIG_B64=$(kubectl get secret kubelb-ccm-kubeconfig --namespace "$TENANT_NAME" --template='{{ .data.kubelb }}')
  # Switch to the tenant cluster.
  export KUBECONFIG="$TENANT_KUBECONFIG"
  kubectl --namespace kubelb create secret generic kubelb-cluster \
    --from-literal=kubelb="$(printf '%s' "$KUBELB_KUBECONFIG_B64" | base64 -d)"
  ```

* Override the Secret name with `.Values.kubelb.clusterSecretName` if required. Otherwise, the Secret is named `kubelb-cluster` and looks like this:

  ```sh
  kubectl get secret kubelb-cluster --namespace kubelb -o yaml
  ```

  ```yaml
  apiVersion: v1
  data:
    kubelb: xxx-base64-encoded-xxx
  kind: Secret
  metadata:
    name: kubelb-cluster
    namespace: kubelb
  type: Opaque
  ```

* Set `tenantName` in `values.yaml` to the tenant's unique identifier. The management cluster stores tenant namespaces with a `tenant-` prefix; for example, `my-tenant` becomes `tenant-my-tenant`. KubeLB accepts the name with or without this prefix.

At this point a minimal `values.yaml` should look like this:

```yaml
kubelb:
  clusterSecretName: kubelb-cluster
  tenantName: <unique-identifier-for-tenant>
```

{{% notice info %}}

**Private clusters:** If the tenant nodes do not have external IP addresses, set `kubelb.nodeAddressType` to `InternalIP`.

```bash
kubectl get nodes -o wide
```

```
NAME     STATUS   ROLES           AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE          KERNEL-VERSION       CONTAINER-RUNTIME
node-x   Ready    control-plane   208d   v1.29.9   10.66.99.222   <none>        Ubuntu            5.15.0-121-generic   containerd://1.6.33
```

Adjust `values.yaml`:

```yaml
kubelb:
  # -- Address type to use for routing traffic to node ports. Values are ExternalIP, InternalIP, or Hostname.
  nodeAddressType: InternalIP
```

{{% /notice %}}

## Install KubeLB CCM

{{% notice warning %}} To enable Gateway API support, set both fields below in `values.yaml`. KubeLB CCM cannot start with Gateway API enabled unless the CRDs are installed.

```yaml
kubelb:
  enableGatewayAPI: true
  installGatewayAPICRDs: true
```

{{% /notice %}}

{{< tabs name="KubeLB CCM" >}}
{{% tab name="Enterprise Edition" %}}

### Prerequisites

* Create a namespace **kubelb** for the CCM to be deployed in.
* Create **imagePullSecrets** for the chart to pull the image from the registry in kubelb namespace.

At this point a minimal values.yaml should look like this:

```yaml
imagePullSecrets:
  - name: <imagePullSecretName>
kubelb:
    clusterSecretName: kubelb-cluster
    tenantName: <unique-identifier-for-tenant>
```

### Install the Helm chart

```sh
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-ccm-ee --version=v1.4.3 --untardir "." --untar
## Apply CRDs
kubectl apply -f kubelb-ccm-ee/crds/
## Create and update values.yaml with the required values.
helm upgrade --install kubelb-ccm kubelb-ccm-ee --namespace kubelb -f kubelb-ccm-ee/values.yaml --create-namespace
```

### Review KubeLB CCM EE values

<!-- helm-values-kubelb-ccm-ee start -->
The chart publishes the complete, version-matched configuration reference. Inspect it directly instead of relying on a copied values table:

```sh
helm show values oci://quay.io/kubermatic/helm-charts/kubelb-ccm-ee --version=v1.4.3
helm show readme oci://quay.io/kubermatic/helm-charts/kubelb-ccm-ee --version=v1.4.3
```
<!-- helm-values-kubelb-ccm-ee end -->

{{% /tab %}}
{{% tab name="Community Edition" %}}

### Install the Helm chart

```sh
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-ccm --version=v1.4.3 --untardir "." --untar
## Apply CRDs
kubectl apply -f kubelb-ccm/crds/
## Create and update values.yaml with the required values.
helm upgrade --install kubelb-ccm kubelb-ccm --namespace kubelb -f kubelb-ccm/values.yaml --create-namespace
```

### Review KubeLB CCM CE values

<!-- helm-values-kubelb-ccm start -->
The chart publishes the complete, version-matched configuration reference. Inspect it directly instead of relying on a copied values table:

```sh
helm show values oci://quay.io/kubermatic/helm-charts/kubelb-ccm --version=v1.4.3
helm show readme oci://quay.io/kubermatic/helm-charts/kubelb-ccm --version=v1.4.3
```

You can also browse the [v1.4.3 Community Edition chart reference](https://github.com/kubermatic/kubelb/blob/v1.4.3/charts/kubelb-ccm/README.md#values).
<!-- helm-values-kubelb-ccm end -->

{{% /tab %}}
{{< /tabs >}}

## Verify the installation

Check that the CCM is running:

```bash
kubectl get pods -n kubelb
```

```text
NAME                          READY   STATUS    RESTARTS   AGE
kubelb-ccm-7c9f7d6b8d-4qk2n   2/2     Running   0          1m
```

The `kubelb-ccm` pod must be in `Running` state before load balancer services are reconciled.

## Set up the tenant cluster

### Install Gateway API CRDs

Starting from KubeLB v1.2.0, the Gateway API CRDs can be installed using the `installGatewayAPICRDs` flag.

{{< tabs name="Gateway APIs" >}}
{{% tab name="Enterprise Edition" %}}

```yaml
imagePullSecrets:
  - name: <imagePullSecretName>
kubelb:
    clusterSecretName: kubelb-cluster
    tenantName: <unique-identifier-for-tenant>
    # This will install the experimental channel of the Gateway API CRDs
    installGatewayAPICRDs: true
    enableGatewayAPI: true
```

For more details: [Experimental Install](https://gateway-api.sigs.k8s.io/guides/#install-experimental-channel)
{{% /tab %}}
{{% tab name="Community Edition" %}}

```yaml
kubelb:
    clusterSecretName: kubelb-cluster
    tenantName: <unique-identifier-for-tenant>
    # This will install the standard channel of the Gateway API CRDs
    installGatewayAPICRDs: true
    enableGatewayAPI: true
```

For more details: [Standard Install](https://gateway-api.sigs.k8s.io/guides/#install-standard-channel)

{{% /tab %}}
{{< /tabs >}}
