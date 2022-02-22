#!/usr/bin/env bash

cd $(dirname $0)/..

SOURCE="${GOPATH}/src/github.com/kubermatic/kubermatic/pkg/apis/kubermatic/v1/"

which crd-ref-docs >/dev/null || { 
  echo "running go install github.com/elastic/crd-ref-docs@master in 5s... (ctrl-c to cancel)"
  sleep 5
  go install github.com/elastic/crd-ref-docs@master
}

configfile=$(mktemp)
cat <<EOF >${configfile}
render:
# Version of Kubernetes to use when generating links to Kubernetes API documentation.
  kubernetesVersion: 1.22

processor:
  ignoreFields:
    - "TypeMeta$"
    - "apiversion$"
    - "kind$"
  
  ignoreTypes:
    - "Quantity$"
    - "Fake$"
EOF

crd-ref-docs \
  --source-path "${SOURCE}" \
  --max-depth 10 \
  --renderer markdown \
  --templates-dir=hack/crd-templates \
  --config ${configfile} \
  --output-path content/kubermatic/master/references/crds/_index.en.md

rm ${configfile}
