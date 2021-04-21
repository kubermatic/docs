+++
title = "Using Service Accounts"
date = 2021-02-10T11:07:15+02:00
weight = 15
+++

This document describes how to use a Service Accounts in Kubermatic Kubernetes Platform (KKP).
The main Service Account concept you can find [here]({{< ref "../../service_account">}}) .

## Managing Service Accounts and Tokens

A service account is a special type of user account that belongs to the KKP project. Once you decide that you need
a service account, you can add one in Kubermatic dashboard.

![Service account](/img/kubermatic/v2.17/guides/service_account/serviceAccount.png)

Users can create many Service Accounts (SA) with unique names in the project scope. 

![Create service account](/img/kubermatic/v2.17/guides/service_account/createServiceAccount.png)

Over time, as you create more and more SA, you might lose track of which SA is used for what purpose. The display name
of a SA is a good way to capture additional information about the service account, such as the purpose of the SA.

The service account can have multiple tokens with unique names. The service account token is visible to the user during creation.

![Create service account](/img/kubermatic/v2.17/guides/service_account/createServiceAccountToken.png)

{{% notice note %}}
**Note:** Make sure to save this token at a safe place on your own device. It cannot be displayed again after closing the dashboard window.
{{% /notice %}}

Users can manage tokens. At any time, you can revoke any personal access token by clicking the respective `Regenerate Service Account Token` button under the Token area.
You can also change a token name. It is possible to delete a service account token and then create a new  with the same name.

![Create service account](/img/kubermatic/v2.17/guides/service_account/manageToken.png)

You can see when a token was created and when will expire.

## Using service accounts with KKP

 - You can create a cluster in the same project with different service accounts.

 - You can grant `editor` or `viewer` roles to service accounts to define access group.

 - Deleting a service account which was used in cluster creation does not affect the cluster, as the owner of the cluster
   is the user which created the service account.


## Accessing API via Service Account Token

A client that wants to authenticate itself with a server can then do so by including an `Authorization` request header
field with the service account token:

For getting project cluster list you can use:

```HTTP
GET http://localhost:8080/api/v2/projects/jnpllgp66z/clusters
Accept: application/json
Authorization: Bearer aaa.bbb.ccc
```

You can also use `curl` command to reach API endpoint:

```
curl -i -H "Accept: application/json" -H "Authorization: Bearer aaa.bbb.ccc" -X GET http://localhost:8080/api/v2/projects/jnpllgp66z/clusters
```
