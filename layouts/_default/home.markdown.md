{{- if not .Params.sitemapexclude -}}
---
title: {{ .Title | plainify }}
url: {{ .Permalink }}
---

# {{ .Title | plainify }}
{{ with .Description | default .Params.description }}
> {{ . }}
{{ end }}
## Products
{{ range sort hugo.Data.products "weight" }}
{{- if not .sitemapexclude -}}
{{- $key := .name | urlize -}}
{{- $version := "" -}}
{{- if .versions -}}
  {{- $version = partial "latest-release.html" .versions -}}
{{- end -}}
### {{ .title }}

{{ .description }}
{{ if $version -}}
Documentation: [/{{ $key }}/{{ $version }}/](/{{ $key }}/{{ $version }}/)
{{ end }}
{{ end -}}
{{- end -}}
{{- end -}}
