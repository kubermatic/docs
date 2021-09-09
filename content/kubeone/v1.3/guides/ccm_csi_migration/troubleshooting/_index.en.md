+++
title = "Troubleshooting a failed migration"
date = 2021-09-06T12:00:00+02:00
enableToc = true
+++

In some rare cases it might happen that the CCM/CSI migration fails. This
document provides a quick checklist that you can follow in order to debug the
potential issue.

If you don't manage to solve the problem by following this guide, you can
create a new issue in the [KubeOne GitHub repository][kubeone-issues].
The issue should include details about the issue, including which migration
phase failed, and logs for the failing component.

1. Check the status of your nodes:
   ```
   kubectl get nodes
   ```
    All nodes in the cluster should be Ready. You should have 3 control plane
    nodes, while the number of worker nodes depend on your configuration. In
    case there's a node that's NotReady, describe the node to check its status
    and events:
    ```
    kubectl describe node NODE_NAME
    ```
    
2. Check the status of pods in the `kube-system` namespace. All pods should be
Running and not restarting or crashlooping:
   ```
   kubectl get pods -n kube-system
   ```

3. If there's a pod that's not running properly, describe the pod to check its
   events inspect and check the logs:
   ```
   kubectl describe pod -n kube-system POD_NAME
   kubectl logs -n kube-system POD_NAME
   ```
   Note: you can get logs for previous runs of the pod by using the `-p` flag,
   for example: `kubectl logs -p -n kube-system POD_NAME`

4. 
   a) In case there's a control plane component that's failing (such as
   kube-apiserver or kube-controller-manager), you'll need to restart the
   container itself. In this case, you can't use `kubectl delete` to restart
   the component because the control plane components are managed by static
   manifests.

   1. SSH to the affected node. You can find the node where the pod is running
      either from the pod name, which is usually `<component-name>-<node-name>`.
   2. List all running containers and find the ID of the container that you want
      to restart
      ```
      sudo crictl ps
      ```
   3. First stop the container and then delete it:
      ```
      sudo crictl stop CONTAINER_ID
      sudo crictl rm CONTAINER_ID
      ```
    4. You can now observe the status of the pod and check its logs using
       `kubectl`

   b) In case some other component is running, you can try restarting it by
   deleting the pod:
   ```
   kubectl delete pod -n kube-system POD_NAME
   ```

5. If the previous steps didn't reveal the issue, SSH to the node and inspect
   the Kubelet logs. That can be done by using the following command:
   ```
   sudo journalctl -fu kubelet.service
   ```
   You can try restarting kubelet by running the following command:
   ```
   sudo systemctl restart kubelet
   ```

6. If none of the previous steps help you resolve the issue, you can try
   restarting the affected instance. In some cases, restarting the instance can
   make the issue go away.

   1. First, drain and cordon the node. This will make node unschedulable while
      moving all the workload on other nodes:
      ```
      kubectl drain NODE_NAME
      kubectl cordon NODE_NAME
      ```
   2. SSH to the node and restart it:
      ```
      sudo restart
      ```
   3. Wait for node to boot and observe is it going to become healthy again. If
      it becomes healthy, you can uncordon it to make it schedulable again:
      ```
      kubectl uncrodon NODE_NAME
      ```

[kubeone-issues]: https://github.com/kubermatic/kubeone/issues
