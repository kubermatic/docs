+++
title = "Compatibility Matrix"
date = 2026-03-17T10:07:15+02:00
weight = 35
+++

This matrix reflects the tested combinations of Conformance EE with Kubermatic Kubernetes Platform and Kubernetes versions.

## Component Compatibility

| Conformance EE | KKP Version | Kubernetes | Ginkgo |
|----------------|-------------|------------|--------|
| main | v2.30 | v1.32, v1.33, v1.34, v1.35 | v2.28.1 |

## Supported Cloud Providers

| Provider | Status | Notes |
|----------|--------|-------|
| KubeVirt | Supported | Full infrastructure discovery and scenario generation |

## Supported OS Distributions

| Distribution | Versions | KubeVirt |
|-------------|----------|----------|
| Ubuntu | 20.04, 22.04 | ✔️ |
| RHEL | 8, 9 | ✔️ |
| Flatcar | 3374.2.2 | ✔️ |
| Rocky Linux | 8, 9 | ✔️ |

## Key Dependencies

| Dependency | Version |
|------------|---------|
| Kubermatic SDK | v2.30.0 |
| KubeVirt API | v1.3.1 |
