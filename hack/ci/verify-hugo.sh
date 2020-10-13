#!/usr/bin/env bash

set -euo pipefail

cd $(dirname "$0")/../..

cleanup() {
  rm -f hugo.log
}
trap "cleanup" EXIT SIGINT

cleanup

echo "Checking if the site can be built with Hugo..."
hugo --logFile hugo.log --renderToMemory

if grep -q "WARN" hugo.log; then
  echo "Warnings occurred."
  exit 1
fi

echo "Build succeeded."
