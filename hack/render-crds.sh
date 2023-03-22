#!/usr/bin/env bash

set -euox pipefail

cd $(dirname $0)/..

# starting with https://github.com/kubermatic/kubermatic/pull/12079,
# CRDs are kept in a dedicated repo and are only available because KKP's
# update-docs.sh just did a `go mod vendor`, just for us.
SOURCE="${GOPATH}/src/github.com/kubermatic/kubermatic/vendor/k8c.io/api/v2/pkg/apis/"

# We are building for an older KKP release.
if [ ! -d "$SOURCE" ]; then
  SOURCE="${GOPATH}/src/github.com/kubermatic/kubermatic/pkg/apis/"
fi

which crd-ref-docs >/dev/null || {
  echo "running go install github.com/elastic/crd-ref-docs@v0.0.8 in 5s... (ctrl-c to cancel)"
  sleep 5
  go install github.com/elastic/crd-ref-docs@v0.0.8
}

${GOPATH}/bin/crd-ref-docs \
  --source-path "${SOURCE}" \
  --max-depth 10 \
  --renderer markdown \
  --templates-dir=hack/crd-templates \
  --config hack/crd-ref-docs.yaml \
  --output-path content/kubermatic/main/references/crds/_index.en.md
