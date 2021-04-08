+++
title = "Datacenters"
date = 2021-04-07T12:07:15+02:00
weight = 10

+++

## Datacenter concept

Datacenters are an integral part of Kubermatic. They define physical datacenters in which the user clusters are created.
Datacenters, as Kubermatic resources, are a part of the Seed resource, and all user clusters of that datacenter are handled by its respected Seed Cluster.

The datacenter structure contains the following fields:


- `country` -- Country code of the DC location. It's purely cosmetic and reflected by a flag shown in the UI.
- `location` -- Optional: Detailed location of the cluster, like "Hamburg" or "Datacenter 7". For informational purposes in the Kubermatic dashboard only.
- `nodeSettings` -- Node holds node-specific settings, like e.g. HTTP proxy, Docker
   registries and the like. Proxy settings are inherited from the seed if
   not specified here.
- `spec` one of:
    - `digitalocean` -- Cloud-specific configuration for DigitalOcean DCs.
    - `bringyourown` -- Specifies a DC that doesn't use any cloud-provider-specific features
    - `aws` -- Cloud-specific configuration for AWS DCs.
    - `azure` -- Cloud-specific configuration for Azure DCs.
    - `openstack` -- Cloud-specific configuration for Openstack DCs.
    - `packet` -- Cloud-specific configuration for Packet DCs.
    - `gcp` -- Cloud-specific configuration for GCP DCs.
    - `hetzner` -- Cloud-specific configuration for Hetzner DCs.
    - `vsphere` -- Cloud-specific configuration for vSphere DCs.
    - `kubevirt` -- Cloud-specific configuration for KubeVirt DCs.
    - `alibaba`-- Cloud-specific configuration for Alibaba DCs.
    - `anexia` -- Cloud-specific configuration for Anexia DCs.
    - and
    - `enforceAuditLogging` -- enforces audit logging on every cluster within the DC, ignoring cluster-specific settings.
    - `enforcePodSecurityPolicy` -- enforces pod security policy plugin on every clusters within the DC, ignoring cluster-specific settings
    - `requiredEmailDomain` -- (deprecated since v2.13) Optional string. Limits the availability of the datacenter to users with email addresses in the given domain.
    - `requiredEmailDomains` -- (since v2.13) Optional string array. Limits the availability of the datacenter to users with email addresses in the given domains.

Example specs for different providers:

```yaml

  #==================================
  #=========== OpenStack ============
  #==================================
  # The keys for non-seeds can be freely chosen.
  openstack-zone-1:
    # The location is shown in the KKP dashboard
    # and should be descriptive within each provider (e.g.
    # for AWS a good location name would be "US East-1").
    location: Datacenter 2

    # The country is also used by the dashboard to show
    # the corresponding flag and make it easier to select
    # the proper region.
    country: DE

    # Configure cloud provider-specific further information.
    spec:
      openstack:
        # Authentication endpoint for Openstack, must be v3
        auth_url: https://our-openstack-api/v3
        availability_zone: zone-1
        region: "region-1"
        # This DNS server will be set when KKP creates a network
        dns_servers:
        - "8.8.8.8"
        - "8.8.4.4"
        # Those are default images for nodes which will be shown in the Dashboard.
        images:
          ubuntu: "Ubuntu 18.04"
          centos: "CentOS 7"
          coreos: "CoreOS"
        # Enforce the creation of floating IP's for new nodes
        # Available since v2.9.0
        enforce_floating_ip: false
        # Gets mapped to the "manage-security-groups" setting in the cloud config.
        # See https://kubernetes.io/docs/concepts/cluster-administration/cloud-providers/#load-balancer
        # Defaults to true
        # Available since v2.9.2
        manage_security_groups: true

  #==================================
  #========== Digitalocean ==========
  #==================================
  do-ams2:
    location: Amsterdam
    country: NL
    spec:
      digitalocean:
        # Digitalocean region for the nodes
        region: ams2

  #==================================
  #============== AWS ===============
  #==================================
  aws-us-east-1a:
    location: US East (N. Virginia)
    country: US
    spec:
      aws:
        # Set default AMI ID's(HVM) for this region
        # Available since v2.10.0
        images:
          # Must be Ubuntu 18.04, defaults to https://aws.amazon.com/marketplace/pp/B07CQ33QKV
          ubuntu: "ami-07e101c2aebc37691"
          # Must be CentOS 7, defaults to https://aws.amazon.com/marketplace/pp/B00O7WM7QW
          centos: "ami-02eac2c0129f6376b"
          # CoreOS Container Linux, defaults to https://coreos.com/os/docs/latest/booting-on-ec2.html
          coreos: "ami-08e58b93705fb503f"
        # Region to use for nodes
        region: us-east-1

  #==================================
  #============ Hetzner =============
  #==================================
  hetzner-fsn1:
    location: Falkenstein 1 DC 8
    country: DE
    spec:
      hetzner:
        datacenter: fsn1-dc8

  #==================================
  #============ vSphere =============
  #==================================
  vsphere-office1:
    location: Office
    country: DE
    spec:
      vsphere:
        endpoint: "https://some-vcenter.com"
        datacenter: "Datacenter"
        datastore: "example-datastore"
        cluster: "example-cluster"
        allow_insecure: true
        root_path: "/Datacenter/vm/foo"
        templates:
          ubuntu: "ubuntu-template"
          centos: "centos-template"
          coreos: "coreos-template"
      requiredEmailDomains:
      - "kubermatic.com"
      - "example.com"

  #==================================
  #============= Azure ==============
  #==================================
  azure-westeurope:
    location: "Azure West europe"
    country: NL
    spec:
      azure:
        location: "westeurope"

  #==================================
  #============= GCP ================
  #==================================
  gcp-westeurope:
    location: "Europe West (Germany)"
    country: DE
    spec:
      gcp:
        region: europe-west3
        zone_suffixes:
        - c

  #==================================
  #============= Packet =============
  #==================================
  packet-ams1:
    location: "Packet AMS1 (Amsterdam)"
    country: NL
    spec:
      packet:
        facilities:
        - ams1

  #==================================
  #============= Alibaba ============
  #==================================
  alibaba-eu1:
    location: "Alibaba N2"
    country: NL
    spec:
      alibaba:
        region: "eu1"
    
  #==================================
  #============= Anexia ============
  #==================================
  anexia-ams1:
    location: "Anexia NL"
    country: NL
    spec:
      anexia:
        location: "ams"

```


