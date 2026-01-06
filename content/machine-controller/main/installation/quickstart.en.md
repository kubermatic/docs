+++
title = "Installation"
date = 2024-05-31T07:00:00+02:00
weight = 5
+++

## Prerequisites

Before installing machine-controller, ensure you have:

- A running Kubernetes cluster (version 1.20 or higher)
- `kubectl` configured to access your cluster
- Appropriate cloud provider credentials
- Cluster admin permissions

## Installation Methods

### Via KubeOne

The recommended way to install machine-controller is through [KubeOne]({{< ref "/kubeone/" >}}), which automatically deploys and configures machine-controller as part of the cluster setup.

KubeOne handles:
- Deployment of machine-controller
- Configuration of cloud provider credentials
- Setup of necessary RBAC permissions
- Initial MachineDeployment creation

See the [KubeOne machine-controller guide]({{< ref "/kubeone/main/guides/machine-controller/" >}}) for detailed instructions.

### Manual Installation

For manual installation or custom deployments:

1. **Clone the repository:**

```bash
git clone https://github.com/kubermatic/machine-controller.git
cd machine-controller
```

2. **Deploy the machine-controller:**

```bash
kubectl apply -f examples/machine-controller.yaml
```

3. **Create cloud provider secret:**

Create a secret containing your cloud provider credentials. The exact format depends on your provider:

```bash
kubectl create secret generic machine-controller-credentials \
  -n kube-system \
  --from-literal=token=<YOUR_TOKEN>
```

4. **Verify the installation:**

```bash
kubectl get pods -n kube-system | grep machine-controller
```

The machine-controller pod should be running.

## Configuration

### Environment Variables

Machine-controller supports the following environment variables for cloud provider authentication:

- **AWS:** `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
- **Azure:** `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`
- **DigitalOcean:** `DO_TOKEN`
- **GCP:** `GOOGLE_SERVICE_ACCOUNT` (base64-encoded)
- **Hetzner:** `HCLOUD_TOKEN`
- **OpenStack:** `OS_AUTH_URL`, `OS_USERNAME`, `OS_PASSWORD`, `OS_DOMAIN_NAME`, `OS_TENANT_NAME`

### Deployment Configuration

Customize the machine-controller deployment by editing the deployment manifest:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: machine-controller
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: machine-controller
  template:
    metadata:
      labels:
        app: machine-controller
    spec:
      serviceAccountName: machine-controller
      containers:
      - name: machine-controller
        image: quay.io/kubermatic/machine-controller:latest
        command:
        - /usr/local/bin/machine-controller
        args:
        - -logtostderr
        - -v=4
        - -worker-count=10
        env:
        # Add cloud provider credentials here
        - name: HCLOUD_TOKEN
          valueFrom:
            secretKeyRef:
              name: machine-controller-credentials
              key: token
```

## Upgrading

To upgrade machine-controller to a newer version:

1. **Update the image version:**

```bash
kubectl set image deployment/machine-controller \
  machine-controller=quay.io/kubermatic/machine-controller:v1.59.0 \
  -n kube-system
```

2. **Verify the rollout:**

```bash
kubectl rollout status deployment/machine-controller -n kube-system
```

## Uninstallation

To remove machine-controller from your cluster:

1. **Delete all MachineDeployments:**

```bash
kubectl delete machinedeployments --all -n kube-system
```

2. **Wait for all machines to be deleted:**

```bash
kubectl get machines -n kube-system
```

3. **Delete the machine-controller deployment:**

```bash
kubectl delete deployment machine-controller -n kube-system
```

4. **Clean up RBAC resources:**

```bash
kubectl delete clusterrole machine-controller
kubectl delete clusterrolebinding machine-controller
kubectl delete serviceaccount machine-controller -n kube-system
```

## Next Steps

- [Configure cloud provider specific settings]({{< ref "../references/cloud-providers/" >}})
- [Learn about operating system support]({{< ref "../references/operating-systems/" >}})
- [Create your first MachineDeployment]({{< ref "../tutorials/creating-machines/" >}})

