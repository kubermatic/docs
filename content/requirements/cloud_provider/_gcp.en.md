+++
title = "Google Cloud Platform"
date = 2019-07-31T13:00:00+02:00
weight = 7
pre = "<b></b>"
+++

## Google Cloud Platform

### User Roles

The user for the *Google Service Account* that has to be created has to
have three roles:

- *Compute Admin*
- *Service Account User*
- *Viewer*

### Google Service Account

A *Google Service Account* for the platform has to be created, see
[Creating and managing service accounts](https://cloud.google.com/iam/docs/creating-managing-service-accounts).
The result is a JSON file containing the fields

- `type`
- `project_id`
- `private_key_id`
- `private_key`
- `client_email`
- `client_id`
- `auth_uri`
- `token_uri`
- `auth_provider_x509_cert_url`
- `client_x509_cert_url`

The private key is BASE64 containing the newlines as non-escaped strings
*"\n"*. So to avoid the resulting troubles the machine controller expects
the whole service account encoded in BASE64.

### Passing the Google Service Account

The service account will passed in the field `serviceAccount` of the
`cloudProviderSpec`. If unset the environment variable `GOOGLE_SERVICE_ACCOUNT`
will be taken.
