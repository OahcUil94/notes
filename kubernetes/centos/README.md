# centos

## vagrant

离线下载centos7的box: [https://app.vagrantup.com/centos/boxes/7/versions/2004.01/providers/virtualbox.box](https://app.vagrantup.com/centos/boxes/7/versions/2004.01/providers/virtualbox.box)

下载完成后, 添加到box列表中, 执行命令: `vagrant box add centos/7 /d/vtest/images/CentOS-7-x86_64-Vagrant-2004_01.VirtualBox.box`
```bash
$ vagrant box add centos/7 /d/vtest/images/CentOS-7-x86_64-Vagrant-2004_01.VirtualBox.box

==> box: Box file was not detected as metadata. Adding it directly...
==> box: Adding box 'centos/7' (v0) for provider:
    box: Unpacking necessary files from: file:///D:/vtest/images/CentOS-7-x86_64-Vagrant-2004_01.VirtualBox.box
    box:
==> box: Successfully added box 'centos/7' (v0) for 'virtualbox'!
```

## 编写Vagrantfile文件

## 参考资料

- [https://www.jianshu.com/p/11b7af07b7eb](https://www.jianshu.com/p/11b7af07b7eb)
- [https://blog.csdn.net/qianghaohao/article/details/98588427](https://blog.csdn.net/qianghaohao/article/details/98588427)
- [https://github.com/OahcUil94/kubeadm-vagrant/blob/master/install-centos.sh](https://github.com/OahcUil94/kubeadm-vagrant/blob/master/install-centos.sh)