#!/usr/bin/env bash

cd $(dirname $0)/..

SOURCE="${GOPATH}/src/github.com/kubermatic/kubermatic/charts/monitoring/prometheus/rules/src"

# merge all files,
# convert to JSON,
# filter out rules that are not alerts,
# filter out groups that have no rules left over,
# dump as JSON
yq \
  merge -a append ${SOURCE}/*/*.yaml | \
  yq read -j - | \
  jq "{
    groups: [
      .groups[] |
      {
        name: .name,
        rules: [(.rules[] | select (.alert))]
      } |
      select (.rules | length > 0)
    ]
  }" \
  > data/kubermatic/master/runbook.json
