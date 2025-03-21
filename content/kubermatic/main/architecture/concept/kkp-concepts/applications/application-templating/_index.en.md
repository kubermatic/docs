+++
title = "Templating"
date = 2025-03-03T08:31:15+02:00
weight = 4
enterprise = true

+++

#### Values Templating

KKP treats each `valuesBlock` string value or `values` map in an application installation resource as a
[Go template](https://golang.org/pkg/text/template/), so it is possible to inject user-cluster related information into applications at runtime. Please refer to the Go documentation for
the exact templating syntax.

KKP injects an instance of the `TemplateData` struct into each template. The following
Go snippet shows the available information:

```
{{< readfile "kubermatic/main/data/applicationdata.go" >}}
```

### A practical example

Let's take nginx ingress controller as an example to demonstrate how to use predefined values and also injecting helm variables for values which are wrapped by a `tpl` function inside the chart. Here is an example application definition which configures two configmap values rendered by helm. One with the cluster name passed from pre-defined values and the other one uses a helm variable to set the release namespace as a value.

```yaml
apiVersion: apps.kubermatic.k8c.io/v1
kind: ApplicationDefinition
metadata:
  name: nginx-demo
spec:
  description: Demo app for testing pre defined values and helm variables
  displayName: demo nginx
  method: helm
  versions:
  - template:
      source:
        helm:
          chartName: ingress-nginx
          chartVersion: 4.12.0
          url: https://kubernetes.github.io/ingress-nginx
    version: 1.12.0
  defaultValuesBlock: |
      tcp:
        namespace: '{{ `{{.Release.Namespace}}` }}'
        cluster-name: '{{ .Cluster.Name }}'
  documentationURL: https://kubernetes.github.io/ingress-nginx/
  sourceURL: https://github.com/kubernetes/ingress-nginx
```

The available pre-defined variables can be accessed as normal go template variables with `.Cluster` as the parent object.

To use helm variables which are wrapped by a `tpl` function inside the helm chart it is required to wrap these ones with go template brackets.
