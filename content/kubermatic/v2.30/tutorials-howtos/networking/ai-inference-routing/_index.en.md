+++
title = "AI Inference Routing with Gateway API Inference Extension in KKP Clusters"
date = 2025-10-31T15:23:00+01:00
weight = 110
+++

## Overview

This is a guide on how to deploy and configure Gateway API Inference Extension with `kgateway` v2.1.1 in a KKP User Cluster. It will use the Inference Extension which enables intelligent routing for AI inference workloads and provides model aware load balancing and request routing. 

## Inference Routing - general high-level overview of the architecture

Before getting started we can have a quick overview of the inference routing architecture from a high level. This is not KKP specific. The main components are:

- Gateway: This is an entry point with HTTPS listener and TLS 
- HTTPRoute: Resource that defines routing rules with InferencePool
- InferencePool: Resource that groups model pods and references the Endpoint Picker
- Endpoint Picker: Makes routing decisions based on metrics from pods

## Installation Steps

### Step 1: Install Gateway API CRDs

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml
```

Verify the CRDs were installed and are present in the UC:

```bash
kubectl get crd | grep gateway
```

You should see the following CRDs installed in the UC:
```
gatewayclasses.gateway.networking.k8s.io
gateways.gateway.networking.k8s.io
httproutes.gateway.networking.k8s.io
grpcroutes.gateway.networking.k8s.io
referencegrants.gateway.networking.k8s.io
```

### Step 2: Install kgateway Policy CRDs

kgateway will require additional policy CRDs

```bash
helm upgrade -i \
  --create-namespace \
  --namespace kgateway-system \
  --version v2.1.0 \
  kgateway-crds \
  oci://cr.kgateway.dev/kgateway-dev/charts/kgateway-crds
```

Verify the CRDs are installed:

```bash
kubectl get crd | grep kgateway
```

Expected output:
```
backendconfigpolicies.gateway.kgateway.dev
backends.gateway.kgateway.dev
directresponses.gateway.kgateway.dev
gatewayextensions.gateway.kgateway.dev
gatewayparameters.gateway.kgateway.dev
httplistenerpolicies.gateway.kgateway.dev
trafficpolicies.gateway.kgateway.dev
```

### Step 3: Install kgateway Controller

We will install kgateway v2.1.1 (which is the latest at the time of writing this guide) and it will be installed with inference extension enabled (this is very important).

```bash
helm upgrade -i \
  --create-namespace \
  --namespace kgateway-system \
  --version v2.1.1 \
  --set inferenceExtension.enabled=true \
  kgateway \
  oci://cr.kgateway.dev/kgateway-dev/charts/kgateway
```

Check GatewayClass:

```bash
kubectl get gatewayclass
```

Expected:
```
NAME                CONTROLLER              ACCEPTED   AGE
kgateway            kgateway.dev/kgateway   True       30s
```

### Step 4: Install Inference Extension CRDs

Install the Inference Extension CRDs:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api-inference-extension/releases/download/v1.1.0/manifests.yaml
```

```bash
kubectl get crd | grep inference
```

Expected output:
```
inferenceobjectives.inference.networking.x-k8s.io
inferencepools.inference.networking.k8s.io
inferencepools.inference.networking.x-k8s.io
```

### Step 5: Create Namespace and TLS Certificate

We will create a namespace for the AI workloads: 

```bash
kubectl create namespace ai-inference
```

For TLS certificates, we can use Cert Manager and set it up in KKP. You can create an application installation with `cert-manager` as an application and the KKP application controller will install cert-manager in your cluster. 
You can also generate a self signed TLS certificate for testing for the Gateway. The steps would require specifying a CN and also creating the Kubernetes secret with the certificate called `ai-gateway-tls`. For production, the use of cert-manager is recommended.

### Step 6: Deploy Model Server

Deploy server with the specific labels. Choose the option that matches your hardware. For testing we can chose llama.cpp, but you can deploy any model you would like based on your hardware. The next steps can be followed with minor tweaks if you chose another model server.

#### llama.cpp

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: llama-cpp-inference
  namespace: ai-inference
spec:
  replicas: 3
  selector:
    matchLabels:
      app: llama-cpp-inference
  template:
    metadata:
      labels:
        app: llama-cpp-inference
    spec:
      containers:
      - name: llama-cpp
        image: ghcr.io/ggerganov/llama.cpp:server
        args:
        - --hf-repo
        - bartowski/Llama-3.2-1B-Instruct-GGUF
        - --hf-file
        - Llama-3.2-1B-Instruct-Q4_K_M.gguf
        - --host
        - "0.0.0.0"
        - --port
        - "8000"
        - -c
        - "2048"
        - --n-gpu-layers
        - "0"
        - -t
        - "20"
        ports:
        - containerPort: 8000
          name: http
        resources:
          requests:
            cpu: "15"
            memory: "4Gi"
          limits:
            cpu: "20"
            memory: "6Gi"
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 60
          periodSeconds: 10
          failureThreshold: 30
