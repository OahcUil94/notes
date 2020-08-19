# kubernetes1.18.3 ubuntu安装

时间: 2020-08-17

## 版本信息

- Vagrant 2.2.7
- VirtualBox 6.1.4
- CentOS 7.8.2003 (Core)
- Kubernetes 1.18.3

```bash
# centos查看系统版本
cat /etc/centos-release
```

## 硬件信息

- CPU: Intel(R) Core(TM) i9-9900KF CPU @ 3.60GHz 8核
- RAM: 32GB

## 开始安装

### 切换超级管理员账户

```bash
sudo su
```

### 配置yum源

```bash
# 备份默认的yum源
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
# 下载aliyun的yum源
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
# 解决Couldn't resolve host 'mirrors.cloud.aliyuncs.com提示
sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
# 清除并生成缓存
yum clean all && yum makecache -y
```

参考资料: 
- [https://developer.aliyun.com/mirror/centos?spm=a2c6h.13651102.0.0.3e221b11vH8Z1X](https://developer.aliyun.com/mirror/centos?spm=a2c6h.13651102.0.0.3e221b11vH8Z1X)

### 配置DNS

```bash
# 备份NetworkManager.conf文件
mv /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf.backup

cat > /etc/NetworkManager/NetworkManager.conf <<EOF
[main]
dns=none

[logging]
EOF

# 解决mirrors.aliyun.com域名无法解析
cat >> /etc/resolv.conf <<EOF
nameserver 180.76.76.76
EOF

# 重启网络服务
systemctl restart NetworkManager.service
```

> 默认NetworkManager会自动更新`resolv.conf`文件, 添加`dns=none`配置到`NetworkManager.conf`文件会禁用此行为

参考资料:
- `man NetworkManager.conf`

### 安装docker前的准备工作

```bash
cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

# modprobe用于向内核中加载模块
# br_netfilter启用此内核模块, 以便遍历桥的数据包​​由iptables进行处理以进行过滤和端口转发, 并且集群中的k8s窗格可以相互通信
modprobe overlay
modprobe br_netfilter

# 创建kubernetes cri需要的网络参数
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# 表示开启网桥模式
# net.bridge.bridge-nf-call-iptables = 1
# net.bridge.bridge-nf-call-ip6tables = 1

## 手动加载所有的配置文件
sysctl --system

# 更新本地包
yum update -y

# 安装常用工具包
yum install -y vim net-tools telnet bind-utils wget yum-utils device-mapper-persistent-data lvm2
```

overlay参考资料:
- [https://www.cnblogs.com/lehuoxiong/p/9908118.html](https://www.cnblogs.com/lehuoxiong/p/9908118.html)

br_netfilter参考资料:
- [https://www.howtoing.com/centos-kubernetes-docker-cluster](https://www.howtoing.com/centos-kubernetes-docker-cluster)

官方资料:
- [https://kubernetes.io/docs/setup/production-environment/container-runtimes/](https://kubernetes.io/docs/setup/production-environment/container-runtimes/)

### 安装docker

```bash
# 配置阿里云的docker源
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 清理并更新缓存
yum clean all && yum makecache -y

# 安装docker相关组件
yum install -y docker-ce docker-ce-cli containerd.io
```

### 配置docker daemon.json文件

```bash
# 先启动docker, 启动docker会自动在/etc目录下创建docker目录
systemctl start docker
# 没有docker目录不会自动创建, 配置docker daemon.json文件
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "registry-mirrors" : [
    "https://thd69qis.mirror.aliyuncs.com",
    "https://f1361db2.m.daocloud.io",
    "https://mirror.ccs.tencentyun.com",
    "https://reg-mirror.qiniu.com",
    "https://docker.mirrors.ustc.edu.cn/",
    "https://registry.docker-cn.com"
  ]
}
EOF
systemctl daemon-reload
systemctl restart docker
systemctl enable docker

# 查看是否设置为了systemd
docker info | grep Cgroup
```

native.cgroupdriver=systemd配置原因:
- [https://blog.whsir.com/post-5312.html](https://blog.whsir.com/post-5312.html)
- [https://kubernetes.io/docs/setup/production-environment/container-runtimes/](https://kubernetes.io/docs/setup/production-environment/container-runtimes/)

### 添加vagrant用户到docker用户组

```bash
egrep "^docker" /etc/group
usermod -aG docker vagrant
```

shell中判断docker用户组是否存在: 
```bash
# 添加vagrant用户到docker用户组, egrep匹配字符串docker, 如果能匹配到, 返回0, 没有匹配到返回1
egrep "^docker" /etc/group >& /dev/null
if [ $? -ne 0 ]
then
  groupadd docker
fi
usermod -aG docker vagrant
```

### 禁用 SELinux

```bash
# 将SELinux设置为permissive模式(相当于将其禁用)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```

### 禁用swap分区

```bash
# 禁用swap
swapoff -a
# 给/etc/fstab这个文件swap相关内容前加注释
sed -i '/swap/s/^/#/g' /etc/fstab
```

### 关闭网络防火墙

```bash
systemctl stop firewalld
systemctl disable firewalld
```

### 配置kubernetes阿里云yum源

```bash
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# 清理并生成缓存
yum clean all && yum makecache -y
```

### 安装kubelet,kubeadm,kubectl前版本确认

```bash
# 查看镜像源支持的kubeadm版本, 目前最新版本支持到1.18.8-00, 但是还要检测阿里云镜像支持到的镜像版本
yum list kubeadm --showduplicates | sort -r
# 通过docker pull命令测试, 阿里云镜像支持的版本是1.18.3, 所以安装版本选择1.18.3
docker pull registry.aliyuncs.com/google_containers/kube-apiserver:v1.18.3
```

### 安装kubelet,kubeadm,kubectl

```bash
# 安装
yum install -y kubelet-1.18.3-0 kubeadm-1.18.3-0 kubectl-1.18.3-0

# 阻止包自动升级
yum -y install yum-versionlock
yum versionlock add kubelet kubeadm kubectl

# 设置开机自启动kubelet, 现在不用启动, 等一切配置都就绪再启动
systemctl enable kubelet
# 查看日志, 发现kubelet在报错, 不要介意
# journalctl -f
# 查看kubelet安装都生成了哪些文件
rpm -ql kubelet
```

### 下载kubernetes需要的镜像

```bash
echo "====pull images from aliyun===="
# 指定阿里云的镜像仓库
repo_name="registry.aliyuncs.com/google_containers"
# 指定镜像仓库并指定版本
kubeadm config images pull --image-repository=${repo_name} --kubernetes-version=v1.18.3
# 将阿里云镜像tag改成k8s.gcr.io
docker image list |grep ${repo_name} |awk '{print "docker tag ",$1":"$2,$1":"$2}' |sed -e "s#${repo_name}#k8s.gcr.io#2" |sh -x
# 查看docker镜像列表
docker image list
```

- [https://www.cnblogs.com/hongdada/p/11395200.html](https://www.cnblogs.com/hongdada/p/11395200.html)

### kubeadm init

```bash
# --pod-network-cidr: 指定pod所属网络cidr格式的网络地址
# --service-cidr: 指定service所属网络
# --apiserver-advertise-address: 指定apiserver监听的地址
# --ignore-preflight-errors='Swap': 可以不关闭swap
kubeadm init --apiserver-advertise-address='0.0.0.0' --pod-network-cidr='10.244.0.0/16' --kubernetes-version='v1.18.3'
```

kubeadm init --apiserver-advertise-address='192.168.34.103' --pod-network-cidr='10.244.0.0/16' --kubernetes-version='v1.18.3'

### 如果不关闭Swap, 如何进行初始化成功

1. 需要编辑kubelet配置文件: `/etc/sysconfig/kubelet`

```
KUBELET_EXTRA_ARGS="--fail-swap-on=false"
```

> 经过实验, 不加也是可以的

2. 执行`kubeadm init`命令的时候, 添加`--ignore-preflight-errors='Swap'`选项

## 初始化成功之后检验

- ss -tnl
- kubectl get cs

## 设置日志journald方案

日志的保存方式, 在升级到7以后，因为它的引导方式改成了systemd, 所以就会有两个日志系统在同时工作, 默认是rsyslogd, 还有一个是systemd journald, 默认使用journald方案, 更好一些

```bash
# 持久化保存日志的目录
mkdir /var/log/journal
mkdir /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/99-prophet.conf <<EOF
[Journal]
# 持久化保存到磁盘
Storage=persistent
# 压缩历史日志
Compress=yes
SyncIntervalSec=5m
RateLimitInterval=30s
RateLimitBurst=1000

# 最大占用空间 10G
SystemMaxUse=10G
# 单日志文件最大 200M
SystemMaxFileSize=200M
# 日志保存时间2周
MaxRetentionSec=2week
# 不将日志转发到syslog, 可以减轻系统压力
ForwardToSyslog=no
EOF
systemctl restart systemd-journald
```

## 可能初始化不成功的原因

- [https://blog.csdn.net/boling_cavalry/article/details/91306095](https://blog.csdn.net/boling_cavalry/article/details/91306095)
- [https://www.jianshu.com/p/745c96476a32](https://www.jianshu.com/p/745c96476a32)

 kubeadm init --apiserver-advertise-address='192.168.34.103' --pod-network-cidr='10.244.0.0/16' --kubernetes-version='v1.18.3'
W0818 17:27:18.847066     875 configset.go:202] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
[init] Using Kubernetes version: v1.18.3
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [worker2 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.34.103]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [worker2 localhost] and IPs [192.168.34.103 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [worker2 localhost] and IPs [192.168.34.103 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
W0818 17:27:22.008439     875 manifests.go:225] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
[control-plane] Creating static Pod manifest for "kube-scheduler"
W0818 17:27:22.009522     875 manifests.go:225] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 21.501864 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.18" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node worker2 as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node worker2 as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: 62y81o.5hochdto8cr2y8ik
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.34.103:6443 --token 62y81o.5hochdto8cr2y8ik \
    --discovery-token-ca-cert-hash sha256:476f6535fa1d53f81fd1a4d376e48e0ad3cc870dfa0cd77b57b12e12ea07d506
