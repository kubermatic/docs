+++
title = "Configuring Operating System Manager"
date = 2022-08-20T12:00:00+02:00
enableToc = true
+++

## Configuring Operating System Manager

OSM can be configured using the following command line flags:

| Flags               | Type   | Required | Default | Description                         |
| ------------------- | ------ | -------- | ------- | ----------------------------------- |
| `kubeconfig` | string | false | `""` | Path to a kubeconfig. Only required if out-of-cluster. |
| `worker-cluster-kubeconfig` | string | false | `""` | Path to kubeconfig of cluster where provisioning secrets are created. |
| `namespace` | string | true | `""` | The namespace where the OSC controller will run. |
| `container-runtime` | string | false | `containerd` | Container runtime to deploy. |
| `external-cloud-provider` | bool | false | `false` | Cloud-provider Kubelet flag set to external.. |
| `cluster-dns` | string | false | `10.10.10.10` | Comma-separated list of DNS server IP address. |
| `pause-image` | string | false | `""` | Pause image to use in Kubelet. |
| `initial-taints` | string | false | `""` | Taints to use when creating the node. |
| `node-kubelet-feature-gates` | string | false | `RotateKubeletServerCertificate=true` | Feature gates to set on the kubelet. If user overrides the value, `RotateKubeletServerCertificate=true` is appended by OSM in the feature gates. |
| `node-http-proxy` | string | false | `""` | If set, it configures the 'HTTP_PROXY' & 'HTTPS_PROXY' environment variable on the nodes. |
| `node-no-proxy` | string | false | `.svc,.cluster.local,localhost,127.0.0.1` | If set, it configures the 'NO_PROXY' environment variable on the nodes. |
| `node-insecure-registries` | string | false | `""` | Comma separated list of registries which should be configured as insecure on the container runtime. |
| `node-http-proxy` | string | false | `""` | If set, it configures the 'HTTP_PROXY' & 'HTTPS_PROXY' environment variable on the nodes. |
| `node-registry-mirrors` | string | false | `""` | Comma separated list of Docker image mirrors. |
| `node-containerd-registry-mirrors` | string | false | `""` | Configure registry mirrors endpoints. Can be used multiple times to specify multiple mirrors. |
| `node-registry-credentials-secret` | string | false | `""` | A Secret object reference, that contains auth info for image registry in namespace/secret-name form, example: kube-system/registry-credentials. See doc at <https://github.com/kubermaric/machine-controller/blob/master/docs/registry-authentication.md>. |
| `health-probe-address` | string | false | `127.0.0.1:8085` | The address on which the liveness check on /healthz and readiness check on /readyz will be available. |
| `metrics-address` | string | false | `127.0.0.1:8080` | The address on which Prometheus metrics will be available under /metrics. |
| `worker-health-probe-address` | string | false | `127.0.0.1:8086` | For worker manager, the address on which the liveness check on /healthz and readiness check on /readyz will be available. |
| `worker-metrics-address` | string | false | `127.0.0.1:8081` | For worker manager, the address on which Prometheus metrics will be available under /metrics. |
| `leader-elect` | bool | false | `true` | Enable leader election for controller manager. |
| `override-bootstrap-kubelet-apiserver` | string | false | `""` | Override for the API server address used in worker nodes bootstrap-kubelet.conf. |
| `bootstrap-token-service-account-name` | string | false | `""` | When set use the service account token from this SA as bootstrap token instead of creating a temporary one. Passed in `namespace/name` format. |
| `worker-count` | int | false | `10` | Number of workers which process reconciliation in parallel. |
| `ca-bundle` | string | false | `""` | Path to a file containing all PEM-encoded CA certificates. Will be used for Kubernetes CA certificates. |

## Configuring Operating System Profile

To generate bootstrapping and provisioning configurations, OSM uses the OSP(template) and values from MachineDeployment and command line flags. These values are substituted dynamically to generate the configurations.

Following is the list of the variables accessible inside an OSP:

| Variable            | Type   | Description                         |
| ------------------- | ------ | ----------------------------------- |
| `KubeVersion` | string | Kubernetes version to use, picked from the MachineDeployment. |
| `InTreeCCMAvailable` | bool | True if in-tree CCM is available for the cloud provider. |
| `ClusterDNSIPs` | []string | List of Cluster DNS IP, picked from flags. |
| `KubernetesCACert` | string | CA certificate for the worker machine. Set at `/etc/kubernetes/pki/ca.crt`. |
| `CloudConfig` | string | Cloud config for the machine. |
| `ContainerRuntime` | string | Name of the container runtime to use. |
| `CloudProviderName` | string | Name of the cloud provider. |
| `ExternalCloudProvider` | bool | External CCM should be used for the cloud provider. |
| `PauseImage` | string | Image for the pause container, specified using `--pod-infra-container` for the kubelet. |
| `InitialTaints` | string | Register the node with the given list of taints. |
| `HTTPProxy` | string | Configuration for HTTP_PROXY, HTTPS_PROXY |
| `NoProxy` | string | Configuration for NO_PROXY |
| `ContainerRuntimeConfig` | string | Configuration for NO_PROXY |
| `ContainerRuntimeAuthConfig` | string | Configuration for NO_PROXY |
| `KubeletFeatureGates` | string | Feature gates for kubelet |
| `NetworkIPFamily` | string | Type of Network IP family; IPv4, IPv6 or IPv4+IPv6 |
| `NetworkConfig` | string | Static networking configuration, picked from the MachineDeployment. |
| `KubeReserved` | map[string]string | Picked up from annotations on MachineDeployment. |
| `SystemReserved` | map[string]string | Picked up from annotations on MachineDeployment. |
| `EvictionHard` | map[string]string | Picked up from annotations on MachineDeployment. |
| `MaxPods` | int32 | Picked up from annotations on MachineDeployment. |
| `ContainerLogMaxSize` | string | Picked up from annotations on MachineDeployment. |
| `ContainerLogMaxFiles` | string | Picked up from annotations on MachineDeployment. |
