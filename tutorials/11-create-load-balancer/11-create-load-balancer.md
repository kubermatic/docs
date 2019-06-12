

## The Kubernetes Manifest

Kubernetes defines a resource type "LoadBalancer" that you can use to create a managed load balancer for every [service](https://kubernetes.io/docs/concepts/services-networking/service/). To create a Kubernetes managed load balancer, use a manifest like the following:

```yaml
kind: Service
apiVersion: v1
metadata:
  name: $LOADBALANCER_NAME
spec:
  selector:
    $APPLICATION_LABEL: $APPLICATION_NAME
  ports:
    - protocol: TCP
      port: 80
      name: http
    - protocol: TCP
      port: 443
      name: https
  type: LoadBalancer
```

Be sure to match the [label](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) and value of the [selector](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors) to your application and preferably choose a speaking name for the Load Balancer. The created Load Balancer might look like this:

```bash
$ kubectl get svc
NAME           TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE
loadbalancer   LoadBalancer   10.10.10.202   195.192.128.46   80:31228/TCP,443:30279/TCP   11s
```

This load balancer now exposes port 80 to the outside world and maps it to port 31228 on all cluster nodes, and it exposes port 443 to the outside world and maps it to ports 30279 on all cluster nodes. This means that a loadbalancer service is also a NodePort service (i.e. a service that exposes pods on specific "NodePorts" on all nodes).