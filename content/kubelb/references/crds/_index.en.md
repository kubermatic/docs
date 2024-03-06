+++
title = "Kubermatic CRDs Reference"
date = 2021-12-02T00:00:00
weight = 40
searchExclude = true
+++

## Packages
- [kubelb.k8c.io/v1alpha1](#kubelbk8ciov1alpha1)


## kubelb.k8c.io/v1alpha1


Package v1alpha1 contains API Schema definitions for the kubelb.k8c.io v1alpha1 API group

### Resource Types
- [Config](#config)
- [ConfigList](#configlist)
- [LoadBalancer](#loadbalancer)
- [LoadBalancerList](#loadbalancerlist)



### Config



Config is the object that represents the Config for the KubeLB management controller.

_Appears in:_
- [ConfigList](#configlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubelb.k8c.io/v1alpha1`
| `kind` _string_ | `Config`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ConfigSpec](#configspec)_ |  |


[Back to top](#top)



### ConfigList



ConfigList contains a list of Config



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubelb.k8c.io/v1alpha1`
| `kind` _string_ | `ConfigList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Config](#config) array_ |  |


[Back to top](#top)



### ConfigSpec



ConfigSpec defines the desired state of the Config

_Appears in:_
- [Config](#config)

| Field | Description |
| --- | --- |
| `envoyProxy` _[EnvoyProxy](#envoyproxy)_ | EnvoyProxy defines the desired state of the Envoy Proxy |
| `propagatedAnnotations` _object (keys:string, values:string)_ | PropagatedAnnotations defines the list of annotations(key-value pairs) that will be propagated to the LoadBalancer service. Keep the value empty to allow any value. Annotations specified at the namespace level will have a higher precedence than the annotations specified at the Config level. |
| `propagateAllAnnotations` _boolean_ | PropagateAllAnnotations defines whether all annotations will be propagated to the LoadBalancer service. If set to true, PropagatedAnnotations will be ignored. |


[Back to top](#top)



### EndpointAddress



EndpointAddress is a tuple that describes single IP address.

_Appears in:_
- [LoadBalancerEndpoints](#loadbalancerendpoints)

| Field | Description |
| --- | --- |
| `ip` _string_ | The IP of this endpoint. May not be loopback (127.0.0.0/8), link-local (169.254.0.0/16), or link-local multicast ((224.0.0.0/24). |
| `hostname` _string_ | The Hostname of this endpoint |


[Back to top](#top)



### EndpointPort



EndpointPort is a tuple that describes a single port.

_Appears in:_
- [LoadBalancerEndpoints](#loadbalancerendpoints)

| Field | Description |
| --- | --- |
| `name` _string_ | The name of this port.  This must match the 'name' field in the corresponding ServicePort. Must be a DNS_LABEL. Optional only if one port is defined. |
| `port` _integer_ | The port number of the endpoint. |
| `protocol` _[Protocol](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#protocol-v1-core)_ | The IP protocol for this port. Must be TCP. Default is TCP. |


[Back to top](#top)



### EnvoyProxy



EnvoyProxy defines the desired state of the EnvoyProxy

_Appears in:_
- [ConfigSpec](#configspec)

| Field | Description |
| --- | --- |
| `topology` _EnvoyProxyTopology_ | Topology defines the deployment topology for Envoy Proxy. Valid values are: shared, dedicated, and global. |
| `useDaemonset` _boolean_ | UseDaemonset defines whether Envoy Proxy will run as daemonset. By default, Envoy Proxy will run as deployment. If set to true, Replicas will be ignored. |
| `replicas` _integer_ | Replicas defines the number of replicas for Envoy Proxy. This field is ignored if UseDaemonset is set to true. |
| `singlePodPerNode` _boolean_ | SinglePodPerNode defines whether Envoy Proxy pods will be spread across nodes. This ensures that multiple replicas are not running on the same node. |
| `nodeSelector` _object (keys:string, values:string)_ | NodeSelector is used to select nodes to run Envoy Proxy. If specified, the node must have all the indicated labels. |
| `tolerations` _[Toleration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#toleration-v1-core) array_ | Tolerations is used to schedule Envoy Proxy pods on nodes with matching taints. |
| `affinity` _[Affinity](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#affinity-v1-core)_ | Affinity is used to schedule Envoy Proxy pods on nodes with matching affinity. |


[Back to top](#top)



### LoadBalancer



LoadBalancer is the Schema for the loadbalancers API

_Appears in:_
- [LoadBalancerList](#loadbalancerlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubelb.k8c.io/v1alpha1`
| `kind` _string_ | `LoadBalancer`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[LoadBalancerSpec](#loadbalancerspec)_ |  |
| `status` _[LoadBalancerStatus](#loadbalancerstatus)_ |  |


[Back to top](#top)



### LoadBalancerEndpoints



LoadBalancerEndpoints is a group of addresses with a common set of ports. The expanded set of endpoints is the Cartesian product of Addresses x Ports. For example, given: 
 	{ 	  Addresses: [{"ip": "10.10.1.1"}, {"ip": "10.10.2.2"}], 	  Ports:     [{"name": "a", "port": 8675}, {"name": "b", "port": 309}] 	} 
 The resulting set of endpoints can be viewed as: 
 	a: [ 10.10.1.1:8675, 10.10.2.2:8675 ], 	b: [ 10.10.1.1:309, 10.10.2.2:309 ]

_Appears in:_
- [LoadBalancerSpec](#loadbalancerspec)

| Field | Description |
| --- | --- |
| `addresses` _[EndpointAddress](#endpointaddress) array_ | IP addresses which offer the related ports that are marked as ready. These endpoints should be considered safe for load balancers and clients to utilize. |
| `ports` _[EndpointPort](#endpointport) array_ | Port numbers available on the related IP addresses. |


[Back to top](#top)



### LoadBalancerList



LoadBalancerList contains a list of LoadBalancer



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubelb.k8c.io/v1alpha1`
| `kind` _string_ | `LoadBalancerList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[LoadBalancer](#loadbalancer) array_ |  |


[Back to top](#top)



### LoadBalancerPort



LoadBalancerPort contains information on service's port.

_Appears in:_
- [LoadBalancerSpec](#loadbalancerspec)

| Field | Description |
| --- | --- |
| `name` _string_ | The name of this port within the service. This must be a DNS_LABEL. All ports within a Spec must have unique names. When considering the endpoints for a Service, this must match the 'name' field in the EndpointPort. Optional if only one ServicePort is defined on this service. |
| `protocol` _[Protocol](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#protocol-v1-core)_ | The IP protocol for this port. Supports "TCP". Default is TCP. |
| `port` _integer_ | The port that will be exposed by the LoadBalancer. |


[Back to top](#top)



### LoadBalancerSpec



LoadBalancerSpec defines the desired state of LoadBalancer

_Appears in:_
- [LoadBalancer](#loadbalancer)

| Field | Description |
| --- | --- |
| `endpoints` _[LoadBalancerEndpoints](#loadbalancerendpoints) array_ | Sets of addresses and ports that comprise an exposed user service on a cluster. |
| `ports` _[LoadBalancerPort](#loadbalancerport) array_ | The list of ports that are exposed by the load balancer service. only needed for layer 4 |
| `type` _[ServiceType](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#servicetype-v1-core)_ | type determines how the Service is exposed. Defaults to ClusterIP. Valid options are ExternalName, ClusterIP, NodePort, and LoadBalancer. "ExternalName" maps to the specified externalName. "ClusterIP" allocates a cluster-internal IP address for load-balancing to endpoints. Endpoints are determined by the selector or if that is not specified, by manual construction of an Endpoints object. If clusterIP is "None", no virtual IP is allocated and the endpoints are published as a set of endpoints rather than a stable IP. "NodePort" builds on ClusterIP and allocates a port on every node which routes to the clusterIP. "LoadBalancer" builds on NodePort and creates an external load-balancer (if supported in the current cloud) which routes to the clusterIP. More info: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types |


[Back to top](#top)



### LoadBalancerStatus



LoadBalancerStatus defines the observed state of LoadBalancer

_Appears in:_
- [LoadBalancer](#loadbalancer)

| Field | Description |
| --- | --- |
| `loadBalancer` _[LoadBalancerStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#loadbalancerstatus-v1-core)_ | LoadBalancer contains the current status of the load-balancer, if one is present. |
| `service` _[ServiceStatus](#servicestatus)_ | Service contains the current status of the LB service. |


[Back to top](#top)



### ServicePort



ServicePort contains information on service's port.

_Appears in:_
- [ServiceStatus](#servicestatus)

| Field | Description |
| --- | --- |
| `ServicePort` _[ServicePort](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#serviceport-v1-core)_ |  |
| `upstreamTargetPort` _integer_ |  |


[Back to top](#top)



### ServiceStatus





_Appears in:_
- [LoadBalancerStatus](#loadbalancerstatus)

| Field | Description |
| --- | --- |
| `ports` _[ServicePort](#serviceport) array_ |  |


[Back to top](#top)



