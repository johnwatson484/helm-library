![Build Status](https://github.com/bvaughan-nexient/helm-library/actions/workflows/release-helm-chart.yml/badge.svg?branch=main)

# Helm Library

Helm library chart that includes templates for common Kubernetes structures.

## Including the library chart

In your microservice Helm chart:

* Update `Chart.yaml` to `apiVersion: v2`.
* Add the library chart under `dependencies` and choose the version you want (example below). Version number can include `~` or `^` to pick up latest PATCH and MINOR versions respectively.
* Issue the following commands to add the repo that contains the library chart, update the repo, then update dependencies in your Helm chart:

```shell
helm repo add https://bvaughan-nexient.github.io/helm-library/
helm repo update
helm dependencies update
```

An example `Chart.yaml`:

```yaml
apiVersion: v2
description: A Helm chart
name: chart
version: 1.0.0
dependencies:
- name: helm-library
  version: ^2.0.0
  repository: https://bvaughan-nexient.github.io/helm-library/
```

### All template required values

All the K8s object templates in the library require the following values to be set in the parent microservice Helm chart's `values.yaml`:

```yaml
name: <string>
```

### Template pattern

The library chart templates must be called as subtemplates to your chart. The basic pattern is this:

```golang
{{- include "helm-library.service" (list . "chart.service") -}}
{{- define "chart.service" -}}
#local configurations to be merged with the library templates
{{- end -}}
```

Each template in the library works on this basic premis. Some of the library templates are left intentially sparse. This means that you will need to provide additional configuration in your parent chart to make functional charts using those library templates.

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

Template for configuration of an http GET probe, which can be used for `readinessProbe` and/or `livenessProbe` in a container definition within a `Deployment`. The following values need to be passed to the probe in the `<map_of_probe_values>`:

```yaml
path: <string>
port: <integer>
initialDelaySeconds: <integer>
periodSeconds: <integer>
failureThreshold: <integer>
```

### Exec probe

* Template name: `helm-library.exec-probe`
* Usage: `{{- include "helm-library.exec-probe" (list . <map_of_probe_values>) }}`

Template for configuration of an "exec" probe that runs a local script, which can be used for `readinessProbe` and/or `livenessProbe` in a container definition within a `Deployment`. The following values need to be passed to the probe in the `<map_of_probe_values>`:

```yaml
script: <string>
initialDelaySeconds: <integer>
periodSeconds: <integer>
failureThreshold: <integer>
```

### Azure Identity template

* Template file: `_azure-identity.yaml`
* Template name: `helm-library.azure-identity`

A K8s `AzureIdentity` object. Must be used in conjunction with the `AzureIdentityBinding` described below. The name of the template is set automatically based on the name of the Helm chart (as defined by `name:` in the `values.yaml`) to `<name>-identity`.

A basic usage of this object template would involve the creation of `templates/azure-identity.yaml` in the parent Helm chart (e.g. `microservice`) containing:

```golang
{{- include "helm-library.azure-identity" (list . "microservice.azure-identity") -}}
{{- define "microservice.azure-identity" -}}
{{- end -}}
```

#### Required values

The following values need to be set in the parent chart's `values.yaml` in addition to the globally required values [listed above](#all-template-required-values):

```yaml
azureIdentity:
  resourceID:
  clientID:
```

### Azure Identity Binding template

* Template file: `_azure-identity-binding.yaml`
* Template name: `helm-library.azure-identity-binding`

A K8s `AzureIdentityBinding` object. Must be used in conjunction with the `AzureIdentity` described above. The name of the template is set automatically based on the name of the Helm chart (as defined by `name:` in the `values.yaml`) to `<name>-identity-binding`.

A basic usage of this object template would involve the creation of `templates/azure-identity-binding.yaml` in the parent Helm chart (e.g. `microservice`) containing:

```golang
{{- include "helm-library.azure-identity-binding" (list . "microservice.azure-identity-binding") -}}
{{- define "microservice.azure-identity-binding" -}}
{{- end -}}
```
