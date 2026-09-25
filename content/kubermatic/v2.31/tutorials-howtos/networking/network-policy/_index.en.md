+++
title = "Network Policy"
date = 2025-10-13T12:00:00+03:00
weight = 120
+++

## Network Policy

This document outlines the use of the standard Kubernetes `NetworkPolicy` resource as a primary security control at the IP address or port level (OSI layer 3 or 4) within the cluster.


By default, Kubernetes networking is flat and fully permissive. This means any pod can, by default, initiate network connections to any other pod within the same cluster. This "default-allow" posture presents a significant security challenge. Network Policies are Kubernetes' built-in firewall rules that control which pods can talk to each other. 
They provide a declaration-based virtual firewall at the pod level.

Kubermatic Kubernetes Platform (KKP) already supports NetworkPolic resources to ensure network isolation in the clusters. The enforcement of these policies is handled by the underlying CNI plugin, such as Cilium or Canal, which are supported by default in KKP.

## Example: Deploy AI Workloads in KKP User Cluster 

{{% notice warning %}}
This example is for demonstration purposes only. Not suitable for production use.
{{% /notice %}}

We'll demonstrate this concept by securing a LocalAI deployment (an OpenAI-compatible API) so that only authorized services can access it

LocalAI can be deployed through the KKP UI from the Applications tab. When deploying, it creates pods with specific labels that we'll use for network isolation. For this example, we'll assume LocalAI is deployed with default settings in the `local-ai` namespace.


Similarly, deploy the Nginx Ingress Controller from the KKP's default Application Catalog. This will handle external traffic and route it to your AI services.

{{% notice note %}}
LocalAI and Nginx Applications can be deployed via the KKP UI by navigating to your cluster's Applications tab and selecting LocalAI from the catalog. For detailed deployment instructions, refer to the [LocalAI Application documentation]({{< ref "../../../architecture/concept/kkp-concepts/applications/default-applications-catalog/local-ai/" >}}) and [Nginx Application documentation]({{< ref "../../../architecture/concept/kkp-concepts/applications/default-applications-catalog/nginx/" >}}) .
{{% /notice %}}


Before proceeding, ensure that `kubectl` is properly configured and points to your user cluster, not the seed cluster.
```bash
# Check the current context
kubectl config current-context
# or, set the context explicitly
export KUBECONFIG=$HOME/.kube/<user_cluster_kubeconfig>
```

### Expose Your AI Service

First, let's make LocalAI accessible through the Nginx Ingress Controller by creating an Ingress resource:

```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: localai-ingress
  namespace: local-ai
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: localai.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: local-ai-local-ai
            port:
              number: 8080
EOF
```

This tells Nginx to route requests for `localai.local` to your LocalAI service on port 8080

Let's also retrieve the external endpoint from the Nginx LoadBalancer service:

```bash
# Get the LoadBalancer endpoint (IP or hostname)
# This command first tries to get the IP, if not available, gets the hostname
# Some cloud providers (e.g., AWS) provide hostname, others provide IP

NAMESPACE="nginx"
NGINX_SVC_NAME="nginx-nginx-ingress-nginx-controller"
export INGRESS_ENDPOINT=$(kubectl get svc -n $NAMESPACE $NGINX_SVC_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [ -z "$INGRESS_ENDPOINT" ]; then
  export INGRESS_ENDPOINT=$(kubectl get svc -n $NAMESPACE $NGINX_SVC_NAME -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
fi
echo "==> Ingress endpoint: $INGRESS_ENDPOINT"
```

Before applying any Network Policies, let's see how accessible LocalAI is. Currently, any pod in the cluster can reach it.

- External access through nginx:
```bash
$ curl -H "Host: localai.local" http://$INGRESS_ENDPOINT/v1/models
{"object":"list","data":[]}%
```

- In-cluster access across namespaces:
```bash
$ kubectl run test-connectivity -n nginx --image=gcr.io/kubernetes-e2e-test-images/dnsutils:1.3 \
    --rm -i --restart=Never -- wget -T 5 -q -O - http://local-ai-local-ai.local-ai.svc.cluster.local:8080/v1/models
{"object":"list","data":[]}
```

