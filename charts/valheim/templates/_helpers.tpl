{{/*
Expand the name of the chart.
*/}}
{{- define "valheim.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "valheim.fullname" -}}
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
{{- define "valheim.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "valheim.labels" -}}
helm.sh/chart: {{ include "valheim.chart" . }}
{{ include "valheim.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "valheim.selectorLabels" -}}
app.kubernetes.io/name: {{ include "valheim.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "valheim.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "valheim.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create volumes definition
*/}}
{{- define "valheim.serverData.volume" -}}
- name: server-files
{{- if and .Values.persistence.serverData.enabled (or (eq .Values.persistence.serverData.type "pvc") (eq .Values.persistence.serverData.type "hostPath")) }}
{{- if eq .Values.persistence.serverData.type "pvc" }}
  persistentVolumeClaim:
    {{- if ne .Values.persistence.serverData.pvc.existingClaim nil }}
    claimName: {{ .Values.persistence.serverData.pvc.existingClaim }}
    {{- else }}
    claimName: {{ include "valheim.fullname" . }}-server-data
    {{- end }}
{{- else if eq .Values.persistence.serverData.type "hostPath" }}
  hostPath:
    path: /data/valheim-serverfiles
    type: DirectoryOrCreate
{{- end }}
{{- else }}
  emptyDir:
    sizeLimit: {{ .Values.persistence.serverData.pvc.size }}
{{- end }}
{{- end }}

{{- define "valheim.worldData.volume" -}}
- name: world-files
{{- if and .Values.persistence.worldData.enabled (or (eq .Values.persistence.worldData.type "pvc") (eq .Values.persistence.worldData.type "hostPath")) }}
{{- if eq .Values.persistence.worldData.type "pvc" }}
  persistentVolumeClaim:
    {{- if ne .Values.persistence.worldData.pvc.existingClaim nil}}
    claimName: {{ .Values.persistence.worldData.pvc.existingClaim }}
    {{- else }}
    claimName: {{ include "valheim.fullname" . }}-world-data
    {{- end }}
{{- else if eq .Values.persistence.worldData.type "hostPath" }}
  hostPath:
    path: /data/valheim-worldfiles
    type: DirectoryOrCreate
{{- end }}
{{- else }}
  emptyDir:
    sizeLimit: {{ .Values.persistence.worldData.pvc.size }}
{{- end }}
{{- end }}

{{- define "valheim.volumes" }}
{{ include "valheim.serverData.volume" . }}
{{ include "valheim.worldData.volume" . }}
{{- end }}

{{/*
Return true if we should use an existingSecret for serverPassword.
*/}}
{{- define "valheim.server.useExistingSecret" -}}
{{- if .Values.server.serverPasswordSecret -}}
{{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return randomly generated serverPassword
*/}}
{{- define "valheim.server.password" -}}
{{- if .Values.server.serverPassword -}}
{{ .Values.server.serverPassword | b64enc }}
{{- else -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (include "valheim.fullname" .)) -}}
{{- if $secret -}}
{{ $secret.data.serverPassword }}
{{- else -}}
{{ randAlphaNum 10 | b64enc }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return true if we should use an existingSecret for supervisorPassword.
*/}}
{{- define "valheim.supervisor.useExistingSecret" -}}
{{- if .Values.server.supervisorPasswordSecret -}}
{{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return randomly generated supervisorPassword
*/}}
{{- define "valheim.supervisor.password" -}}
{{- if .Values.server.supervisorPassword -}}
{{ .Values.server.supervisorPassword | b64enc }}
{{- else -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (include "valheim.fullname" .)) -}}
{{ if $secret -}}
{{ $secret.data.supervisorPassword }}
{{ else -}}
{{ randAlphaNum 10 | b64enc }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return backups env config
*/}}
{{- define "valheim.server.backups" -}}
- name: BACKUPS
  value: {{ .Values.server.backups.enabled | quote }}
- name: BACKUPS_CRON
  value: {{ .Values.server.backups.cron | quote }}
- name: BACKUPS_DIRECTORY
  value: {{ .Values.server.backups.directory | quote }}
- name: BACKUPS_MAX_AGE
  value: {{ .Values.server.backups.maxAge | quote }}
- name: BACKUPS_MAX_COUNT
  value: {{ .Values.server.backups.maxCount | quote }}
- name: BACKUPS_IF_IDLE
  value: {{ .Values.server.backups.backupsIdle | quote }}
- name: BACKUPS_IDLE_GRACE_PERIOD
  value: {{ .Values.server.backups.gracePeriod | quote }}
- name: BACKUPS_ZIP
  value: {{ .Values.server.backups.zip | quote }}
{{- end -}}

