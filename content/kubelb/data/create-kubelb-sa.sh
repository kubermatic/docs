#!/usr/bin/env bash
set -euox pipefail

if [ $# -ne 1 ] ; then
    echo 'No cluster ID provided'
    exit 1
fi

clusterId=$1
namespace=$clusterId

kubectl create namespace "$namespace"
cat <<EOF | kubectl apply -n "$namespace" -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kubelb-agent
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: kubelb-agent-role
rules:
  - apiGroups:
      - kubelb.k8c.io
    resources:
      - loadbalancers
    verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
  - apiGroups:
      - kubelb.k8c.io
    resources:
      - loadbalancers/status
    verbs:
      - get
      - patch
      - update
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kubelb-agent-rolebinding
subjects:
  - kind: ServiceAccount
    name: kubelb-agent
roleRef:
  kind: Role
  name: kubelb-agent-role
  apiGroup: rbac.authorization.k8s.io
EOF


# your server name goes here
server=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
token_name=$(kubectl -n $namespace get sa kubelb-agent -o jsonpath='{.secrets[0].name}')
ca=$(kubectl -n $namespace get secret/$token_name -o jsonpath='{.data.ca\.crt}')
token=$(kubectl -n $namespace get secret/$token_name -o jsonpath='{.data.token}' | base64 --decode)

echo "
apiVersion: v1
kind: Config
clusters:
- name: kubelb-cluster
  cluster:
    certificate-authority-data: ${ca}
    server: ${server}
contexts:
- name: default-context
  context:
    cluster: kubelb-cluster
    namespace: $namespace
    user: default-user
current-context: default-context
users:
- name: default-user
  user:
    token: ${token}"
