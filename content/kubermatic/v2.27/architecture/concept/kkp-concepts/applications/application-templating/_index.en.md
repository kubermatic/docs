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
