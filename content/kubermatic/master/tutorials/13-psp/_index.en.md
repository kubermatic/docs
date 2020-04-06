+++
title = "Pod Security Policy"
date = 2020-04-02T12:07:15+02:00
weight = 130
+++

[Pod Security Policy](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) is a key security feature in Kubernetes. It allows cluster administrators to set [granular controls](https://kubernetes.io/docs/concepts/policy/pod-security-policy/#policy-reference) over security sensitive aspects of pod and container spec.

PSP is implemented using an optional admission controller that's disabled by default. It's important to have an initial authorizing policy on the cluster _before_ enabling the PSP admission controller, especially on existing existing cluster is important. Without an authorizing policy, the the controller will prevent all pods from being created on the cluster.

PSP objects are cluster-level objects. They define a set of conditions that a pod must pass to be accepted by the PSP admission controller. Most common way to apply this is using RBAC. For a pod to use a specific Pod Security Policy, the pod should run using a Service Account or a User that has `use` permission to that particular Pod Security policy.

## Kubermatic Support

Kubermatic provides support for enabling PSP during cluster creation using a simple switch:

![Create Cluster](01-create-cluster.png)

For existing clusters, it's also possible to enable/disable PSP:

![Edit Cluster](01-edit-cluster.png)


{{% notice note %}}
Activating Pod Security Policy will mean that a lot of Pod specifications, Operators and Helm charts will not work out of the box. Kubermatic will apply a default authorizing policy to prevent this. Additionally, all Kubermatic user-cluster are configured to work with PSP enabled with no problems. Make sure that you know the consequences of activating this feature on your workloads.
{{% /notice %}}


#### Using Pod Security Policies

See the [official Pod Security Policy documentation](https://kubernetes.io/docs/concepts/policy/pod-security-policy/#example) for a detailed usage example.
