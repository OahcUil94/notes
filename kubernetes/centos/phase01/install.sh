#!/usr/bin/env bash

#### 以下步骤是初始化centos7配置, 并且安装kubeadm,kubectl,kubelet以及k8s启动需要的镜像 ####

echo '====set timezone===='
timedatectl set-timezone Asia/Shanghai
timedatectl set-local-rtc 0

echo '====config hosts===='
cat >> /etc/hosts <<EOF
192.168.33.101 master
192.168.33.102 worker1
192.168.33.103 worker2
EOF

echo '====set aliyun yum repo===='
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
yum clean all && yum makecache -y

echo '====set baidu dns server===='
mv /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf.backup

cat > /etc/NetworkManager/NetworkManager.conf <<EOF
[main]
dns=none

[logging]
EOF

cat >> /etc/resolv.conf <<EOF
nameserver 180.76.76.76
EOF

systemctl restart NetworkManager.service

echo '====close not need service===='
systemctl stop postfix && systemctl disable postfix

echo '====set only journald log===='
mkdir /var/log/journal
mkdir /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/99-prophet.conf <<EOF
[Journal]
Storage=persistent
Compress=yes
SyncIntervalSec=5m
RateLimitInterval=30s
RateLimitBurst=1000
SystemMaxUse=10G
SystemMaxFileSize=200M
MaxRetentionSec=2week
ForwardToSyslog=no
EOF
systemctl restart systemd-journald

echo '====load overlay, br_netfilter module===='
cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

echo '==== yum update and install common package===='
yum update -y
yum install -y vim net-tools telnet bind-utils wget yum-utils device-mapper-persistent-data lvm2

echo '==== clear iptable rules ===='
yum install -y iptables-services
systemctl start iptables
systemctl enable iptables
iptables -F
service iptables save

echo '====disable firewalld===='
systemctl stop firewalld
systemctl disable firewalld

echo '====config system k8s network params===='
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system

echo '==== install docker===='
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum clean all && yum makecache -y
yum install -y docker-ce docker-ce-cli containerd.io
systemctl start docker
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

echo '====add vagrant user to docker group===='
egrep "^docker" /etc/group >& /dev/null
if [ $? -ne 0 ]
then
  groupadd docker
fi
usermod -aG docker vagrant

echo '====disable selinux===='
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

echo '====disable swap===='
swapoff -a
sed -i '/swap/s/^/#/g' /etc/fstab

echo '====install kubeadm,kubectl,kubelet===='
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
yum clean all && yum makecache -y
yum install -y kubelet-1.18.3-0 kubeadm-1.18.3-0 kubectl-1.18.3-0
yum -y install yum-versionlock
yum versionlock add kubelet kubeadm kubectl
systemctl enable kubelet

echo "====pull images from aliyun===="
repo_name="registry.aliyuncs.com/google_containers"
kubeadm config images pull --image-repository=${repo_name} --kubernetes-version=v1.18.3
docker image list |grep ${repo_name} |awk '{print "docker tag ",$1":"$2,$1":"$2}' |sed -e "s#${repo_name}#k8s.gcr.io#2" |sh -x

if [[ $1 -eq 0 ]]
then
  echo "====configure master node===="
  kubeadm init --apiserver-advertise-address=$2 --control-plane-endpoint=$2 --pod-network-cidr='10.244.0.0/16' --kubernetes-version='v1.18.3'
  mkdir -p $HOME/.kube
  cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  chown $(id -u):$(id -g) $HOME/.kube/config

  echo "====install flannel===="
  wget https://cdn.jsdelivr.net/gh/coreos/flannel@0.12.0/Documentation/kube-flannel.yml
  repo_name="quay.mirrors.ustc.edu.cn"
  docker image list |grep ${repo_name} |awk '{print "docker tag ",$1":"$2,$1":"$2}' |sed -e "s#${repo_name}#quay.io#2" |sh -x
  kubectl create -f kube-flannel.yml
  kubectl get pod -n kube-system
fi

if [[ $1 -eq 1 ]]
then
	echo "configure node2, need join master"
fi

if [[ $1 -eq 2 ]]
then
	echo "configure node3, need join master"
fi