To download the kubeconfig, navigate to `Clusters` and select the correct cluster. On the top right you can find a button `Download Config`:

![Download config button in the top right corner](06-download-kubeconfig-button.png)

The token in the kubeconfig gives you full admin rights within the Kubernetes cluster.
You can change the admin token by revoking the existing one on the cluster detail page. For that, click on the link saying `More` under the cluster details to show the full details:

![Roll out more cluster details](06-download-kubeconfig-more.png)

Click the link saying `Revoke` and confirm in the opening dialog.

![Revoke the admin token](06-download-kubeconfig-revoke.png)