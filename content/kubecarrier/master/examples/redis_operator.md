---
title: Manage Redis Service via KubeCarrier
weight: 10
slug: redis_operator
date: 2020-02-24T09:00:00+03:00
enableToc: true
---
This example will show you how to manage [Redis](https://redis.io/) service cross cluster via KubeCarrier.

## Prerequisites
### Management Cluster
In this example, you will need a [**KubeCarrier Management Cluster**]({{< relref "../architecture/concepts#management-cluster" >}})
where KubeCarrier will be installed.   
For setting up KubeCarrier Management Cluster, please refer to
[KubeCarrier Requirements]({{< relref "../tutorials_howtos/requirements" >}}) 
and [KubeCarrier Installation]({{< relref "../tutorials_howtos/installation" >}}) for more details.

### Accounts
In this example, we will create two `Account` objects, one is `Provider`(service provider), who will provide Redis service
via KubeCarrier, and another one is `Tenant`(service consumer), who will create Redis instance and consume Redis service.  
You can do:

>Management Cluster
```bash
$ kubectl apply \
  -f https://raw.githubusercontent.com/kubermatic/kubecarrier/master/docs/manifests/accounts.yaml
```

This will create two `Account` objects for you: `team-a`(Provider), and `team-b`(Tenant).
Please refer to [Accounts Usage]({{< relref "../tutorials_howtos/api_usage/accounts" >}}) for more details.

### Service Cluster
To provide Redis service, a [**Service Cluster**]({{< relref "../architecture/concepts#service-clusters" >}}) 
needs to be created and registered to KubeCarrier by the service provider.
  
For setting up a Service Cluster, please refer to [Setting up A Service Cluster]({{< relref "../tutorials_howtos/api_usage/service_clusters" >}})
for more details.

### Catalog
To select which services to offer to which tenants, a `Catalog` object needs to be created:

>Management Cluster
```bash
$ kubectl apply -n team-a \
  -f https://raw.githubusercontent.com/kubermatic/kubecarrier/master/docs/manifests/catalog.yaml
```

This will create a `Catalog` object which selects all `CatalogEntries` and offers them to all `Tenants`.
Please refer to [Catalog Usage]({{< relref "../tutorials_howtos/api_usage/catalogs" >}}) for more details.

## Redis Operator
We will use [Redis Operator from Opstree Solutions](https://github.com/OT-CONTAINER-KIT/redis-operator) in this example.
For installing it in the Service Cluster, you will need to clone the repository, and do:

>Service Cluster
```bash
$ helm upgrade --create-namespace redis-operator ./helm-charts/redis-operator --install --namespace redis-operator
```

Alternatively, you can save the following manifests to a `redis-operator.yaml` file:

```yaml
---
# Source: redis-operator/templates/service-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: redis-operator
  labels:
    control-plane: "redis-operator"
    app.kubernetes.io/name: redis-operator
    helm.sh/chart: redis-operator-0.4.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: redis-operator
    app.kubernetes.io/version: 0.4.0
---
# Source: redis-operator/templates/role-binding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: redis-operator
  labels:
    control-plane: "redis-operator"
    app.kubernetes.io/name: redis-operator
    helm.sh/chart: redis-operator-0.4.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: redis-operator
    app.kubernetes.io/version: 0.4.0
subjects:
- kind: ServiceAccount
  name: redis-operator
  namespace: redis-operator
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
---
# Source: redis-operator/templates/operator-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-operator
  labels:
    control-plane: "redis-operator"
    app.kubernetes.io/name: redis-operator
    helm.sh/chart: redis-operator-0.4.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: redis-operator
    app.kubernetes.io/version: 0.4.0
spec:
  replicas: 1
  selector:
    matchLabels:
      name: redis-operator
  template:
    metadata:
      labels:
        name: redis-operator
    spec:
      containers:
      - name: "redis-operator"
        image: "quay.io/opstree/redis-operator:v0.4.0"
        imagePullPolicy: Always
        command:
        - /manager
        args:
        - --leader-elect
        resources:
          limits:
            cpu: 100m
            memory: 100Mi
          requests:
            cpu: 100m
            memory: 100Mi
      serviceAccountName: "redis-operator"
      serviceAccount: "redis-operator"
```

Then you can use the following commands to install it:

>Service Cluster
```bash
$ kubectl create namespace redis-operator
$ kubectl apply -f https://raw.githubusercontent.com/OT-CONTAINER-KIT/redis-operator/v0.4.0/helm-charts/redis-operator/crds/crd-redis.yaml
$ kubectl apply -n redis-operator -f redis-operator.yaml
```

You should see the Redis operator deployment is up and running in a few seconds:

>Service Cluster
```bash
$ kubectl get -n redis-operator deployments
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
redis-operator   1/1     1            1           1m
```

## CatalogEntrySet
When the Redis operator is up and running, we can register the Redis CRD into KubeCarrier Management Cluster so that `team-b`
can consume this Redis service.

The only thing that you need to do is to create a `CatalogEntrySet` object with the following content in Management Cluster:

```yaml
apiVersion: catalog.kubecarrier.io/v1alpha1
kind: CatalogEntrySet
metadata:
  name: redis
spec:
  metadata:
    displayName: Redis
    description: The redis database
    shortDescription: The redis database
  discover:
    webhookStrategy: None
    crd:
      name:  redis.redis.redis.opstreelabs.in
    serviceClusterSelector: {}
  derive:
    expose:
    - versions:
      - v1beta1
      fields:
      - jsonPath: .spec.global.password
      - jsonPath: .spec.global.image
      - jsonPath: .spec.mode
      - jsonPath: .spec.size
      - jsonPath: .spec.redisExporter.enabled
      - jsonPath: .spec.redisExporter.image
      - jsonPath: .spec.service.type
      - jsonPath: .spec.redisConfig
```

In the `spec.discover.crd.name`, we specify the name of Redis CRD in the Service Cluster, and KubeCarrier will try to
search in the Service Clusters which are subject to the `serviceClusterSelector`, and register the CRDs with the name
`redis.redis.redis.opstreelabs.in` in the Management Cluster.  

Also, from a service provider perspective, you can define which version of CRD, and which fields of the CRD you would
like to make available for users. Please refer to [Catalog Entries]({{< relref "../tutorials_howtos/api_usage/catalogs#catalog-entries" >}})
and [CatalogEntrySet API]({{< relref "../references/api-reference/#catalogentrysetcatalogkubecarrieriov1alpha1" >}})
for more details.

Let's save the above `CatalogEntrySet` in a `redis-catalogentryset.yaml` file and create it for `team-a`:

>Management Cluster
```bash
$ kubectl apply -n team-a -f redis-catalogentryset.yaml --as=team-a-member
```

Two new CRDs will be added to the Management Cluster.

>Management Cluster
```bash
$ kubectl get crds | grep redis
redis.eu-west-1.team-a                          2021-02-24T10:05:41Z
redis.internal.eu-west-1.team-a                 2021-02-24T10:05:28Z
```

`redis.eu-west-1.team-a` is a “slimmed-down” version of `redis.redis.redis.opstreelabs.in` CRD from Service Cluster, only containing fields specified
in the CatalogEntrySet, and `redis.internal.eu-west-1.team-a` is a copy of `redis.redis.redis.opstreelabs.in` CRD.

## Redis Service
Now, we can create a Redis instance for `team-b`, let's check the available service `Offerings` for `team-b`:

```bash
$ kubectl get offerings -n team-b --as=team-b-member
NAME                     DISPLAY NAME   PROVIDER   AGE
redis.eu-west-1.team-a   Redis          team-a     13s
```

Then we can create a `Redis` instance with the following content as a `team-b` member:

```yaml
apiVersion: eu-west-1.team-a/v1beta1
kind: Redis
metadata:
  name: redisinstance
spec:
  global:
    password: "1234"
    image: opstree/redis:v2.0
  mode: "standalone"
  redisExporter:
    enabled: false
    image: quay.io/opstree/redis-exporter:1.0
  size: 3
  redisConfig: {}
  service:
    type: ClusterIP
```

Let's save the above `Redis` instance in a `redis.yaml` file and create it as a `team-b` member:

>Management Cluster
```bash
kubectl apply -n team-b --as=team-b-member -f redis.yaml
```

After this `Redis` custom resource is created, a Redis instance will be provisioned for `team-b` in the Service cluster.

There will be a `namespace` in Service Cluster, which is created by KubeCarrier for `team-b`, we can get the name of the 
`namespace` by looking into the `ServiceClusterAssignment` object:

>Management Cluster
```bash
$ kubectl get -n team-a serviceclusterassignments team-b.eu-west-1 -o json | jq .status.serviceClusterNamespace.name
"team-b-wqpd2"
```

Then you can see the Pod of Redis instance is running in that `namespace`:

>Service Cluster
```bash
$ kubectl get -n team-b-wqpd2 pods
NAME                         READY   STATUS    RESTARTS   AGE
redisinstance-standalone-0   1/1     Running   0          22m
```

## Register Another Service Cluster
If `team-a` would like to provide Redis service from another Service Cluster, `team-a` can just register a
Service Cluster with Redis operator installed, and the `Redis` service from the new Service Cluster will be 
discovered automatically by KubeCarrier.

Please follow [Setting up A Service Cluster]({{< relref "../tutorials_howtos/api_usage/service_clusters" >}}) and
[Redis Operator](#redis-operator) to prepare another Service Cluster (we can name it as `eu-west-2`) with Redis operator installed.

After you register the new Service Cluster to KubeCarrier, you will see two more CRDs in the Management Cluster in few seconds:

>Management Cluster
```bash
$ kubectl get crds | grep redis
redis.eu-west-1.team-a                          2021-02-25T09:07:58Z
redis.eu-west-2.team-a                          2021-02-25T09:15:41Z
redis.internal.eu-west-1.team-a                 2021-02-25T09:07:33Z
redis.internal.eu-west-2.team-a                 2021-02-25T09:15:26Z
```

Also, there will be one more available service `Offering` for `team-b`:

```bash
$ kubectl get offerings -n team-b --as=team-b-member
NAME                     DISPLAY NAME   PROVIDER   AGE
redis.eu-west-1.team-a   Redis          team-a     13s
redis.eu-west-2.team-a   Redis          team-a     13s
```

Now `team-b` can provision Redis instance from `eu-west-2` Service Cluster:

```yaml
apiVersion: eu-west-2.team-a/v1beta1
kind: Redis
metadata:
  name: redisinstance
spec:
  global:
    password: "1234"
    image: opstree/redis:v2.0
  mode: "standalone"
  redisExporter:
    enabled: false
    image: quay.io/opstree/redis-exporter:1.0
  size: 3
  redisConfig: {}
  service:
    type: ClusterIP
```

Save the above `Redis` object in a `redis-eu-west-2.yaml` file, and create it in the Management Cluster as a `team-b` member:

>Management Cluster
```bash
$ kubectl apply -n team-b --as=team-b-member -f redis-eu-west-2.yaml
```

Then you should be able to see that the Pod of Redis instance is running in `eu-west-2` Service Cluster.