+++
title = "Certificate Management"
date = 2024-01-10T15:50:00+02:00
+++

## Certificate Renewal

{{% notice warning %}}
In general, kubeone automatically updates certificates that are within 90 days of expiry automatically when updating your cluster. If you keep cluster updates in line with the [Kubernetes Support Period](https://kubernetes.io/releases/patch-releases/#support-period), there should be no need to manually re-new certificates.
{{% /notice %}}

In case you want to manually update your certificates, you can run the following:

```sh
kubeone apply --force-upgrade
```

This will renew all of your certificates and restart the kube-apiserver to make use of the updated certificates, assuming your certificates are within 90 days of expiry.
