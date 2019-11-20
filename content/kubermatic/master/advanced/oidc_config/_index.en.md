+++
title = "OIDC Provider Configuration"
date = 2018-06-21T14:07:15+02:00
weight = 1
pre = "<b></b>"
+++

This manual explains how to configure OIDC providers to use them with Kubermatic.

## Default Configuration

By default Kubermatic uses Dex located on the same host, using the following base URL:

```plaintext
<PROTOCOL>//<HOST>/dex/auth
```

Where:

- `PROTOCOL` is currently used protocol
- `HOST` is currently used host

Base URL is followed by following query parameters:

```plaintext
<BASE_URL>?response_type=<RESPONSE_TYPE>&client_id=<CLIENT_ID>&redirect_uri=<REDIRECT_URI>&scope=<SCOPE>&nonce=<NONCE>
```

Where:

- `BASE_URL` is the OIDC provider base URL
- `RESPONSE_TYPE` is set to `id_token`
- `CLIENT_ID` is set to `kubermatic`
- `REDIRECT_URI` is set to `<PROTOCOL>//<HOST>/projects` which is root view of the application
- `SCOPE` is set to `openid email profile groups`
- `NONCE` is randomly generated, 32 character-long string

## Custom Configuration

The default configuration can be changed as Kubermatic supports other OIDC providers as well.
Configuration can be found in the `config.json` file, that is part of the application
configuration. Check the [Creating the Master Cluster `values.yaml`](/installation/install_kubermatic/_manual/#creating-the-master-cluster-values-yaml)
to find out how to specify the config.

In the config it is allowed to specify two optional parameters:

- `oidc_provider_url` that can be used to change the base URL of the OIDC provider (`BASE_URL`)
- `oidc_provider_scope` that can be used to change the scope of the OIDC provider (`SCOPE`)

A configuration of a OIDC provider may look like this:

```json
{
  "cleanup_cluster":  false,
  "custom_links": [],
  "default_node_count": 3,
  "openstack": {
    "wizard_use_default_user": false
  },
  "share_kubeconfig": false,
  "show_demo_info": false,
  "show_terms_of_service": false,
  "oidc_provider_url": "https://keycloak.kubermatic.test/auth/realms/test/protocol/openid-connect/auth",
  "oidc_provider_scope": "openid email profile roles"
}
```
