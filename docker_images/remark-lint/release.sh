#!/usr/bin/env bash

TAG=1.0.0

set -euox pipefail

docker build --no-cache --pull -t quay.io/kubermatic/remark-lint:${TAG} .
docker push quay.io/kubermatic/remark-lint:${TAG}
