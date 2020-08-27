+++
title = "Kubermatic Addons"
date = 2018-06-21T14:07:15+02:00
weight = 8

+++

Addons are specific services and tools extending the functionality of Kubernetes.

### Default Addons

Default addons are installed in each user-cluster in Kubermatic. The default addons are:

* [Canal](https://github.com/projectcalico/canal): policy based networking for cloud native applications
* [Dashboard](https://github.com/kubernetes/dashboard): General-purpose web UI for Kubernetes clusters
* [DNS](https://github.com/coredns/coredns): Kubernetes DNS service
* [kube-proxy](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/): Kubernetes network proxy
* [rbac](https://kubernetes.io/docs/reference/access-authn-authz/rbac/): Kubernetes Role-Based Access Control, needed for [TLS node bootstrapping](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet-tls-bootstrapping/)
* [OpenVPN client](https://openvpn.net/index.php/open-source/overview.html): virtual private network (VPN). Lets the control plan access the Pod & Service network. Required for functionality like `kubectl proxy` & `kubectl port-forward`.
* default-storage-class: A cloud provider specific StorageClass
* kubelet-configmap: A set of ConfigMaps used by kubeadm

Installation and configuration of these addons is done by 2 controllers which are part of the Kubermatic controller-manager:

* `addon-installer-controller`: Ensures a given set of addons will be installed in all clusters
* `addon-controller`: Templates the addons & applies the manifests in the user clusters

#### Configuration

To configure which addons shall be installed in all user clusters, set the following settings in the `values.yaml` for the kubermatic chart:

```yaml
kubermatic:
  controller:
    addons:
      kubernetes:
        defaultAddons:
        - canal
        - dashboard
        - dns
        - kube-proxy
        - openvpn
        - rbac
        - kubelet-configmap
        - default-storage-class
        image:
          repository: "quay.io/kubermatic/addons"
          tag: "v0.2.9"
          pullPolicy: "IfNotPresent"
```

To deploy the changes:

```bash
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace kubermatic kubermatic charts/kubermatic
```

##### Setting a Custom Docker Registry

In case you want to set a custom registry for all addons, you can specify the `-overwrideRegistry` flag on the `kubermatic-controller-manager` or via the helm setting `kubermatic.controller.overwriteRegistry`.
It will set the specified registry on all control plane components & addons.

### Accessible Addons

Accessible addons can be installed in each user-cluster in Kubermatic on user demand. If an addon is both default
and accessible, then it will be installed in the user-cluster, but also be visible to the user, who can manage it from
the UI like the other accessible addons. The accessible addons are:

* [node-exporter](https://github.com/prometheus/node_exporter): Exports metrics from the node

Accessible addons can be managed in the UI from the cluster details view:

![View](/img/kubermatic/v2.13/advanced/addons/view.png)

#### Configuration
To configure which addons shall be accessible, set the following settings in the `values.yaml` for the Kubermatic chart:

```yaml
kubermatic:
  api:
    # List of optional addons that can be installed into every user-cluster. All need to exist in the addons image.
    accessibleAddons:
    - node-exporter
```

Accessible addons are configured by the `AddonConfig` custom resources with the same names as the addons that are
configured. The configuration is not required, but it is recommended. Each config should contain logo and description.
Form specification of addon variables is optional. Here is an example of `node-exporter` config:

```yaml
apiVersion: kubermatic.k8s.io/v1
kind: AddonConfig
metadata:
  name: node-exporter
spec:
  description: "The Prometheus Node Exporter exposes a wide variety of hardware- and kernel-related metrics."
  logoFormat: "svg+xml"
  logo: "PHN2ZyB3aWR0aD0iMTY2IiBoZWlnaHQ9IjQwIiB2aWV3Qm94PSIwIDAgMTY2IDQwIiBmaWxsPSJub25lIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgo8cGF0aCBkPSJNMTkuOTEyNCA1LjE3NTU0QzExLjY3NjggNS4xNzU1NCA1IDExLjg1MTYgNSAyMC4wODc0QzUgMjguMzIyOSAxMS42NzY4IDM0Ljk5OTUgMTkuOTEyNCAzNC45OTk1QzI4LjE0NzkgMzQuOTk5NSAzNC44MjQ1IDI4LjMyMjkgMzQuODI0NSAyMC4wODc0QzM0LjgyNDUgMTEuODUxNiAyOC4xNDc2IDUuMTc1NTQgMTkuOTEyNCA1LjE3NTU0VjUuMTc1NTRaTTE5LjkxMjQgMzMuMDg0N0MxNy41NjkyIDMzLjA4NDcgMTUuNjY5NSAzMS41MTk1IDE1LjY2OTUgMjkuNTg5MkgyNC4xNTUzQzI0LjE1NTMgMzEuNTE5MiAyMi4yNTU1IDMzLjA4NDcgMTkuOTEyNCAzMy4wODQ3Wk0yNi45MjAzIDI4LjQzMTZIMTIuOTAzN1YyNS44OUgyNi45MjA1VjI4LjQzMTZIMjYuOTIwM1pNMjYuODcgMjQuNTgxOUgxMi45NDM3QzEyLjg5NzQgMjQuNTI4NCAxMi44NSAyNC40NzU4IDEyLjgwNTMgMjQuNDIxNkMxMS4zNzA1IDIyLjY3OTUgMTEuMDMyNiAyMS43NyAxMC43MDQ1IDIwLjg0MzJDMTAuNjk4OSAyMC44MTI2IDEyLjQ0NDIgMjEuMTk5NyAxMy42ODE4IDIxLjQ3ODJDMTMuNjgxOCAyMS40NzgyIDE0LjMxODcgMjEuNjI1NSAxNS4yNDk3IDIxLjc5NTNDMTQuMzU1OCAyMC43NDc0IDEzLjgyNSAxOS40MTUzIDEzLjgyNSAxOC4wNTM3QzEzLjgyNSAxNS4wNjQ1IDE2LjExNzYgMTIuNDUyNCAxNS4yOTA1IDEwLjM0MTFDMTYuMDk1NSAxMC40MDY2IDE2Ljk1NjYgMTIuMDQgMTcuMDE0NyAxNC41OTRDMTcuODcwNSAxMy40MTEzIDE4LjIyODcgMTEuMjUxNiAxOC4yMjg3IDkuOTI3MzhDMTguMjI4NyA4LjU1NjMzIDE5LjEzMjEgNi45NjM3IDIwLjAzNTggNi45MDkyMkMxOS4yMzAzIDguMjM2ODUgMjAuMjQ0NSA5LjM3NTAxIDIxLjE0NjEgMTIuMTk4NEMyMS40ODQyIDEzLjI1OSAyMS40NDExIDE1LjA0MzcgMjEuNzAyMSAxNi4xNzU1QzIxLjc4ODcgMTMuODI0NyAyMi4xOTI5IDEwLjM5NDcgMjMuNjg0MiA5LjIxMDU0QzIzLjAyNjMgMTAuNzAxOSAyMy43ODE2IDEyLjU2NzkgMjQuMjk4MiAxMy40NjVDMjUuMTMxNiAxNC45MTI0IDI1LjYzNjggMTYuMDA5IDI1LjYzNjggMTguMDgyOUMyNS42MzY4IDE5LjQ3MzQgMjUuMTIzNCAyMC43ODI2IDI0LjI1NzQgMjEuODA2MUMyNS4yNDIxIDIxLjYyMTMgMjUuOTIyMSAyMS40NTQ3IDI1LjkyMjEgMjEuNDU0N0wyOS4xMiAyMC44MzA4QzI5LjEyMDMgMjAuODMwNSAyOC42NTU1IDIyLjc0MTYgMjYuODcgMjQuNTgxOVoiIGZpbGw9IiNFNjUyMkMiLz4KPHBhdGggZD0iTTU3LjMyMDMgMjdINTUuNjI0TDQ5LjE4MTYgMTcuMTM4N1YyN0g0Ny40ODU0VjE0LjIwMzFINDkuMTgxNkw1NS42NDE2IDI0LjEwODRWMTQuMjAzMUg1Ny4zMjAzVjI3WiIgZmlsbD0iYmxhY2siLz4KPHBhdGggZD0iTTU5LjYzMTggMjIuMTU3MkM1OS42MzE4IDIxLjIyNTYgNTkuODEzNSAyMC4zODc3IDYwLjE3NjggMTkuNjQzNkM2MC41NDU5IDE4Ljg5OTQgNjEuMDU1NyAxOC4zMjUyIDYxLjcwNjEgMTcuOTIwOUM2Mi4zNjIzIDE3LjUxNjYgNjMuMTA5NCAxNy4zMTQ1IDYzLjk0NzMgMTcuMzE0NUM2NS4yNDIyIDE3LjMxNDUgNjYuMjg4MSAxNy43NjI3IDY3LjA4NSAxOC42NTkyQzY3Ljg4NzcgMTkuNTU1NyA2OC4yODkxIDIwLjc0OCA2OC4yODkxIDIyLjIzNjNWMjIuMzUwNkM2OC4yODkxIDIzLjI3NjQgNjguMTEwNCAyNC4xMDg0IDY3Ljc1MjkgMjQuODQ2N0M2Ny40MDE0IDI1LjU3OTEgNjYuODk0NSAyNi4xNTA0IDY2LjIzMjQgMjYuNTYwNUM2NS41NzYyIDI2Ljk3MDcgNjQuODIwMyAyNy4xNzU4IDYzLjk2NDggMjcuMTc1OEM2Mi42NzU4IDI3LjE3NTggNjEuNjI5OSAyNi43Mjc1IDYwLjgyNzEgMjUuODMxMUM2MC4wMzAzIDI0LjkzNDYgNTkuNjMxOCAyMy43NDggNTkuNjMxOCAyMi4yNzE1VjIyLjE1NzJaTTYxLjI2NjYgMjIuMzUwNkM2MS4yNjY2IDIzLjQwNTMgNjEuNTA5OCAyNC4yNTIgNjEuOTk2MSAyNC44OTA2QzYyLjQ4ODMgMjUuNTI5MyA2My4xNDQ1IDI1Ljg0ODYgNjMuOTY0OCAyNS44NDg2QzY0Ljc5MSAyNS44NDg2IDY1LjQ0NzMgMjUuNTI2NCA2NS45MzM2IDI0Ljg4MThDNjYuNDE5OSAyNC4yMzE0IDY2LjY2MzEgMjMuMzIzMiA2Ni42NjMxIDIyLjE1NzJDNjYuNjYzMSAyMS4xMTQzIDY2LjQxNDEgMjAuMjcwNSA2NS45MTYgMTkuNjI2QzY1LjQyMzggMTguOTc1NiA2NC43Njc2IDE4LjY1MDQgNjMuOTQ3MyAxOC42NTA0QzYzLjE0NDUgMTguNjUwNCA2Mi40OTcxIDE4Ljk2OTcgNjIuMDA0OSAxOS42MDg0QzYxLjUxMjcgMjAuMjQ3MSA2MS4yNjY2IDIxLjE2MTEgNjEuMjY2NiAyMi4zNTA2WiIgZmlsbD0iYmxhY2siLz4KPHBhdGggZD0iTTY5LjkzMjYgMjIuMTY2QzY5LjkzMjYgMjAuNzA3IDcwLjI3ODMgMTkuNTM1MiA3MC45Njk3IDE4LjY1MDRDNzEuNjYxMSAxNy43NTk4IDcyLjU2NjQgMTcuMzE0NSA3My42ODU1IDE3LjMxNDVDNzQuNzk4OCAxNy4zMTQ1IDc1LjY4MDcgMTcuNjk1MyA3Ni4zMzExIDE4LjQ1N1YxMy41SDc3Ljk1N1YyN0g3Ni40NjI5TDc2LjM4MzggMjUuOTgwNUM3NS43MzM0IDI2Ljc3NzMgNzQuODI4MSAyNy4xNzU4IDczLjY2OCAyNy4xNzU4QzcyLjU2NjQgMjcuMTc1OCA3MS42NjcgMjYuNzI0NiA3MC45Njk3IDI1LjgyMjNDNzAuMjc4MyAyNC45MTk5IDY5LjkzMjYgMjMuNzQyMiA2OS45MzI2IDIyLjI4OTFWMjIuMTY2Wk03MS41NTg2IDIyLjM1MDZDNzEuNTU4NiAyMy40Mjg3IDcxLjc4MTIgMjQuMjcyNSA3Mi4yMjY2IDI0Ljg4MThDNzIuNjcxOSAyNS40OTEyIDczLjI4NzEgMjUuNzk1OSA3NC4wNzIzIDI1Ljc5NTlDNzUuMTAzNSAyNS43OTU5IDc1Ljg1NjQgMjUuMzMzIDc2LjMzMTEgMjQuNDA3MlYyMC4wMzkxQzc1Ljg0NDcgMTkuMTQyNiA3NS4wOTc3IDE4LjY5NDMgNzQuMDg5OCAxOC42OTQzQzczLjI5MyAxOC42OTQzIDcyLjY3MTkgMTkuMDAyIDcyLjIyNjYgMTkuNjE3MkM3MS43ODEyIDIwLjIzMjQgNzEuNTU4NiAyMS4xNDM2IDcxLjU1ODYgMjIuMzUwNloiIGZpbGw9ImJsYWNrIi8+CjxwYXRoIGQ9Ik04NC40MzQ2IDI3LjE3NThDODMuMTQ1NSAyNy4xNzU4IDgyLjA5NjcgMjYuNzUzOSA4MS4yODgxIDI1LjkxMDJDODAuNDc5NSAyNS4wNjA1IDgwLjA3NTIgMjMuOTI2OCA4MC4wNzUyIDIyLjUwODhWMjIuMjFDODAuMDc1MiAyMS4yNjY2IDgwLjI1MzkgMjAuNDI1OCA4MC42MTEzIDE5LjY4NzVDODAuOTc0NiAxOC45NDM0IDgxLjQ3ODUgMTguMzYzMyA4Mi4xMjMgMTcuOTQ3M0M4Mi43NzM0IDE3LjUyNTQgODMuNDc2NiAxNy4zMTQ1IDg0LjIzMjQgMTcuMzE0NUM4NS40Njg4IDE3LjMxNDUgODYuNDI5NyAxNy43MjE3IDg3LjExNTIgMTguNTM2MUM4Ny44MDA4IDE5LjM1MDYgODguMTQzNiAyMC41MTY2IDg4LjE0MzYgMjIuMDM0MlYyMi43MTA5SDgxLjcwMTJDODEuNzI0NiAyMy42NDg0IDgxLjk5NzEgMjQuNDA3MiA4Mi41MTg2IDI0Ljk4NzNDODMuMDQ1OSAyNS41NjE1IDgzLjcxMzkgMjUuODQ4NiA4NC41MjI1IDI1Ljg0ODZDODUuMDk2NyAyNS44NDg2IDg1LjU4MyAyNS43MzE0IDg1Ljk4MTQgMjUuNDk3MUM4Ni4zNzk5IDI1LjI2MjcgODYuNzI4NSAyNC45NTIxIDg3LjAyNzMgMjQuNTY1NEw4OC4wMjA1IDI1LjMzODlDODcuMjIzNiAyNi41NjM1IDg2LjAyODMgMjcuMTc1OCA4NC40MzQ2IDI3LjE3NThaTTg0LjIzMjQgMTguNjUwNEM4My41NzYyIDE4LjY1MDQgODMuMDI1NCAxOC44OTA2IDgyLjU4MDEgMTkuMzcxMUM4Mi4xMzQ4IDE5Ljg0NTcgODEuODU5NCAyMC41MTM3IDgxLjc1MzkgMjEuMzc1SDg2LjUxNzZWMjEuMjUyQzg2LjQ3MDcgMjAuNDI1OCA4Ni4yNDggMTkuNzg3MSA4NS44NDk2IDE5LjMzNTlDODUuNDUxMiAxOC44Nzg5IDg0LjkxMjEgMTguNjUwNCA4NC4yMzI0IDE4LjY1MDRaIiBmaWxsPSJibGFjayIvPgo8cGF0aCBkPSJNMTAxLjk4NiAyMS4wODVIOTYuNDQwNFYyNS42MjAxSDEwMi44ODNWMjdIOTQuNzUyOVYxNC4yMDMxSDEwMi43OTVWMTUuNTkxOEg5Ni40NDA0VjE5LjcwNTFIMTAxLjk4NlYyMS4wODVaIiBmaWxsPSJibGFjayIvPgo8cGF0aCBkPSJNMTA3LjkxOSAyMC45NjE5TDExMC4wMjggMTcuNDkwMkgxMTEuOTI3TDEwOC44MTUgMjIuMTkyNEwxMTIuMDIzIDI3SDExMC4xNDNMMTA3Ljk0NSAyMy40NDA0TDEwNS43NDggMjdIMTAzLjg1OEwxMDcuMDY2IDIyLjE5MjRMMTAzLjk1NSAxNy40OTAySDEwNS44MzZMMTA3LjkxOSAyMC45NjE5WiIgZmlsbD0iYmxhY2siLz4KPHBhdGggZD0iTTEyMS42OTEgMjIuMzUwNkMxMjEuNjkxIDIzLjc5NzkgMTIxLjM2IDI0Ljk2MzkgMTIwLjY5OCAyNS44NDg2QzEyMC4wMzYgMjYuNzMzNCAxMTkuMTQgMjcuMTc1OCAxMTguMDA5IDI3LjE3NThDMTE2Ljg1NCAyNy4xNzU4IDExNS45NDYgMjYuODA5NiAxMTUuMjg0IDI2LjA3NzFWMzAuNjU2MkgxMTMuNjU4VjE3LjQ5MDJIMTE1LjE0NEwxMTUuMjIzIDE4LjU0NDlDMTE1Ljg4NSAxNy43MjQ2IDExNi44MDUgMTcuMzE0NSAxMTcuOTgyIDE3LjMxNDVDMTE5LjEyNSAxNy4zMTQ1IDEyMC4wMjcgMTcuNzQ1MSAxMjAuNjg5IDE4LjYwNjRDMTIxLjM1NyAxOS40Njc4IDEyMS42OTEgMjAuNjY2IDEyMS42OTEgMjIuMjAxMlYyMi4zNTA2Wk0xMjAuMDY1IDIyLjE2NkMxMjAuMDY1IDIxLjA5MzggMTE5LjgzNyAyMC4yNDcxIDExOS4zOCAxOS42MjZDMTE4LjkyMyAxOS4wMDQ5IDExOC4yOTYgMTguNjk0MyAxMTcuNDk5IDE4LjY5NDNDMTE2LjUxNSAxOC42OTQzIDExNS43NzYgMTkuMTMwOSAxMTUuMjg0IDIwLjAwMzlWMjQuNTQ3OUMxMTUuNzcxIDI1LjQxNSAxMTYuNTE1IDI1Ljg0ODYgMTE3LjUxNyAyNS44NDg2QzExOC4yOTYgMjUuODQ4NiAxMTguOTE0IDI1LjU0MSAxMTkuMzcxIDI0LjkyNThDMTE5LjgzNCAyNC4zMDQ3IDEyMC4wNjUgMjMuMzg0OCAxMjAuMDY1IDIyLjE2NloiIGZpbGw9ImJsYWNrIi8+CjxwYXRoIGQ9Ik0xMjMuMzM1IDIyLjE1NzJDMTIzLjMzNSAyMS4yMjU2IDEyMy41MTcgMjAuMzg3NyAxMjMuODggMTkuNjQzNkMxMjQuMjQ5IDE4Ljg5OTQgMTI0Ljc1OSAxOC4zMjUyIDEyNS40MDkgMTcuOTIwOUMxMjYuMDY1IDE3LjUxNjYgMTI2LjgxMiAxNy4zMTQ1IDEyNy42NSAxNy4zMTQ1QzEyOC45NDUgMTcuMzE0NSAxMjkuOTkxIDE3Ljc2MjcgMTMwLjc4OCAxOC42NTkyQzEzMS41OTEgMTkuNTU1NyAxMzEuOTkyIDIwLjc0OCAxMzEuOTkyIDIyLjIzNjNWMjIuMzUwNkMxMzEuOTkyIDIzLjI3NjQgMTMxLjgxMyAyNC4xMDg0IDEzMS40NTYgMjQuODQ2N0MxMzEuMTA0IDI1LjU3OTEgMTMwLjU5OCAyNi4xNTA0IDEyOS45MzYgMjYuNTYwNUMxMjkuMjc5IDI2Ljk3MDcgMTI4LjUyMyAyNy4xNzU4IDEyNy42NjggMjcuMTc1OEMxMjYuMzc5IDI3LjE3NTggMTI1LjMzMyAyNi43Mjc1IDEyNC41MyAyNS44MzExQzEyMy43MzMgMjQuOTM0NiAxMjMuMzM1IDIzLjc0OCAxMjMuMzM1IDIyLjI3MTVWMjIuMTU3MlpNMTI0Ljk3IDIyLjM1MDZDMTI0Ljk3IDIzLjQwNTMgMTI1LjIxMyAyNC4yNTIgMTI1LjY5OSAyNC44OTA2QzEyNi4xOTEgMjUuNTI5MyAxMjYuODQ4IDI1Ljg0ODYgMTI3LjY2OCAyNS44NDg2QzEyOC40OTQgMjUuODQ4NiAxMjkuMTUgMjUuNTI2NCAxMjkuNjM3IDI0Ljg4MThDMTMwLjEyMyAyNC4yMzE0IDEzMC4zNjYgMjMuMzIzMiAxMzAuMzY2IDIyLjE1NzJDMTMwLjM2NiAyMS4xMTQzIDEzMC4xMTcgMjAuMjcwNSAxMjkuNjE5IDE5LjYyNkMxMjkuMTI3IDE4Ljk3NTYgMTI4LjQ3MSAxOC42NTA0IDEyNy42NSAxOC42NTA0QzEyNi44NDggMTguNjUwNCAxMjYuMiAxOC45Njk3IDEyNS43MDggMTkuNjA4NEMxMjUuMjE2IDIwLjI0NzEgMTI0Ljk3IDIxLjE2MTEgMTI0Ljk3IDIyLjM1MDZaIiBmaWxsPSJibGFjayIvPgo8cGF0aCBkPSJNMTM4LjYyOCAxOC45NDkyQzEzOC4zODIgMTguOTA4MiAxMzguMTE1IDE4Ljg4NzcgMTM3LjgyOCAxOC44ODc3QzEzNi43NjIgMTguODg3NyAxMzYuMDM4IDE5LjM0MTggMTM1LjY1NyAyMC4yNVYyN0gxMzQuMDMxVjE3LjQ5MDJIMTM1LjYxM0wxMzUuNjQgMTguNTg4OUMxMzYuMTczIDE3LjczOTMgMTM2LjkyOSAxNy4zMTQ1IDEzNy45MDcgMTcuMzE0NUMxMzguMjI0IDE3LjMxNDUgMTM4LjQ2NCAxNy4zNTU1IDEzOC42MjggMTcuNDM3NVYxOC45NDkyWiIgZmlsbD0iYmxhY2siLz4KPHBhdGggZD0iTTE0Mi43NzYgMTUuMTg3NVYxNy40OTAySDE0NC41NTJWMTguNzQ3MUgxNDIuNzc2VjI0LjY0NDVDMTQyLjc3NiAyNS4wMjU0IDE0Mi44NTUgMjUuMzEyNSAxNDMuMDE0IDI1LjUwNTlDMTQzLjE3MiAyNS42OTM0IDE0My40NDEgMjUuNzg3MSAxNDMuODIyIDI1Ljc4NzFDMTQ0LjAxIDI1Ljc4NzEgMTQ0LjI2OCAyNS43NTIgMTQ0LjU5NiAyNS42ODE2VjI3QzE0NC4xNjggMjcuMTE3MiAxNDMuNzUyIDI3LjE3NTggMTQzLjM0OCAyNy4xNzU4QzE0Mi42MjEgMjcuMTc1OCAxNDIuMDczIDI2Ljk1NjEgMTQxLjcwNCAyNi41MTY2QzE0MS4zMzUgMjYuMDc3MSAxNDEuMTUgMjUuNDUzMSAxNDEuMTUgMjQuNjQ0NVYxOC43NDcxSDEzOS40MTlWMTcuNDkwMkgxNDEuMTVWMTUuMTg3NUgxNDIuNzc2WiIgZmlsbD0iYmxhY2siLz4KPHBhdGggZD0iTTE1MC40MDUgMjcuMTc1OEMxNDkuMTE2IDI3LjE3NTggMTQ4LjA2NyAyNi43NTM5IDE0Ny4yNTkgMjUuOTEwMkMxNDYuNDUgMjUuMDYwNSAxNDYuMDQ2IDIzLjkyNjggMTQ2LjA0NiAyMi41MDg4VjIyLjIxQzE0Ni4wNDYgMjEuMjY2NiAxNDYuMjI1IDIwLjQyNTggMTQ2LjU4MiAxOS42ODc1QzE0Ni45NDUgMTguOTQzNCAxNDcuNDQ5IDE4LjM2MzMgMTQ4LjA5NCAxNy45NDczQzE0OC43NDQgMTcuNTI1NCAxNDkuNDQ3IDE3LjMxNDUgMTUwLjIwMyAxNy4zMTQ1QzE1MS40MzkgMTcuMzE0NSAxNTIuNCAxNy43MjE3IDE1My4wODYgMTguNTM2MUMxNTMuNzcxIDE5LjM1MDYgMTU0LjExNCAyMC41MTY2IDE1NC4xMTQgMjIuMDM0MlYyMi43MTA5SDE0Ny42NzJDMTQ3LjY5NSAyMy42NDg0IDE0Ny45NjggMjQuNDA3MiAxNDguNDg5IDI0Ljk4NzNDMTQ5LjAxNyAyNS41NjE1IDE0OS42ODUgMjUuODQ4NiAxNTAuNDkzIDI1Ljg0ODZDMTUxLjA2NyAyNS44NDg2IDE1MS41NTQgMjUuNzMxNCAxNTEuOTUyIDI1LjQ5NzFDMTUyLjM1MSAyNS4yNjI3IDE1Mi42OTkgMjQuOTUyMSAxNTIuOTk4IDI0LjU2NTRMMTUzLjk5MSAyNS4zMzg5QzE1My4xOTQgMjYuNTYzNSAxNTEuOTk5IDI3LjE3NTggMTUwLjQwNSAyNy4xNzU4Wk0xNTAuMjAzIDE4LjY1MDRDMTQ5LjU0NyAxOC42NTA0IDE0OC45OTYgMTguODkwNiAxNDguNTUxIDE5LjM3MTFDMTQ4LjEwNSAxOS44NDU3IDE0Ny44MyAyMC41MTM3IDE0Ny43MjUgMjEuMzc1SDE1Mi40ODhWMjEuMjUyQzE1Mi40NDEgMjAuNDI1OCAxNTIuMjE5IDE5Ljc4NzEgMTUxLjgyIDE5LjMzNTlDMTUxLjQyMiAxOC44Nzg5IDE1MC44ODMgMTguNjUwNCAxNTAuMjAzIDE4LjY1MDRaIiBmaWxsPSJibGFjayIvPgo8cGF0aCBkPSJNMTYwLjYwMSAxOC45NDkyQzE2MC4zNTQgMTguOTA4MiAxNjAuMDg4IDE4Ljg4NzcgMTU5LjgwMSAxOC44ODc3QzE1OC43MzQgMTguODg3NyAxNTguMDExIDE5LjM0MTggMTU3LjYzIDIwLjI1VjI3SDE1Ni4wMDRWMTcuNDkwMkgxNTcuNTg2TDE1Ny42MTIgMTguNTg4OUMxNTguMTQ2IDE3LjczOTMgMTU4LjkwMSAxNy4zMTQ1IDE1OS44OCAxNy4zMTQ1QzE2MC4xOTYgMTcuMzE0NSAxNjAuNDM3IDE3LjM1NTUgMTYwLjYwMSAxNy40Mzc1VjE4Ljk0OTJaIiBmaWxsPSJibGFjayIvPgo8L3N2Zz4K"
  formSpec:
    - displayName: Replicas
      internalName: replicas
      required: true
      type: number
    - displayName: Description
      internalName: desc
      required: false
      type: text
    - displayName: Debug
      internalName: debug
      required: false
      type: boolean
    - displayName: Spec
      internalName: spec
      required: false
      type: text-area
```

After applying above config the UI should look like below:

![Form](/img/kubermatic/v2.13/advanced/addons/form.png)

### How to Add a Custom Addon?

1. All manifests and config files for the default addons are stored in the `quay.io/kubermatic/addons` image. Use this image as a base image and copy configs and manifests for all custom addons to `/addons` folder.

    Custom addon with manifest

   ```plaintext
   .
   ├── Dockerfile
   └── foo
       └── deployment.yaml
   ```

    Dockerfile for custom addons:

   ```dockerfile
   FROM quay.io/kubermatic/addons:v0.0.1

   ADD ./ /addons/
   ```

    Release the image with custom addon

   ```bash
   export TAG=v1.0
   docker build -t customer/addons:${TAG} .
   docker push customer/addons:${TAG}
   ```

1. Edit `values.yaml` you are using for the installation of Kubermatic. Change the path to the addons repository

   ```yaml
   kubermatic:
     controller:
       addons:
         kubernetes:
           image:
             repository: "quay.io/customer/addons" # <-- add your repo here
   ```

1. Add your addon to the list of default addons in `values.yaml`:

   ```yaml
   kubermatic:
     controller:
       addons:
         kubernetes:
           # list of addons to install into every user-cluster. All need to exist in the addons image
           defaultAddons:
           - foo # <-- add your addon here
           - canal
           - dashboard
           - dns
           - kube-proxy
           - openvpn
           - rbac
   ```

1. Update the installation of Kubermatic

   ```bash
   helm upgrade --install --wait --timeout 300 --values values.yaml --namespace kubermatic kubermatic charts/kubermatic
   ```

#### Template Variables

All cluster object variables can be used in all addon manifests. Specific template variables and functions used in default templates:

* `{{first .Cluster.Spec.ClusterNetwork.Pods.CIDRBlocks}}`: will render an IP block of the cluster
* `{{.DNSClusterIP}}`: will render the IP address of the DNS server
* `image: {{ Registry quay.io }}/some-org/some-app:v1.0`: Will use quay.io as registry or the overwrite registry if specified
