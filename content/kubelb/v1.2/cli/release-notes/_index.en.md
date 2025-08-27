+++
title = "Release Notes"
date = 2024-03-15T00:00:00+01:00
weight = 40
+++


## Kubermatic KubeLB CLI  v0.1.0

- [Kubermatic KubeLB CLI  v0.1.0](#kubermatic-kubelb-cli--v010)
- [v0.1.0](#v010)
  - [Highlights](#highlights)
    - [Community Edition(CE)](#community-editionce)
    - [Enterprise Edition(EE)](#enterprise-editionee)

## v0.1.0

**GitHub release: [v0.1.0](https://github.com/kubermatic/kubelb-cli/releases/tag/v0.1.0)**

### Highlights

#### Community Edition(CE)

- Support for provisioning Load balancers with hostnames. THe hostnames are secured with TLS certificates and the DNS and traffic policies are managed by KubeLB.
- Status command has been introduced to get the status of the tenant. This includes the load balancer limit, allowed domains, wildcard domain, etc.
- Version command can be used to get the version of the CLI.
- Add supply chain security with SBOMs and cosign signatures for the CLI.

#### Enterprise Edition(EE)

- Tunneling has been introduced to allow users to tunnel locally running applications on their workstations or inside VMs and expose them over the internet without worrying about firewalls, NAT, DNS, and certificate issues.
