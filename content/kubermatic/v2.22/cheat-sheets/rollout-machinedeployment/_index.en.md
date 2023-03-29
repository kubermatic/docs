+++
title = "Rolling Restart MachineDeploments"
date = 2021-06-07T15:00:00+02:00
description = "Rolling restart machine deployments for KKP 2.22: Learn about the concept and keep it handy"
weight = 25
+++

## To Rolling Restart a Single MachineDeployment

```shell
forceRestartAnnotations="{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"forceRestart\":\"$(date +%s)\"}}}}}"
kubectl patch machinedeployment -n kube-system <NAME> --type=merge -p $forceRestartAnnotations 
```

## To Rolling Restart all MachineDeployments

```shell
forceRestartAnnotations="{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"forceRestart\":\"$(date +%s)\"}}}}}"
for md in $(kubectl get machinedeployments -n kube-system --no-headers | awk '{print $1}'); do
  kubectl patch machinedeployment -n kube-system $md --type=merge -p $forceRestartAnnotations
done
```
