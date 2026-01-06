+++
title = "Developing"
date = 2024-05-31T07:00:00+02:00
weight = 35
+++

This section provides guidance for developers who want to contribute to machine-controller or extend it with new providers.

## Development Setup

### Prerequisites

- Go 1.21 or later
- Docker
- kubectl
- Access to a Kubernetes cluster (local or cloud)
- Make

### Clone the Repository

```bash
git clone https://github.com/kubermatic/machine-controller.git
cd machine-controller
```

### Building

Build the binary:

```bash
make build
```

Build the Docker image:

```bash
make docker-build
```

### Running Locally

You can run machine-controller locally against a remote cluster:

```bash
# Set your kubeconfig
export KUBECONFIG=/path/to/kubeconfig

# Set cloud provider credentials (example for Hetzner)
export HCLOUD_TOKEN=your-token

# Run the controller
./machine-controller \
  -kubeconfig=$KUBECONFIG \
  -logtostderr \
  -v=4 \
  -worker-count=5
```

### Running Tests

Run unit tests:

```bash
make test
```

Run end-to-end tests:

```bash
# Requires cloud provider credentials
make e2e-test
```

## Project Structure

```
machine-controller/
├── cmd/                    # Main applications
│   └── machine-controller/ # Controller binary
├── pkg/
│   ├── apis/              # API definitions (CRDs)
│   ├── cloudprovider/     # Cloud provider implementations
│   │   ├── provider/      # Individual provider packages
│   │   │   ├── aws/
│   │   │   ├── azure/
│   │   │   ├── hetzner/
│   │   │   └── ...
│   │   └── types/         # Common provider types
│   ├── controller/        # Controller logic
│   │   ├── machine/       # Machine controller
│   │   ├── machineset/    # MachineSet controller
│   │   └── machinedeployment/ # MachineDeployment controller
│   ├── userdata/          # OS provisioning logic
│   │   ├── ubuntu/
│   │   ├── flatcar/
│   │   └── ...
│   └── providerconfig/    # Provider configuration utilities
├── examples/              # Example manifests
├── test/                  # Test suites
│   ├── e2e/              # End-to-end tests
│   └── tools/            # Test utilities
└── Makefile              # Build automation
```

## Adding a New Cloud Provider

See the detailed guide: [Adding a new Cloud Provider]({{< ref "./creating-providers" >}})

Quick overview:

1. Create a new package in `pkg/cloudprovider/provider/<provider-name>/`
2. Implement the `Provider` interface
3. Register the provider in `pkg/cloudprovider/provider.go`
4. Add example manifest to `examples/`
5. Add tests in `test/e2e/provisioning/`

## Adding Operating System Support

To add support for a new operating system:

1. **Create userdata package**: `pkg/userdata/<os-name>/`

```go
package myos

import (
    "github.com/kubermatic/machine-controller/pkg/userdata/plugin"
)

// Provider implements the userdata.Provider interface
type Provider struct{}

func (p *Provider) UserData(req plugin.UserDataRequest) (string, error) {
    // Generate cloud-init or ignition config
    return cloudInitConfig, nil
}
```

2. **Register the OS provider**: In `pkg/userdata/manager.go`

```go
import "github.com/kubermatic/machine-controller/pkg/userdata/myos"

func init() {
    Register("myos", &myos.Provider{})
}
```

3. **Add tests**: Create test cases in `pkg/userdata/myos/myos_test.go`

4. **Update documentation**: Add OS to the support matrix

## Code Style and Standards

### Go Style Guide

Follow the [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments) and:

- Use `gofmt` for formatting
- Use `golangci-lint` for linting
- Write meaningful commit messages
- Add tests for new functionality

### Running Linters

```bash
make lint
```

### Code Generation

After modifying CRD definitions, regenerate code:

```bash
make generate
```

## Testing Guidelines

### Unit Tests

- Test individual functions and methods
- Mock external dependencies
- Use table-driven tests for multiple scenarios

Example:

