{{- if not (partial "llms/is-excluded.txt" .) -}}
---
title: {{ .Title | plainify }}
url: {{ .Permalink }}
---

# {{ .Title | plainify }}
{{ with .Description | default .Params.description }}
> {{ . }}
{{ end }}
{{ partial "llms/decode-entities.txt" .Plain }}
{{- end -}}