- In-cluster access in the service's `local-ai` namespace:
```bash
$ kubectl run test-connectivity -n local-ai --image=gcr.io/kubernetes-e2e-test-images/dnsutils:1.3 \
    --rm -i --restart=Never -- wget -T 5 -q -O - http://local-ai-local-ai.local-ai.svc.cluster.local:8080/v1/models
{"object":"list","data":[]}
```
All three tests succeed because Kubernetes allows all connections by default.

### Secure AI Workload Access

Let's secure the LocalAI service using Network Policies. We'll implement a zero-trust model where the AI service is completely isolated except for legitimate traffic from the Nginx ingress controller.

First, create a default-deny policy to block all incoming traffic to LocalAI:

```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: localai-default-deny
  namespace: local-ai
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: local-ai
  policyTypes:
  - Ingress
EOF
```

This policy:
- Targets pods with the label `app.kubernetes.io/name: local-ai`
- Blocks all incoming traffic by specifying no ingress rules
- Ensures your AI models are isolated by default

### Allow Traffic from Nginx Ingress

Now, explicitly allow traffic from the Nginx ingress controller to LocalAI:

```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: localai-allow-nginx
  namespace: local-ai
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: local-ai
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: nginx
      podSelector:
        matchLabels:
          app.kubernetes.io/name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8080  # LocalAI default port
EOF
```

This policy:
- Allows traffic only from Nginx ingress pods
- Restricts access to the specific port LocalAI uses
- Maintains isolation from all other cluster workloads

### Verify Network Isolation
To verify your Network Policies are working as expected, let's test the access again:

1. External access:
The external access should continue working as expected as long as the request comes from the Nginx pods configured in the NetworkPolicy:
```bash
$ curl -H "Host: localai.local" http://$INGRESS_ENDPOINT/v1/models
{"object":"list","data":[]}
```

2. From Nginx pod itself:
The external access should continue working as expected as long as the request comes from the Nginx pods configured in the NetworkPolicy:
```bash
NGINX_POD=$(kubectl get pods -n nginx -l app.kubernetes.io/name=ingress-nginx -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n nginx $NGINX_POD -- \
    wget -T 5 -q -O - http://local-ai-local-ai.local-ai.svc.cluster.local:8080/v1/models
{"object":"list","data":[]}
```

2. From another pod:
Besides from the external traffic through nginx pod, no other pods can access to Local AI regardless of the namespace, due to Deny-All policy applied.

```bash
# Test connectivity from a temporary pod using Kubernetes' official test image
# This should timeout after 5 seconds, confirming the Network Policy is blocking access
kubectl run test-connectivity -n local-ai --image=gcr.io/kubernetes-e2e-test-images/dnsutils:1.3 --rm -i --restart=Never -- \
    wget -T 5 -q -O - http://local-ai-local-ai.local-ai.svc.cluster.local:8080/v1/models
```

```bash
kubectl run test-connectivity -n nginx --image=gcr.io/kubernetes-e2e-test-images/dnsutils:1.3 \
    --rm -i --restart=Never -- wget -T 5 -q -O - http://local-ai-local-ai.local-ai.svc.cluster.local:8080/v1/models
```

## CNI-Specific Features

While standard NetworkPolicies provide robust security, KKP's supported CNIs offer additional capabilities:

- **Cilium**: Provides CiliumNetworkPolicy for Layer 7 filtering, allowing you to control API-level access to AI endpoints
- **Canal** (Calico): Offers GlobalNetworkPolicy for cluster-wide rules and application layer policies

These advanced features are automatically available when you select the respective CNI during cluster creation in KKP.

## Further Reading

For more advanced Network Policy configurations and patterns:

- [Kubernetes Network Policies Documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [KKP CNI Configuration Guide]({{< relref "../cni-cluster-network/" >}})
- [KKP Applications Documentation]({{< ref "../../../tutorials-howtos/applications/" >}})

For CNI-specific advanced features:
- [Cilium Network Policies](https://docs.cilium.io/en/stable/security/policy/)
- [Calico Network Policies](https://docs.tigera.io/calico/latest/network-policy/)

## Conclusion

Network Policies transform Kubernetes' open networking into a secure, controlled environment. By implementing zero-trust networking, you ensure only authorized services can access your workloads.

For AI workloads and other sensitive services, this approach provides strong security and network isolations for critical workloads. Combined with KKP's Application Catalog and supported CNIs, you can quickly deploy and secure workloads.
