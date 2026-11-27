+++
title = "Service Accounts"
weight = 3
+++

Service accounts are identities for machines rather than people, such as CI pipelines, GitOps
controllers or scripts that work with your KDP workspace. You give a service account roles, then
create long-lived tokens that an external application uses to authenticate.

Service accounts belong to the current organisation or project. See
[Organisations, Projects and Namespaces]({{< ref "/developer-platform/v1.2/guides/platform-users/organizations-and-projects" >}}).

Keep two things in mind:

- A service account lives in one namespace. Its **namespace roles** apply only in that namespace,
  while its **cluster-wide roles** apply across the whole organisation or project.
- Tokens don't expire. They stay valid until you revoke them or delete the service account.

For the Kubernetes objects behind service accounts, see
[Members and service accounts]({{< ref "/developer-platform/v1.2/introduction/concepts/rbac#members-and-service-accounts" >}}).

## Viewing service accounts

Open **Service Accounts** in the sidebar. The table shows each service account's namespace, roles,
number of tokens and creation date. Each role is tagged **Namespace** or **Cluster-wide**. You can
search by name or namespace, and filter by role or by whether a service account has tokens.

Service accounts named `default` are not listed.

To open this page you need permission to list `serviceaccounts` in the workspace.

## Creating a service account

1. Click **Create Service Account**.
2. Enter a **Name**. It can have at most 63 characters, contain only lowercase letters, digits and
   hyphens, and must start and end with a letter or digit.
3. Select the **Namespace** the service account lives in.
4. Select roles. You need at least one, from either list:
   - **Namespace roles** apply only within the selected namespace.
   - **Cluster-wide roles** apply across the entire organisation or project.

   These are the same roles you assign to members; see
   [Members and Roles]({{< ref "/developer-platform/v1.2/guides/platform-users/members-and-roles#roles" >}}).
5. Click **Create Service Account**.

To change the roles later, open the service account's menu (**...**) and choose **Update Roles**.
This needs permission to create and delete `rolebindings`, or `clusterrolebindings` for
cluster-wide roles. Without the latter, the **Cluster-wide roles** list is disabled.

## Creating a token

1. Click the service account's name to open its details.
2. Click **Create Token**, enter a **Token Name** and click **Create Token**.
3. The dashboard waits for Kubernetes to generate the token, then shows it in the **Token Created**
   dialog. Use **Copy token** or **Show token** to get the value.

{{% notice warning %}}
The dashboard only shows the token once, so copy it before closing the dialog. The value is still
stored in the token Secret: anyone who can read Secrets in that namespace can read the token. Give
`get secrets` permission in that namespace only to people who may use the service account.
{{% /notice %}}

To create tokens you need permission to create `secrets` in the namespace.

## Using a token

Use the token as a bearer token against the KDP API endpoint of the workspace. For example, to build
a kubeconfig, download your own kubeconfig from the user menu (**Download Kubeconfig**), then
replace the user credentials with the token:

```bash
kubectl config set-credentials my-ci-bot --token=<token>
kubectl config set-context --current --user=my-ci-bot
kubectl get <resource> --namespace <namespace>
```

The dashboard does not create a kubeconfig for service accounts.

## Revoking a token

On the service account's details page, open the token's menu (**...**) and choose **Revoke token**.
This deletes the token Secret, and the token stops working. You need permission to delete `secrets`
in the namespace.

## Deleting a service account

Open the service account's menu (**...**), choose **Delete** and type the service account name to
confirm. This deletes the service account together with its role bindings and all its tokens. If
the service account has cluster-wide roles, you also need permission to delete
`clusterrolebindings`.

## Related topics

- [Members and Roles]({{< ref "/developer-platform/v1.2/guides/platform-users/members-and-roles" >}})
- [RBAC]({{< ref "/developer-platform/v1.2/introduction/concepts/rbac" >}})
