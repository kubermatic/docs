+++
title = "Changelog"
date = 2018-06-21T14:07:15+02:00
weight = 50
+++

Changelog feature allows informing users about all those new and shiny features, but also warn users about breaking
or action required changes.

- ### [Changelog Schema](#changelog-schema)
- ### [Configuring the Changelog](#configuring-the-changelog)
- ### [Overriding Embedded Changelog](#overriding-embedded-changelog)
- ### [Using Changelog](#using-changelog)

## Changelog Schema

This section will explain the schema of our changelog together with some information about supported categories.

### JSON Schema of the Changelog Entry
```json
{
  "type": "object",
  "properties": {
    "externalChangelogURL": {
      "type": "string"
    },
    "entries": {
      "type": "array",
      "items": [
        {
          "type": "object",
          "properties": {
            "category": {
              "type": "string"
            },
            "description": {
              "type": "string"
            },
            "links": {
              "type": "array",
              "items": [
                {
                  "type": "object",
                  "properties": {
                    "url": {
                      "type": "string"
                    },
                    "caption": {
                      "type": "string"
                    }
                  },
                  "required": [
                    "url",
                    "caption"
                  ]
                },
                {
                  "type": "object",
                  "properties": {
                    "url": {
                      "type": "string"
                    },
                    "caption": {
                      "type": "string"
                    }
                  },
                  "required": [
                    "url",
                    "caption"
                  ]
                }
              ]
            }
          },
          "required": [
            "category",
            "description"
          ]
        }
      ]
    }
  },
  "required": [
    "entries"
  ]
}
```

### Supported Changelog Categories
- `action-required`
- `added`
- `removed`
- `fixed`
- `changed`
- `deprecated`
- `security`

## Configuring the Changelog

The `changelog.json` file is available inside the `assets/config` directory and can be directly updated before building
and releasing the application. It is possible to also [override embedded changelog](#overriding-embedded-changelog)
after the release.

### Example of `changelog.json`

```json
{
  "externalChangelogURL": "https://github.com/kubermatic/kubermatic/blob/release/v2.17/CHANGELOG.md#kubermatic-217",
  "entries": [
    {
      "category": "action-required",
      "description": "Added logos and descriptions for the addons. In order to see the logos and description, addons have to be configured with AddonConfig CRDs with the same names as addons."
    },
    {
      "category": "added",
      "description": "Added User Settings, Cluster Addons management, RBAC management functionality and new Project View",
      "links": [
        {
          "url": "https://docs.kubermatic.com",
          "caption": "User Guide"
        }
      ]
    }
  ]
}
```

### Overriding embedded changelog

Assuming that you know how to exec into the container and copy resources from/to it, `changelog.json` can be simply
copied over to running KKP Dashboard container. It is stored inside the container in `dist/assets/config` directory.

##### Kubernetes
Assuming that the KKP Dashboard pod name is `kubermatic-dashboard-5b96d7f5df-mkmgh` you can copy changelog to the container
using the below command:

```bash
kubectl -n kubermatic cp ~/changelog.json kubermatic-dashboard-5b96d7f5df-mkmgh:/dist/assets/config
```

##### Docker
Assuming that the KKP Dashboard container name is `kubermatic-dashboard` you can copy changelog to the container using
the below command:

```bash
docker cp ~/changelog.json kubermatic-dashboard:/dist/assets/config
```

After that, simply restart the application, and it should pick up the new changelog.

## Using Changelog

Starting from version 2.17 of the KKP Dashboard it will be enabled and available by default. After every update, when the
version of the application changes it will be automatically shown right after logging in. Closing the changelog saves
last seen version in the user object in order to avoid showing it every time after logging in when there was no version
update. It is still possible to open it manually by using the `What's new` entry inside `Help & Support` panel.

![Opening Changelog](/img/kubermatic/main/ui/opening_changelog.png?classes=shadow,border)

An example changelog might look like the one below.

![Changelog](/img/kubermatic/main/ui/changelog.png?classes=shadow,border)