## Datacenter management - CE

Datacenters are a part of the Seed resource and need to be managed by an Kubermatic operator on the Seed object.

## Datacenter management - EE

The EE offers 2 different ways to manage the datacenters. One way is using the dynamic datacenters feature through which
admins can manage Datacenters on Seeds through API/UI. This is the preferred and recommended way. The other way is through the
`datacenter.yaml` file which needs to be provided to the Kubermatic API server. 

### Dynamic Datacenters

The dynamic datacenters are activated by setting the `dynamic-datacenters` flag to `true` on the Kubermatic API server.

Admins can manage the datacenters through the admin panel:
![Admin panel datacenters](01-admin-panel-dc.png)

To create a new Datacenter, press the `+` icon and fill out the form:
![Add Datacenter](02-add-dc-1.png)

and add the provider spec based on the Datacenter provider:
![Add Datacenter Provider](02-add-dc-2.png)

The added datacenter can easily be found with the filtering functions:
![Find Datacenter](03-filter-to-find-dc.png)

It is also possible to edit the existing Datacenter, everything can be changed except the seed:
![Edit Datacenter](04-edit-dc.png)
*NOTICE: editing does not affect existing user clusters that were created using this datacenter*

When we are satisfied with our new datacenter, we can use it in the Cluster creation wizard:
![Use Datacenter](05-use-dc-in-cluster-creation.png)

To delete the datacenter, just click on the trash icon in the admin panel:
![Delete Datacenter](06-delete-dc.png)
*NOTICE: deleting does not affect existing user clusters that were created using this datacenter*


### Management through static files - datacenter.yaml

This option is activated by setting the `datacenters` flag on the Kubermatic API server and providing the path to the `datacenters.yaml` file. 

In this option all the Seeds and datacenters used in KKP will be taken from this file, Seed objects in the cluster won't have any effect. 

Example file:

```yaml
datacenters:
  #==================================
  #============== Seeds =============
  #==================================

  # The name needs to match the a context in the kubeconfig given to the API
  seed-1:
    # Defines this datacenter as a seed
    is_seed: true
    # Though not used, you must configured a provider spec even for seeds.
    # The bringyourown provider is a good placeholder, as it requires no
    # further configuration.
    spec:
      bringyourown: ~

  seed-2:
    is_seed: true
    spec:
      bringyourown: ~

  #==================================
  #======= Node Datacenters =========
  #==================================

  #==================================
  #=========== OpenStack ============
  #==================================
  # The keys for non-seeds can be freely chosen.
  openstack-zone-1:
    # The location is shown in the KKP dashboard
    # and should be descriptive within each provider (e.g.
    # for AWS a good location name would be "US East-1").
    location: Datacenter 2

    # The country is also used by the dashboard to show
    # the corresponding flag and make it easier to select
    # the proper region.
    country: DE

    # The name of the seed to use when creating clusters in
    # this datacenter; when someone creates a cluster with
    # nodes in this dc, the master components will live in seed-1.
    seed: seed-1

    # Configure cloud provider-specific further information.
    spec:
      openstack:
        # Authentication endpoint for Openstack, must be v3
        auth_url: https://our-openstack-api/v3
        availability_zone: zone-1
        region: "region-1"
        # This DNS server will be set when KKP creates a network
        dns_servers:
        - "8.8.8.8"
        - "8.8.4.4"
        # Those are default images for nodes which will be shown in the Dashboard.
        images:
          ubuntu: "Ubuntu 18.04"
          centos: "CentOS 7"
          coreos: "CoreOS"
        # Enforce the creation of floating IP's for new nodes
        # Available since v2.9.0
        enforce_floating_ip: false
        # Gets mapped to the "manage-security-groups" setting in the cloud config.
        # See https://kubernetes.io/docs/concepts/cluster-administration/cloud-providers/#load-balancer
        # Defaults to true
        # Available since v2.9.2
        manage_security_groups: true

  #==================================
  #========== Digitalocean ==========
  #==================================
  do-ams2:
    location: Amsterdam
    country: NL
    seed: seed-1
    spec:
      digitalocean:
        # Digitalocean region for the nodes
        region: ams2
```



