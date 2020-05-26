+++
title = "Adding the Custom Links to the Dashboard"
date = 2018-06-21T14:07:15+02:00
weight = 1

+++

This manual explains how to add custom links to the application. They may be used to link to any services and will
be displayed in the application menu. Following section describes how to configure them.

## Adding the Custom Links

Custom links should be specified in the `config.json` file, that is part of the application configuration.
Check the [Creating the Master Cluster `values.yaml`](../../installation/install_kubermatic/_manual/#creating-the-master-cluster-values-yaml)
to find out how to specify the Dashboard's config.

Definition of a single custom link consists of three fields:

- `label` - Label that will be displayed in the side navigation. This field is required.
- `url` - URL of the link. This field is required.
- `icon` - URL of a icon to display. This field is optional. If it is empty, icon from the default set will be used.

A configuration of a single link may look like this:

```json
"custom_links": [
  {
    "label": "Some Label",
    "url": "https://www.some.url"
  }
]
```

### Examples

Let's assume that we have following configuration of the Dashboard:

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
  "show_terms_of_service": false
}
```

Application looks like this:

![Clean state](/img/advanced/custom_links/clean.png)

And we would like to add some links to the external services used by the team.

As a first step we need to change the application config:

```json
{
  "cleanup_cluster":  false,
  "custom_links": [
    {
      "label": "Twitter",
      "url": "https://www.twitter.com/loodse"
    },
    {
      "label": "GitHub",
      "url": "https://github.com/kubermatic"
    },
    {
      "label": "Slack",
      "url": "http://slack.kubermatic.io/"
    }
  ],
  "default_node_count": 3,
  "openstack": {
    "wizard_use_default_user": false
  },
  "share_kubeconfig": false,
  "show_demo_info": false,
  "show_terms_of_service": false
}
```

After applying the changes the application should look following:

![Default icons](/img/advanced/custom_links/default_icons.png)

As you can see icons from the default set were used. The services were recognized by the application that is looking
for matches in labels and in the URL-s of provided links.

Let's change some of the icons:

```json
{
  "cleanup_cluster":  false,
  "custom_links": [
    {
      "label": "Twitter",
      "url": "https://www.twitter.com/loodse",
      "icon": "http://www.stickpng.com/assets/images/580b57fcd9996e24bc43c53e.png"
    },
    {
      "label": "GitHub",
      "url": "https://github.com/kubermatic",
      "icon": "/assets/images/icons/custom/github.svg"
    },
    {
      "label": "Slack",
      "url": "http://slack.kubermatic.io/"
    }
  ],
  "default_node_count": 3,
  "openstack": {
    "wizard_use_default_user": false
  },
  "share_kubeconfig": false,
  "show_demo_info": false,
  "show_terms_of_service": false
}
```

Notice, that URL-s from inside the container can also be used. Icons can be mounted into
the application container and then displayed.

After applying the changes the application should look following:

![Custom icons](/img/advanced/custom_links/custom_icons.png)
