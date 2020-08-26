# 阶段0: 升级内核版本

```bash
## 载入公钥
$ rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

## 安装 ELRepo 最新版本
$ yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm

## 列出可以使用的 kernel 包版本
$ yum list available --disablerepo=* --enablerepo=elrepo-kernel

## 安装指定的 kernel 版本：
$ yum install -y kernel-lt-4.4.233-1.el7.elrepo --enablerepo=elrepo-kernel

## 查看系统可用内核
$ cat /boot/grub2/grub.cfg | grep menuentry

menuentry 'CentOS Linux (3.10.0-1062.el7.x86_64) 7 (Core)' --class centos （略）
menuentry 'CentOS Linux (4.4.218-1.el7.elrepo.x86_64) 7 (Core)' --class centos ...（略）

## 设置开机从新内核启动
$ grub2-set-default "CentOS Linux (4.4.233-1.el7.elrepo.x86_64) 7 (Core)"

## 查看内核启动项
$ grub2-editenv list
saved_entry=CentOS Linux (4.4.218-1.el7.elrepo.x86_64) 7 (Core)

## 重启
$ reboot

## 确认是否设置成功
$ uname -r
```

rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
yum install -y kernel-lt-4.4.233-1.el7.elrepo --enablerepo=elrepo-kernel
grub2-set-default "CentOS Linux (4.4.233-1.el7.elrepo.x86_64) 7 (Core)"
reboot