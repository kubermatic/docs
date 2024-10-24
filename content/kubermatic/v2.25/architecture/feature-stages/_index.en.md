+++
title = "Feature Stages"
date = 2024-10-11T12:11:35+02:00
weight = 4

+++

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
