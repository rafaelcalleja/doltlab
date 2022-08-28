{{/* vim: set filetype=mustache: */}}
{{/*
helper-from:
  repository: https://charts.bitnami.com/bitnami/common
  version: 1.16.1
Renders a value that contains template.
Usage:
{{ include "common.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "common.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- $newVar := tpl .value .context -}}
        {{- $nextVar := tpl ($newVar) .context -}}
        {{- if eq $newVar $nextVar -}}
        {{- $newVar }}
        {{- else }}
        {{- include "common.tplvalues.render" (dict "value" (tpl .value .context) "context" .context) }}
        {{- end }}
    {{- else }}
        {{- $newVar := tpl (.value | toYaml) .context -}}
        {{- $nextVar := tpl ($newVar) .context -}}
        {{- if eq $newVar $nextVar -}}
        {{- $newVar }}
        {{- else }}
        {{- include "common.tplvalues.render" (dict "value" (tpl (.value | toYaml) .context) "context" .context) }}
        {{- end }}
    {{- end }}
{{- end }}
