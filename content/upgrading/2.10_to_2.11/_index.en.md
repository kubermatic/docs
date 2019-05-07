+++
title = "Upgrading from 2.10 to 2.11"
date = 2019-05-03T12:07:15+02:00
#publishDate = 2019-07-30T00:00:00+00:00
weight = 50
pre = "<b></b>"
+++

## Helm Charts

### Kubermatic: service account tokens structure

A new flag `service-account-signing-key` was added to the Kubermatic API. It is used to sign service account tokens via
HMAC. It should be unique per Kubermatic installation and can be generated with the command: `base64 -w0 /dev/urandom | head -c 100`
The value for this flag must be stored in `auth` section for `kubermatic`

For example:

```yaml
kubermatic:
  auth:
    serviceAccountKey: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### Elasticsearch 7.0

Kubermatic 2.11 ships with Elasticsearch 7.0. Version 7 can do rolling upgrades only if the Elasticsearch cluster is already running on version 6.7 (the version shipped in Kubermatic 2.10).

If you are already running Kubermatic 2.10, you can simply deploy the updated Helm chart and the nodes will update one by one to Elasticsearch 7.

If you are running an older Kubermatic release, you must either upgrade to Kubermatic 2.10 first or shutdown the entire Elasticsearch cluster before doing the upgrade (e.g. by purging the chart before installing the new chart).

{{% notice warning %}}
Note that because Elasticsearch 7.0 changed its database fields, you cannot downgrade to any previous release after the upgrade.
{{% /notice %}}

### Alertmanager

Alertmanager 0.17 changed the included `amtool` to be incompatible with previous versions. This only affects you if you ever exported silences and wanted to re-import them. Please consult the [release notes](https://github.com/prometheus/alertmanager/releases/tag/v0.17.0) for more information.

The `alertmanager.version` field in the Chart's `values.yaml` was deprecated and replaced with the more common `alertmanager.image.tag` field. Update your Helm values if you have ever set the Alertmanager's version explicitly. The `migrate-values` command of the Kubermatic-Installer can automate this migration step for you.

### NodePort-Proxy

The top-level key in the `values.yaml` has been fixed and is now called `nodePortProxy`. Please update your Helm values as the old name (`nodePortPoxy`) is now deprecated.
