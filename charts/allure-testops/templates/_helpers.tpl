{{/* vim: set filetype=mustache: */}}

{{- define "imagePullSecret" }}
{{- with .Values.registry }}
  {{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"auth\":\"%s\"}}}" .repo .auth.username .auth.password (printf "%s:%s" .auth.username .auth.password | b64enc) | b64enc }}
{{- end }}
{{- end }}

{{- define "allure-testops.name" -}}
  {{- default .Chart.Name .Values.releaseName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "allure-testops.fullname" -}}
  {{- $name := default .Chart.Name .Values.releaseName -}}
  {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "allure-testops.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "allure-testops.gateway.fullname" -}}
  {{- printf "%s-%s" .Release.Name "gateway" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "allure-testops.jwks" }}
  {{- printf "http://%s-%s:%.f/.well-known/jwks.json" .Release.Name "gateway" .Values.gateway.service.port | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "allure-testops.uaa.fullname" -}}
  {{- printf "%s-%s" .Release.Name "uaa" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "allure-testops.report.fullname" -}}
  {{- printf "%s-%s" .Release.Name "report" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "allure-testops.rabbitmq.fullname" -}}
  {{- printf "%s-%s" .Release.Name "rabbitmq" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "allure-testops.minio.fullname" -}}
  {{- printf "%s-%s" .Release.Name "minio" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "allure-testops.postgresql.fullname" -}}
  {{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "allure-testops.redis.fullname" -}}
{{- if .Values.redis.enabled }}
  {{- printf "%s-%s" .Release.Name "redis-master" | trunc 63 | trimSuffix "-" }}
{{- else if (eq .Values.redis.keyDB true) }}
  {{- printf "%s-%s" .Release.Name "redis" | trunc 63 | trimSuffix "-" }}
{{- else }}
  {{- print .Values.redis.host }}
{{- end }}
{{- end -}}

{{- define "allure-testops.secret.name" -}}
{{- if and (not .Values.externalSecrets.enabled) (not .Values.vault.enabled) }}
  {{- $secret_name := include "allure-testops.fullname" . }}
  {{- printf $secret_name }}
{{- else }}
  {{- if .Values.externalSecrets.name }}
    {{- $secret_name := .Values.externalSecrets.name }}
    {{- printf $secret_name }}
  {{- else }}
    {{- if .Values.vault.enabled }}
      {{- $secret_name := .Values.vault.secretName }}
      {{- printf $secret_name }}
    {{ else }}
      {{- $secret_name := include "allure-testops.fullname" . }}
      {{- printf $secret_name }}
  {{- end }}
{{- end }}
{{- end -}}
{{- end }}

{{- define "rabbitHost" }}
{{- if .Values.rabbitmq.enabled }}
  {{- printf "amqp://%s-%s:%.f" .Release.Name "rabbitmq" .Values.rabbitmq.service.ports.amqp | trunc 63 | trimSuffix "-" }}
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
  {{- print .Values.postgresql.external.uaaPort }}
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
  {{- print .Values.postgresql.external.reportPort }}
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

{{- define "renderCommonEnvs" }}
  - name: SPRING_PROFILES_ACTIVE
    value: kubernetes
  - name: TZ
    value: "{{ .Values.allure.timeZone }}"
  - name: {{ .Values.build }}_ENDPOINT
    value: "{{ ternary "https" "http" .Values.network.tls.enabled }}://{{ .Values.host }}"
  - name: SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWKSETURI
    value: {{ template "allure-testops.jwks" . }}
  - name: MANAGEMENT_METRICS_EXPORT_PROMETHEUS_ENABLED
    value: 'true'
  - name: MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE
    value: "{{ .Values.allure.management.expose }}"
  - name: MANAGEMENT_ENDPOINT_HEALTH_CACHE_TIME-TO-LIVE
    value: "{{ .Values.allure.management.cacheTTL }}"
  - name: MANAGEMENT_HEALTH_DISKSPACE_ENABLED
    value: "false"
  - name: MANAGEMENT_HEALTH_KUBERNETES_ENABLED
    value: "false"
  - name: SPRING_CLOUD_DISCOVERY_CLIENT_HEALTH_INDICATOR_ENABLED
    value: "false"
  - name: SERVER_ERROR_INCLUDE_STACKTRACE
    value: "always"
  - name: LOGGING_LEVEL_ORG_SPRINGFRAMEWORK
    value: "{{ .Values.allure.logging }}"
  - name: SPRING_OUTPUT_ANSI_ENABLED
    value: "never"
  - name: LOGGING_LEVEL_ORG_SPRINGFRAMEWORK_SECURITY
    value: "{{ .Values.allure.logging }}"
  - name: ALLURE_EE_REPORT_SERVICE_HOST
    value: "{{ template "allure-testops.report.fullname" . }}"
  - name: ALLURE_EE_REPORT_SERVICE_PORT
    value: "{{ .Values.report.service.port }}"
  - name: ALLURE_EE_UAA_SERVICE_HOST
    value: "{{ template "allure-testops.uaa.fullname" . }}"
  - name: ALLURE_EE_UAA_SERVICE_PORT
    value: "{{ .Values.uaa.service.port }}"
  - name: ALLURE_EE_GATEWAY_SERVICE_HOST
    value: "{{ template "allure-testops.gateway.fullname" . }}"
  - name: ALLURE_EE_GATEWAY_SERVICE_PORT
    value: "{{ .Values.gateway.service.port }}"
  - name: {{ .Values.build }}_JWT_SECRET
    valueFrom:
      secretKeyRef:
        name: {{ template "allure-testops.secret.name" . }}
        key: "jwtSecret"
{{- end }}

{{- define "renderCrypto" }}
  - name: {{ .Values.build }}_CRYPTO_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ template "allure-testops.secret.name" . }}
        key: "cryptoPass"
{{- end }}

