{{/*
A default message string to be used when checking for a required value
*/}}
{{- define "helm-library.default-check-required-msg" -}}
{{- "No value found for '%s' in helm-library template" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "helm-library.labels" -}}
{{- $requiredMsg := include "helm-library.default-check-required-msg" . -}}
app.kubernetes.io/name: {{ required (printf $requiredMsg "name") .Values.name | quote }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
environment: {{ required (printf $requiredMsg "environment") .Values.environment | quote }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "helm-library.selector-labels" -}}
{{- $requiredMsg := include "helm-library.default-check-required-msg" . -}}
app.kubernetes.io/name: {{ required (printf $requiredMsg "name") .Values.name | quote }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Settings for an http GET probe to be used for readiness or liveness
*/}}
{{- define "helm-library.http-get-probe" -}}
{{- $settings := (index . 1) -}}
{{- $requiredMsg := include "helm-library.default-check-required-msg" . -}}
httpGet:
  path: {{ required (printf $requiredMsg "probe.path") $settings.path | quote }}
  port: {{ required (printf $requiredMsg "probe.port") $settings.port }}
initialDelaySeconds: {{ required (printf $requiredMsg  "probe.initialDelaySeconds") $settings.initialDelaySeconds }}
periodSeconds: {{ required (printf $requiredMsg "probe.periodSeconds") $settings.periodSeconds }}
failureThreshold: {{ required (printf $requiredMsg "probe.failureThreshold") $settings.failureThreshold }}
{{- end -}}

{{/*
Settings for a script execution probe to be used for readiness or liveness
*/}}
{{- define "helm-library.exec-probe" -}}
{{- $settings := (index . 1) -}}
{{- $requiredMsg := include "helm-library.default-check-required-msg" . -}}
exec:
  command:
  - "sh"
  - "-c"
  - {{ required (printf $requiredMsg "probe.script") $settings.script | quote }}
initialDelaySeconds: {{ required (printf $requiredMsg "probe.initialDelaySeconds") $settings.initialDelaySeconds }}
periodSeconds: {{ required (printf $requiredMsg "probe.periodSeconds") $settings.periodSeconds }}
failureThreshold: {{ required (printf $requiredMsg "probe.failureThreshold") $settings.failureThreshold }}
{{- end -}}
