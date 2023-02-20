+++
title = "Seed Configurations"
date = 2023-02-20
weight = 20
+++


Seed Configurations view in the Admin Panel allows administrators to see available seeds
in KKP. This view provides listing of seeds, providers, datacenters and clusters associated to datacenter. All of these will be described below.

{{% notice note %}}
Seed Configuration section is readonly view page. This page does not provider any **CRUD** operation.
{{% /notice %}}

- ### Listing seeds in KKP

![Seed Configurations](/img/kubermatic/main/tutorials/seed-configurations/seed_confgurations.png?classes=shadow,border "Seed Configurations List View")

Following view displays Summary of how many following are linked
- Providers
- Datacenters
- Clusters

- ### Listing of Providers

Following view displays details of seed and following table displays list of providers and displays summary of associated in 


- Datacenters
- Clusters

![Providers](/img/kubermatic/main/tutorials/seed-configurations/seed_confgurations_details.png?classes=shadow,border "Available providers per seed")


In order to view breakdown for datacenters click on to expansion panel for each provider.

- ### Listing of Datacenters per provider

Expansion panel shows list of each datacenter name and associated cluster per datacenter.

![Datacenters](/img/kubermatic/main/tutorials/seed-configurations/seed_confgurations_provider_datacenters.png?classes=shadow,border "Associated clusters per datacenter")
