+++
title = "Templating"
date = 2025-03-03T08:31:15+02:00
weight = 4
enterprise = true

+++

### Values Templating

KKP treats each `valuesBlock` string value or `values` map in an application installation resource as a
[Go template](https://golang.org/pkg/text/template/), so it is possible to inject user-cluster related information into applications at runtime. Please refer to the Go documentation for
the exact templating syntax.

KKP injects an instance of the `TemplateData` struct into each template. The following
Go snippet shows the available information:

```
{{< readfile "kubermatic/v2.28/data/applicationdata.go" >}}
```

### A practical example

Let's take nginx ingress controller as an example to demonstrate how to use predefined values.

#### Example Applicationdefintion

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

Additionally if the upstream chart is using [helms native tpl function](https://helm.sh/docs/howto/charts_tips_and_tricks/#using-the-tpl-function) (see example below) double curly bracket syntax can be used to escape these values to be injected later in helm value context.

The syntax of Helm's native tpl function for a helm chart template file would look like this for the above application definition:

```yaml
{{- if .Values.tcp -}}
apiVersion: v1
kind: ConfigMap
metadata:
...
data: {{ tpl (toYaml .Values.tcp) . | nindent 2 }}
{{- end }}
```
