{{/*
Expand the name of the chart.
*/}}
{{- define "wasabi-stats-exporter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "wasabi-stats-exporter.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "wasabi-stats-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "wasabi-stats-exporter.labels" -}}
helm.sh/chart: {{ include "wasabi-stats-exporter.chart" . }}
{{ include "wasabi-stats-exporter.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "wasabi-stats-exporter.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wasabi-stats-exporter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "wasabi-stats-exporter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "wasabi-stats-exporter.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding WASABI_API_KEYS
*/}}
{{- define "wasabi-stats-exporter.secretName" -}}
{{- if .Values.wasabiApiKeys.existingSecret }}
{{- .Values.wasabiApiKeys.existingSecret }}
{{- else }}
{{- include "wasabi-stats-exporter.fullname" . }}
{{- end }}
{{- end }}

{{/*
Key within the Secret holding WASABI_API_KEYS
*/}}
{{- define "wasabi-stats-exporter.secretKey" -}}
{{- if .Values.wasabiApiKeys.existingSecret }}
{{- .Values.wasabiApiKeys.existingSecretKey }}
{{- else }}
{{- "WASABI_API_KEYS" }}
{{- end }}
{{- end }}

{{/*
Fail fast if no Wasabi credential source is configured
*/}}
{{- define "wasabi-stats-exporter.validateWasabiApiKeys" -}}
{{- if and (not .Values.wasabiApiKeys.accounts) (not .Values.wasabiApiKeys.existingSecret) (not .Values.wasabiApiKeys.value) }}
{{- fail "Set one of wasabiApiKeys.accounts, wasabiApiKeys.existingSecret, or wasabiApiKeys.value" }}
{{- end }}
{{- end }}
