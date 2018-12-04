+++
title = "Kubermatic OIDC Authentication"
date = 2018-11-23T12:01:35+02:00
weight = 5
pre = "<b></b>"
+++

### Kubermatic OIDC authentication

Allows for using OIDC provider for example `dex` to authenticate to kubernetes clusters. You can use this feature to share access to your clusters with other users.
**Note** that this feature is experimental and not enabled by default. See [prerequisites](/advanced/oidc_auth/#prerequisites) section for instruction on how to enable it in your installation.

### How does it work

This section will demonstrate how to obtain and use `kubeconfig` to connect to a cluster. Note that the user, the one that wil generate `kubeconfig` will not have any permissions when accessing the cluster. You will have
to explicitly grant permissions by creating appropriate `RBAC` roles and bindings.

Before we start, the very first thing we need to do is to grant some permissions. We are going to utilize an existing `viewer` role and assign it to the user.
The user name will be taken directly from the email address which will be encoded in `kubeconfig` we are going to create. 
The following command grants read only access to the cluster to `lukasz@loodse.com`.

```
kubectl create clusterrolebinding lukaszviewer --clusterrole=view --user=lukasz@loodse.com
```

In order to demonstrate the feature we are going to need a working cluster. If you don't have one please see [how to create a cluster](/getting_started/create_cluster/) section.
If the feature was enabled on your installation you should see "Share cluster" button after navigating to "Cluster details" page.

![Kubermatic cluster details share cluster button](/img/advanced/oidc_auth/share_cluster_button.png)

Right after clicking on the button you will see a modal window where you can copy the generated link to your clipboard.

![Kubermatic share cluster link](/img/advanced/oidc_auth/share_cluster_modal.png)

Next open a new window tab in the browser and paste the generated link. You will be redirected to a login page. On that page choose an authentication provider and provide valid credentials.
After successful authentication the browser will download `kubeconfig`.

Now it's time to use the config and list some resources for example `pods`. Even though there might be no `pods` running at the moment 
the command will not report any authorization related issues.

```
kubectl get po
No resources found.

```

If you deleted `lukaszviewer` binding and run the command again you would see the following output.

```
kubectl get po
Error from server (Forbidden): pods is forbidden: User "lukasz@loodse.com" cannot list pods in the namespace "default"
```

### Prerequisites 

In order to enable the feature the necessary flags must be passed to various applications:

`kubermatic-api-server` must be run with the following flags:
```
-feature-gates=OIDCKubeCfgEndpoint=true
-oidc-issuer-redirect-uri=REDACTED
-oidc-issuer-client-id=REDACTED
-oidc-issuer-client-secret=REDACTED
-oidc-issuer-cookie-hash-key=REDACTED
```

`kubermatic-controll-manager` must be run with the following flags.
Note that `oidc-ca-file` must contain OIDC provider's root CA certificates chain, 
see [Root CA certificates chain](/advanced/oidc_auth/#root-ca-certificates-chain) section that explains how to create the file.

```
-feature-gates=OpenIDAuthPlugin=true 
-oidc-issuer-url=REDACTED
-oidc-issuer-client-id=REDACTED 
-oidc-ca-file=REDACTED
```


`conifg.json` file for `kubermatic-dashboard` must contain the following fields:
```
{
...
"share_kubeconfig": true
}
```

### Root CA certificates chain

In order to verify OIDC provider's certificate in `kubermatic-controll-manager` when establishing TLS connection a public root CA certificate is required. Ideally the whole 
chain including all intermediary CAs certificates. Note that we expect that all certificates will be PEM encoded. 

For example if the certificate used by your provider was issued by Lest's Encrypt. You can visit [Let's Encrypt](https://letsencrypt.org/certificates) to download the necessary certificates 
and use the following command to prepare the bundle.


```
cat isrgrootx1.pem.txt lets-encrypt-x3-cross-signed.pem.txt > caBundle.pem

```
