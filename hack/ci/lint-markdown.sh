#!/usr/bin/env sh

set -euo pipefail

cd $(dirname "$0")/../..

echo "Running remark-lint on the content directory..."
remark --quiet --frail content
echo "No problems found, good job :-)"
