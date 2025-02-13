+++
title = "Compatibility Matrix"
date = 2024-03-15T00:00:00+01:00
weight = 30
+++

Currently, we don't have any hard dependencies on certain components and their versions. This matrix is here to reflect any changes in the compatibility matrix of the components we are using.

We are only testing our software with specific versions of the components, we are not enforcing these versions but these are the ones tested. It should work with other versions of Kubernetes, Gateway API, and Envoy Gateway as well, but we can't guarantee it.

| KubeLB | Kubermatic Kubernetes Platform | Gateway API | Envoy Gateway | Kubernetes |
|--------|-------------------------------|-------------|---------------|------------|
| v1.0   | v2.24, v2.25                 | Not Supported| Not Supported | v1.27+     |
