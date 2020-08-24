# kubernetes

- [kubectl](./kubectl/README.md)

## containerd

- [https://zhuanlan.zhihu.com/p/88993632](https://zhuanlan.zhihu.com/p/88993632)
- [https://github.com/containerd/containerd](https://github.com/containerd/containerd)

## vagrant

- [https://github.com/llaoj/vagrant-k8s-cluster](https://github.com/llaoj/vagrant-k8s-cluster)

快速构建三台虚拟机: 

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  (1..3).each do |i|
    config.vm.define "node#{i}" do |node|

      hostname = "node#{i}"
      ip = "192.168.33.#{i+100}"

      node.vm.box = "ubuntu/xenial64"
      node.vm.hostname = hostname
      node.vm.network "private_network", ip: ip
      node.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
        vb.cpus = 2
        vb.name = hostname
      end
      node.vm.provision "shell", path: "install.sh", args: [i, ip, hostname]
    end
  end
end
```

## 生产环境部署

[https://github.com/rootsongjc/kubernetes-vagrant-centos-cluster](https://github.com/rootsongjc/kubernetes-vagrant-centos-cluster)

- [https://www.jianshu.com/p/cb97268267b2](https://www.jianshu.com/p/cb97268267b2)
