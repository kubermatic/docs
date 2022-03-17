+++
title = "Customize the KKP Deployment"
weight = 40
+++

You were given the pre-configured setup in a declarative form, feel free to touch any parts of the `terraform`,
`kubeone` or `kubermatic` configurations according to your needs.

Documentation for [KubeOne](https://docs.kubermatic.com/kubeone/) and [Kubermatic Kubernetes Platform](https://docs.kubermatic.com/kubermatic)
should be helpful in these cases.

Do you want to install more applications or provide new Kubernetes resources? Just add or update them in the `flux` directory.

For example, create a new KKP project and assign it to your existing user:

```yaml
# file: flux/clusters/master/kubermatic/internal-project.yaml
---
apiVersion: kubermatic.k8c.io/v1
kind: Project
metadata:
  name: 8wtyahtwlq
spec:
  name: internal
status:
  phase: Active
---
apiVersion: kubermatic.k8c.io/v1
kind: UserProjectBinding
metadata:
  name: ilmepndbvt
spec:
  group: owners-8wtyahtwlq
  projectId: 8wtyahtwlq
  userEmail: admin@kubermatic.com
```

Do you want to enable authentication in the KKP using Google or other OIDC providers? Just update the
`kubermatic/values.yaml`, see the Connectors in dex [documentation](https://dexidp.io/docs/connectors/).

And how to apply all of the above? Guess … yes, **GitOps** way...

Pipeline will take care of updating the environment for you.
