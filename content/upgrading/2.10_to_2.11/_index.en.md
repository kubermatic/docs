+++
title = "From 2.10 to 2.11"
date = 2018-10-23T12:07:15+02:00
publishDate = 2019-07-30T00:00:00+00:00
weight = 13
pre = "<b></b>"
+++

## `values.yaml` structure for service account tokens
A new flag `service-account-signing-key` was added to the Kubermatic API. It is used to sign service account tokens via
HMAC. It should be unique per Kubermatic installation and can be generated with the command: `base64 -w0 /dev/urandom |head -c 100`
The value for this flag must be stored in `auth` section for `kubermatic`

For example:
```
kubermatic:
  auth:
    serviceAccountKey: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```
