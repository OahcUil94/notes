# helm install

时间: 2020-08-19

https://github.com/helm/helm

https://get.helm.sh/helm-v2.16.10-linux-amd64.tar.gz

```bash
# 解压缩
tar xf helm-v2.16.10-linux-amd64.tar.gz
# 进入linux-amd64目录
cd linux-amd64
# 把helm二进制文件移入/usr/bin
mv helm /usr/bin
# 配置tiller的rbac
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
helm init --service-account tiller --tiller-image=registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.16.6 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts --kubeconfig /root/.kube/config
helm version
```

关于rbac的配置: 
[https://github.com/helm/charts/blob/d256819ae938ca36b795de786b97076cf6e7ed90/stable/contour/README.md](https://github.com/helm/charts/blob/d256819ae938ca36b795de786b97076cf6e7ed90/stable/contour/README.md)

[https://github.com/helm/helm/blob/release-2.16/docs/rbac.md](https://github.com/helm/helm/blob/release-2.16/docs/rbac.md)

helm init命令去部署tiller, 联系上api-server, api-server去指挥安装tiller pod
helm和kubectl命令一样, 也会去获取.kube/config文件, 链接至k8s集群之上, 来完成初始化

[https://www.cnblogs.com/breezey/p/9398927.html](https://www.cnblogs.com/breezey/p/9398927.html)

helm官方可用的chart官方仓库: 
[https://hub.kubeapps.com/](https://hub.kubeapps.com/)
[https://blog.51cto.com/14157628/2474498?source=dra](https://blog.51cto.com/14157628/2474498?source=dra)

registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.16.6