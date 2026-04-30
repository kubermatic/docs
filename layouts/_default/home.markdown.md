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
  {{- $latest := cond (gt (len .versions) 1) (index .versions 1) (index .versions 0) -}}
  {{- $version = $latest.release -}}
{{- end -}}
### {{ .title }}

{{ .description }}
{{ if $version -}}
Documentation: [/{{ $key }}/{{ $version }}/](/{{ $key }}/{{ $version }}/)
{{ end }}
{{ end -}}
{{- end -}}
{{- end -}}
