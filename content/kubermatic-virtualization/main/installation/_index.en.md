+++
title = "Installation"
date = 2025-12-18T09:00:00+02:00
weight = 5
+++

## Kubermatic Virtualization Installation Overview

The **Kubermatic Virtualization** Installer offers multiple installation methods for deploying a **Kubermatic Virtualization** stack, enabling users to select the approach that best aligns with their operational preferences. You can choose between a guided, interactive installation or a fully automated, GitOps-driven workflow. Both methods also support **offline mode**, making them suitable for fully offline environments or air-gapped environements.

## Interactive TUI Installation

Kubermatic Virtualization can be installed using an interactive **Terminal User Interface (TUI)**. This method guides users step by step through the installation process.

During the TUI-based installation, the user is prompted to:

* Prompting for all required configuration values in a structured sequence
* Offering interactive selection of installation options (e.g., Load balancing settings, network settings, offline mode)
* Validating inputs in real time to prevent misconfigurations before provisioning begins

Once all inputs are collected and confirmed, the installer automatically provisions and configures the full Kubermatic Virtualization stack.

**This approach is ideal for:**

* Quick, one-time installations
* First-time users exploring Kubermatic Virtualization
* Proof-of-concept (PoC) or demo environments
* Teams or individuals who prefer a guided, interactive experience over manual configuration

---

## API-Driven - Declarative Installation

Kubermatic Virtualization also supports an **API-driven installation approach**, aligned with GitOps and cloud-native best practices.

In this model, the installation is defined and controlled through a **Kubermatic Virtualization** configuration file, which declaratively specifies the complete desired state of the Kubermatic Virtualization stack. This configuration file can be:

* Stored in version control (e.g., Git)
* Applied declaratively
* Automatically reconciled to ensure the live system matches the declared state

This approach enables Infrastructure as Code (IaC) workflows and simplifies ongoing operations.

**This approach is ideal for:**

* GitOps-oriented teams and environments
* Simplified future upgrades and reconfigurations
* Users seeking a persistent, reusable, and portable installation configuration

---

## Offline Mode (Fully Offline or Air-Gapped Installations)

Both installation methods—Interactive TUI and Declarative GitOps—fully support offline mode, enabling you to deploy a complete Kubermatic Virtualization (KubeV) stack in air-gapped or disconnected environments.

To prepare for an offline installation, you’ll need to perform a few additional upfront steps, such as:

* Preloading required container images into a local registry
* Providing access to internal or mirrored package repositories
* Configuring the installation to disable or replace any external dependencies (e.g., public APIs, update servers, or cloud integrations)

Detailed, step-by-step guidance for preparing and executing an offline installation—including image bundles, registry setup, and configuration adjustments—is available in the dedicated Offline Mode section of this documentation.

---

With flexible installation workflows and comprehensive offline support, Kubermatic Virtualization delivers consistent, secure, and reproducible deployments across diverse infrastructure environments—from connected cloud setups to fully isolated on-premises data centers.
