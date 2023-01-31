+++
title = "Web Terminal"
date = 2023-01-30T14:40:55+02:00
weight = 80
+++

You can also manage your cluster with the Web Terminal and using `kubectl` commands there.

To enable it, go to the [Interface section]({{< ref "../../administration/admin-panel/interface/_index.en.md" >}}) of the Admin Panel.
After enabling it, a button will appear on the top right side of the user cluster page and the API will allow its usage.

![Web Terminal](/img/kubermatic/main/ui/web_terminal.png?classes=shadow,border)

**Note:** at the first usage time, you will be requested to login again using the ***same Kubermatic user email***. This is necessary to 
save the cluster `Kubeconfig` as a secret.

## How it works

After stablishing a websocket connection with the UI, the API deploys, in the user cluster, some Kubernetes resources responsible for executing 
the commands (pod), managing expiration, cleanup and network policy.

Then, the API starts streaming terminal commands from the UI to the Web Terminal pod deployed in the user cluster.

After 30 minutes, the expiration happens and every deployed resource is destroyed. Although, before 5 minutes of the expiration time, 
the user is asked for extending the terminal for more 30 minutes.

![Web Terminal sequence diagram](/img/kubermatic/main/ui/web_terminal_sequence_diagram.png?classes=shadow,border)
