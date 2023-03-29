+++
title = "Rolling Restart MachineDeploments"
date = 2022-08-20T12:00:00+02:00
description = "Rolling restart machine deployments for Operating System Manager (OSM): Learn about the concept and keep it handy"
weight = 25
+++

## To rolling restart a single machineDeployment

```shell
forceRestartAnnotations="{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"forceRestart\":\"$(date +%s)\"}}}}}"
kubectl patch machinedeployment -n kube-system <NAME> --type=merge -p $forceRestartAnnotations
```

## To rolling restart all machineDeployments

```shell
forceRestartAnnotations="{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"forceRestart\":\"$(date +%s)\"}}}}}"
for md in $(kubectl get machinedeployments -n kube-system --no-headers | awk '{print $1}'); do
  kubectl patch machinedeployment -n kube-system $md --type=merge -p $forceRestartAnnotations
done
```
