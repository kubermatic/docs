+++
title = "Kubermatic Release Process"
date = 2025-07-22-T15:00:00+01:00
weight = 80
+++


## Kubermatic Release Process

This document provides comprehensive information about the Kubermatic release process, outlining release types, cadence, upgrade paths, and artifact delivery mechanisms. This guide is intended for technical users and system administrators managing Kubermatic deployments.

---

### Release Types

Kubermatic employs a structured release strategy with distinct release types to address varying needs, from new feature introductions to critical bug fixes.

### Major Releases

* Purpose: Major releases signify fundamental shifts or significant architectural overhauls, often introducing backward-incompatible changes. They aim to bring substantial new capabilities, address long-standing technical debt, or realign the product with new strategic directions.  
* Impact on Users: Major releases typically require extensive planning and migration efforts from users. Upgrades can be more complex. Users should expect to thoroughly review migration guides and allocate substantial resources for the upgrade process.

#### Minor Releases

* Purpose: Minor releases introduce new features, enhancements, and significant bug fixes. They often align with new upstream Kubernetes minor versions, bringing the latest Kubernetes capabilities to Kubermatic users.  
* Typical Scope of Changes:  
  * New Product features and functionalities.  
  * Support for newer upstream Kubernetes minor versions.  
  * Updates to core components and dependencies.  
  * Major improvements to existing features.  
  * Non-disruptive API changes (e.g., additive features, new API versions) unless the API is deprecated.  
  * Removal of deprecated features.  
* Impact on Users: Minor releases require a planned upgrade process. While generally designed for minimal disruption, users should review release notes for any potential configuration changes or new prerequisites. Downtime may be required depending on the scale and nature of the changes, particularly for control plane upgrades.

#### Patch Releases

* Purpose: Patch releases focus on stability and security. They primarily deliver bug fixes, security patches, and critical performance improvements for a specific minor release.  
* Typical Scope of Changes:  
  * Resolution of identified bugs and regressions.  
  * Security vulnerability fixes.  
  * Performance optimizations.  
  * Minor, non-breaking component and dependency updates.  
  * No new features are introduced in patch releases.  
* Impact on Users: Patch releases are designed to be low-impact and generally non-disruptive. They're highly recommended to ensure the security and stability of your Kubermatic deployment. Upgrades typically involve minimal or no downtime, depending on the affected components.

#### Hotfix Releases

* Purpose: To temporarily resolve critical support cases, Kubermatic may provide a version of the affected software (e.g., package) that applies a patch. Such versions are referred to as "hotfixes."  
* Typical Scope of Changes: Hotfixes address urgent, critical issues that severely impact Kubermatic functionality, stability, or security and cannot wait for the next scheduled patch release.  
* Impact on Users: Hotfixes provided by Kubermatic are supported for 90 days after the corresponding patch has been incorporated into a release of the software. However, if a patch is addressing a problem in an upstream project and is rejected by the upstream project, the hotfix will no longer be supported, and the case will remain open. The final fix will be provided when the upstream accepts it and incorporates it into a release of the software. Customers should update the software to the new release, including the stable fix.  
  Important Hotfix Release Notice  
* The hotfix is for a critical issue and should not be deployed into a production environment without direct approval and guidance from Kubermatic support.  
* This release contains a targeted fix for a specific issue. Applying it to a production environment without proper assessment and support from the Kubermatic support team could lead to unintended consequences or instability.  
* Important note about upgrading: This hotfix contains changes that may not be included in all subsequent versions. To ensure a smooth upgrade process after installing this hotfix, please contact Kubermatic Support for further instructions before upgrading to a newer version. Kubermatic Support will let you know which versions you can safely upgrade to.  
* Before proceeding, please contact Kubermatic support and reference this hotfix version. Our team will work with you to evaluate your specific situation, provide a deployment plan, and ensure a smooth and safe application of this fix.

---

### General Cadence

The Kubermatic release cadence is designed to provide a balance between delivering new features and ensuring stability and predictability.

