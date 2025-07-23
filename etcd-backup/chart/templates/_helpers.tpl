{{/* Generate full name */}}
{{- define "etcd-backup.fullname" -}}
{{- printf "%s-%s" .Release.Name "cron-job" | trunc 63 | trimSuffix "-" -}}
{{- end -}}