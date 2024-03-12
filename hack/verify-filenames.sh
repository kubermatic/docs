#!/usr/bin/env bash

set -euo pipefail

cd $(dirname $0)/..

EXIT_CODE=0

function ensure_valid_filenames_dir() {
  echo "Checking $1…"

  dataDir="$1/data"

  while read -d $'\0' entry; do
    lastPart="$(basename "$entry")"

    # _index.en.md files are allowed to not follow our filename rules
    if [[ "$lastPart" =~ ^_index ]]; then
      continue
    fi

    # data files are exempt as well, as they do not directly influence URLs
    if [[ "$(dirname "$entry")" == "$dataDir" ]]; then
      continue
    fi

    if [[ "$entry" =~ [A-Z_] ]]; then
      echo "  ❌ $entry"
      EXIT_CODE=1
    fi
  done < <(find "$1" -print0)
}

function ensure_valid_filenames() {
  local product="$1"

  # surround with commas to make regex checks easier
  local ignoreList=",$2,"

  while read -d $'\0' path; do
    version="$(basename "$path")"

    if [[ "$ignoreList" =~ ",$version," ]]; then
      continue
    fi

    ensure_valid_filenames_dir "$path"

    imgDir="static/img/$product/$version"
    if [ -d "$imgDir" ]; then
      ensure_valid_filenames_dir "$imgDir"
    fi

  done < <(find "content/$product" -maxdepth 1 -mindepth 1 -type d -print0)
}

# Instead of only enforcing good names in the "main" version, we explicitly
# want to also validate each version created after the big cleanup, so that
# even when by accident new files are introduced in an existing version, it
# would be caught in the presubmit job.
# These version lists should therefore only ever contain versions that are
# guaranteed to not be updated anymore or, again, were created before the
# big cleanup.

ensure_valid_filenames kubeone "v1.0,v1.2,v1.3,v1.4,v1.5,v1.6,v1.7"
ensure_valid_filenames kubermatic "v2.12,v2.13,v2.14,v2.15,v2.16,v2.17,v2.18,v2.19,v2.20,v2.21,v2.22,v2.23,v2.24,"
ensure_valid_filenames_dir kubelb "ce,ee"
ensure_valid_filenames_dir content/operatingsystemmanager

if [[ $EXIT_CODE == 1 ]]; then
  echo
  echo "Only lowercase alphanumeric characters (a-z, 0-9) and dashes are allowed in file and directory names."
  echo "Please adjust your content accordingly."
fi

exit $EXIT_CODE
