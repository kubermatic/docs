
In order to SSH into a worker node, you first have to find the external IP address of the node:

```bash
$ kubectl get nodes -o wide
NAME                          STATUS    ROLES     AGE       VERSION   EXTERNAL-IP       OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
kubermatic-fhgbvx12xg-4kmht   Ready     <none>    1d        v1.10.3   123.123.123.1     Ubuntu 16.04.4 LTS   4.4.0-116-generic   docker://17.3.2
kubermatic-fhgbvx12xg-jzspq   Ready     <none>    1d        v1.10.3   123.123.123.2     Ubuntu 16.04.4 LTS   4.4.0-116-generic   docker://17.3.2
kubermatic-fhgbvx12xg-t8nwc   Ready     <none>    1d        v1.10.3   123.123.123.3     Ubuntu 16.04.4 LTS   4.4.0-116-generic   docker://17.3.2
```

You can use the external IP to ssh into the node using the SSH key you added as described in [add an SSH key](../01.add-an-ssh-key/default.en.md):

```bash
ssh -i ~/.ssh/id_rsa ubuntu@123.123.123.1
```