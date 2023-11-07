+++
title = "[Experimental] OPA Mutation"
date = 2021-09-08T12:07:15+02:00
weight = 40

+++

### [Experimental] OPA Mutation

KKP release 2.22 includes Gatekeeper version v3.7.2 which also supports the Experimental [Mutation](https://open-policy-agent.github.io/gatekeeper/website/docs/mutation/) feature, which is not integrated with KKP(yet), but users can still use it on the user clusters.

**How to activate Mutation on Gatekeeper**
The mutation is Disabled by default, but users can opt-in by setting the flag `experimentalEnableMutation` in the Cluster spec.
By setting this flag `experimentalEnableMutation` to true, Kubermatic deploys Mutation Webhook on the user cluster.

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Cluster
metadata:
  name: bpc9nstqvk
spec:
  humanReadableName: suspicious-mcnulty
  oidc: {}
  opaIntegration:
    enabled: true
    experimentalEnableMutation: true
```