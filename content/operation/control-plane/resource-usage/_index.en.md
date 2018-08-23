+++
title = "Example usage"
date = 2018-04-28T12:07:15+02:00
weight = 10
pre = "<b></b>"
+++

Based on the number of Pods & Nodes in a cluster, the resource usage differs.
Below some values we identified by testing with the [clusterloader](https://github.com/kubernetes/perf-tests/tree/master/clusterloader2) tool.  

## Storage

As each user cluster contains an etcd StatefulSet with 3 pods, it requires 3 5GB volumes.   
5GB might be for some scenarios too big, therefore the size can be configured cluster-wide via the values.yaml.

## CPU & Memory

### Medium HA Cluster

#### Specs
- 3 API Servers
- 100 Nodes
- 500 Pods

Resource usage:
```bash
NAME                                  CPU(cores)   MEMORY(bytes)   
apiserver-88967d5c9-9chfn             513m         783Mi           
apiserver-88967d5c9-cqq6z             257m         662Mi           
apiserver-88967d5c9-xj2h2             446m         639Mi           
controller-manager-7f86977967-cmdj9   75m          143Mi           
dns-resolver-b88b48ddc-lsbxp          1m           7Mi             
dns-resolver-b88b48ddc-zjgvl          1m           7Mi             
etcd-0                                63m          285Mi           
etcd-1                                86m          331Mi           
etcd-2                                72m          351Mi           
kube-state-metrics-6bc577c974-9927q   18m          47Mi            
machine-controller-7678c8668b-n5fzz   28m          25Mi            
openvpn-server-b967fd79-26vqv         1m           3Mi             
prometheus-0                          17m          238Mi           
scheduler-85c7699468-mmqrq            14m          71Mi            
```

#### Total
- Memory: `~3590Mi`
- CPU: `~1592m`

### Small Cluster

#### Specs
- 1 API Servers
- 10 Nodes
- 100 Pods

Resource usage:
```bash
NAME                                  CPU(cores)   MEMORY(bytes)   
apiserver-57b447b75f-gvz5s            150m         518Mi           
controller-manager-5cd975b49-qsqvs    29m          85Mi            
dns-resolver-58cb9fdcb5-4tzw6         1m           7Mi             
dns-resolver-58cb9fdcb5-zm4wq         1m           7Mi             
etcd-0                                20m          48Mi            
etcd-1                                23m          51Mi            
etcd-2                                41m          76Mi            
kube-state-metrics-7cc464c7d8-7tbrl   2m           19Mi            
machine-controller-d89b4f87f-mxbx2    5m           17Mi            
openvpn-server-5979c74b64-msrzx       1m           2Mi             
prometheus-0                          6m           118Mi           
scheduler-76b5f555fc-qwswn            8m           37Mi            
```
#### Total
- Memory: `~985Mi`
- CPU: `~287m`
