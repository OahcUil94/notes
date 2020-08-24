#!/usr/bin/env bash

wget https://get.helm.sh/helm-v2.16.10-linux-amd64.tar.gz
tar xf helm-v2.16.10-linux-amd64.tar.gz
cd linux-amd64
mv helm /usr/bin
cat > tiller-rbac.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF
kubectl create -f tiller-rbac.yaml
kubectl get sa -n kube-system
helm init --service-account tiller \
    --tiller-image registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.16.6 \
    --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts \
    --kubeconfig /root/.kube/config
helm version
