#!/usr/bin/env bash

set -euox pipefail

cd $(dirname $0)/..

SOURCE="${GOPATH}/src/github.com/kubermatic/kubermatic/pkg/apis/kubermatic/v1/"

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
  --output-path content/kubermatic/master/references/crds/_index.en.md
