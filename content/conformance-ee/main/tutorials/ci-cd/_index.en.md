+++
title = "CI/CD Integration"
date = 2026-03-17T10:07:15+02:00
weight = 30
+++

This guide covers integrating Conformance EE into your CI/CD pipeline.

## GitHub Actions

Conformance EE container images are automatically built and published on each tagged release.

### Running Tests in CI

Create a workflow that runs conformance tests against your KKP installation:

```yaml
name: Conformance Tests
on:
  schedule:
    - cron: '0 2 * * 1'  # Weekly on Monday at 2 AM
  workflow_dispatch:

jobs:
  conformance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up kubeconfig
        run: |
          mkdir -p ~/.kube
          echo "${{ secrets.KUBECONFIG }}" | base64 -d > ~/.kube/config

      - name: Deploy Conformance Tests
        run: |
          kubectl create namespace conformance-tests --dry-run=client -o yaml | kubectl apply -f -
          kubectl create configmap conformance-config \
            --from-file=config.yaml=./config.yaml \
            -n conformance-tests --dry-run=client -o yaml | kubectl apply -f -
          kubectl apply -f conformance-job.yaml

      - name: Wait for Completion
        run: |
          kubectl wait --for=condition=complete \
            job/conformance-tests \
            -n conformance-tests \
            --timeout=3600s

      - name: Collect Reports
        if: always()
        run: |
          kubectl cp conformance-tests/conformance-tests:/reports ./reports

      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: conformance-reports
          path: reports/
```

## JUnit Report Integration

Conformance EE produces JUnit XML reports that are compatible with most CI systems:

### GitHub Actions

```yaml
- name: Publish Test Results
  uses: EnricoMi/publish-unit-test-result-action@v2
  if: always()
  with:
    files: reports/junit.*.xml
```

### Jenkins

Configure the **JUnit** post-build action to collect `reports/junit.*.xml`.

### GitLab CI

```yaml
conformance:
  artifacts:
    reports:
      junit: reports/junit.*.xml
```

## Live Monitoring via ConfigMap

During long-running test suites, monitor progress via the ConfigMap reporter:

```bash
# Watch for updates
kubectl get configmap -n conformance-tests -l app=conformance-reports -w

# Get detailed results
kubectl get configmap conformance-reports-<project-name> \
  -n conformance-tests -o jsonpath='{.data}' | jq .
```

Each entry in the ConfigMap represents a completed spec with its state, duration, and any failure message.
