+++
title = "Compatibility Matrix"
date = 2026-03-17T10:07:15+02:00
weight = 35
+++

This matrix reflects the tested combinations of Conformance EE with Kubermatic Kubernetes Platform and Kubernetes versions.

## Component Compatibility

| Conformance EE | KKP Version | Kubernetes | Go | Ginkgo |
|----------------|-------------|------------|----|--------|
| main | v2.30 | v1.31, v1.32 | 1.25 | v2.28.1 |

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
| k8s.io/client-go | v0.35.2 |
| KubeVirt API | v1.3.1 |
| Bubble Tea | v1.3.10 |
| Gomega | v1.39.0 |
