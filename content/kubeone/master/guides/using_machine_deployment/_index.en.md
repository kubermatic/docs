+++
title = "Using Machine Deployments"
date = 2021-04-05T12:00:00+02:00
enableToc = true
+++

Kubeone internally delegates worker node creation and management to kubermatic [machine-controller](https://github.com/kubermatic/machine-controller). machine-controller behavior can be controlled via `MachineDeployment` CRD. 

One way to specify values for this CRD is in terraform output.tf. Other options is to use a yaml file definition to provide `MachineDeployment` CRD values. MachineDeployment CRD is part of Cluster API - which is a spec from Kubernetes project itself. Go spec for this CRD can be found [here](https://pkg.go.dev/github.com/kubermatic/machine-controller@v1.27.4/pkg/apis/cluster/v1alpha1#MachineDeploymentSpec).

Some examples of possible machine deployment yamls can be found in Machine-controller [examples directory](https://github.com/kubermatic/machine-controller/tree/master/examples)

If you want to use yaml approach to provide machine-controller deployment, then do not define `kubeone_workers` object in output.tf of terraform. Instead, provide the values via machines.yaml file as below.

```shell
# Create a machines.yaml with MachineDeployment resource definition
# Apply this file directly using kubectl
kubectl apply -f machines.yaml
```
