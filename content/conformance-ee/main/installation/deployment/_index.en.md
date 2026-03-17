+++
title = "In-Cluster Deployment"
date = 2026-03-17T10:07:15+02:00
weight = 30
+++

Conformance EE is designed to run as a Kubernetes Job inside a cluster with access to the KKP API. The interactive TUI handles resource creation, but you can also deploy manually.

## Automated Deployment via TUI

The simplest way to deploy is using the interactive terminal UI:

```bash
./conformance-tester
```

The TUI will guide you through:

1. Selecting the environment (local or existing cluster)
2. Choosing cloud providers to test
3. Configuring kubeconfig and credentials
4. Selecting Kubernetes versions, OS distributions, and datacenters
5. Deploying the test Job

## Manual Deployment

### 1. Create the Namespace

```bash
kubectl create namespace conformance-tests
```

### 2. Create RBAC

The conformance tester needs `cluster-admin` privileges:

```bash
kubectl create clusterrolebinding conformance-tests-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=conformance-tests:default
```

### 3. Create the Configuration ConfigMap

Create a `config.yaml` with your test configuration (see [Configuration]({{< ref "../../configuration/" >}})) and store it in a ConfigMap:

```bash
kubectl create configmap conformance-config \
  --from-file=config.yaml=./config.yaml \
  -n conformance-tests
```

### 4. Create the Kubeconfig Secret

```bash
kubectl create secret generic conformance-kubeconfig \
  --from-file=kubeconfig=./kubeconfig \
  -n conformance-tests
```

### 5. Deploy the Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: conformance-tests
  namespace: conformance-tests
spec:
  backoffLimit: 0
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: conformance-tester
          image: quay.io/kubermatic/conformance-ee:latest
          args:
            - /e2e.test
            - --ginkgo.v
          volumeMounts:
            - name: config
              mountPath: /opt/config.yaml
              subPath: config.yaml
            - name: kubeconfig
              mountPath: /opt/kubeconfig
              subPath: kubeconfig
          env:
            - name: CONFORMANCE_TESTER_CONFIG_FILE
              value: /opt/config.yaml
            - name: KUBECONFIG
              value: /opt/kubeconfig
      volumes:
        - name: config
          configMap:
            name: conformance-config
        - name: kubeconfig
          secret:
            secretName: conformance-kubeconfig
```

```bash
kubectl apply -f conformance-job.yaml
```

### 6. Monitor Progress

View live test progress via the ConfigMap reporter:

```bash
kubectl get configmap -n conformance-tests -l app=conformance-reports -o yaml
```

View Job logs:

```bash
kubectl logs -n conformance-tests job/conformance-tests -f
```

## Resource Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU | 500m | 1000m |
| Memory | 512Mi | 1Gi |
| Disk | - | - |

{{% notice warning %}}
Ensure the cluster has enough capacity for the conformance tester pod and that network policies allow access to the KKP API and cloud provider endpoints.
{{% /notice %}}
