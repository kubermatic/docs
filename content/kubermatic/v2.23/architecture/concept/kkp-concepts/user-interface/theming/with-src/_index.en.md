+++
title = "With Source Access"
date = 2018-06-21T14:07:15+02:00
weight = 50

+++

## Preparing a New Theme With Access to the Sources

{{% notice note %}}
This approach gives user the possibility to reuse already defined code, work with `scss` instead of `css` and quickly
test your new theme before uploading it to the official deployment.
{{% /notice %}}

All available themes can be found inside `src/assets/themes` directory. Follow the below steps to prepare a new custom theme:

- Create a new `scss` theme file inside `src/assets/themes` directory called `custom.scss`. This is only a temporary name that can be changed later.
- As a base reuse code from one of the default themes, either `light.scss` or `dark.scss`.
- Register a new style in `src/assets/config/config.json` similar to how it's done for `light` and `dark` themes. As the `name` use `custom`.
    - `name` - refers to the theme file name stored inside `assets/themes` directory.
    - `displayName` - will be used by the theme picker available in the `Account` view to display a new theme.
    - `isDark` - defines the icon to be used by the theme picker (sun/moon).
    ```json
    {
      "openstack": {
        "wizard_use_default_user": false
      },
      "themes": [
        {
          "name": "custom",
          "displayName": "Custom",
          "isDark": false
        }
      ]
    }
    ```

- Make sure that theme is registered in the `angular.json` file before running the application locally. It is done for `custom` theme by default.
- Run the application using `npm start`, open the `Account` view under `User settings`, select your new theme and update `custom.scss` according to your needs.
  It is possible to override basically everything inside this theme file. In example if you want to change background color of a `mat-form-field` do this:
  ```scss
  .mat-form-field {
    background-color: red;
  }
  ```
  **TIP:** As currently selected theme name is saved inside user settings, change it back to one of the default themes before uploading your theme to the official deployment.
- Once your new theme is ready run `npm run build:themes`. It should create a `dist-themes` directory inside Kubermatic Kubernetes Platform (KKP) Dashboard directory with compiled `css` files of all themes
  stored inside `src/assets/themes` directory. Now you can rename your `custom.css` theme file to some other name, i.e. `solar.css`.

![Themes dir](/img/kubermatic/main/ui/themes_dir.png?classes=shadow,border "Themes dir")

- Now, update the `config.json` in [KubermaticSettings]({{< relref "../../../../../../references/crds/#kubermaticuiconfiguration" >}}) CR used by `Kubermatic Dashboard` Deployment and register the new theme same as it was done earlier.
  Make sure that `name` entry corresponds to the name of your theme file (without the `css` suffix).
- As the last step, mount your custom CSS theme file to the `dist/assets/themes` directory. To do so, specify `extraVolumes` and `extraVolumeMounts` in the [KubermaticSettings]({{< relref "../../../../../../references/crds/#kubermaticuiconfiguration" >}}) CR. Make sure not to override whole directory as default themes are required by the application.
- After application restart, theme picker should show your new theme.

![Theme picker](/img/kubermatic/main/ui/custom_theme.png?classes=shadow,border "Theme picker")
