+++
title = "Validate Cluster and KKP Readiness"
weight = 20
+++

### Check cluster nodes health
```bash
kubectl get nodes
```
Should provide an output like:
```text
NAME                                             STATUS   ROLES                  AGE     VERSION
ip-172-31-94-139.eu-central-1.compute.internal   Ready    control-plane,master   2d10h   v1.21.3
ip-172-31-94-250.eu-central-1.compute.internal   Ready    <none>                 2d10h   v1.21.3
ip-172-31-95-121.eu-central-1.compute.internal   Ready    <none>                 2d10h   v1.21.3
ip-172-31-95-122.eu-central-1.compute.internal   Ready    control-plane,master   2d10h   v1.21.3
ip-172-31-96-137.eu-central-1.compute.internal   Ready    control-plane,master   2d10h   v1.21.3
ip-172-31-96-184.eu-central-1.compute.internal   Ready    <none>                 2d10h   v1.21.3
```

### Check Pod resources are healthy
```bash
kubectl get pod -A
```

If there are any pods in Pending state - check if the reason is insufficient resources and scale the MachineDeployment resources accordingly.

{{% notice info %}}
You can scale MachineDeployment resource(s) with following command: `kubectl scale machinedeployment -n kube-system <md-name> --replicas=2`.
{{% /notice %}}

If there are some failing pods, investigate the specific logs.

### Check Flux kustomizations are applied

```bash
kubectl get kustomizations.kustomize.toolkit.fluxcd.io -A
```
Should provide an output like:
```text
NAMESPACE     NAME                 READY   STATUS                                                            AGE
flux-system   flux-system          True    Applied revision: main/1d6cdc2b442c11c30ee005430b25b27f668ed5f9   2d9h
kubermatic    sops-kustomization   True    Applied revision: main/1d6cdc2b442c11c30ee005430b25b27f668ed5f9   2d9h
```

### Check Helm Releases managed by Flux are reconciled

```bash
kubectl get helmreleases.helm.toolkit.fluxcd.io -A
```
Should provide an output like:
```text
NAMESPACE     NAME                 READY   STATUS                                                                                                                                                               AGE
iap           iap                  True    Release reconciliation succeeded                                                                                                                                            2d9h
kube-system   s3-exporter          True    Release reconciliation succeeded                                                                                                                                     2d9h
minio         minio                True    Release reconciliation succeeded                                                                                                                                            41h
monitoring    alertmanager         True    Release reconciliation succeeded                                                                                                                                     2d9h
monitoring    blackbox-exporter    True    Release reconciliation succeeded                                                                                                                                     2d9h
monitoring    grafana              True    Release reconciliation succeeded                                                                                                                                     2d9h
monitoring    karma                True    Release reconciliation succeeded                                                                                                                                     2d9h
monitoring    kube-state-metrics   True    Release reconciliation succeeded                                                                                                                                     2d9h
monitoring    node-exporter        True    Release reconciliation succeeded                                                                                                                                     2d9h
monitoring    prometheus           True    Release reconciliation succeeded
```
