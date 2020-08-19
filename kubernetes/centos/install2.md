# kubeadm init之后的事情

kubeadm config print init-defaults > kubeadm-config.yaml

```yaml
apiVersion: kubeadm.k8s.io/v1beta2
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.34.101
  bindPort: 6443
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: worker1
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kind: ClusterConfiguration
kubernetesVersion: v1.18.3
networking:
  dnsDomain: cluster.local
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/12
scheduler: {}
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
featureGates:
  SupportIPVSProxyMode: true
mode: ipvs
```

kubeadm init --config=kubeadm-config.yaml | tee kubeadm-init.log

> [https://blog.csdn.net/woshizhangliang999/article/details/107675543](https://blog.csdn.net/woshizhangliang999/article/details/107675543)

## 忘记了token

- kubeadm token list
- kubeadm token create --print-join-command --ttl=0 默认ttl是24小时, 0表示不用过期

```bash
$ kubeadm token create --print-join-command --ttl=0
W0819 10:35:13.061489   29168 configset.go:202] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
kubeadm join 192.168.33.101:6443 --token 8q610z.o1u2ent8eadj4dyl --discovery-token-ca-cert-hash sha256:33f0ce330dc8af3be72ff3d404870356b4bba234b276c8b8b53fe92ffc585d02
```

 kubeadm join 192.168.33.101:6443 --token 8q610z.o1u2ent8eadj4dyl --discovery-token-ca-cert-hash sha256:33f0ce330dc8af3be72ff3d404870356b4bba234b276c8b8b53fe92ffc585d02
W0819 10:37:56.807673    4692 join.go:346] [preflight] WARNING: JoinControlPane.controlPlane settings will be ignored when control-plane flag is not set.
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.18" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

[root@worker1 vagrant]# kubectl get nodes
The connection to the server localhost:8080 was refused - did you specify the right host or port?

wget https://cdn.jsdelivr.net/gh/coreos/flannel@0.12.0/Documentation/kube-flannel.yml

kubectl create -f kube-flannel.yml
如果镜像一直下载不下来， 可以先:
kubectl delete -f kube-flannel.yml

quay.io/coreos/flannel:v0.12.0-amd64
docker pull quay.mirrors.ustc.edu.cn/coreos/flannel:v0.12.0-amd64

repo_name="quay.mirrors.ustc.edu.cn"
docker image list |grep ${repo_name} |awk '{print "docker tag ",$1":"$2,$1":"$2}' |sed -e "s#${repo_name}#quay.io#2" |sh -x
