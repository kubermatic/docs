+++
title = "Datacenters"
date = 2019-10-10T12:07:15+02:00
weight = 10
pre = "<b></b>"
+++


# Overview

There are 2 types of datacenters:

- **Seed datacenter**, where Kubermatic's controller-manager and the control planes for each customer cluster are
  running.
- **Node datacenter**, where the customer worker nodes are provisioned.

Both are defined in a file named `datacenters.yaml`:

{{%expand "Sample datacenters.yaml"%}}
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
    # The location is shown in the Kubermatic dashboard
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
        # This DNS server will be set when Kubermatic creates a network
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

  #==================================
  #============== AWS ===============
  #==================================
  aws-us-east-1a:
    location: US East (N. Virginia)
    country: US
    seed: seed-2
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
        # Character of the zone in the given region
        zone_character: a

  #==================================
  #============ Hetzner =============
  #==================================
  hetzner-fsn1:
    location: Falkenstein 1 DC 8
    country: DE
    seed: seed-1
    spec:
      hetzner:
        datacenter: fsn1-dc8

  #==================================
  #============ vSphere =============
  #==================================
  vsphere-office1:
    location: Office
    country: DE
    seed: europe-west3-c
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

  #==================================
  #============= Azure ==============
  #==================================
  azure-westeurope:
    location: "Azure West europe"
    country: NL
    seed: europe-west3-c
    spec:
      azure:
        location: "westeurope"

  #==================================
  #============= GCP ================
  #==================================
  gcp-westeurope:
    location: "Europe West (Germany)"
    seed: europe-west3-c
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
    seed: europe-west3-c
    country: NL
    spec:
      packet:
        facilities:
        - ams1

```
{{%/expand%}}

The datacenter structure contains the following fields:

- `seed` -- Tells whether the DC is supposed to be a seed or a normal DC. `true` or `false`.
- `spec`:
  - `seed` -- Which seed to use to deploy the master components of this DCs clusters.
  - `country` -- Country code of the DC location. It's purely cosmetic and reflected by a flag shown in the UI.
  - `location` -- Name of the DC's location.
  - `provider` -- Name of the providing entity. Optional.
  - `requiredEmailDomain` -- Optional. Limits the availability of the datacenter to users with email addresses in the given domain.
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

