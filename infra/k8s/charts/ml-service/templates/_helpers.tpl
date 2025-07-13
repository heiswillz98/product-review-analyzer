{{/*
Return the app name
*/}}
{{- define "ml-service.name" -}}
ml-service
{{- end }}

{{/*
Return the full name of the release
*/}}
{{- define "ml-service.fullname" -}}
{{ .Release.Name }}-ml-service
{{- end }}
