+++
title = "Custom Links"
date = 2020-02-10T11:07:15+02:00
weight = 20
+++

Custom Links section in the Admin Panel allows user to control the way custom links are displayed in the Kubermatic
Dashboard. Choose the place that suits you best, whether it is a sidebar, footer or a help & support panel.

![Admin Panel](/img/kubermatic/v2.22/ui/custom_links.png?height=250px&classes=shadow,border "Custom Links Settings")

- ### [Managing Custom Links](#managing-custom-links)
- ### [API Documentation](#api-documentation)
- ### [Terms of Service](#terms-of-service)
- ### [Demo Information](#demo-information)

## Managing Custom Links
Custom links have following properties:
- Label - label displayed next to the icon or in the tooltip if the link is located in the footer.
- URL - target location of the custom link.
- Icon - path of the icon inside or outside the container can be used, i.e. `/assets/images/icons/custom.png` or
  `http://example.com/icon.png`. It can be also left empty, then KKP UI with try to auto discover the icon based on the
  provided URL.
- Location - links can be placed in the footer, sidebar and help & support section.

Use the form to add and delete custom links visible in the KKP UI. The changes should be visible immediately after
performing any changes.

## API Documentation
After enabling API documentation checkbox `API Documentation` link will be shown in the KKP UI help panel. It links to
the KKP API documentation.

![Help Panel](/img/kubermatic/v2.22/ui/help_panel.png?height=250px&classes=shadow,border "Help Panel")

![API Documentation](/img/kubermatic/v2.22/ui/api_docs.png?height=250px&classes=shadow,border "API Documentation")

## Terms of Service
After enabling terms of service checkbox `Terms of Service` link will be shown in the KKP UI footer. It links to the
page with terms of use information.

## Demo Information
After enabling demo information checkbox `Demo system` information will be shown in the KKP UI footer.