```

Create the deployment:

```bash
kubectl apply -f llama-cpp-deployment.yaml
```

```bash
kubectl wait --for=condition=ready pod -l app=llama-cpp-inference -n ai-inference 
```

#### vLLM 

You can also chose a vLLM deployment, but the llama.cpp one should serve as a good starting point for testing the feature in our KKP cluster. This is an example deployment with vLLM.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-model
  namespace: ai-inference
spec:
  replicas: 3
  selector:
    matchLabels:
      app: vllm-model
  template:
    metadata:
      labels:
        app: vllm-model
    spec:
      containers:
      - name: vllm
        image: vllm/vllm-openai:latest
        args:
        - --model
        - meta-llama/Llama-3.2-1B-Instruct
        - --dtype
        - auto
        - --api-key
        - token-abc123
        ports:
        - containerPort: 8000
          name: http
        env:
        - name: HUGGING_FACE_HUB_TOKEN
          value: <your value>
        resources:
          requests:
            nvidia.com/gpu: "1"
          limits:
            nvidia.com/gpu: "1"
```

Create the deployment:

```bash
kubectl apply -f vllm-deployment.yaml
```

Wait for pods to be ready:

```bash
kubectl wait --for=condition=ready pod -l app=vllm-model -n ai-inference --timeout=300s
```

### Step 7: Create Gateway

Create the Gateway resource with HTTPS listener and TLS:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: ai-gateway
  namespace: ai-inference
spec:
  gatewayClassName: kgateway
  listeners:
  - name: https
    protocol: HTTPS
    port: 443
    tls:
      mode: Terminate
      certificateRefs:
      - name: ai-gateway-tls
    allowedRoutes:
      namespaces:
        from: Same
```

Apply the spec of the Gateway resource:

```bash
kubectl apply -f gateway.yaml
```

Wait for the Gateway to be programmed and receive an external IP:

```bash
kubectl wait --for=condition=Programmed gateway/ai-gateway -n ai-inference 
```

Get the Gateway external IP:

```bash
kubectl get gateway ai-gateway -n ai-inference
```

Expected output:
```
NAME         CLASS      ADDRESS                            PROGRAMMED   AGE
ai-gateway   kgateway   <should not be blank>              True         2m
```

**Why TLS is Required:**

TLS is not optional for the Inference Extension. The ext_proc filter in Envoy strips the `Content-Length` header when reading request bodies to extract model names.

### Step 8: Install Endpoint Picker

**For llama.cpp:**

```bash
helm install llama-cpp-picker \
  oci://registry.k8s.io/gateway-api-inference-extension/charts/inferencepool \
  --version v1.1.0 \
  --namespace ai-inference \
  --set inferencePool.modelServers.matchLabels.app=llama-cpp-inference \
  --set provider.name=kgateway
```

**For vLLM:**

```bash
helm install vllm-model-picker \
  oci://registry.k8s.io/gateway-api-inference-extension/charts/inferencepool \
  --version v1.1.0 \
  --namespace ai-inference \
  --set inferencePool.modelServers.matchLabels.app=vllm-model \
  --set provider.name=kgateway
```

Verify the Endpoint Picker deployment:

```bash
# For llama.cpp
kubectl get deployment,pod -n ai-inference -l app.kubernetes.io/name=llama-cpp-picker-epp

# For vLLM
kubectl get deployment,pod -n ai-inference -l app.kubernetes.io/name=vllm-model-picker-epp
```

Check the InferencePool resource

```bash
kubectl get inferencepool -n ai-inference
```

Should output:
```
NAME                 AGE
llama-cpp-picker     30s
```

InferencePool details:

```bash
# For llama.cpp
kubectl describe inferencepool llama-cpp-picker -n ai-inference

# For vLLM
kubectl describe inferencepool vllm-model-picker -n ai-inference
```

If you encounter an error like "InferencePool not found" in the HTTPRoute status after installation you should restart kgateway:

```bash
kubectl rollout restart deployment kgateway -n kgateway-system
kubectl rollout status deployment kgateway -n kgateway-system 
```

The issue can be a timing issue where kgateway starts before the InferencePool CRD is registered.

### Step 9: Create HTTPRoute with InferencePool

You should update the `name` field in `backendRefs` to match your Endpoint Picker installation.

**For llama.cpp:**

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: ai-inference-route
  namespace: ai-inference
spec:
  parentRefs:
  - name: ai-gateway
    sectionName: https
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - group: inference.networking.k8s.io
      kind: InferencePool
      name: llama-cpp-picker
      port: 8000
```

**For vLLM:**

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: ai-inference-route
  namespace: ai-inference
spec:
  parentRefs:
  - name: ai-gateway
    sectionName: https
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - group: inference.networking.k8s.io
      kind: InferencePool
      name: vllm-model-picker
      port: 8000
```

Apply the HTTPRoute:

```bash
kubectl apply -f httproute.yaml
```

Check the HTTPRoute status:

```bash
kubectl get httproute ai-inference-route -n ai-inference
```

The route should show `ACCEPTED` status with parent references properly resolved. If you see `ResolvedRefs: False` with "InferencePool not found" you should check the Troubleshooting section below.

## Testing and Verification

### Test Model List Endpoint

Test the `/v1/models` endpoint to verify basic connectivity:

```bash
GATEWAY_IP=$(kubectl get gateway ai-gateway -n ai-inference -o jsonpath='{.status.addresses[0].value}')

