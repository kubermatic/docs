+++
title = "SSH Access to Worker Nodes"
date = 2019-11-13T12:07:15+02:00
weight = 90
+++
In order to SSH into a worker node, you first have to find the external IP address of the node:

```bash
$ kubectl get nodes -o wide
NAME                                          STATUS     ROLES    AGE   VERSION   INTERNAL-IP     EXTERNAL-IP      OS-IMAGE             KERNEL-VERSION    CONTAINER-RUNTIME
ip-172-31-19-107.eu-west-2.compute.internal   Ready      <none>   22s   v1.15.6   172.31.19.107   35.176.177.33    Ubuntu 18.04.3 LTS   4.15.0-1054-aws   docker://18.9.2
ip-172-31-20-156.eu-west-2.compute.internal   Ready      <none>   21s   v1.15.6   172.31.20.156   35.176.25.131    Ubuntu 18.04.3 LTS   4.15.0-1054-aws   docker://18.9.2
```

You can use the external IP to ssh into the node using the SSH key you added as described in [add an SSH key]({{< ref "../../../tutorials_howtos/project_and_cluster_management/" >}}) under project management section.

```bash
ssh -i ~/.ssh/id_rsa ubuntu@35.176.177.33
```

Note that some providers (e.g. Digitalocean) don't allow SSH access to worker nodes.
