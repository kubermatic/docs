+++
title = "Start with KKP"
description = "Start.kubermatic.io is a web application tool that bootstraps your Kubermatic Kubernetes Platform within a few minutes in an automated way with applied GitOps principles."
weight = 1

+++

![Kubermatic Kubernetes Platform logo](/img/KubermaticKubernetesPlatform-logo.jpg)

## What is [start.kubermatic.io](https://start.kubermatic.io)?

A web application and additional tools that bootstraps your Kubermatic Kubernetes Platform within a few minutes in an automated way with applied GitOps principles.

This documentation provides you with the details of your journey.

![High-level Flow](flow.png?width=700px&classes=shadow,border "High-level Flow")

Check the [Concepts]({{< ref "./concepts/" >}}) page before starting to understand the used tools and prerequisites.

Follow the steps in [Guides]({{< ref "./guides/" >}}) for a detailed explanation of all steps and understanding of generated content.

Last but not least, there are a bunch of [Operations and Troubleshooting Guides]({{< ref "./cheat_sheets/" >}}) ready for you as well.

## Disclaimer
This project is in early version at this stage.

This project should serve mainly for the onboarding purposes and easiness to start with KKP. Make sure that you fully
understand all parts and perform internal security checks before making your setup a production ready.

At this stage, there are following limitations:
 * only AWS and vSphere are available as the cloud providers
 * GitHub and GitLab are supported for storing and integration with GitOps tool
 * KKP CE edition is used.

All the above limitations may change in upcoming iterations.

{{% notice info %}}
If any of above limitations are blocking you, you can install KKP from scratch by following our
[KKP Installation guide]({{< ref "../guides/installation/" >}}).
{{% /notice %}}

{{% notice tip %}}
For latest updates follow us on Twitter [@Kubermatic](https://twitter.com/Kubermatic)
{{% /notice %}}
