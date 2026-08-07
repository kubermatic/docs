+++
title = "Engineering Reference"
date = 2026-06-11T09:00:00+02:00
weight = 4
+++

This section documents how every number in the preceding pages was measured: the definition of a
capacity ceiling, the per-test procedures, the distress signals that stop a run, and the cluster
tuning the numbers depend on.

- [Ceiling methodology]({{< ref "./ceiling-methodology" >}}): the definition of a capacity
  ceiling, the measurement loop, functional verification, and the distress probes that stop a run.
- [Degradation methodology]({{< ref "./degradation-methodology" >}}): why tenant bundles are used,
  the canary topology, the measurement statistics, and the stop thresholds.
- [Per-test method cards]({{< ref "./method-cards" >}}): for each capability, what the test
  creates, what "programmed" means, the parameters used, the stop trigger, and the result.
- [Cluster tuning and limits]({{< ref "./tuning-and-findings" >}}): the tuning baseline the numbers
  depend on, the first binding factor per capability, and the interpretation caveats.
- [Glossary]({{< ref "./glossary" >}}): the network control-plane terms used throughout.
