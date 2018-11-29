+++
title = "From 2.8 to 2.9"
date = 2018-10-29T12:07:15+02:00
weight = 13
pre = "<b></b>"
+++

After modifying the `values.yaml` files according to the information below, you merely need to re-apply helm charts upgrade from the `release/2.9` branch.

### Mandatory migrations

#### Kubermatic

With v2.9 the Kubermatic related CustomResourceDefinitions are not part of the Kubermatic Helm chart anymore.
To avoid potential deletions of CRD's a migration script has been written.
It is mandatory to execute this script with the new available charts:
```bash
# Change into the charts directory (Must be on the release/v2.9 branch)
cd charts
./kubermatic//migrate/migrate-kubermatic-chart.sh
```

The script will delete old Helm release information, delete the Kubermatic Namespace & reapply the new chart files.

After the migration has been done, it is safe to execute a `helm delete --purge kubermatic` without deleting all clusters.
