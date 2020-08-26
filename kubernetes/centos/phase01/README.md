# 第一阶段 配置服务器, 初始化k8s配置

- kubeadm token list
- kubeadm token create --print-join-command --ttl=0
- kubeadm join 192.168.33.101:6443 --token 8q610z.o1u2ent8eadj4dyl --discovery-token-ca-cert-hash sha256:33f0ce330dc8af3be72ff3d404870356b4bba234b276c8b8b53fe92ffc585d02
- kubectl config view
- scp /etc/kubernetes/admin.conf worker1:/root/.kube/config
- scp /etc/kubernetes/admin.conf worker2:/root/.kube/config

## 说明

kubectl是靠.kube目录下的默认是config文件来加载该联系哪个集群，并向集群提供认证信息的

echo "====install flannel===="
wget https://cdn.jsdelivr.net/gh/coreos/flannel@0.12.0/Documentation/kube-flannel.yml
kubectl create -f kube-flannel.yml
kubectl get pod -n kube-system
