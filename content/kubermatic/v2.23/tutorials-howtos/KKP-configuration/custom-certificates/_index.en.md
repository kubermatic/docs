+++
title = "Custom Certificates"
date = 2020-11-03T13:07:15+02:00
weight = 130
+++

## Custom CA

KKP 2.17+ allows to configure a "CA bundle" (a set of CA certificates) on the master cluster.
This CA bundle is then automatically

* copied into each seed cluster
* copied into each usercluster namespace
* copied into each usercluster (into the `kube-system` namespace)
* used for various components, like the KKP API, machine-controller, usercluster kube-apiserver etc.

Changes to the CA bundle are automatically reconciled across these locations. If the CA bundle
is invalid, no further reconciliation happens, so if the master cluster's CA bundle breaks,
seed clusters are not affected.

Do note that the CA bundle configured in KKP is usually _the only_ source of CA certificates
for all of these components, meaning that no certificates are mounted from any of the Seed
cluster host systems.


## Issuing Certificates

KKP uses [cert-manager](https://cert-manager.io/) for managing all TLS certificates used for KKP
itself, as well as Dex and the Identity-Aware Proxies (IAP). The default configuration sets up
Certificate Issuers for [Let's Encrypt](https://letsencrypt.org/), but other issuers can be configured
as well. This section describes the various options for using a custom CA: using cert-manager or managing
certificates manually outside of the cluster.

### Using cert-manager

cert-manager offers a [CA Issuer](https://cert-manager.io/docs/configuration/ca/) that can automatically
create and sign certificates inside the cluster. This requires that the CA itself is stored inside the
cluster as a Kubernetes Secret, so care must be taken to prevent unauthorized access (e.g. by setting
up proper RBAC rules).

If having the CA certificate and key inside the cluster is not a problem, this approach is recommended,
as it introduces the least friction and can be achieved rather easily.

Currently the `cert-manager` Helm chart that is part of KKP does not support creating non-ACME
ClusterIssuers (i.e ClusterIssuers that do not use Let's Encrypt). New issuers must therefore be
created manually. Please follow the [description](https://cert-manager.io/docs/configuration/ca/) in
the cert-manager documentation.

Once the new ClusterIssuer has been created, KKP and the IAP need to be adjusted to use the new issuer.
For KKP, update the `KubermaticConfiguration` and configure `spec.ingress.certificateIssuer` accordingly:

```yaml
spec:
  ingress:
    certificateIssuer:
      name: my-own-ca-issuer
```

Re-apply the changed configuration and the KKP Operator will reconcile the Certificate resource,
after which cert-manager will provision a new certificate Secret.

Similarly, update your Helm `values.yaml` that is used for the Dex/IAP deployment and configure
the new issuer:

```yaml
dex:
  certIssuer:
    name: my-own-ca-issuer

iap:
  certIssuer:
    name: my-own-ca-issuer
```

Re-deploy the `iap` Helm chart to perform the changes and update the Certificate resources.

### External

If issuing certificates inside the cluster is not possible, static certificates can also be provided. The
cluster admin is responsible for renewing and updating them as needed. Going forward, it is assumed that
proper certificates have already been created and now need to be configured inside the cluster.

## Configuration

The CA bundle is stored as a single ConfigMap in the `kubermatic` namespace on the master cluster.
It needs to have a `ca-bundle.pem` key, which is simply the collection of all PEM-encoded CA
certificates.
A good source for a general purpose CA bundle is Mozilla's CA database. The curl maintainers
provide a [ready-to-use bundle file](https://curl.se/docs/caextract.html) that can be used as
a starting point and then extended with your own CAs.

KKP ships the CA bundle mentioned above by default in the `kubermatic-operator` Helm chart.
This means that after installing KKP, a usable default CA bundle is available right from the
start.

To override the CA bundle, either overwrite the `static/ca-bundle.pem` file in the
`kubermatic-operator` Helm chart with your own and then `helm upgrade` the operator, or manually
change the ConfigMap later using `kubectl edit`. Note that you should not use Helm and kubectl
to manage your CA bundle, but only one of the two.

Changes to the ConfigMap are picked up automatically and are then reconciled.

A typical CA bundle ConfigMap must look like this:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ca-bundle
  namespace: kubermatic
data:
  # The key must be "ca-bundle.pem".
  ca-bundle.pem: |
    GlobalSign Root CA
    ==================
    -----BEGIN CERTIFICATE-----
    MIIDdTCCAl2gAwIBAgILBAAAAAABFUtaw5QwDQYJKoZIhvcNAQEFBQAwVzELMAkGA1UEBhMCQkUx
    GTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNVBAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkds
    b2JhbFNpZ24gUm9vdCBDQTAeFw05ODA5MDExMjAwMDBaFw0yODAxMjgxMjAwMDBaMFcxCzAJBgNV
    BAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMRAwDgYDVQQLEwdSb290IENBMRswGQYD
    VQQDExJHbG9iYWxTaWduIFJvb3QgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDa
    DuaZjc6j40+Kfvvxi4Mla+pIH/EqsLmVEQS98GPR4mdmzxzdzxtIK+6NiY6arymAZavpxy0Sy6sc
    THAHoT0KMM0VjU/43dSMUBUc71DuxC73/OlS8pF94G3VNTCOXkNz8kHp1Wrjsok6Vjk4bwY8iGlb
    Kk3Fp1S4bInMm/k8yuX9ifUSPJJ4ltbcdG6TRGHRjcdGsnUOhugZitVtbNV4FpWi6cgKOOvyJBNP
    c1STE4U6G7weNLWLBYy5d4ux2x8gkasJU26Qzns3dLlwR5EiUWMWea6xrkEmCMgZK9FGqkjWZCrX
    gzT/LCrBbBlDSgeF59N89iFo7+ryUp9/k5DPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNV
    HRMBAf8EBTADAQH/MB0GA1UdDgQWBBRge2YaRQ2XyolQL30EzTSo//z9SzANBgkqhkiG9w0BAQUF
    AAOCAQEA1nPnfE920I2/7LqivjTFKDK1fPxsnCwrvQmeU79rXqoRSLblCKOzyj1hTdNGCbM+w6Dj
    Y1Ub8rrvrTnhQ7k4o+YviiY776BQVvnGCv04zcQLcFGUl5gE38NflNUVyRRBnMRddWQVDf9VMOyG
    j/8N7yy5Y0b2qvzfvGn9LhJIZJrglfCm7ymPAbEVtQwdpf5pLGkkeB6zpxxxYu7KyJesF12KwvhH
    hm4qxFYxldBniYUr+WymXUadDKqC5JlR3XC321Y9YeRq4VzW9v493kHMB65jUr9TU/Qr6cf9tveC
    X4XSQRjbgbMEHMUfpIBvFSDJ3gyICh3WZlXi/EjJKSZp4A==
    -----END CERTIFICATE-----
    GlobalSign Root CA - R2
    =======================
    -----BEGIN CERTIFICATE-----
    MIIDujCCAqKgAwIBAgILBAAAAAABD4Ym5g0wDQYJKoZIhvcNAQEFBQAwTDEgMB4GA1UECxMXR2xv
    YmFsU2lnbiBSb290IENBIC0gUjIxEzARBgNVBAoTCkdsb2JhbFNpZ24xEzARBgNVBAMTCkdsb2Jh
    bFNpZ24wHhcNMDYxMjE1MDgwMDAwWhcNMjExMjE1MDgwMDAwWjBMMSAwHgYDVQQLExdHbG9iYWxT
    aWduIFJvb3QgQ0EgLSBSMjETMBEGA1UEChMKR2xvYmFsU2lnbjETMBEGA1UEAxMKR2xvYmFsU2ln
    bjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKbPJA6+Lm8omUVCxKs+IVSbC9N/hHD6
    ErPLv4dfxn+G07IwXNb9rfF73OX4YJYJkhD10FPe+3t+c4isUoh7SqbKSaZeqKeMWhG8eoLrvozp
    s6yWJQeXSpkqBy+0Hne/ig+1AnwblrjFuTosvNYSuetZfeLQBoZfXklqtTleiDTsvHgMCJiEbKjN
    S7SgfQx5TfC4LcshytVsW33hoCmEofnTlEnLJGKRILzdC9XZzPnqJworc5HGnRusyMvo4KD0L5CL
    TfuwNhv2GXqF4G3yYROIXJ/gkwpRl4pazq+r1feqCapgvdzZX99yqWATXgAByUr6P6TqBwMhAo6C
    ygPCm48CAwEAAaOBnDCBmTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4E
    FgQUm+IHV2ccHsBqBt5ZtJot39wZhi4wNgYDVR0fBC8wLTAroCmgJ4YlaHR0cDovL2NybC5nbG9i
    YWxzaWduLm5ldC9yb290LXIyLmNybDAfBgNVHSMEGDAWgBSb4gdXZxwewGoG3lm0mi3f3BmGLjAN
    BgkqhkiG9w0BAQUFAAOCAQEAmYFThxxol4aR7OBKuEQLq4GsJ0/WwbgcQ3izDJr86iw8bmEbTUsp
    9Z8FHSbBuOmDAGJFtqkIk7mpM0sYmsL4h4hO291xNBrBVNpGP+DTKqttVCL1OmLNIG+6KYnX3ZHu
    01yiPqFbQfXf5WRDLenVOavSot+3i9DAgBkcRcAtjOj4LaR0VknFBbVPFd5uRHg5h6h+u/N5GJG7
    9G+dwfCMNYxdAfvDbbnvRG15RjF+Cv6pgsH/76tuIMRQyV+dTZsXjAzlAcmgQWpzU/qlULRuJQ/7
    TBj0/VLZjmmx6BEP3ojY+x1J96relc8geMJgEtslQIxq/H5COEBkEveegeGTLg==
    -----END CERTIFICATE-----
    .... more certificates ....
```

The CA bundle needs to be configured in the `KubermaticConfiguration`. By default
the configuration refers to the `ca-bundle` ConfigMap that is shipped with the
`kubermatic-operator` Helm chart; if you need to use a different ConfigMap, adjust
the `spec.caBundle` settings:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  # This configures the global default CA bundle, which is used on the
  # master cluster and on all seeds, userclusters.
  caBundle:
    kind: ConfigMap
    # name of the ConfigMap;
    # must be in the same namespace as KKP
    name: ca-bundle
```


### KKP

The KKP Operator manages a single Ingress for the KKP API/dashboard. This by default includes setting up
the required annotations and spec settings for usage with cert-manager. However, if the cert-manager
integration is disabled, the cluster admin is free to manage these settings themselves.

To disable the cert-manager integration, set the `spec.ingress.certificateIssuer.name` to an empty string
in the `KubermaticConfiguration`:

```yaml
spec:
  ingress:
    certificateIssuer:
      name: ""
```

It is now possible to set `spec.tls` on the `kubermatic` Ingress to a custom certificate:

```yaml
spec:
  tls:
  - secretName: my-custom-kubermatic-cert
    hosts:
    - kubermatic.example.com
```

Refer to the [Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls)
for details on the format for certificate Secrets.

#### User Cluster

KKP automatically synchronizes the relevant CA bundle into each user cluster. The ConfigMap
is called `ca-bundle` and created in the `kube-system` namespace. For this reason it's important
to not put actual secrets into the CA bundle.

### Dex

The same technique used for KKP is applicable to Dex as well: Set the name of the cert issuer to an empty
string to be able to configure your own certificates. Update the Helm `values.yaml` used to deploy the
chart like so:

```yaml
dex:
  certIssuer:
    name: ""
```

Re-deploy the chart and the Certificate resource will not be created anymore. You have to manually create
a `dex-tls` Secret in Dex's namespace. This Secret follows the
[same format](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) as the one for KKP's API.

### Identity-Aware Proxy

The configuration is identical to Dex: Disable the cert issuer's name and then manually create the TLS
certificates.

```yaml
iap:
  certIssuer:
    name: ""
```

For each configured Deployment (`iap.deployments`) a matching Secret needs to be created. For a Deployment
named `grafana`, the Secret needs to be called `grafana-tls`.

### Token Validation

Both the KKP API and the OAuth-Proxy from the IAP need to validate the OAuth tokens (generated by Dex,
by default). If the the token issuer uses a custom CA, this CA needs to be configured for KKP and all
IAPs.

In both cases, the full certificate chain (including intermediates) needs to be configured.

#### KKP API

The token issuer (not to be confused with a cert-manager certificate issuer) is configured in the
`KubermaticConfiguration` and by default requires a valid certificate. The required adjustments for this
are the same for custom internal or external CA's.

```yaml
spec:
  auth:
    tokenIssuer: https://example.com/dex

    # this should never be enabled in production environments
    skipTokenIssuerTLSVerify: false
```

If the certificate used for Dex is not issued by a CA that is trusted by default (e.g. Let's Encrypt),
the issuing CA's certificate chain needs to be set via a Custom CA.

Do note that if the [OIDC Endpoint Feature]({{< ref "../../OIDC-Provider-Configuration" >}}) is enabled in KKP, this CA bundle
is also configured for the Kubernetes apiserver, so that it can also validate the tokens issued by Dex.

#### IAP

The certificate chain can be put into a Kubernetes Secret and then be referred to from the `values.yaml`.
Create a Secret inside the IAP's namespace (`iap` by default) and then update your `values.yaml` like so:

```yaml
iap:
  customProviderCA:
    secretName: my-ca-secret
    secretKey: ca.crt
```

Re-deploy the `iap` Helm chart to apply the changes.

## Wildcard Certificates

Generally the KKP stack is built to use dedicated certificates for each Ingress / application, but it's
possible to instead configure a single (usually wildcard) certificate in nginx that will be used as the
default certificate for all domains.

As with all other custom certificates, create a new Secret with the certificate and private key in it,
and then adjust your Helm `values.yaml` to configure nginx like so:

```yaml
nginx:
  extraArgs:
    # The value of this flag is in the form "namespace/name".
    - '--default-ssl-certificate=mynamespace/mysecret'
```

Redeploy the `nginx-ingress-controller` Helm chart to enable the changes.