curl -k https://${GATEWAY_IP}/v1/models \
  -H "Host: ai.example.com"
```

**Expected response for llama.cpp:**
```json
{
  "object": "list",
  "data": [
    {
      "id": "/root/.cache/llama.cpp/bartowski_Llama-3.2-1B-Instruct-GGUF_Llama-3.2-1B-Instruct-Q4_K_M.gguf",
      "object": "model",
      "created": 1730000000,
      "owned_by": "llamacpp",
      "meta": {
        "n_ctx_train": 131072,
        "n_embd": 2048,
        "n_params": 1235814432,
        "size": 799862912
      }
    }
  ]
}
```

### Test Completions

Test the inference routing with a chat completion request. Use the appropriate model ID based on your deployment:

**For llama.cpp:**

```bash
curl -k https://${GATEWAY_IP}/v1/chat/completions \
  -H "Host: ai.example.com" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "/root/.cache/llama.cpp/bartowski_Llama-3.2-1B-Instruct-GGUF_Llama-3.2-1B-Instruct-Q4_K_M.gguf",
    "messages": [
      {
        "role": "user",
        "content": "Say random fact of the day"
      }
    ],
    "max_tokens": 100
  }' | jq -r '.choices[0].message.content'
```

You should receive a response with the model's answer with a random fact of the day. 

### Verify Load Balancing

Send multiple requests to verify load balancing across pods. 

**For llama.cpp:**

```bash
for i in {1..10}; do
  echo "Request $i:"
  curl -sk https://${GATEWAY_IP}/v1/chat/completions \
    -H "Host: ai.example.com" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "/root/.cache/llama.cpp/bartowski_Llama-3.2-1B-Instruct-GGUF_Llama-3.2-1B-Instruct-Q4_K_M.gguf",
      "messages": [{"role": "user", "content": "Hello"}],
      "max_tokens": 10
    }' | jq -r '.choices[0].message.content'
  sleep 1
done
```

All requests should complete successfully, demonstrating that traffic is being routed through the Endpoint Picker to healthy pods.

## Troubleshooting

### Gateway Not Programmed

If the Gateway remains in `Pending` state:

1. Check kgateway logs:
   ```bash
   kubectl logs -n kgateway-system deployment/kgateway --tail=100
   ```

2. Check CRDs installation:
   ```bash
   kubectl get crd | grep -E '(gateway|kgateway|inference)'
   ```

3. Kgateway pod should be running and ready:
   ```bash
   kubectl get pods -n kgateway-system
   ```

### HTTPRoute Not Accepted

If HTTPRoute shows `NOT ACCEPTED`:

1. Check the HTTPRoute status for detailed error messages:
   ```bash
   kubectl describe httproute ai-inference-route -n ai-inference
   ```

### Connection Errors or Timeouts

If requests fail with connection errors:

1. Verify server pods are running:
   ```bash
   kubectl get pods -n ai-inference -l app=llama-cpp-inference
   ```

2. Check logs:
   ```bash
   kubectl logs -n ai-inference -l app=llama-cpp-inference --tail=100
   ```

3. Verify InferencePool can discover pods:
   ```bash
   # Check InferencePool status
   kubectl get inferencepool llama-cpp-picker -n ai-inference -o yaml

   # Verify pods match the InferencePool selector
   kubectl get pods -n ai-inference -l app=llama-cpp-inference -o wide
   ```

4. Test direct pod access:
   ```bash
   # For llama.cpp
   kubectl port-forward -n ai-inference deployment/llama-cpp-inference 8000:8000
   # In another terminal:
   curl http://localhost:8000/v1/models

   ```

### Content-Length Header Issues

The Inference Extension ext_proc filter strips the `Content-Length` header. If your model server requires `Content-Length` you would need to ensure you're using HTTPS, and also need to verify the Gateway has the right TLS configuration.

## Upstream documentation for the resources used

- [Gateway API Documentation](https://gateway-api.sigs.k8s.io/)
- [Gateway API Inference Extension](https://gateway-api-inference-extension.sigs.k8s.io/)
- [kgateway Documentation](https://kgateway.dev/docs/)
- [kgateway Inference Extension Guide](https://kgateway.dev/docs/integrations/inference-extension/)
- [Envoy External Processing](https://www.envoyproxy.io/docs/envoy/latest/configuration/http/http_filters/ext_proc_filter)

## Version Information

This guide was tested with:

- KKP: 2.29
- Kubernetes: 1.33.5
- Gateway API CRDs: v1.2.1
- kgateway: v2.1.1
- kgateway-crds: v2.1.0
- Inference Extension: v1.1.0
- Endpoint Picker: v1.1.0

**Tested Inference Servers:**
- llama.cpp server (ghcr.io/ggerganov/llama.cpp:server) 
  - Model: Llama-3.2-1B-Instruct Q4_K_M (GGUF)
