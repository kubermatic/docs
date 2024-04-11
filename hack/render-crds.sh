#!/usr/bin/env bash

set -euo pipefail

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

# get latest stable Kubernetes version
currentStable="$(curl -sSL https://dl.k8s.io/release/stable-1.txt)"

# trim leading v
currentStable="${currentStable#v}"

# drop patch
currentRelease="$(echo "$currentStable" | cut -d. -f1,2)"

configFile=hack/crd-ref-docs.yaml

# Version of Kubernetes to use when generating links to Kubernetes API documentation.
yq --inplace ".render.kubernetesVersion = \"$currentRelease\"" "$configFile"

$(go env GOPATH)/bin/crd-ref-docs \
  --source-path "$SOURCE" \
  --max-depth 10 \
  --renderer markdown \
  --templates-dir hack/crd-templates \
  --config "$configFile" \
  --output-path content/kubermatic/main/references/crds/_index.en.md
