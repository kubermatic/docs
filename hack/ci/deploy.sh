#!/usr/bin/env bash

set -euo pipefail

LATEST_VERSION=v2.11 # the current stable release
MASTER_VERSION=v2.12 # the version that is currently inside the master branch
TMPDIR=octodocs      # directory where all the documentations are placed

cd $(dirname "$0")/../..

cleanup() {
  rm -rf $TMPDIR
}
# trap "cleanup" EXIT SIGINT

cleanup

# collect release branch names ('v2.10', 'v2.11', 'v2.9', ...), sorted by version number
BRANCHES=$(git branch -r | sed 's/^ *//' | grep -E '^origin/release/' | cut -d/ -f3 | sort -V)
BRANCHES+=$'\nmaster'

# put branch info in a Hugo data file (we use TOML because it's easy to generate)
VFILE=data/versions.toml
rm -f $VFILE

while read -r release; do
  case "$release" in
    "$LATEST_VERSION") name="$release (latest)" ;;
    "master")          name="$MASTER_VERSION (dev)"; release="$MASTER_VERSION" ;;
    *)                 name="$release" ;;
  esac

  cat >> $VFILE << EOF
[[versions]]
release = "$release"
name = "$name"
EOF
done <<< "$BRANCHES"

mkdir -p $TMPDIR

# build each branch sequentially and copy the result to the octodocs directory
while read -r release; do
  echo "Build documentation for release $release..."
  rm -rf public

  dir="$release"

  if [ "$release" == "master" ]; then
    git checkout master
    dir="$MASTER_VERSION"
  else
    git checkout "release/$release"
  fi

  hugo
  mkdir $TMPDIR/$dir
  mv public/* $TMPDIR/$dir
done <<< "$BRANCHES"

# create some handy symlinks
(
  cd $TMPDIR
  ln -s $LATEST_VERSION latest
  ln -s $MASTER_VERSION dev
)