{{- define "renderS3Envs" }}
{{- if eq .Values.fs.type "S3" }}
  - name: {{ .Values.build }}_BLOBSTORAGE_MAXCONCURRENCY
    value: "{{ .Values.report.maxS3Concurrency }}"
  - name: {{ .Values.build }}_BLOBSTORAGE_S3_ENDPOINT
{{- if .Values.minio.enabled }}
    value: http://{{ template "allure-testops.minio.fullname" . }}:{{ .Values.minio.service.ports.api }}
  - name: {{ .Values.build }}_BLOBSTORAGE_S3_PATHSTYLEACCESS
    value: "true"
{{- else }}
    value: {{ .Values.fs.s3.endpoint }}
  - name: {{ .Values.build }}_BLOBSTORAGE_S3_PATHSTYLEACCESS
    value: "{{ .Values.fs.s3.pathstyle }}"
{{- end }}
  - name: {{ .Values.build }}_BLOBSTORAGE_S3_BUCKET
{{- if .Values.minio.enabled }}
    value: {{ .Values.minio.defaultBuckets }}
{{- else }}
    value: {{ .Values.fs.s3.bucket }}
{{- end }}
  - name: {{ .Values.build }}_BLOBSTORAGE_S3_REGION
{{- if .Values.minio.enabled }}
    value: {{ .Values.minio.defaultRegion }}
{{- else }}
    value: {{ .Values.fs.s3.region}}
{{- end }}
{{ if .Values.fs.s3.kms.enabled }}
  - name: {{ .Values.build}}_ALLURE_BLOBSTORAGE_S3_KMSKEYID
    valueFrom:
      secretKeyRef:
        name: {{ template "allure-testops.secret.name" . }}
        key: "s3KmsKeyId"
{{- end}}
{{- if and (not .Values.allure.manualConfig) (not .Values.aws.enabled) }}
  - name: {{ .Values.build }}_BLOBSTORAGE_S3_ACCESSKEY
    valueFrom:
      secretKeyRef:
        name: {{ template "allure-testops.secret.name" . }}
        key: "s3AccessKey"
  - name: {{ .Values.build }}_BLOBSTORAGE_S3_SECRETKEY
    valueFrom:
      secretKeyRef:
        name: {{ template "allure-testops.secret.name" . }}
        key: "s3SecretKey"
{{- end }}
{{- end }}
{{- end }}

{{- define "calculateMemory" }}
  {{- $v := . }}
  {{- if not $v }}
    {{- print "-Xms256M -Xmx768M" }}
  {{- end }}
  {{- $unit := "M" }}
  {{- $xms := 256 }}
  {{- $xmx := 768 }}
  {{- if $v | hasSuffix "Mi" }}
    {{- $xms = div ($v | trimSuffix "Mi" ) 4 }}
    {{- $xmx = mul $xms 3 }}
  {{- else if $v | hasSuffix "Gi" }}
    {{- if le ($v | trimSuffix "Gi" | atoi ) 4 }}
      {{- $unit = "M" }}
      {{- $xms = div (mul ($v | trimSuffix "Gi") 1024) 4 }}
      {{- $xmx = mul $xms 3 }}
    {{- else }}
      {{- $unit = "G" }}
      {{- $xms = div ($v | trimSuffix "Gi" ) 4 }}
      {{- $xmx = mul $xms 3 }}
    {{- end }}
  {{- end }}
  {{- if gt ($v | trimSuffix "Gi" | atoi ) 6 }}
    {{- printf "-XX:+UseG1GC -XX:+UseStringDeduplication -Xms%d%s -Xmx%d%s" $xms $unit $xmx $unit }}
  {{- else }}
    {{- printf "-XX:+UseParallelGC -Xms%d%s -Xmx%d%s" $xms $unit $xmx $unit }}
  {{- end }}
{{- end }}

{{- define "renderJavaOpts" }}
  {{- $v := . }}
  {{- $memString := include "calculateMemory" $v }}
  {{- printf "-XX:AdaptiveSizePolicyWeight=50 -XX:+UseTLAB -XX:GCTimeRatio=15 -XX:MinHeapFreeRatio=40 -XX:MaxHeapFreeRatio=70 %s" $memString }}
{{- end }}

{{- define "getImageRegistry" }}
{{- if .Values.registry.name }}
  {{- printf "%s/%s/" .Values.registry.repo .Values.registry.name }}
{{- else }}
  {{- printf "%s/" .Values.registry.repo }}
{{- end }}
{{- end }}