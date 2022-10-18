# Documentation process for Kubermatic projects

This document describes the documentation process for Kubermatic projects.

## What must be documented?

All user-facing changes must be documented. Documentation for KKP,
KubeOne, and KubeCarrier is located in this repository. Documentation for
other projects is usually located in the respective repository.

## How are changes documented?

Changes are documented by creating a PR in the appropriate repository. The PR
should contain a new markdown document or update an existing document. The
purpose of the PR is to describe the change, including but not limited to:

- how does the change affect users
- how users can utilize that change (e.g. how to use a new feature)
- any information about manual (migration) steps that user might need to take

The PR description should contain a reference to the PR that implemented said
change and/or a reference to the Epic/issue.

## PR workflow

For some repositories, we're requiring users to provide a reference to
documentation in a PR the implements the change. This reference is provided via
the `documentation` block in the PR description. The `documentation` block looks
like this:

````
```documentation

```
````

The provided reference must be one of:

- a link to the documentation PR (it can be a placeholder PR)
- a link to the documentation issue for that change
- `TBD` — used to annotate PRs for which documentation will be provided at some
  point later
- `NONE` — used to annotate PRs for which there's no need to document anything

Providing an invalid documentation reference will block the PR from being
merged until a valid reference is not provided.

If you're unsure what to provide, you can use `TBD` or ask for some guidance
via comments.

**Note:** `TBD` should be only used if you're not sure what reference to provide
or if it's needed to urgently merge the PR. In other cases, it's strongly
advised to create a new issue for documenting that change or a placeholder PR
in the appropriate repository.
