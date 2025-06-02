+++
title = "Feature Stages"
date = 2024-10-11T12:11:35+02:00
weight = 4

+++

## Introduction

Feature stages in Kubermatic Kubernetes Platform (KKP) help users understand the maturity and stability of features. This classification system ensures that users can make informed decisions about which features to use in their environments based on their specific needs and risk tolerance.

## Alpha

- Targeted users: internal, or specific customer
- Disabled by default by its feature gate
- Enabling the feature may expose bugs
- No guaranteed support for the feature
- The feature may change in incompatible ways in a later software release without notice
- The whole feature can be revoked immediately and without notice
- Recommended only for testing and providing feedback

## Beta / Technical Preview

- Targeted users: experienced KKP administrators
- Can be enabled or disabled by default by its feature gate
- Enabling the feature is considered safe
- Support is guaranteed for the overall feature
- The schema and/or semantics of objects may change in incompatible ways in later software release
  - When this happens, we will provide instructions for migrating to the next version, which can require manual work and/or downtime
- The whole feature can still be revoked, but with prior notice and respecting a deprecation cycle
- Recommended for only non-business-critical uses, testing usability, performance, and compatibility in real-world environments

## General Availability (GA)

- Users: All users
- The feature is always enabled; you cannot disable it by a feature gate
  - Some features which are meant to be optional (Optional Features) are an exception of this, and can still be disabled by default
- Feature is considered production-ready
- Support is guaranteed
- All changes to the feature are backwards compatible with an automated migration path implemented where needed
- Removing the feature requires a strict deprecation cycle and replacement or migration path when possible
- Recommended for production use

### Feature Stage Guidelines

- The following components should explicitly be marked as alpha/beta:
  - APIs/CRDs: Dedicated CRDs including fields in API and CRD that are introduced for this feature.
  - UI: All the views/fields that are used to interact with the feature.
    - Example: Add "(Alpha)" or "(Beta)" suffix to feature names in the UI
  - Documentation: All the documentation related to the feature.
    - Example: Add "This feature is in alpha/beta stage" warning at the top of relevant docs
  - Helm chart/Application: All the helm charts and Applications related to the feature.
    - Example: Add "This feature is in alpha/beta stage" notice in README.md

**NOTE: For General Availability (GA) features, the above feature stage guidelines are not applicable as the feature is considered production-ready. There is no need to explicitly mark the feature as GA.**
