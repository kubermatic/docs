+++
title = "K8sGPT Application"
linkTitle = "K8sGPT"
enterprise = true
date = 2024-01-16T12:57:00+02:00
weight = 11

+++

# What is K8sGPT?
K8sGPT gives Kubernetes SRE superpowers to everyone. 

It is a tool for scanning your Kubernetes clusters, diagnosing, and triaging issues in simple English. It has SRE experience codified into its analyzers and helps to pull out the most relevant information to enrich it with AI.

Out of the box integration with OpenAI, Azure, Cohere, Amazon Bedrock and local models.

For more information on the K8sGPT, please refer to the [official documentation](https://docs.k8sgpt.ai/)

# How to deploy?

Argo CD is available as part of the KKP's default application catalog. 
It can be deployed to the user cluster either during the cluster creation or after the cluster is ready(existing cluster) from the Applications tab via UI.

* Select the K8sGPT application from the Application Catalog.

![Select K8sGPT Application](/img/kubermatic/v2.24/architecture/concepts/applications/default-applications-catalog/01-select-application-k8sgpt-app.png)

* Under the Settings section, select and provide appropriate details and clck `-> Next` button.

![Settings for K8sGPT Application](/img/kubermatic/v2.24/architecture/concepts/applications/default-applications-catalog/02-settings-k8sgpt-app.png)

* Under the Application values page section, check the default values and add values if any required to be configured explicitly. Finally click on the `+ Add Application` to deploy the K8sGPT application to the user cluster.

![Application Values for K8sGPT Application](/img/kubermatic/v2.24/architecture/concepts/applications/default-applications-catalog/03-applicationvalues-k8sgpt-app.png)

To further configure the values.yaml, find more information under the [K8sGPT Helm chart](https://github.com/k8sgpt-ai/k8sgpt/tree/main/charts/k8sgpt)
