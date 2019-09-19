#!/usr/bin/env bash

set -euo pipefail

# as all branches are deployed in a single website, we want to always
# run a consistent build script; to achieve this we always build and
# deploy the docs using the master branch's deploy.sh version.
# if [ "$(git rev-parse --abbrev-ref HEAD)" != "master" ]; then
#   echo "Switching to the master branch for building the documentation."
#   git checkout master
#   ./hack/ci/deploy.sh
#   exit 0
# fi

LATEST_VERSION=v2.11 # the current stable release
MASTER_VERSION=v2.12 # the version that is currently inside the master branch
TMPDIR=octodocs      # directory where all the documentations are placed

cd $(dirname "$0")/../..
source ./hack/lib.sh

# setup Docker
# echodate "Logging into Quay"
# docker ps > /dev/null 2>&1 || start-docker.sh
# retry 5 docker login -u "$QUAY_IO_USERNAME" -p "$QUAY_IO_PASSWORD" quay.io
# echodate "Successfully logged into Quay"

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

rm -rf $TMPDIR
mkdir -p $TMPDIR

# build each branch sequentially and copy the result to the octodocs directory;
# at the same time collect branch heads to build a consistent, meaningful tag for
# our octodocs
HASHES=""
while read -r release; do
  dir="$release"
  branch="$release"

  if [ "$release" == "master" ]; then
    dir="$MASTER_VERSION"
  else
    branch="release/$release"
  fi

  rev=$(git rev-parse "$branch")

  echodate "Build documentation for release $release (@ $rev)..."
  git checkout "$branch"

  # build site
  rm -rf public
  hugo --baseURL "/$dir/"

  # leave behind a nice version file
  HASHES+="$rev"
  echo "$rev" > public/version

  # move site to octodocs
  mkdir $TMPDIR/$dir
  mv public/* $TMPDIR/$dir
done <<< "$BRANCHES"

# create some handy symlinks so that people can create links
# to docs.kubermatic.io/latest/...
(
  cd $TMPDIR
  ln -s $LATEST_VERSION latest
  ln -s $MASTER_VERSION dev
)

# return to the master branch to find the current Dockerfile
git checkout octobox

# create Docker image
echodate "Creating Docker Image..."

TAG=$(echo "$HASHES" | sha1sum - | cut -d" " -f1)
IMAGE="quay.io/kubermatic/documentation:$TAG"

docker build -t "$IMAGE" --no-cache .
docker push "$IMAGE"

echodate "Build succeeded."
