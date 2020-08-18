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

kubeadm init --pod-network-cidr='10.244.0.0/16' --kubernetes-version='v1.18.3'

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

## 可能初始化不成功的原因

- [https://blog.csdn.net/boling_cavalry/article/details/91306095](https://blog.csdn.net/boling_cavalry/article/details/91306095)
- [https://www.jianshu.com/p/745c96476a32](https://www.jianshu.com/p/745c96476a32)
