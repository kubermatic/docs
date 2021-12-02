{{- define "gvList" -}}
{{- $groupVersions := . -}}
+++
title = "Kubermatic CRDs reference"
date = 2021-12-02T00:00:00
weight = 40
+++

## Packages
{{- range $groupVersions }}
- {{ markdownRenderGVLink . }}
{{- end }}

{{ range $groupVersions }}
{{ template "gvDetails" . }}
{{ end }}

{{- end -}}
