+++
title = "Web Terminal"
date = 2023-01-30T14:40:55+02:00
weight = 80
+++

Web terminal allows `kubectl` access to a user cluster directly from the KKP dashboard web interface.
Therefore, you can also manage your cluster with the Web Terminal by using `kubectl` commands there.

To enable it, go to the [Interface section]({{< ref "../../administration/admin-panel/interface/_index.en.md" >}}) of the Admin Panel.
After enabling it, a button will appear on the top right side of the user cluster page and the API will allow its usage.

![Web Terminal](/img/kubermatic/main/ui/web_terminal.png?classes=shadow,border)

**Note:** at the first usage time, you will be requested to login to KKP again. Please use a user with the ***same Kubermatic user email***.

## How it works

After KKP UI establishes a websocket connection with the the KKP API, webterminal-related Kubernetes resources are deployed in the user cluster. 
These are responsible for executing the commands (pod), managing expiration, cleanup and network policy.

Then, the API starts streaming terminal commands from the UI to the Web Terminal pod deployed in the user cluster.

After 30 minutes, the expiration happens and every deployed resource is destroyed. Although, 5 minutes before the expiration time, 
the user is asked for extending the terminal for more 30 minutes.

![Web Terminal sequence diagram](/img/kubermatic/main/ui/web_terminal_sequence_diagram.png?classes=shadow,border)

## Troubleshooting

### Connection being closed after some time

KKP nginx ingress controller is configured with 1 hour proxy timeout to support long-lasting connections of webterminal. In case that you use a different ingress controller in your setup, you may need to extend the timeouts for the `kubermatic` ingress - e.g. in case of nginx ingress controller, you can add these annotations to have a 1 hour "read" and "send" timeouts:
```
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
```

### Cannot connect to other pods or internet from the web terminal pod

The `network policy` deployed to the user cluster restricts access from the web terminal `pod` and allow only the egress to the Kubernetes API server. Therefore you will not be able to access any other pods in the cluster from the web terminal pod.
