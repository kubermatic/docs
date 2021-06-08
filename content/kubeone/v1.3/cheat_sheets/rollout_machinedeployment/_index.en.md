+++
title = "Rolling Restart MachineDeploments"
date = 2021-06-07T15:00:00+02:00
weight = 25
+++

## To rolling restart a single machineDeploment

```shell
forceRestartAnnotations="{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"forceRestart\":\"$(date +%N)\"}}}}}"
kubectl patch machinedeployment <NAME> --type=merge -p $forceRestartAnnotations 
```

## To rolling restart all machineDeploments

```shell
forceRestartAnnotations="{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"forceRestart\":\"$(date +%N)\"}}}}}"
for md in $(kubectl get machinedeployments --no-headers | awk '{print $1}'); do
  kubectl patch machinedeployment $md --type=merge -p $forceRestartAnnotations
done
```
