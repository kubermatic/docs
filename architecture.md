# Architecture
Kubermatic's infrastructure consists of three main components that provide maximum availability without compromising on flexibility.

#### Master cluster
The master cluster runs all user facing services such as the API or the dashboard.
All components run using Kubernetes to make them fault-tolerant and scalable to support even high load scenarios.

#### Seed cluster
The seed cluster runs in a Google Cloud datacenter to provide low latency and a highly reliable internet connection.
It's purpose is to deploy the final customer clusters.
The seed cluster itself is likewise managed by Kubernetes.
The master cluster communicates with a selected seed cluster to deploy a customer cluster.

#### Customer cluster
The customer cluster provides all needed components to run a Kubernetes cluster such as etcd and the Kubernetes master.
The services will be proxied to the nodes of the customer which are located in their datacenter.
