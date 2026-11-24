+++
title = "KubeVirt"
date = 2026-11-14T12:00:00+02:00
weight = 3
+++

KubeOne can create the control plane `VirtualMachines` on a KubeVirt
infrastructure cluster itself, so you don't need other tools to create them.

When `controlPlane.nodeSets` is set together with
`cloudProvider.kubevirt.controlPlane`, `kubeone apply`:

1. Creates a Kubernetes `Service` in the infra cluster that selects the
   control plane VMs, or reuses an existing one with the same name. KubeOne
   sets `apiEndpoint` from this Service.
2. Creates the control plane `VirtualMachines` in the infra namespace with the
   machine-controller KubeVirt driver.
3. Connects to the VMs over SSH using their in-cluster IP addresses. KubeVirt
   VMs only have internal addresses, so you usually need a bastion (see
   [SSH Access](#ssh-access)).

If you set `controlPlane.nodeSets` without `cloudProvider.kubevirt.controlPlane`,
KubeOne creates only the VMs. You must then set `apiEndpoint.host` yourself.

## Prerequisites

* A KubeVirt infrastructure cluster and its kubeconfig.
* A namespace in the infra cluster for the VMs and the Service, set as
  `cloudProvider.kubevirt.infraNamespace`.
* A way to reach the VMs over SSH from where KubeOne runs, for example a
  bastion in the infra cluster.
* `clusterNetwork.podSubnet` and `clusterNetwork.serviceSubnet` that don't
  overlap with the networks of the infra cluster.

## Credentials

KubeOne reads the infra cluster kubeconfig from the `KUBEVIRT_KUBECONFIG` key
of the credentials file, or from the `KUBEVIRT_KUBECONFIG` environment
variable. The value can be plain or base64-encoded kubeconfig YAML.

```yaml
KUBEVIRT_KUBECONFIG: <base64-encoded kubeconfig>
```

## SSH Access

The control plane VMs get addresses from the infra cluster network, which
usually isn't reachable from your machine. One way to reach them is to run an
SSH server in the infra namespace and expose it with a `NodePort` Service:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: sshd-authorized-keys
type: Opaque
stringData:
  authorized_keys: |
    ssh-ed25519 AAAA...
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: sshd-config
data:
  sshd_config: |
    Port 2222
    HostKey /host-keys/ssh_host_ed25519_key
    PermitRootLogin no
    PasswordAuthentication no
    PubkeyAuthentication yes
    AuthorizedKeysFile .ssh/authorized_keys
    AllowTcpForwarding yes
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bastion
spec:
  replicas: 1
  selector:
    matchLabels:
      app: bastion
  template:
    metadata:
      labels:
        app: bastion
    spec:
      containers:
        - name: sshd
          image: alpine:3.21
          command:
            - sh
            - -c
            - |
              apk add --no-cache openssh-server openssh-keygen
              mkdir -p /host-keys /run/sshd
              ssh-keygen -t ed25519 -f /host-keys/ssh_host_ed25519_key -N ""
              # passwd -d unlocks the account, password login stays disabled in sshd_config
              adduser -D -s /bin/sh user && passwd -d user
              mkdir -p /home/user/.ssh
              cp /authorized-keys/authorized_keys /home/user/.ssh/authorized_keys
              chmod 700 /home/user/.ssh && chmod 600 /home/user/.ssh/authorized_keys
              chown -R user:user /home/user/.ssh
              exec /usr/sbin/sshd -D -e -f /sshd-config/sshd_config
          ports:
            - name: ssh
              containerPort: 2222
          volumeMounts:
            - name: sshd-config
              mountPath: /sshd-config
            - name: authorized-keys
              mountPath: /authorized-keys
      volumes:
        - name: sshd-config
          configMap:
            name: sshd-config
        - name: authorized-keys
          secret:
            secretName: sshd-authorized-keys
---
apiVersion: v1
kind: Service
metadata:
  name: bastion
spec:
  type: NodePort
  selector:
    app: bastion
  ports:
    - name: ssh
      port: 2222
      targetPort: 2222
```

Set an infra cluster node IP and the allocated node port as `ssh.bastion` and
`ssh.bastionPort` of the nodeSets, and `user` as `ssh.bastionUser`.

This example generates new SSH host keys each time the Pod restarts. To keep
them stable, store them in a PersistentVolume or a Secret.

## Configuration

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: my-cluster

versions:
  kubernetes: 1.37.2

clusterNetwork:
  # Must not overlap with the networks of the infra cluster
  podSubnet: 172.26.0.0/16
  serviceSubnet: 10.241.0.0/16

cloudProvider:
  external: true
  kubevirt:
    infraNamespace: my-cluster
    controlPlane:
      loadBalancer:
        # Name of the Service. Default: "<CLUSTER_NAME>-kubeapi"
        name: my-cluster-kubeapi
        # Type of the Service: LoadBalancer, NodePort, ClusterIP or ExternalName
        serviceType: LoadBalancer
        # Annotations of the Service
        annotations:
          metallb.universe.tf/address-pool: public

controlPlane:
  nodeSets:
    - name: cp
      replicas: 3
      operatingSystem: ubuntu
      ssh:
        username: ubuntu
        publicKeys:
          - ssh-ed25519 AAAA...
        bastion: 192.0.2.10
        bastionPort: 31022
        bastionUser: user
      cloudProviderSpec:
        virtualMachine:
          template:
            vcpus:
              cores: 2
            memory: 4Gi
            primaryDisk:
              osImage: docker://quay.io/containerdisks/ubuntu:24.04
              source: registry
              size: 20Gi
              storageClassName: longhorn
```

The `cloudProviderSpec` is the [machine-controller KubeVirt provider
spec][mc-kubevirt]. KubeOne sets its `clusterName` to the KubeOne cluster
name.

### Load Balancer Options

| Field | Default | Description |
|-------|---------|-------------|
| `name` | `<CLUSTER_NAME>-kubeapi` | Name of the Service in the infra namespace |
| `serviceType` | `ClusterIP` (the Kubernetes default) | Type of the Service: `LoadBalancer`, `NodePort`, `ClusterIP` or `ExternalName` |
| `annotations` | empty | Annotations of the Service |

## How the Service Works

KubeOne creates the Service in the infra namespace with a selector for port
6443 on the control plane VMs. KubeOne adds these labels to the VMs:

| Label | Value |
|-------|-------|
| `kubeone_cluster_name` | `<CLUSTER_NAME>` |
| `kubeone_role` | `api` |

If a Service with the configured name already exists, KubeOne uses it as it
is. How KubeOne sets `apiEndpoint` depends on the Service type:

| Service type | `apiEndpoint` |
|--------------|---------------|
| `LoadBalancer` | The ingress address of the Service. KubeOne waits up to 5 minutes for it to be assigned. The infra cluster needs a load balancer implementation, e.g. MetalLB |
| `NodePort`, `ClusterIP` | `<name>.<infraNamespace>.svc.cluster.local:6443`. Only clients that use the DNS of the infra cluster can resolve this name |
| `ExternalName` | The external name of the Service, port 6443 |

If `apiEndpoint.host` is set in the manifest, KubeOne doesn't create or look up
the Service.

With `NodePort` or `ClusterIP`, the API endpoint is only reachable from inside
the infra cluster. To reach the cluster from your machine, use `kubeone proxy`.

## Creating the Cluster

```bash
kubeone apply --manifest kubeone.yaml --credentials credentials.yaml
```

## Destroying the Cluster

```bash
kubeone reset --manifest kubeone.yaml --credentials credentials.yaml \
  --destroy-control-plane \
  --destroy-control-plane-load-balancer
```

This deletes the control plane VMs and the Service.

{{% notice warning %}}
`--destroy-control-plane-load-balancer` deletes the Service with the configured
name, even if you created it yourself.
{{% /notice %}}

[mc-kubevirt]: https://github.com/kubermatic/machine-controller/blob/main/docs/cloud-provider.md#kubevirt
