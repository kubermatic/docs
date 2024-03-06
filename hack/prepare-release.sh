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
  echo "  -k    Location of kubermatic/kubermatic working copy. (env: KUBERMATIC_DIR, default: '../kubermatic')"
  echo "  -h    Print this help."
  echo
  echo "Product and Version can be passed by flag or environment variable. The flag has the higher weight."
  echo "For the component version update the code of KKP either needs to be located at ../kubermatic or an alternative location needs to be set (see -k)."
}

line() {
  printf "| %-30s | %-30s |\n" "$1" "$2"
}

version_table() {
  line "KKP Component" "Version"
  line "---" "---"
  for comp in $(find $KUBERMATIC_DIR/charts -name 'Chart.yaml')
  do
    folder=${comp%/*}
    name=${folder#$KUBERMATIC_DIR/charts/}
    ver=$(yq e '.appVersion' $comp | sed "s/__KUBERMATIC_TAG__/${VERSION}.0/;s/^v//")
    line $name $ver
  done
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
    k)
      export KUBERMATIC_DIR=${OPTARG};;
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

# Default value if unset
KUBERMATIC_DIR=${KUBERMATIC_DIR:-"../kubermatic"}

PRIMARY_BRANCH=master
if [ -d content/$PRODUCT/main ]; then
  PRIMARY_BRANCH=main
fi

# Update component versions and copy static images only when preparing docs for KKP release
if [[ $PRODUCT == 'kubermatic' ]]
then
  tmpfile=$(mktemp)
  sed '/^|.*KKP/Q' content/kubermatic/$PRIMARY_BRANCH/architecture/compatibility/KKP-components-versioning/_index.en.md > $tmpfile
  version_table >> $tmpfile
  mv $tmpfile content/kubermatic/$PRIMARY_BRANCH/architecture/compatibility/KKP-components-versioning/_index.en.md

  cp -R static/img/kubermatic/{$PRIMARY_BRANCH,$VERSION}
fi

# Copy content
cp -R content/$PRODUCT/{$PRIMARY_BRANCH,$VERSION}

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
