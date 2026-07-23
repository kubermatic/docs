+++
title = "Glossary"
date = 2026-06-11T09:00:00+02:00
weight = 5
+++

- **logical switch**: the virtual layer-2 segment that a subnet maps to in OVN.
- **logical router**: the virtual router that a tenant or VPC maps to.
- **ACL**: one compiled firewall rule entry in the network control plane. A single policy compiles
  to several ACLs.
- **port-group**: a named set of ports that rules attach to; the form a security group takes in
  OVN.
- **ovn-northd**: the compiler that turns logical configuration into data-plane flows. Its CPU
  usage is the classic scale signal.
- **NB-DB / SB-DB**: OVN's northbound database (the desired logical state) and southbound database
  (the compiled state that the nodes consume).
- **conntrack**: the kernel's tracked-connections table.
- **VIP**: a service's virtual IP, programmed as an OVN load-balancer entry.
- **canary**: an always-on probe VM or pod whose latency and readiness are watched to measure the
  effect on existing workloads.
- **programmed**: the object exists in the network control plane (visible in the NB database), not
  only in the Kubernetes API.
