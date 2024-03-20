{{/*
Expand the name of the chart.
*/}}
{{- define "issuer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "issuer.fullname" -}}
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
{{- define "issuer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Determine secret name.
*/}}
{{- define "issuer.secretName" -}}
{{- if .Values.existingSecret -}}
{{- .Values.existingSecret }}
{{- else -}}
{{- include "issuer.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Define secret name of postgres dependency.
*/}}
{{- define "issuer.postgresSecretName" -}}
{{- printf "%s-%s" .Release.Name "issuer-postgres" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "issuer.labels" -}}
helm.sh/chart: {{ include "issuer.chart" . }}
{{ include "issuer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "issuer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "issuer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "issuer.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "issuer.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Determine database hostname for subchart
*/}}

{{- define "issuer.postgresql.primary.fullname" -}}
{{- if eq .Values.postgresql.architecture "replication" }}
{{- printf "%s-primary" (include "issuer.chart.name.postgresql.dependency" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{- include "issuer.chart.name.postgresql.dependency" . -}}
{{- end -}}
{{- end -}}

{{- define "issuer.postgresql.readReplica.fullname" -}}
{{- printf "%s-read" (include "issuer.chart.name.postgresql.dependency" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "issuer.chart.name.postgresql.dependency" -}}
{{- if .Values.postgresql.fullnameOverride -}}
{{- .Values.postgresql.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}