# vagrant

# Box

box是开发人员或者组织打包好的镜像: [https://app.vagrantup.com/boxes/search](https://app.vagrantup.com/boxes/search)

## add命令

添加一个镜像: `vagrant box add ubuntu/xenial64`, 如果本地没有`ubuntu/xenial64`镜像, 此时会自动进行镜像下载

但是在国内的网络中, 通常会下载失败, 此时就需要下载离线包, 本地添加:

- `https://app.vagrantup.com/boxes/search`找到自己要下载的镜像, 点进去, 并选择合适的版本, 复制`URL`, 例如: [https://app.vagrantup.com/ubuntu/boxes/xenial64/versions/20200807.0.0](https://app.vagrantup.com/ubuntu/boxes/xenial64/versions/20200807.0.0)
- 链接拼接`/providers/虚拟化平台.box`, 这里例如: `/providers/virtualbox.box`, [https://app.vagrantup.com/ubuntu/boxes/xenial64/versions/20200807.0.0/providers/virtualbox.box](https://app.vagrantup.com/ubuntu/boxes/xenial64/versions/20200807.0.0/providers/virtualbox.box)
- 执行添加命令: ` vagrant box add ubuntu/xenial64 /d/vtest/images/xenial-server-cloudimg-amd64-vagrant.box`


```bash
$ vagrant box add ubuntu/xenial64 /d/vtest/images/xenial-server-cloudimg-amd64-vagrant.box
==> box: Box file was not detected as metadata. Adding it directly...
==> box: Adding box 'ubuntu/xenial64' (v0) for provider:
    box: Unpacking necessary files from: file:///D:/vtest/images/xenial-server-cloudimg-amd64-vagrant.box
    box:
==> box: Successfully added box 'ubuntu/xenial64' (v0) for 'virtualbox'!
```

> 以上是在windows系统下git bash中实验

## list命令

查看本地已经存在的镜像列表: 

```
$ vagrant box list
centos7         (virtualbox, 0)
centos8         (virtualbox, 0)
ubuntu/xenial64 (virtualbox, 0)
```

## up

指定虚拟化平台, `vagrant up --provider=virtualbox`

## ssh

## halt

关机命令: `vagrant halt`

## suspend

挂机命令: `vagrant suspend`

## 销毁

销毁命令: `vagrant destroy`

## 重启

重启命令: `vagrant reload`

`--provision`参数表示, 虚拟机重启的时候, 执行`Vagrantfile`里的命令

## 如何让虚拟机启动时读取Vagrantfile里的命令执行

1. `vagrant reload --provision`
2. `vagrant up --provision`
3. `vagrant provision`

## 三种网络模型

### Forwarded Ports: 端口转发

`config.vm.network "forwarded_port", guest: 80, host: 8080`

把主机的8080转发到虚拟机的80端口

### Private Networks: 私有网络

`config.vm.network "private_network", ip: "192.168.50.4"`

把虚拟机作为一个私有网络, 虚拟机在一个网段里面, 宿主机可以通过ip地址进行访问, 但是外部的机器是无法访问到的, 类似于把主机作为交换机, 路由器的概念

配置好了, 进行`reload`就行

如果不想设置私有网络固定的ip, 可以选择使用dhcp去动态的分配: 

`config.vm.network "private_network", type: "dhcp"`

### Public Network: 公有网络

在公网上可以访问到这台机器

## vagrant配置root账号信息

```ruby
config.ssh.username = 'root'
config.ssh.password = 'vagrant'
config.ssh.insert_key = 'true'
```

- [https://stackoverflow.com/questions/25758737/vagrant-login-as-root-by-default](https://stackoverflow.com/questions/25758737/vagrant-login-as-root-by-default)