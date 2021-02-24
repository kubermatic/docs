---
title: Redis Operator
weight: 10
slug: redis_operator
date: 2020-02-24T09:00:00+03:00
---

## Redis Operator

## Requirements

You should have kubecarrier deployed and ready. Check [Installation]({{< relref "../tutorials_howtos/installation/kubectl#install-kubecarrier" >}}) for more info.

We will also need to have one [Service Cluster]({{< relref "../tutorials_howtos/api_usage/service_clusters" >}}), where we will be deploying redis operator.

And add some demo [Accounts]({{< relref "../tutorials_howtos/api_usage/accounts/">}})
with [Catalog]({{< relref "../tutorials_howtos/api_usage/catalogs#catalogs" >}}) that cover all service clusters and tenants

## Deploy Redis Operator to the Service Cluster

We can go to the https://github.com/OT-CONTAINER-KIT/redis-operator, clone source code and deploy the operator using the command
>ServiceCluster
```bash
$ helm upgrade --create-namespace redis-operator ./helm-charts/redis-operator --install --namespace redis-operator
```

or we can save this yaml to the `redis-operator.yaml` file and apply it to the service cluster

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

>ServiceCluster
```bash
kubectl create namespace redis-operator
kubectl apply -f https://raw.githubusercontent.com/OT-CONTAINER-KIT/redis-operator/master/helm-charts/redis-operator/crds/crd-redis.yaml
kubectl apply -n redis-operator -f redis-operator.yaml
```

you should have as a result
>ServiceCluster
```bash
$ kubectl get -n redis-operator deployments
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
redis-operator   1/1     1            1           1m

```
## Create CatalogEntrySet for Redis Operator

Now when redis operator ready we can go to the Management cluster and add CatalogEntrySet and Catalog

Let's create `catalogentryset.yaml` file with content:

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

and apply it to the management cluster in the `team-a` namespace

>ManagementCluster
```bash
kubectl apply -n team-a -f redis-catalogentryset.yaml
```
Two new CRDs will be added to the management cluster.
>ManagementCluster
```bash
$ kubectl get crds | grep redis
redis.eu-west-1.team-a                          2021-02-24T10:05:41Z
redis.internal.eu-west-1.team-a                 2021-02-24T10:05:28Z
```

## Deploy Redis workload to the Service Cluster

And now we finally ready to add Redis instance.
Dump Redis CR instance to the file `redis.yaml` and apply it to the management cluster as a `team-b` member


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

>ManagementCluster
```bash
kubectl apply -n team-b --as=team-b-member -f redis.yaml
```

after that Redis CR should be provisioned to the Service cluster and we should see redis workload running in the service cluster.

let's find out service cluster assignment namespace
>ManagementCluster
```bash
$ kubectl get -n team-a serviceclusterassignments team-b.eu-west-1 -o json | jq .status.serviceClusterNamespace.name
"team-b-wqpd2"
```

>ServiceCluster
```bash
$ kubectl get -n team-b-wqpd2 pods
NAME                         READY   STATUS    RESTARTS   AGE
redisinstance-standalone-0   1/1     Running   0          22m
```