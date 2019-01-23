+++
title = "Runbook"
date = 2018-04-28T12:07:15+02:00
weight = 0
pre = "<b></b>"
+++

As Rob Ewaschuk [puts it](https://docs.google.com/document/d/199PqyG3UsyXlwieHaqbGiWVa8eMWi8zzAn0YfcApr8Q/edit):

> Playbooks (or runbooks) are an important part of an alerting system; it's best to have an entry for each alert or
> family of alerts that catch a symptom, which can further explain what the alert means and how it might be addressed.

It is a recommended practice that you add an annotation of "runbook" to every prometheus alert with a link to a clear
description of its meaning and suggested remediation or mitigation. While some problems will require private and custom
solutions, most common problems have common solutions. In practice, you'll want to automate many of the procedures
(rather than leaving them in a wiki), but even a self-correcting problem should provide an explanation as to what
happened and why to observers.

### Group: "kubermatic"

##### Alert: "KubermaticTooManyUnhandledErrors"

+ *Severity*: warning
+ *Message*: `Kubermatic Controller Manager in {{ $labels.namespace }} has too many errors in its loop.`
+ *Action*: Check the logs using `kubectl -n kubermatic logs -f controller-manager-*` for further information.

##### Alert: "KubermaticStuckClusterPhase"

+ *Severity*: warning
+ *Message*: `Kubermatic cluster {{ $labels.cluster }} is stuck in unexpected phase {{ $labels.phase }}.`
+ *Action*: Check the Controller Manager logs with `kubectl -n kubermatic logs -f controller-manager-*` and the CRD of
  the cluster with `kubectl get clusters <clusterID> -o yaml`

### Group: "machine-controller"

##### Alert: "MachineControllerTooManyErrors"

+ *Message*: `Machine Controller in {{ $labels.namespace }} has too many errors in its loop.`
+ *Severity*: warning
+ *Action*: Check the machine controller logs using `kubectl logs <pod>` for further information.

### Group: "kubernetes-absent"

##### Alert: "CadvisorDown"

+ *Message*: `Cadvisor has disappeared from Prometheus target discovery.`
+ *Severity*: critical
+ *Action*: Check the Prometheus targets page, try connecting to the service itself directly.

##### Alert: "KubeAPIDown"

+ *Message*: `KubeAPI has disappeared from Prometheus target discovery.`
+ *Severity*: critical
+ *Action*: Check the Prometheus targets page, try connecting to the service itself directly.

##### Alert: "KubeControllerManagerDown"

+ *Message*: `KubeControllerManager has disappeared from Prometheus target discovery.`
+ *Severity*: critical
+ *Action*: Check the Prometheus targets page, try connecting to the service itself directly.

##### Alert: "KubeSchedulerDown"

+ *Message*: `KubeScheduler has disappeared from Prometheus target discovery.`
+ *Severity*: critical
+ *Action*: Check the Prometheus targets page, try connecting to the service itself directly.

##### Alert: "KubeStateMetricsDown"

+ *Message*: `KubeStateMetrics has disappeared from Prometheus target discovery.`
+ *Severity*: critical
+ *Action*: Check the Prometheus targets page, try connecting to the service itself directly.

##### Alert: "KubeletDown"

+ *Message*: `Kubelet has disappeared from Prometheus target discovery.`
+ *Severity*: critical
+ *Action*: Check the Prometheus targets page, try connecting to the service itself directly.

##### Alert: "KubermaticAPIDown"

+ *Message*: `KubermaticAPI has disappeared from Prometheus target discovery.`
+ *Severity*: critical
+ *Action*: Check the Prometheus targets page, try connecting to the service itself directly.

##### Alert: "KubermaticControllerManagerDown"

+ *Message*: `KubermaticControllerManager has disappeared from Prometheus target discovery.`
+ *Severity*: critical
+ *Action*: Check the Prometheus targets page, try connecting to the service itself directly.

##### Alert: "KubernetesApiserverDown"

+ *Message*: `KubernetesApiserver has disappeared from Prometheus target discovery.`
+ *Severity*: critical
+ *Action*: Check the Prometheus targets page, try connecting to the service itself directly.

##### Alert: "MachineControllerDown"

+ *Message*: `MachineController has disappeared from Prometheus target discovery.`
+ *Severity*: critical
+ *Action*: Check the Prometheus targets page, try connecting to the service itself directly.

### Group Name: kubernetes-apps

##### Alert: KubePodCrashLooping

+ *Message*: `{{ $labels.namespace }}/{{ $labels.pod }} ({{ $labels.container }}) is restarting {{ printf "%.2f" $value
  }} / second`
+ *Severity*: critical

##### Alert: "KubePodNotReady"

+ *Message*: `{{ $labels.namespace }}/{{ $labels.pod }} is not ready.`
+ *Severity*: critical

##### Alert: "KubeDeploymentGenerationMismatch"

+ *Message*: `Deployment {{ $labels.namespace }}/{{ $labels.deployment }} generation mismatch`
+ *Severity*: critical

##### Alert: "KubeDeploymentReplicasMismatch"

+ *Message*: `Deployment {{ $labels.namespace }}/{{ $labels.deployment }} replica mismatch`
+ *Severity*: critical

##### Alert: "KubeStatefulSetReplicasMismatch"

+ *Message*: `StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} replica mismatch`
+ *Severity*: critical

##### Alert: "KubeStatefulSetGenerationMismatch"

+ *Message*: `StatefulSet {{ $labels.namespace }}/{{ labels.statefulset }} generation mismatch`
+ *Severity*: critical

##### Alert: "KubeDaemonSetRolloutStuck"

+ *Message*: `Only {{$value}}% of desired pods scheduled and ready for daemon set
  {{$labels.namespace}}/{{$labels.daemonset}}`
+ *Severity*: critical

##### Alert: "KubeDaemonSetNotScheduled"

+ *Message*: `A number of pods of daemonset {{$labels.namespace}}/{{$labels.daemonset}} are not scheduled.`
+ *Severity*: warning

##### Alert: "KubeDaemonSetMisScheduled"

+ *Message*: `A number of pods of daemonset {{$labels.namespace}}/{{$labels.daemonset}} are running where they are not
  supposed to run.`
+ *Severity*: warning

##### Alert: "KubeCronJobRunning"

+ *Message*: `CronJob {{ $labels.namespaces }}/{{ $labels.cronjob }} is taking more than 1h to complete.`
+ *Severity*: warning
+ *Action*: Check the cronjob using `kubectl decribe cronjob <cronjob>` and look at the pod logs using `kubectl logs
  <pod>` for further information.

##### Alert: "KubeJobCompletion"

+ *Message*: `Job {{ $labels.namespaces }}/{{ $labels.job }} is taking more than 1h to complete.`
+ *Severity*: warning
+ *Action*: Check the job using `kubectl decribe job <job>` and look at the pod logs using `kubectl logs <pod>` for
  further information.

##### Alert: "KubeJobFailed"

+ *Message*: `Job {{ $labels.namespaces }}/{{ $labels.job }} failed to complete.`
+ *Severity*: warning
+ *Action*: Check the job using `kubectl decribe job <job>` and look at the pod logs using `kubectl logs <pod>` for
  further information.

### Group: "kubernetes-resources"

##### Alert: "KubeCPUOvercommit"

+ *Message*: `Overcommited CPU resource requests on Pods, cannot tolerate node failure.`
+ *Severity*: warning

##### Alert: "KubeMemOvercommit"

+ *Message*: `Overcommited Memory resource requests on Pods, cannot tolerate node failure.`
+ *Severity*: warning

##### Alert: "KubeCPUOvercommit"

+ *Message*: `Overcommited CPU resource request quota on Namespaces.`
+ *Severity*: warning

##### Alert: "KubeMemOvercommit"

+ *Message*: `Overcommited Memory resource request quota on Namespaces.`
+ *Severity*: warning

##### Alert: "KubeQuotaExceeded"

+ *Message*: `{{ printf "%0.0f" $value }}% usage of {{ $labels.resource }} in namespace {{ $labels.namespace }}.`
+ *Severity*: warning

### Group: "kubernetes-storage"

##### Alert: "KubePersistentVolumeUsageCritical"

+ *Message*: `The persistent volume claimed by {{ $labels.persistentvolumeclaim }} in namespace {{ $labels.namespace }}
  has {{ printf "%0.0f" $value }}% free.`
+ *Severity*: critical

##### Alert: "KubePersistentVolumeFullInFourDays"

+ *Message*: `Based on recent sampling, the persistent volume claimed by {{ $labels.persistentvolumeclaim }} in
  namespace {{ $labels.namespace }} is expected to fill up within four days.`
+ *Severity*: critical

### Group: "kubernetes-system"

##### Alert: "KubeNodeNotReady"

+ *Message*: `{{ $labels.node }} has been unready for more than an hour"`
+ *Severity*: warning

##### Alert: "KubeVersionMismatch"

+ *Message*: `There are {{ $value }} different versions of Kubernetes components running.`
+ *Severity*: warning

##### Alert: "KubeClientErrors"

+ *Message*: `Kubernetes API server client '{{ $labels.job }}/{{ $labels.instance }}' is experiencing {{ printf "%0.0f"
  $value }}% errors.'`
+ *Severity*: warning

##### Alert: "KubeClientErrors"

+ *Message*: `Kubernetes API server client '{{ $labels.job }}/{{ $labels.instance }}' is experiencing {{ printf "%0.0f"
  $value }} errors / sec.'`
+ *Severity*: warning

##### Alert: "KubeletTooManyPods"

+ *Message*: `Kubelet {{$labels.instance}} is running {{$value}} pods, close to the limit of 110.`
+ *Severity*: warning

##### Alert: "KubeAPILatencyHigh"

+ *Message*: `The API server has a 99th percentile latency of {{ $value }} seconds for {{$labels.verb}}
  {{$labels.resource}}.`
+ *Severity*: warning

##### Alert: "KubeAPILatencyHigh"

+ *Message*: `The API server has a 99th percentile latency of {{ $value }} seconds for {{$labels.verb}}
  {{$labels.resource}}.`
+ *Severity*: critical

##### Alert: "KubeAPIErrorsHigh"

+ *Message*: `API server is erroring for {{ $value }}% of requests.`
+ *Severity*: critical

##### Alert: "KubeAPIErrorsHigh"

+ *Message*: `API server is erroring for {{ $value }}% of requests.`
+ *Severity*: warning

##### Alert: "KubeClientCertificateExpiration"

+ *Message*: `Kubernetes API certificate is expiring in less than 7 days.`
+ *Severity*: warning

##### Alert: "KubeClientCertificateExpiration"

+ *Message*: `Kubernetes API certificate is expiring in less than 1 day.`
+ *Severity*: critical

## Other Kubernetes Runbooks and troubleshooting

+ [Kubernetes Mixins](https://github.com/kubernetes-monitoring/kubernetes-mixin/blob/master/runbook.md)
+ [Troubleshoot Clusters ](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-cluster/)
+ [Cloud.gov Kubernetes Runbook ](https://cloud.gov/docs/ops/runbook/troubleshooting-kubernetes/)
+ [Recover a Broken Cluster](https://codefresh.io/Kubernetes-Tutorial/recover-broken-kubernetes-cluster/)
