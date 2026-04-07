+++
title = "Kubermatic Conformance EE"
date = 2026-03-17T10:07:15+02:00
weight = 7
description = "Learn how to use Kubermatic Conformance EE to automatically generate, run, and report end-to-end conformance test scenarios for Kubermatic Kubernetes Platform clusters."
+++

## What is Conformance EE?

*Conformance EE* is a project by Kubermatic that provides an automated end-to-end conformance test framework for **Kubermatic Kubernetes Platform (KKP) Enterprise Edition**. It automatically generates, runs, and reports thousands of test scenarios by combinatorially applying configuration modifiers to cloud provider clusters and machine deployments.

## Motivation and Background

Validating Kubernetes cluster configurations across multiple cloud providers, OS distributions, Kubernetes versions, and feature combinations is a complex and error-prone task when done manually. The number of possible configuration permutations grows exponentially, making exhaustive manual testing impractical.

Conformance EE solves this by:

- **Combinatorially generating test scenarios** from cluster modifiers (CNI, proxy mode, expose strategy, etc.) and machine modifiers (CPU, memory, disk, OS distribution, etc.)
- **Deduplicating clusters** using SHA-256 hashing to avoid creating redundant clusters when different modifier combinations produce the same effective configuration
- **Parallelizing test execution** across Ginkgo nodes with concurrent worker pools
- **Providing live visibility** into test progress via Kubernetes ConfigMap reporting and JUnit XML output
- **Offering an interactive TUI** for configuring and launching test runs directly from the terminal

## Key Features

- **Scenario Matrix Generation**: Combinatorial generation of thousands of test scenarios from provider-discovered settings and user configuration
- **SHA-256 Deduplication**: Prevents duplicate cluster creation by hashing sanitized cluster specs
- **Parallel Execution**: 100 concurrent workers across Ginkgo nodes with max 4 clusters created in parallel
- **Multi-Provider Support**: Currently supports KubeVirt with extensible provider architecture
- **Interactive Terminal UI**: Built with Bubble Tea for configuration and execution management
- **In-Cluster Deployment**: Runs as Kubernetes Jobs with ConfigMap-based live reporting
- **JUnit XML Reports**: Compatible with all major CI systems (Jenkins, GitLab CI, GitHub Actions)
- **YAML Configuration**: Flexible configuration system for providers, releases, distributions, resources, and timeouts

## Table of Content

{{% children depth=5 %}}
{{% /children %}}

## Further Information

- [Kubermatic Kubernetes Platform](https://www.kubermatic.com/products/kubermatic-kubernetes-platform/)

Visit [kubermatic.com](https://www.kubermatic.com/) for further information.

{{% notice tip %}}
For latest updates follow us on Twitter [@Kubermatic](https://twitter.com/Kubermatic)
{{% /notice %}}
