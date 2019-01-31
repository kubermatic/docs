#!/usr/bin/env sh

SOURCE="${GOPATH}/src/github.com/kubermatic/kubermatic/config/monitoring/prometheus/rules/src"

# merge all files,
# convert to JSON,
# filter out rules that are not alerts,
# filter out groups that have no rules left over,
# dump as JSON
yq \
  merge -a ${SOURCE}/*.yaml | \
  yq read -j - | \
  jq "{
    compiled: now | todateiso8601,
    groups: [
      .groups[] |
      {
        name: .name,
        rules: [(.rules[] | select (.alert))]
      } |
      select (.rules | length > 0)
    ]
  }" \
  > data/runbook.json
