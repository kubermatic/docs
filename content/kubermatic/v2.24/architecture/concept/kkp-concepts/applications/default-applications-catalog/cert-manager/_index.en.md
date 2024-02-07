+++
title = "Cert-Manager Application"
linkTitle = "Cert-Manager"
enterprise = true
date = 2024-01-16T12:57:00+02:00
weight = 3

+++

# What is Cert-Manager?

Cert-Manager adds certificates and certificate issuers as resource types in Kubernetes clusters. It simplifies the process of obtaining, renewing and using certificates.

It can issue certificates from a variety of supported sources, including Let's Encrypt, HashiCorp Vault, and Venafi as well as private PKI.

It will ensure certificates are valid and up to date, and attempt to renew certificates at a configured time before expiry.

For more information on the Cert-Manager, please refer to the [official documentation](https://cert-manager.io/)

# How to deploy?

Cert-Manager is available as part of the KKP's default application catalog. 
It can be deployed to the user cluster either during the cluster creation or after the cluster is ready(existing cluster) from the Applications tab via UI.

* Select the Cert-Manager application from the Application Catalog.

![Select Cert-Manager Application](/img/kubermatic/common/applications/default-apps-catalog/01-select-application-cert-manager-app.png)

* Under the Settings section, select and provide appropriate details and clck `-> Next` button.

![Settings for Cert-Manager Application](/img/kubermatic/common/applications/default-apps-catalog/02-settings-cert-manager-app.png)

* Under the Application values page section, check the default values and add values if any required to be configured explicitly. Finally click on the `+ Add Application` to deploy the Cert-Manager application to the user cluster.

![Application Values for Cert-Manager Application](/img/kubermatic/common/applications/default-apps-catalog/03-applicationvalues-cert-manager-app.png)

A full list of available Helm values is on [cert-manager's ArtifactHub page](https://artifacthub.io/packages/helm/cert-manager/cert-manager).
