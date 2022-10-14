# Hack scripts

## hack/prepare-release.sh

* Copies content and assets from `master` (or `main`) to the desired version subfolder
* Updates all references to point to the versioned copies
* Adds the new product version to `data/products.yaml` to make it selectable in the rendered page
* For `kubermatic` only:
    * Updates the components version table based on a working copy of the `kubermatic/kubermatic` repository

### Requirements

* [yq >= v4.x](http://mikefarah.github.io/yq/)

### Usage
```
$ hack/prepare-release.sh -h
Helper script to prepare the docs for upcoming product releases.

Usage:
  prepare-release.sh -p <PRODUCT> -v <VERSION>

Flags:
  -p    Product selection. One of 'kubermatic', 'kubeone', 'kubecarrier'. (env: PRODUCT)
  -v    Version of the upcoming release. (env: VERSION)
  -k    Location of kubermatic/kubermatic working copy. (env: KUBERMATIC_DIR, default: '../kubermatic')
  -h    Print this help.

Product and Version can be passed by flag or environment variable. The flag has the higher weight.
For the component version update the code of KKP either needs to be located at ../kubermatic or an alternative location needs to be set (see -k).
$ hack/prepare-release.sh -p kubermatic -v v2.20
$ git diff
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   content/kubermatic/master/architecture/support_policy/KKP_components_versioning/_index.en.md
	modified:   data/products.yaml

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	content/kubermatic/v2.20/
	static/img/kubermatic/v2.20/
```
