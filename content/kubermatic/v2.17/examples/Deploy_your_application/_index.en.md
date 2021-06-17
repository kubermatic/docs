+++
title = "Deploy your application"
date = 2020-02-21T12:07:15+02:00
weight = 110
+++

This tutorial demonstrates how to deploy your application to your cluster. We will deploy a hello world application to your cluster that responds with "Hello Kubernetes!" when you curl it.

Log into Kubermatic Kubernetes Platform (KKP), then [create and connect to the cluster]({{< ref "/kubermatic/v2.17/tutorials_howtos/project_and_cluster_management/">}}). For this tutorial, external IP is required which will be provided through the supported cloud providers. Be aware that some providers like DigitalOcean do not provide external IPs.

We are using a [hello-world app](https://github.com/GoogleCloudPlatform/kubernetes-engine-samples/tree/master/hello-app) whose image is available at gcr.io/google-samples/node-hello:1.0.

First, create a Deployment:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: load-balancer-example
  name: hello-world
spec:
  replicas: 3
  selector:
    matchLabels:
      app.kubernetes.io/name: load-balancer-example
  template:
    metadata:
      labels:
        app.kubernetes.io/name: load-balancer-example
    spec:
      containers:
      - image: gcr.io/google-samples/node-hello:1.0
        name: hello-world
        ports:
        - containerPort: 8080
```

```bash
kubectl apply -f load-balancer-example.yaml
```
To expose the Deployment, create a Service object of type LoadBalancer.
```bash
kubectl expose deployment hello-world --type=LoadBalancer --name=my-service
```
Now you need to find out the external IP of that service.

```bash
kubectl get services my-service
```
The response on AWS should look like this:

```
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)          AGE
my-service   LoadBalancer   10.240.29.100   <external-ip>   8080:30574/TCP   19m
```
If you curl against that external IP:

```bash
curl <external-ip>:8080
```

you should get this response:

```
Hello Kubernetes!
```
