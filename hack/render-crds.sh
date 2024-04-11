#!/usr/bin/env bash

set -euox pipefail

cd $(dirname $0)/..

SOURCE="${SOURCE:-}"

if [[ -z "$SOURCE" ]]; then
  gopath="$(go env GOPATH)"
  SOURCE="$gopath/src/k8c.io/kubermatic/pkg/apis"

  if ! [ -d "$SOURCE" ]; then
    # legacy path before we set the path_alias on the sync job
    SOURCE="$gopath/src/github.com/kubermatic/kubermatic/pkg/apis"

    if ! [ -d "$SOURCE" ]; then
      echo "\$SOURCE not set and KKP not automatically found."
      exit 1
    fi
  fi
fi

which crd-ref-docs >/dev/null || {
  echo "running go install github.com/elastic/crd-ref-docs@v0.0.12 in 5s... (ctrl-c to cancel)"
  sleep 5
  go install github.com/elastic/crd-ref-docs@v0.0.12
}

$(go env GOPATH)/bin/crd-ref-docs \
  --source-path "${SOURCE}" \
  --max-depth 10 \
  --renderer markdown \
  --templates-dir hack/crd-templates \
  --config hack/crd-ref-docs.yaml \
  --output-path content/kubermatic/main/references/crds/_index.en.md
