+++
title = "Using the seed installer"
date = 2018-04-28T12:07:15+02:00
weight = 5
pre = "<b></b>"
+++

## Using the seed installer

To aid in setting up the seed and master clusters, we provide the
[seed-installer](https://github.com/kubermatic/kubermatic-installer/tree/release/v2.6/kubeadm-seed-installer)
which is a kubeadm-based solution for setting up a Highly-Available Kubernetes cluster.

The cluster has to interact with a cloud provider.

## How it works.
This installer locally renders assets, copies them to the corresponding
machines, installs dependencies on the machines and runs scripts. For this
purpose it uses ssh to connect to the machines, thus it requires passwordless
sudo. (e.g ubuntu@XMachine) ubuntu needs sudo permissions.

It works in two phases:
### Phase 1
* Render static assets (configs, systemd units, etcd static pod manifests)
* Generate PKI on the first master
* Copy generated assets from master to localmachine
* Distribute static contents to all master nodes
* Initialize etcd ring (boot kubelet, providing it with our etcd static
  manifest).

### Phase 2
Having working etcd ring allows us to bootstrap all other control-plain
components, in HA mode.

On second pass script will run `kubeadm init --config=OUR_MASTER_CONFIG.yaml` on
every master node. During that phase the kubeadm will show warning like this:
```
[preflight] Running pre-flight checks.
        [WARNING Port-10250]: Port 10250 is in use
        [WARNING FileAvailable--etc-kubernetes-manifests-etcd.yaml]: /etc/kubernetes/manifests/etcd.yaml already exists
        [WARNING FileExisting-crictl]: crictl not found in system path
```

Which is totally normal and expected. We generated `etcd.yaml` by ourselves and
boot up the kubelet before `kubeadm init` (port is in use warning). Those
warnings are actually fatal errors in normal kubeadm operations, but for our
use-case (kubeadm-based HA setup) they can be neglected.

And in the end the script will run `kubeadm join` on every worker node.

## Prerequisites.
* All machines need to be accessible over a keyfile via ssh.
* All public IPs of the master servers.
* All private IPs of the master server.
* All public IPs of the workers (have to be distinct from the master IPs).
* The LoadBalancer IP (if not existent use a any master server IP).
* The default user used during installation.
* The cloud-provider-config path, check the provided `cloudconfig-<providername>.sample.conf` files for a reference
* The cloud provider used (e.g aws).

Copy the `config-example.sh` script to `config.sh`, edit the variables and run `./install.sh`

# Add workers

To add worker nodes simply update to config.sh nodes and execute `install-worker.sh`

## Upgrading the cluster

First drain the node you want to update.
```bash
kubectl drain <node name>
```
Next edit `/etc/kubernetes/kubeadm-config.yaml` and set the kubernetes version.

Now you can simply initialize this node with the new kubernetes version like:

`sudo kubeadm init --config /etc/kubernetes/kubeadm-config.yaml --ignore-preflight-errors all`

Once that's done you should see the apiserver, node-controller and scheduler restarting.
These components are now running in the new version.

Don't forget to undrain the node again.
```bash
kubectl uncordon <node name>
```

Repeat for all other nodes one by one.
