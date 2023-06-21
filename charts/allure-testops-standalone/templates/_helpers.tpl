{{/*
Expand the name of the chart.
*/}}
{{- define "allure-testops-standalone.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "allure-testops-standalone.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "allure-testops-standalone.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "allure-testops-standalone.labels" -}}
helm.sh/chart: {{ include "allure-testops-standalone.chart" . }}
{{ include "allure-testops-standalone.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "allure-testops-standalone.selectorLabels" -}}
app.kubernetes.io/name: {{ include "allure-testops-standalone.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "allure-testops-standalone.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "allure-testops-standalone.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "getImageRegistry" }}
{{- if .Values.registry.name }}
  {{- printf "%s/%s/" .Values.registry.repo .Values.registry.name }}
{{- else }}
  {{- printf "%s/" .Values.registry.repo }}
{{- end }}
{{- end }}

{{- define "imagePullSecret" }}
{{- with .Values.registry }}
  {{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"auth\":\"%s\"}}}" .repo .auth.username .auth.password (printf "%s:%s" .auth.username .auth.password | b64enc) | b64enc }}
{{- end }}
{{- end }}

{{- define "allure-testops.redis.fullname" -}}
{{- if .Values.redis.enabled }}
  {{- printf "%s-%s" .Release.Name "redis-master" | trunc 63 | trimSuffix "-" }}
{{- else }}
  {{- print .Values.redis.host }}
{{- end }}
{{- end -}}

{{- define "rabbitHost" }}
{{- if .Values.rabbitmq.enabled }}
  {{- printf "amqp://%s:%.f" .Values.rabbitmq.fullnameOverride .Values.rabbitmq.service.ports.amqp | trunc 63 | trimSuffix "-" }}
{{- else }}
  {{- print .Values.rabbitmq.external.hosts }}
{{- end }}
{{- end }}

{{- define "uaaDBHost" }}
{{- if .Values.postgresql.enabled }}
  {{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" }}
{{- else }}
  {{- print .Values.postgresql.external.uaaHost }}
{{- end }}
{{- end }}

{{- define "uaaDBPort" }}
{{- if .Values.postgresql.enabled }}
  {{- printf "%.f" .Values.postgresql.primary.service.ports.postgresql }}
{{- else }}
  {{- printf "%.f" .Values.postgresql.external.uaaPort }}
{{- end }}
{{- end }}

{{- define "uaaDBName" }}
{{- if .Values.postgresql.enabled }}
  {{- print "uaa" }}
{{- else }}
  {{- print .Values.postgresql.external.uaaDbName }}
{{- end }}
{{- end }}

{{- define "reportDBHost" }}
{{- if .Values.postgresql.enabled }}
  {{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" }}
{{- else }}
  {{- print .Values.postgresql.external.reportHost }}
{{- end }}
{{- end }}

{{- define "reportDBPort" }}
{{- if .Values.postgresql.enabled }}
  {{- printf "%.f" .Values.postgresql.primary.service.ports.postgresql }}
{{- else }}
  {{- printf "%.f" .Values.postgresql.external.reportPort }}
{{- end }}
{{- end }}

{{- define "reportDBName" }}
{{- if .Values.postgresql.enabled }}
  {{- print "report"}}
{{- else }}
  {{- print .Values.postgresql.external.reportDbName }}
{{- end }}
{{- end }}

{{- define "postgresSSL" }}
{{- if .Values.postgresql.enabled }}
  {{- print "disable" }}
{{- else }}
  {{- print .Values.postgresql.external.sslMode }}
{{- end }}
{{- end }}

{{- define "allure-testops.minio.fullname" -}}
  {{- printf "%s-%s" .Release.Name "minio" | trunc 63 | trimSuffix "-" -}}
{{- end -}}