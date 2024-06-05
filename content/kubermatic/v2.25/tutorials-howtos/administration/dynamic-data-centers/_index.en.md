+++
title = "Datacenters"
date = 2021-04-07T12:07:15+02:00
weight = 10

+++

## Datacenter Concept

Datacenters are an integral part of Kubermatic. Depending on the cloud provider, they define a zone that has network connection for all machines, for example for hyperscalers it would be an availability zone.
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
    - `requiredEmailDomains` -- (deprecated since v2.20) Optional string array. Limits the availability of the datacenter to users with email addresses in the given domains.
    - `requiredEmails` -- (since v2.20) Optional string array. Limits the availability of the datacenter to users with email addresses in the given domains.

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
        authURL: https://our-openstack-api/v3
        availabilityZone: zone-1
        region: "region-1"
        # This DNS server will be set when KKP creates a network
        dnsServers:
        - "8.8.8.8"
        - "8.8.4.4"
        # Those are default images for nodes which will be shown in the Dashboard.
        images:
          ubuntu: "Ubuntu 18.04"
          centos: "CentOS 7"
          coreos: "CoreOS"
        # Enforce the creation of floating IP's for new nodes
        # Available since v2.9.0
        enforceFloatingIP: false
        # Gets mapped to the "manage-security-groups" setting in the cloud config.
        # See https://kubernetes.io/docs/concepts/cluster-administration/cloud-providers/#load-balancer
        # Defaults to true
        # Available since v2.9.2
        manageSecurityGroups: true

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
        allowInsecure: true
        rootPath: "/Datacenter/vm/foo"
        templates:
          ubuntu: "ubuntu-template"
          centos: "centos-template"
          coreos: "coreos-template"
      requiredEmails:
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
        zoneSuffixes:
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

## Dynamic Datacenters

Admins can manage the datacenters through the admin panel:
![Dynamic Datacenters](/img/kubermatic/v2.25/ui/dc.png?classes=shadow,border "Dynamic Datacenters View")

To create a new Datacenter, press the `+` icon and fill out the form:
![Add Datacenter](/img/kubermatic/v2.25/ui/dc-add1.png?classes=shadow,border&height=600 "Dynamic Datacenters Add Dialog")

and add the provider spec based on the Datacenter provider:
![Add Datacenter Provider](/img/kubermatic/v2.25/ui/dc-add2.png?classes=shadow,border&height=600 "Dynamic Datacenters Add Dialog")

The added datacenter can easily be found with the filtering functions:
![Find Datacenter](/img/kubermatic/v2.25/ui/dc-filter.png?classes=shadow,border "Filter Datacenters")

It is also possible to edit the existing Datacenter, everything can be changed except the seed:
![Edit Datacenter](/img/kubermatic/v2.25/ui/dc-edit1.png?classes=shadow,border&height=600 "Dynamic Datacenters Edit Dialog")
*NOTICE: editing does not affect existing user clusters that were created using this datacenter*

![Edit Datacenter](/img/kubermatic/v2.25/ui/dc-edit2.png?classes=shadow,border&height=600 "Dynamic Datacenters Edit Dialog")

When we are satisfied with our new datacenter, we can use it in the Cluster creation wizard:
![Use Datacenter](/img/kubermatic/v2.25/ui/wizard-step1.png?classes=shadow,border "Use Datacenter during Cluster Creation")

To delete the datacenter, just click on the trash icon in the admin panel:
![Delete Datacenter](/img/kubermatic/v2.25/ui/dc-delete.png?classes=shadow,border&height=200 "Dynamic Datacenters Delete Dialog")
*NOTICE: deleting does not affect existing user clusters that were created using this datacenter*
