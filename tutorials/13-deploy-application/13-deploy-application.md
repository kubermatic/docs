This tutorial describes how you can deploy a demo application to the cluster.

## Requirements

* A working ingress controller and cert-manager as described in [Create an Ingress Controller](../12-create-ingress-controller/12-create-ingress-controller.md).
* A DNS record pointing to the external IP of the ingress controller.

## Deploy an application

For this tutorial we are going the deploy the [NGINX hello image](https://hub.docker.com/r/nginxdemos/hello/) to our cluster. Therefore create a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/):

```bash
cat <<'EOF' | kubectl apply -f -
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: nginx-hello
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-hello
  template:
    metadata:
      labels:
        app: nginx-hello
    spec:
      containers:
      - name: nginx-hello
        image: nginxdemos/hello:0.2
        livenessProbe:
          httpGet:
            path: /
            port: 80
          timeoutSeconds: 1
        readinessProbe:
          httpGet:
            path: /
            port: 80
          timeoutSeconds: 1
EOF
```

## Make the application accessible from the outside

In order to make the application accessible from the outside, we first have to expose it with a [Service](https://kubernetes.io/docs/concepts/services-networking/service/):

```bash
cat <<'EOF' | kubectl apply -f -
kind: Service
apiVersion: v1
metadata:
  name: nginx-hello
spec:
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: nginx-hello
EOF
```

And then create an [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) resource which registers it at our ingress controller and fetches a TLS certificate for it:

```bash
cat <<'EOF' | kubectl apply -f -
kind: Ingress
apiVersion: extensions/v1beta1
metadata:
  name: nginx-hello
  annotations:
    certmanager.k8s.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - nginx-hello.your-domain.com
    secretName: nginx-hello-tls-secret
  rules:
  - host: nginx-hello.your-domain.com
    http:
      paths:
      - path: /
        backend:
          serviceName: nginx-hello
          servicePort: 80
EOF
```

The application is now reachable at ```https://nginx-hello.your-domain.com```.