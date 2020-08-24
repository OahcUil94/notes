# kubectl

- kubectl是api-server的客户端
- kubectl默认读取`~/.kube/config`配置进行连接, 所以在其他节点上使用时, 可以复制`master`配置到节点`~/.kube/config`

## 常用命令

- kubectl version: 查看版本信息
- kubectl cluster-info: 查看集群信息
- kubectl get nodes: 获取所有节点列表
- kubectl describe node worker1: 获取worker1节点的详细信息
- kubectl get命令访问所有资源时, 使用的是default默认命名空间, 可使用`-n 命名空间`来指定

## 创建运行容器

`kubectl run nginx-deploy --image=nginx:1.19.2-alpine --port=80`

```bash
$ kubectl get pods -o wide
NAME           READY   STATUS    RESTARTS   AGE     IP           NODE      NOMINATED NODE   READINESS GATES
nginx-deploy   1/1     Running   0          3m42s   10.244.2.2   worker2   <none>           <none>

$ curl 10.244.2.2
```

- kubectl get pods 
- kubectl get pods -o wide: 查看pod更详细的信息, 运行在哪个节点

> 注意: 在k8s 1.18版本之后, --replicas参数已经被废弃, 使用清单文件来创建副本, 直接使用`kubectl run`命令只能创建单个pod

```bash
cat > nginx-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.19.2-alpine
        ports:
        - containerPort: 80
EOF

kubectl apply -f nginx-deployment.yaml
```

## 删除pod

`kubectl delete pods nginx-deploy-7999b9c657-2gtfz`

## 创建service

通过`kubectl expose`命令, 可以创建`service`对象

```bash
kubectl apply -f nginx-deployment.yaml
kubectl expose deployment nginx-deploy --name=nginx --port=80 --target-port=80 --protocol=TCP
kubectl get svc
```

## kube-dns解析内部域名

```bash
$ kubectl get svc -n kube-system
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
kube-dns        ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP   2d6h

# yum install -y bind-utils
# 注意这里的ip是kube-dns的ip
$ dig -t A nginx.default.svc.cluster.local @10.96.0.10

# 使用busybox作为pod的客户端, 进行内部网络测试
# kubectl attach client -c client -it
$ kubectl run client --image=busybox -it

# 进入busybox内部后, 查看DNS配置
/ # cat /etc/resolv.conf
nameserver 10.96.0.10
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5

/ # wget -O - -q http://nginx:80/
```

service的策略就是根据标签选择器去选择对应的pod: 

```bash
$ kubectl describe svc nginx
$ kubectl get pods --show-labels
# 自行编辑svc相关的配置, 例如: ip
$ kubectl edit svc nginx
```

如果把service删除, 然后重建, service的信息是可以动态反应到coreDNS中去的

## deployment控制器

控制器也是通过标签选择器来关联到pod资源上去的, nginx-deploy也是一个相关资源: `kubectl describe deployment nginx-deploy`

创建资源时, 监控资源启动的状态 `kubectl get deployment -w`

## 实验

```bash
# 创建pods
kubectl run whoami --image=containous/whoami:v1.5.0 --port=80
# 扩容
kubectl scale --replicas=5 deployment myapp
# 扩容过程中查看扩容变化
while true; do wget -O - -q myapp/hostname.html; sleep 1; done
# 设置pod中哪个容器进行镜像升级
kubectl set image deployment whoami whoami=containous/whoami:dev
# 显示更新过程
kubectl rollout status deployment whoami
# 回滚
kubectl rollout undo deployment whoami
```

已经解决了，如果有人碰到一样的问题，可以尝试清理和重置iptables配置，然后重新启动服务。iptables的转发问题导致数据包到不了容器内部。

yum install -y iptables-services
systemctl start iptables
systemctl enable iptables
iptables -F
service iptables save