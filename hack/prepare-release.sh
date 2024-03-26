#!/usr/bin/env bash
#
# Requirements:
# - yq v4.x

set -eo pipefail

usage() {
  echo "Helper script to prepare the docs for upcoming product releases."
  echo
  echo "Usage:"
  echo "  prepare-release.sh -p <PRODUCT> -v <VERSION>"
  echo
  echo "Flags:"
  echo "  -p    Product selection. One of 'kubermatic', 'kubeone'. (env: PRODUCT)"
  echo "  -v    Version of the upcoming release. (env: VERSION)"
  echo "  -h    Print this help."
  echo
  echo "Product and Version can be passed by flag or environment variable. The flag has the higher weight."
  echo "For the component version update the code of KKP either needs to be located at ../kubermatic or an alternative location needs to be set (see -k)."
}

line() {
  printf "| %-30s | %-30s |\n" "$1" "$2"
}

while getopts "hp:v:k:" option
do
  case $option in
    h)
      usage
      exit 0;;
    p)
      export PRODUCT=${OPTARG};;
    v)
      export VERSION=${OPTARG};;
    \?)
      usage
      exit 1;;
  esac
done

# Check mandatory parameters
[[ $VERSION ]] ||
  (usage; exit 1)

[[ $PRODUCT =~ ^(kubermatic|kubeone)$ ]] ||
  (usage; exit 1)

PRIMARY_BRANCH=main

# ensure leading v
VERSION="v${VERSION#v}"

# Copy content, data
cp -R content/$PRODUCT/{$PRIMARY_BRANCH,$VERSION}
cp -R data/$PRODUCT/{$PRIMARY_BRANCH,$VERSION}

# Update component versions only when preparing docs for KKP release
if [[ $PRODUCT == 'kubermatic' ]]
then
  sed -i --regexp-extended "s/9.9.9-dev/${VERSION#v}.0/g" content/kubermatic/${VERSION}/architecture/compatibility/KKP-components-versioning/_index.en.md
fi

# Update references
grep --recursive --files-with-matches "${PRODUCT}/$PRIMARY_BRANCH" -- "content/${PRODUCT}/${VERSION}" | while read -r f
do
  tmpfile=$(mktemp)
  sed --regexp-extended "s/(${PRODUCT}\/)$PRIMARY_BRANCH/\1${VERSION}/g" "$f" > $tmpfile
  mv $tmpfile "$f"
done

# Insert new release into version dropdown box
yq eval "
.[env(PRODUCT)].versions = [.[env(PRODUCT)].versions[0]]
  + [{\"release\": env(VERSION), \"name\": env(VERSION)}]
  + [.[env(PRODUCT)].versions[] | select(.name != \"$PRIMARY_BRANCH\")]
" -i data/products.yaml
