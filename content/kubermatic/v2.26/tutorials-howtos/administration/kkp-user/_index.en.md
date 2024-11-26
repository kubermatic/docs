+++
title = "Kubermatic User"
date = 2021-10-08T11:11:15+02:00
weight = 20
+++

Initially Kubermatic does not know about any user that can access the Dashboard, because those are managed by the configured OIDC.

When a user authenticates for the first time at the Dashboard, an internal User representation is created based on the values provided by the OIDC.

Example User representation:

```
apiVersion: kubermatic.k8c.io/v1
kind: User
metadata:
  name: e0465fecc52a995ab349675d2ecad3189d18cdfa93f0a52693e6d33ec23af3b1
spec:
  admin: false
  email: jane@example.com
  id: 70c6e2727e9ef316188e56e574105486438ae38064c66464213ba1e4_KUBE
  name: Jane Doe
```

# Initial Admin

After the installation of Kubermatic Kubernetes Platform the first account that authenticates at the Dashboard is elected as an admin.

The account is then capable of setting admin permissions via the [dashboard]({{< ref "../admin-panel/administrators" >}}) .

# Granting Admin Permission via kubectl

Make sure the account logged in once at the Kubermatic Dashboard.

Now you can edit the user with `kubectl edit user` command in the master cluster.

Setting the `admin` flag to `true` will provide admin access to the user.