```go
func TestProviderValidate(t *testing.T) {
    tests := []struct {
        name    string
        spec    v1alpha1.MachineSpec
        wantErr bool
    }{
        {
            name: "valid spec",
            spec: validMachineSpec(),
            wantErr: false,
        },
        {
            name: "missing required field",
            spec: invalidMachineSpec(),
            wantErr: true,
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := provider.Validate(tt.spec)
            if (err != nil) != tt.wantErr {
                t.Errorf("Validate() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}
```

### Integration Tests

- Test interaction between components
- Use real Kubernetes API (via envtest)
- Verify controller behavior

### E2E Tests

- Test complete workflows
- Use actual cloud providers
- Verify machine creation, updates, and deletion

## Debugging

### Enable Debug Logging

```bash
./machine-controller -v=6 -logtostderr
```

### Debug in IDE

Create a run configuration in your IDE:

**VS Code** (`launch.json`):
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Launch machine-controller",
            "type": "go",
            "request": "launch",
            "mode": "debug",
            "program": "${workspaceFolder}/cmd/machine-controller",
            "args": [
                "-kubeconfig=/path/to/kubeconfig",
                "-logtostderr",
                "-v=6"
            ],
            "env": {
                "HCLOUD_TOKEN": "your-token"
            }
        }
    ]
}
```

**GoLand/IntelliJ**: Create a "Go Build" run configuration with similar settings

### Using Delve

```bash
dlv debug ./cmd/machine-controller -- \
  -kubeconfig=$KUBECONFIG \
  -logtostderr \
  -v=6
```

## Contributing

### Pull Request Process

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/my-feature`
3. **Make your changes**: Follow code style guidelines
4. **Add tests**: Ensure good coverage
5. **Run tests and linters**: `make test lint`
6. **Commit changes**: Use meaningful commit messages
7. **Push to your fork**: `git push origin feature/my-feature`
8. **Create Pull Request**: Describe your changes clearly

### Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

Examples:
```
feat(aws): add support for ARM instances

Add support for AWS Graviton instances in the AWS provider.

Closes #123
```

```
fix(azure): handle nil pointer in VM creation

Check for nil before dereferencing availability set pointer.

Fixes #456
```

### Code Review

All submissions require review. We use GitHub pull requests for this purpose. Reviewers will check:

- Code quality and style
- Test coverage
- Documentation updates
- Breaking changes

## Release Process

Releases follow semantic versioning (SEMVER):

- **Major**: Breaking changes
- **Minor**: New features (backward compatible)
- **Patch**: Bug fixes

Release checklist:
1. Update version in relevant files
2. Update CHANGELOG.md
3. Create and push git tag
4. Build and push Docker images
5. Create GitHub release with notes

## Useful Commands

```bash
# Build binary
make build

# Build Docker image
make docker-build

# Run tests
make test

# Run linters
make lint

# Generate code (after CRD changes)
make generate

# Clean build artifacts
make clean

# Run specific provider E2E test
make e2e-test PROVIDER=aws

# Format code
make fmt

# Update dependencies
go mod tidy
go mod vendor
```

## Common Development Tasks

### Testing a New Provider Locally

1. Build the image with your changes
2. Load image into your test cluster (if using kind/minikube)
3. Update the machine-controller deployment to use your image
4. Create a test Machine with your provider config
5. Monitor logs and verify instance creation

### Updating Dependencies

```bash
# Update a specific dependency
go get github.com/some/dependency@version

# Update all dependencies
go get -u ./...

# Tidy and vendor
go mod tidy
go mod vendor
```

### Generating Documentation

Some documentation is auto-generated from code:

```bash
# Generate API documentation
make api-docs

# Generate provider configuration documentation
make provider-docs
```

## Resources

- [GitHub Repository](https://github.com/kubermatic/machine-controller)
- [Issue Tracker](https://github.com/kubermatic/machine-controller/issues)
- [Pull Requests](https://github.com/kubermatic/machine-controller/pulls)
- [Cluster API Documentation](https://cluster-api.sigs.k8s.io/)
- [Kubernetes Development Guide](https://github.com/kubernetes/community/tree/master/contributors/devel)

## Getting Help

- **Slack**: Join [Kubermatic Slack](https://kubermatic.slack.com)
- **GitHub Discussions**: Ask questions in repository discussions
- **Office Hours**: Check community calendar for developer office hours