* Minor Releases: Typically occur every 4 months. This cadence often aligns with upstream Kubernetes minor releases, allowing Kubermatic to quickly integrate and offer the latest Kubernetes features.  
* Patch Releases: Occur approximately every 4 to 6 weeks as needed. The frequency can increase if critical issues are discovered.  
* Hotfix Releases: Issued on demand when critical issues arise. There is no fixed schedule for hotfix releases due to their urgent nature.

Factors Influencing Release Schedule:

* Critical Security Vulnerabilities: Discovery of high-severity security vulnerabilities in Kubermatic or its dependencies will accelerate the release of patch or hotfix releases.  
* Major Upstream Kubernetes Releases: New major or minor releases of upstream Kubernetes may influence the Kubermatic minor release schedule to ensure timely integration and support.  
* Community Feedback and Bug Reports: A high volume of critical bug reports from the community can lead to more frequent patch releases.  
* Internal Quality Assurance: Extensive testing and validation cycles can influence release timing to ensure the highest quality.

---

### Upgrade Path and Compatibility

Effective upgrade management is crucial for Kubermatic users. This section details the recommended upgrade path and important compatibility considerations.

#### Recommended Upgrade Path

* Minor Version Upgrades: Always upgrade Kubermatic one minor version at a time (e.g., from Kubermatic 2.20.x to 2.21.x, then to 2.22.x). Skipping minor versions is not supported and can lead to unpredictable behavior or broken deployments due to potential breaking changes between intermediate versions.  
* Patch Version Upgrades: Within a minor version, you can upgrade directly to the latest patch release (e.g., from Kubermatic 2.21.1 to 2.21.5). It's highly recommended to stay up-to-date with the latest patch releases for security and stability.  
* Hotfix Application: Hotfixes are applied directly to the affected minor.patch version.

#### Compatibility Considerations

* Supported Direct Upgrades: Kubermatic guarantees direct upgrade support for consecutive minor versions only. For example, you can directly upgrade from KKP 2.20 to KKP 2.21, but not from KKP 2.19 to KKP 2.21.  
* Breaking Changes: While efforts are made to minimize breaking changes in minor releases, some may be unavoidable, especially when integrating with new upstream Kubernetes versions or significant architectural improvements.  
  * Release Notes: Always consult the release notes for the specific Kubermatic Product version you are upgrading to. Release notes clearly detail any breaking changes, deprecations, and required manual steps or configuration updates.  
  * Prerequisites: Certain upgrades may have specific prerequisites, such as minimum Kubernetes versions for user clusters, updated kubectl versions, or increased resource requirements. These will be explicitly stated in the release notes.  
* Backward Compatibility Guarantees:  
  * API Versions: Kubermatic generally adheres to the Kubernetes API versioning policy. Stable API versions are guaranteed to be backward compatible. Beta API versions may introduce breaking changes, and alpha API versions offer no compatibility guarantees. Users should be aware of the API versions they are utilizing.  
  * Components: While best efforts are made, some internal component changes in minor releases might not be fully backward compatible. Refer to release notes for specific component compatibility details.  
  * Configuration: Configuration schemas may evolve with minor releases. Tools and documentation will be provided to assist with configuration migration.  
* Guidance on Rollbacks:  
  * Kubermatic Products are designed with upgradeability in mind. While rollbacks are generally not recommended due to the complexity of distributed systems, in certain scenarios, a limited rollback may be possible for the Kubermatic control plane components.  
  * User Cluster Rollbacks: Rolling back user clusters is highly complex and generally not supported once an upgrade has been initiated and significant changes applied.  
  * Backup Strategy: A robust backup and recovery strategy for your Kubermatic Product installation and user cluster etcd instances is paramount before any significant upgrade. This is your primary mechanism for disaster recovery.  
  * Documentation: Specific rollback procedures, if supported for certain components, will be detailed in the Kubermatic Product documentation for the respective release.