+++
title = "Glossary"
date = 2026-06-11T09:00:00+02:00
weight = 5
+++

- **logical switch** — the virtual L2 segment a subnet maps to in OVN.
- **logical router** — the virtual router a tenant/VPC maps to.
- **ACL** — one compiled firewall rule entry in the network control plane; a policy compiles to
  several ACLs.
- **port-group** — a named set of ports that rules attach to; what a security group becomes.
- **ovn-northd** — the compiler that turns logical configuration into data-plane flows; its CPU is
  the classic scale signal.
- **NB-DB / SB-DB** — OVN's northbound DB (desired logical state) and southbound DB (compiled
  state the nodes consume).
- **conntrack** — the kernel's tracked-connections table.
- **VIP** — a service's virtual IP, programmed as an OVN load-balancer entry.
- **canary** — an always-on probe VM (or pod) whose latency/readiness we watch to measure blast
  radius on existing workloads.
- **programmed** — the object exists in the network control plane (visible in the NB DB), not just
  in the Kubernetes API.
