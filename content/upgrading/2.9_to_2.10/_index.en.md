+++
title = "From 2.9 to 2.10"
date = 2018-10-23T12:07:15+02:00
publishDate = 2019-04-30T00:00:00+00:00
weight = 13
pre = "<b></b>"
+++

## `values.yaml` structure for addons

With the addition of Openshift as supported platform the structure for configuring the addons has
changed to allow for a distinct configuration of Openshift and Kubernetes.
Before it was like this:

```
     addons:
       image:
         repository: "quay.io/kubermatic/addons"
         tag: "v0.1.18"
         pullPolicy: "IfNotPresent"
       # list of Addons to install into every user-cluster. All need to exist in the addons image
       defaultAddons:
       - canal
       - dashboard
       - dns
       - kube-proxy
       - openvpn
       - rbac
       - kubelet-configmap
       - default-storage-class
```

Now there is a subkey `openshift` or `kubernetes` after `addons`:

```
     addons:
       kubernetes:
         defaultAddons:
         - canal
         - dashboard
         - dns
         - kube-proxy
         - openvpn
         - rbac
         - kubelet-configmap
         - default-storage-class
         image:
           repository: "quay.io/kubermatic/addons"
           tag: "v0.1.18"
           pullPolicy: "IfNotPresent
       openshift:
         defaultAddons:
         - networking
         - openvpn
         image:
           repository: "quay.io/kubermatic/openshift-addons"
           tag: "v0.3"
           pullPolicy: "IfNotPresent"
```

## kubermatic-api-dep.yaml new parameter for domain
A new parameter `domain` was added for kubermatic API deployment.
By default the `localhost` is set for this parameter. This domain name is used to create unique email address for a
service account.
Now the list of arguments for `kubermatic-api` looks like this:

```
    spec:
      serviceAccountName: kubermatic
      containers:
        - name: api
          command:
          - kubermatic-api
          args:
          - -address=0.0.0.0:8080
          - -v=4
          - -logtostderr
          - -datacenters=/opt/datacenter/datacenters.yaml
          - -oidc-url={{ .Values.kubermatic.auth.tokenIssuer }}
          - -oidc-authenticator-client-id={{ .Values.kubermatic.auth.clientID }}
          - -oidc-skip-tls-verify={{ default false .Values.kubermatic.auth.skipTokenIssuerTLSVerify }}
          - -versions=/opt/master-files/versions.yaml
          - -updates=/opt/master-files/updates.yaml
          - -internal-address=0.0.0.0:8085
          - -domain={{ .Values.kubermatic.domain }}
          - -kubeconfig=/opt/.kube/kubeconfig
          - -master-resources=/opt/master-files
          # the following flags enable oidc kubeconfig feature/endpoint
          - -feature-gates={{ .Values.kubermatic.api.featureGates }}
          {{- if regexMatch ".*OIDCKubeCfgEndpoint=true.*" (default "" .Values.kubermatic.api.featureGates) }}
          - -oidc-issuer-redirect-uri={{ .Values.kubermatic.auth.issuerRedirectURL }}
          - -oidc-issuer-client-id={{ .Values.kubermatic.auth.issuerClientID }}
          - -oidc-issuer-client-secret={{ .Values.kubermatic.auth.issuerClientSecret }}
          - -oidc-issuer-cookie-hash-key={{ .Values.kubermatic.auth.issuerCookieKey }}
          {{- end }}
          {{- if .Values.kubermatic.worker_name }}
          - -worker-name={{ .Values.kubermatic.worker_name }}
          {{- end }}

```
