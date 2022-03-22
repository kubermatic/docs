+++
title = "Work with Secrets using SOPS"
description = "Install sops to Kubermatic Kubernetes Platform to be able to work with secrets. sops is an editor of encrypted files that supports YAML, JSON, ENV, INI and BINARY formats and encrypts with AWS KMS, GCP KMS, Azure Key Vault, age, and PGP."
weight = 50
+++

Install the [sops](https://github.com/mozilla/sops#download) tool locally (version `3.7.1` is used
in the automated pipeline).

## Decrypt the file
Take the values of AGE secret (from `secrets.md`) and put it in a file, e.g. `.age.txt`.

```shell
export SOPS_AGE_KEY_FILE=.age.txt
sops -d kubermatic/kubermatic-configuration.yaml
sops -d kubermatic/values.yaml
```

With above commands, you will get on standard output the decrypted content of the files.
You can also use `-i` option to use the in-place update of the file.

{{% notice warning %}}
Make sure that you never commit the files with decrypted values inside your repository!
{{% /notice %}}

## Encrypt the values

If you want to update some values or encrypt a new ones, you will need the AGE public key (set in `AGE_PUBLIC_KEY` variable)
which is passed to the `sops` command.
```shell
sops -e --encrypted-regex 'secret|Secret|key|Key|password|hash' --age $AGE_PUBLIC_KEY kubermatic/values.yaml
```

{{% notice info %}}
You should decrypt the whole file if you are willing to update some parts, otherwise `sops` will complain
that there the file has already some encrypted values.
{{% /notice %}}
