+++
title = "Using Custom CAs"
date = 2021-02-10T11:07:15+02:00
weight = 10
+++

This document describes how to use a custom set of CA certificates in Kubermatic Kubernetes
Platform (KKP). A general understanding of TLS certificates is assumed.

KKP allows to configure a "CA bundle" (a set of CA certificates) per Seed cluster. This CA
bundle is then automatically injected into various components (like the KKP API, the
kube-apiserver, cloud-controller-managers etc.) to allow for self-signed certificates e.g.
in vSphere. Do note that the CA bundle configured in KKP is _the only_ source of CA certificates
for all of these components, meaning that no certificates are mounted from any of the Seed
cluster host systems.

## Configuration

The CA bundle is stored as a single ConfigMap in the `kubermatic` namespace. It needs to
have a `ca-bundle.pem` key, which is simply the collection of all PEM-encoded CA certificates.
A good source for a general purpose CA bundle is Mozilla's CA database. The curl maintainers
provide a [ready-to-use bundle file](https://curl.se/docs/caextract.html) that can be used as
a starting point and then extended with your own CAs.

KKP ships the CA bundle mentioned above by default in the `kubermatic-operator` Helm chart.
This means that after installing KKP, a usable default CA bundle is available right from the
start.

To override the CA bundle, either overwrite the `static/ca-bundle.pem` file in the
`kubermatic-operator` Helm chart with your own and then `helm upgrade` the operator, or manually
change the ConfigMap later using `kubectl edit`. Changes to the ConfigMap are picked up
automatically and are then reconciled.

A typical CA bundle ConfigMap must look like this:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ca-bundle
  namespace: kubermatic
data:
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

The CA bundle needs to be configured in the `KubermaticConfiguration`; you need to configure
the name of the ConfigMap in it:

```yaml
apiVersion: operator.kubermatic.io/v1alpha1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  # This configures the global default CA bundle, which is used on the
  # master cluster and on all seeds, userclusters.
  caBundle:
    # name of the ConfigMap;
    # must be in the same namespace as KKP
    name: ca-bundle
```

### User Cluster

KKP automatically synchronizes the relevant CA bundle into each user cluster. The ConfigMap
is called `ca-bundle` and created in the `kube-system` namespace. For this reason it's important
to not put actual secrets into the CA bundle.
