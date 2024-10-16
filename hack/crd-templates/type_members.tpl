{{- define "type_members" -}}
{{- $field := . -}}
{{- if eq $field.Name "metadata" -}}
Refer to Kubernetes API documentation for fields of `metadata`.
{{- else -}}
{{ `{{< unsafe >}}` }}{{ markdownRenderFieldDoc $field.Doc }}{{ `{{< /unsafe >}}` }}
{{- end -}}
{{- end -}}
