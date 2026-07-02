+++
title = "Engineering Reference"
date = 2026-06-11T09:00:00+02:00
weight = 4
+++

{{% notice warning %}}
**INTERNAL ENGINEERING REFERENCE.** Everything in this sub-section is measurement provenance for
review: methods, parameters, stop triggers, tuning, and named-vendor comparisons. Review before
public release — trimming or moving this section is the expected outcome of review.
{{% /notice %}}

How every number in this section was measured, and what it took to get there:

- [Ceiling methodology]({{< ref "./ceiling-methodology" >}}) — the definition of a capacity
  ceiling, the run loop, functional verification, and the distress probes that stop a run.
- [Degradation methodology]({{< ref "./degradation-methodology" >}}) — why tenant bundles, the
  canary topology, measurement statistics, and thresholds.
- [Per-test method cards]({{< ref "./method-cards" >}}) — per capability: what the test creates,
  what "programmed" means, parameters, stop trigger, result and headroom.
- [Tuning and findings]({{< ref "./tuning-and-findings" >}}) — the cluster tuning baseline, the
  bottleneck register, the caveats register, and the findings-and-fixes history.
- [Glossary]({{< ref "./glossary" >}}) — the network control-plane terms used throughout.
