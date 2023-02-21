+++
title = "Google Cloud Platform"
date = 2019-07-31T13:00:00+02:00
weight = 3
+++

KKP userclusters can use the Google Cloud Platform (GCP) to host worker nodes. To provision
a cluster on GCP, a Service Account must be provided to KKP. This Service Account needs to
have the appropriate permissions and be properly encoded.

## Access Credentials

### Compute Engine API

To access the Compute Engine API, it has to be enabled first in the
[Google APIs console](https://console.developers.google.com/apis/dashboard).

### Service Account

The user for the *Google Service Account* that has to be created has to have three roles:

- *Compute Admin*: `roles/compute.admin`
- *Service Account User*: `roles/iam.serviceAccountUser`
- *Viewer*: `roles/viewer`

To create a new service account, you can use the [Google IAM Console](https://console.cloud.google.com/iam-admin/serviceaccounts). Alterntively, if the [`gcloud`](https://cloud.google.com/sdk/install)
CLI is installed, a service account can be created as follows:

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

### Credentials

To use the newly created Service Account, a key for it has to be created. This can be
done either in the IAM console (make sure to download the JSON-encoded key) or using the
`gcloud` command line tool like so:

```bash
gcloud iam service-accounts keys create --iam-account YOUR_SERVICE_ACCOUNT k8c-cluster-provisioner-sa-key.json
```

The JSON-encoded service account now needs to be base64-encoded before it can be used in KKP.
Make sure to not create automated linebreaks in the base64 output (i.e. use `-w`):

```bash
base64 -w 0 ./k8c-cluster-provisioner-sa-key.json
```

### Passing the Service Account

The base64-encoded key for the service account can be passed in the field `serviceAccount` of the
`cloudProviderSpec` of the machine deployment. The encoded key can be entered in the UI field `Service Account`:

![GCP Service Account Key](/img/kubermatic/main/ui/gcp_credentials.png?classes=shadow,border "Cluster Wizard Credential Step")
