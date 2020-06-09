[![Build Status](https://dev.azure.com/johnwatson484/John%20D%20Watson/_apis/build/status/Helm%20Library?branchName=master)](https://dev.azure.com/johnwatson484/John%20D%20Watson/_build/latest?definitionId=37&branchName=master)

# Helm Library
Helm library chart

## Including the library chart

In your microservice Helm chart:
  * Update `Chart.yaml` to `apiVersion: v2`.
  * Add the library chart under `dependencies` and choose the version you want (example below). Version number can include `~` or `^` to pick up latest PATCH and MINOR versions respectively.
  * Issue the following commands to add the repo that contains the library chart, update the repo, then update dependencies in your Helm chart:

```
helm repo add https://helm.lynxmagnus.com
helm repo update
helm dependency update <helm_chart_location>
```

An example `Chart.yaml`:

```
apiVersion: v2
description: A Helm chart
name: microservice
version: 1.0.0
dependencies:
- name: helm-library
  version: ^1.0.0
  repository: https://helm.lynxmagnus.com
```

### All template required values

All the K8s object templates in the library require the following values to be set in the parent microservice Helm chart's `values.yaml`:

```
name: <string>
environment: <string>
```

### Cluster IP service template

* Template file: `_cluster-ip-service.yaml`
* Template name: `helm-library.cluster-ip-service`

A K8s `Service` object of type `ClusterIP`.

A basic usage of this object template would involve the creation of `templates/cluster-ip-service.yaml` in the parent Helm chart (e.g. `microservice`) containing:

```
{{- include "helm-library.cluster-ip-service" (list . "microservice.service") -}}
{{- define "microservice.service" -}}
# Microservice specific configuration in here
{{- end -}}
```

#### Required values

The following values need to be set in the parent chart's `values.yaml` in addition to the globally required values [listed above](#all-template-required-values):

```
container:
  port: <integer>
```

### Container template

* Template file: `_container.yaml`
* Template name: `helm-library.container`

A template for the container definition to be used within a K8s `Deployment` object.

A basic usage of this object template would involve the creation of `templates/_container.yaml` in the parent Helm chart (e.g. `microservice`). Note the `_` in the name. This template is part of the `Deployment` object definition and will be used in conjunction the `_deployment.yaml` template ([see below](#deployment-template)). As a minimum `templates/_container.yaml` would define environment variables and may also include liveness/readiness probes when applicable e.g.:

```
{{- define "microservice.container" -}}
env: <list>
livenessProbe: <map>
readinessProbe: <map>
{{- end -}}
```

The liveness and readiness probes could take advantage of the helper templates for [http GET probe](#http-get-probe) and [exec probe](#exec-probe) defined within the library chart and described below.

#### Required values

The following values need to be set in the parent chart's `values.yaml` in addition to the globally required values [listed above](#all-template-required-values):

```
image: <string>
container:
  imagePullPolicy: <string>
  readOnlyRootFilesystem: <boolean>
  allowPrivilegeEscalation: <boolean>
  requestMemory: <string>
  requestCpu: <string>
  limitMemory: <string>
  limitCpu: <string>
```

#### Optional values

The following values can optionally be set in the parent chart's `values.yaml` to enable a command with arguments to run within the container:

```
container:
  command: <list of strings>
  args: <list of strings>
```

### Deployment template

* Template file: `_deployment.yaml`
* Template name: `helm-library.deployment`

A K8s `Deployment` object.

A basic usage of this object template would involve the creation of `templates/deployment.yaml` in the parent Helm chart (e.g. `microservice`) that includes the template defined in `_container.yaml` template:

```
{{- include "helm-library.deployment" (list . "microservice.deployment") -}}
{{- define "microservice.deployment" -}}
spec:
  template:
    spec:
      containers:
      - {{ include "helm-library.container" (list . "microservice.container") }}
{{- end -}}

```

#### Required values

The following values need to be set in the parent chart's `values.yaml` in addition to the globally required values [listed above](#all-template-required-values):

```
deployment:
  replicas: <integer>
  minReadySeconds: <integer>
  redeployOnChange: <string>
  priorityClassName: <string>
  restartPolicy: <string>
  runAsUser: <integer>
  runAsNonRoot: <boolean>
```

#### Optional values

The following value can optionally be set in the parent chart's `values.yaml` to enable the configuration of imagePullSecrets in the K8s object:

```
deployment:
  imagePullSecret: <string>
```

### Ingress template

* Template file: `_ingress.yaml`
* Template name: `helm-library.ingress`

A K8s `Ingress` object that can be configured for Nginx or AWS ALB (Amazon Load Balancer).

A basic Nginx `Ingress` object would involve the creation of `templates/ingress.yaml` in the parent Helm chart (e.g. `microservice`) containing:

```
{{- include "helm-library.ingress" (list . "microservice.ingress") -}}
{{- define "microservice.ingress" -}}
metadata:
  annotations:
    <map_of_nginx-ingress-annotations>
{{- end -}}
```

#### Required values

The following values need to be set in the parent chart's `values.yaml` in addition to the globally required values [listed above](#all-template-required-values):

```
ingress:
  class: <string>
service:
  port: <integer>
```

#### Optional values

The following values can optionally be set in the parent chart's `values.yaml` to set the value of `host`:

```
ingress:
  host: <string>
```

### Postgres service template

* Template file: `_postgres-service.yaml`
* Template name: `helm-library.postgres-service`

A K8s `Service` object of type `ExternalName` configured to refer to a Postgres database hosted on a server outside of the K8s cluster such as AWS RDS.

A basic usage of this object template would involve the creation of `templates/postgres-service.yaml` in the parent Helm chart (e.g. `microservice`) containing:

```
{{- include "helm-library.postgres-service" (list . "microservice.postgres-service") -}}
{{- define "microservice.postgres-service" -}}
# Microservice specific configuration in here
{{- end -}}
```

#### Required values

The following values need to be set in the parent chart's `values.yaml` in addition to the globally required values [listed above](#all-template-required-values):

```
postgresService:
  postgresHost: <string>
  postgresExternalName: <string>
  postgresPort: <integer>
```

### Secret template

* Template file: `_secret.yaml`
* Template name: `helm-library.secret`

A K8s `Secret` object to host sensitive data such as a password or token.

A basic usage of this object template would involve the creation of `templates/secret.yaml` in the parent Helm chart (e.g. `microservice`), which should include the `data` map containing the sensitive data :

```
{{- include "helm-library.secret" (list . "microservice.secret") -}}
{{- define "microservice.secret" -}}
data:
  <key1>: <value1>
  ...
{{- end -}}
```

#### Required values

The following values need to be set in the parent chart's `values.yaml` in addition to the globally required values [listed above](#all-template-required-values):

```
secret:
  name: <string>
  type: <string>
```

### Service template

* Template file: `_service.yaml`
* Template name: `helm-library.service`

A generic K8s `Service` object requiring a service type to be set.

A basic usage of this object template would involve the creation of `templates/secret.yaml` in the parent Helm chart (e.g. `microservice`) containing:

```
{{- include "helm-library.service" (list . "microservice.service") -}}
{{- define "microservice.service" -}}
# Microservice specific configuration in here
{{- end -}}
```

#### Required values

The following values need to be set in the parent chart's `values.yaml` in addition to the globally required values [listed above](#all-template-required-values):

```
service:
  type: <string>
```

### Cron Job template

* Template file: `_cron-job.yaml`
* Template name: `helm-library.cron-job`

A k8s `CronJob`.  

A basic usage of this object template would involve the creation of `templates/cron-job.yaml` in the parent Helm chart (e.g. `microservice`) that includes the template defined in `_container.yaml` template:

```
{{- include "helm-library.cron-job" (list . "microservice.cron-job") -}}
{{- define "microservice.cron-job" -}}
spec:
  template:
    spec:
      containers:
      - {{ include "helm-library.container" (list . "microservice.container") }}
{{- end -}}

```

#### Required values

The following values need to be set in the parent chart's `values.yaml` in addition to the globally required values [listed above](#all-template-required-values):

```
cronJob:
  schedule: <string>
  concurrencyPolicy: <string>
  restartPolicy: <string>
```

### Horozontal Pod Autoscaler template

* Template file: `_horozontal-pod-autoscaler.yaml`
* Template name: `helm-library.horozontal-pod-autoscaler`

A k8s `HorozontalPodAutoscaler`.  

A basic usage of this object template would involve the creation of `templates/horozontal-pod-autoscaler.yaml` in the parent Helm chart (e.g. `microservice`).

```
{{- include "helm-library.horozontal-pod-autoscaler" (list . "microservice.horozontal-pod-autoscaler") -}}
{{- define "microservice.horozontal-pod-autoscaler" -}}
spec:
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  - type: Resource
    resource:
      name: memory
      target:
        type: AverageValue
        averageValue: 100Mi
{{- end -}}

```

#### Required values

The following values need to be set in the parent chart's `values.yaml` in addition to the globally required values [listed above](#all-template-required-values):

```
cronJob:
  minReplicas: <int>
  maxReplicas: <int>
```

## Helper templates

In addition to the K8s object templates described above, a number of helper templates are defined in `_helpers.tpl` that are both used within the library chart and available to use within a consuming parent chart.

### Default check required message

* Template name: `helm-library.default-check-required-msg`
* Usage: `{{- include "helm-library.default-check-required-msg" . }}`

A template defining the default message to print when checking for a required value within the library. This is not designed to be used outside of the library.

### Labels

* Template name: `helm-library.labels`
* Usage: `{{- include "helm-library.labels" . }}`

Common labels to apply to `metadata` of all K8s objects on the K8s platform. This template relies on the globally required values [listed above](#all-template-required-values).

### Selector labels

* Template name: `helm-library.selector-labels`
* Usage: `{{- include "helm-library.selector-labels" . }}`

Common selector labels that can be applied where necessary to K8s objects on the K8s platform. This template relies on the globally required values [listed above](#all-template-required-values).

### Http GET probe

* Template name: `helm-library.http-get-probe`
* Usage: `{{- include "helm-library.http-get-probe" (list . <map_of_probe_values>) }}`

Template for configuration of an http GET probe, which can be used for `readinessProbe` and/or `livenessProbe` in a container definition within a `Deployment` (see [container template](#container-template)). The following values need to be passed to the probe in the `<map_of_probe_values>`:

```
path: <string>
port: <integer>
initialDelaySeconds: <integer>
periodSeconds: <integer>
failureThreshold: <integer>
```

### Exec probe

* Template name: `helm-library.exec-probe`
* Usage: `{{- include "helm-library.exec-probe" (list . <map_of_probe_values>) }}`

Template for configuration of an "exec" probe that runs a local script, which can be used for `readinessProbe` and/or `livenessProbe` in a container definition within a `Deployment` (see [container template](#container-template)). The following values need to be passed to the probe in the `<map_of_probe_values>`:

```
script: <string>
initialDelaySeconds: <integer>
periodSeconds: <integer>
failureThreshold: <integer>
```
