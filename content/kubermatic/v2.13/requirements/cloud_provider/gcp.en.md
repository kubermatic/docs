+++
title = "Google Cloud Platform"
date = 2019-07-31T13:00:00+02:00
weight = 7

+++

## Google Cloud Platform

### Compute Engine API

For the access to the Compute Engine API it has to be enabled at the
[Google APIs console](https://console.developers.google.com/apis/dashboard).

### User Roles

The user for the *Google Service Account* that has to be created has to
have three roles:

- *Compute Admin: `roles/compute.admin`*
- *Service Account User: `roles/iam.serviceAccountUser`*
- *Viewer: `roles/viewer`*

If the [`gcloud`](https://cloud.google.com/sdk/install) CLI is installed, a service account can be created like follow:
```bash
# create new service account
gcloud iam service-accounts create k8c-cluster-provisioner

# get your service account id
gcloud iam service-accounts list
# get your project id
gcloud projects list

# create policy binding
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID --member 'serviceAccount:YOUR_SERVICE_ACCOUNT_ID' --role='roles/compute.admin'
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID --member 'serviceAccount:YOUR_SERVICE_ACCOUNT_ID' --role='roles/iam.serviceAccountUser'
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID --member 'serviceAccount:YOUR_SERVICE_ACCOUNT_ID' --role='roles/viewer'
```

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

```bash
# create a new json key for your service account
gcloud iam service-accounts keys create --iam-account YOUR_SERVICE_ACCOUNT k8c-cluster-provisioner-sa-key.json
# create base64 encoded secret
base64 -w 0 ./k8c-cluster-provisioner-sa-key.json
```

### Passing the Google Service Account

The base64 encoded secret of the service account will passed in the field `serviceAccount` of the
`cloudProviderSpec` of the machine deployment. The encoded secret can be entered in the UI field `Service Account`:

![GCE Service Account Secret](/img/kubermatic/v2.13/requirements/cloud_provider/gce_credentials.png)
