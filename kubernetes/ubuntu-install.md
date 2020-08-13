# kubernetes1.18.3 ubuntu安装

时间: 2020-08-12

## 版本信息

- vagrant 2.2.7
- virtualBox 6.1.4
- ubuntu 16.04.12
- kubernetes 1.18.3

## 硬件信息

- CPU: Intel(R) Core(TM) i9-9900KF CPU @ 3.60GHz 8核
- RAM: 32GB

## 开始安装

### 配置apt源

```bash
# 备份之前的镜像源
cp /etc/apt/sources.list /etc/apt/sources.list.backup

# 追加阿里云的镜像源,以下镜像源是ubuntu16.04LTS版本的
cat >> /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse
EOF

# 解决mirrors.aliyun.com域名无法解析
cat >> /etc/resolv.conf <<EOF
nameserver 180.76.76.76
EOF

# 重启网络
/etc/init.d/networking restart

# 更新本地镜像源和包
apt-get update
```

镜像源配置参考资料:
- [https://developer.aliyun.com/mirror/ubuntu?spm=a2c6h.13651102.0.0.3e221b114Ytqax](https://developer.aliyun.com/mirror/ubuntu?spm=a2c6h.13651102.0.0.3e221b114Ytqax)

### 安装docker前的准备工作

```bash
# 使用overlay文件系统
cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

# modprobe用于向内核中加载模块
modprobe overlay
# br_netfilter启用此内核模块, 以便遍历桥的数据包​​由iptables进行处理以进行过滤和端口转发, 并且集群中的k8s窗格可以相互通信
modprobe br_netfilter

# 创建kubernetes cri需要的网络参数
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

## 手动加载所有的配置文件
sysctl --system
```

overlay参考资料:
- [https://www.cnblogs.com/lehuoxiong/p/9908118.html](https://www.cnblogs.com/lehuoxiong/p/9908118.html)

br_netfilter参考资料:
- [https://www.howtoing.com/centos-kubernetes-docker-cluster](https://www.howtoing.com/centos-kubernetes-docker-cluster)

### 安装docker

```bash
# 获取HTTPS支持
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

# 配置docker阿里云源
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"

## 安装docker
apt-get update
apt-get -y install docker-ce docker-ce-cli containerd.io
docker version
```

### 配置docker daemon.json文件

```bash
# 配置docker daemon.json文件
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
```

native.cgroupdriver=systemd配置原因:
- [https://blog.whsir.com/post-5312.html](https://blog.whsir.com/post-5312.html)

### 添加vagrant用户到docker用户组

```bash
# 添加vagrant用户到docker用户组, egrep匹配字符串docker, 如果能匹配到, 返回0, 没有匹配到返回1
echo '====add user vagrant to docker group===='
egrep "^docker" /etc/group >& /dev/null
if [ $? -ne 0 ]
then
  groupadd docker
fi
usermod -aG docker vagrant
```

### 设置时区

```bash
echo '====set timezone===='
timedatectl set-timezone Asia/Shanghai
```

### 配置hosts文件

```bash
## 配置hosts文件
cat >> /etc/hosts <<EOF
192.168.33.101 node1
192.168.33.102 node2
192.168.33.103 node3
EOF
```

### 关闭swap分区

```bash
# 禁用swap
swapoff -a
# 给/etc/fstab这个文件swap相关内容前加注释
sed -i '/swap/s/^/#/' /etc/fstab
```

### 安装kubelet,kubeadm,kubectl前版本确认

```bash
# 查看镜像源支持的kubeadm版本, 目前最新版本支持到1.18.6-00, 但是还要检测阿里云镜像支持到的镜像版本
apt-cache madison kubeadm
# 通过docker pull命令测试, 阿里云镜像支持的版本是1.18.3, 所以安装版本选择1.18.3
docker pull registry.aliyuncs.com/google_containers/kube-apiserver:v1.18.3
```

### 安装kubelet,kubeadm,kubectl

```bash
# 配置阿里云k8s镜像源
curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF

apt-get update
# 安装kubernetes 1.18.3-00
apt-get install -y kubelet=1.18.3-00 kubeadm=1.18.3-00 kubectl=1.18.3-00

# 标记软件包阻止软件自动更新
apt-mark hold kubelet kubeadm kubectl

# 启动kubelet
systemctl enable kubelet
systemctl start kubelet

# 查看日志, 发现kubelet在报错, 不要介意
journalctl -f
```

其他参考命令: 

```bash
# 查看镜像源支持的kubeadm版本
apt-cache madison kubeadm

# 删除指定包
apt-get purge -y kubeadm kubectl kubelet

# 安装新包之前要确保是解除了标记
apt-mark unhold kubelet kubeadm kubectl
```

### 下载kubernetes需要的镜像

```bash
echo "====pull images from aliyun===="
# 指定阿里云的镜像仓库
repo_name="registry.aliyuncs.com/google_containers"
# 指定镜像仓库并指定版本
kubeadm config images pull --image-repository=${repo_name} --kubernetes-version=v1.18.3
```

- [https://www.cnblogs.com/hongdada/p/11395200.html](https://www.cnblogs.com/hongdada/p/11395200.html)

## 参考资料

- [https://www.howtoing.com/centos-kubernetes-docker-cluster](https://www.howtoing.com/centos-kubernetes-docker-cluster)
- [https://www.cnblogs.com/EmptyFS/p/13070663.html](https://www.cnblogs.com/EmptyFS/p/13070663.html](https://www.cnblogs.com/EmptyFS/p/13070663.html](https://www.cnblogs.com/EmptyFS/p/13070663.html)
- [https://blog.csdn.net/weixin_42331537/article/details/107634308](https://blog.csdn.net/weixin_42331537/article/details/107634308)
- [https://www.jianshu.com/p/04f5b9791dc4](https://www.jianshu.com/p/04f5b9791dc4)
- [https://developer.aliyun.com/article/759310](https://developer.aliyun.com/article/759310)
