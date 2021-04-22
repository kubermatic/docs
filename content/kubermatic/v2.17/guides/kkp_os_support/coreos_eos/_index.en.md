+++
title = "CoreOS End Of Support"
date =  2021-04-22T13:53:56+02:00
weight = 10
+++

Since May 2020 CoreOS Container Linux is end of life and no longer receives updates.
With the upcoming Kubermatic Kubernetes Platform (KKP) 2.16 release, we will no longer support CoreOS Container Linux.
In case you still have CoreOS clusters running, you risk to encounter major security liability from defective clusters.
Please read this blog post to learn how to migrate your clusters to be able to upgrade to v2.16.

## How Do I Check If I Have Running CoreOS Nodes?

You can check the operating system from the KKP dashboard (machine deployments list) or over kubectl commands,
for instance:
* `kubectl get machines -nkube-system`
* `kubectl get nodes -owide`.

## I Have Running CoreOS Nodes And I Want to Upgrade to v2.16 In The Future. What Should I Do?

You should create another machine deployment with a demanded operating system (like Flatcar or else) and delete (or scale down)
the old CoreOS machine deployments. Remember to wait for new machines to come up.

NOTE: To avoid double cluster size, we recommend you to scale up a new machine deployment and scale down the CoreOS deployments one by one.
Remove old deployments afterward.

## Will My Pods Be Evicted to Other Nodes?

Yes, Kubermatic supports pod’s eviction.
With the new deployment, you can then migrate the containers to the newly created machines and check if the application behaves like intended.

Additionally, it is a good idea to consider a pod disruption budget for each application you want to transfer to other nodes.

Example PDB resource:
```yaml
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: example-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: nginx
```
Find more information [here](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/).

## Do I Have to Rely on the Kubermatic Eviction Mechanism?

No, you can drain and cordon the nodes yourself. Remember to delete the CoreOS machine deployment afterward.

Find more information [here](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/).

## Eviction Stuck – What Should I Do?

When you choose to rely on the Kubermatic eviction mechanism, we assume that the eviction is blocked by misconfiguration
or a misbehaving kubelet and/or controller-runtime. If the deletion got triggered a few hours ago (by default, 2 hours),
the mechanism would skip the eviction, and node deletion will continue.
This means that the pod disruption budget would not be respected.

If you drain and cordon the nodes yourself, please find more information [here](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/#stuck-evictions).

In case you have questions regarding the CoreOS EOL or trouble migrating from CoreOS,
please feel free [to reach out to us](https://www.kubermatic.com/company/community/#discussions).

## Where to Learn More

* You will find more information on CoreOS EOL [here](https://coreos.com/os/eol/)
* Find [KKP on Github](https://github.com/kubermatic/kubermatic) to get all the updates on v2.16 soonish
