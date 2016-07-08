---
title: 安装配置vagrant
date: 2016-04-10 09:23:55
tags: [linux,vagrant]
toc: true
---

Vagrant是一个虚拟机管理工具，极大的方便我们使用虚拟机。以前那种打开virtual box/VMware，然后加载镜像，安装捣腾半天的时代过去了。通过Vagrant可以使用别人打包好的box，自己调教好的系统也可以打包给别人使用。

## 安装Vagrant与box

1. 下载安装Vagrant

    从[Download Vagrant - Vagrant](https://www.vagrantup.com/downloads.html)下载安装

2. 下载box

    在[Vagrantbox.es](http://www.vagrantbox.es/)上下载对应的box。这里我下的是[centos6.6](https://github.com/tommy-muehle/puppet-vagrant-boxes/releases/download/1.0.0/centos-6.6-x86_64.box)

3. 添加box到vagrant中

        vagrant box add centos6.6 ~/software/vagrant/centos-6.6-x86_64.box

4. 到你的工程目录中初始化这个box

        vagrant init centos6.6

    这会在目录中生成一个`Vagrantfile`文件

5. 启动虚拟机

        vagrant up

6. 登录虚拟机

        vagrant ssh

    也可以使用ssh命令登录：

        ssh vagrant@127.0.0.1 -p 2222

    密码是`vagrant`。如果需要需要root权限，密码也是`vagrant`

7. 如果你修改了配置，重启虚拟机即可

        vagrant reload

8. 关闭虚拟机

        vagrant halt

9. 如果你要打包你调教的虚拟机：

        vagrant package

    具体参考[Creating a Base Box - Vagrant Documentation](http://docs.vagrantup.com/v2/boxes/base.html)

> vagrant目前不支持移动虚拟机，所以慎重选择新建虚拟机的目录！

## vagrant管理
如果你在本机多个地方启动了vagrant，要怎么管理呢？可以使用命令`global-status`：

```
$ vagrant global-status
id       name    provider   state   directory
--------------------------------------------------------------------------
edb8f98  default virtualbox aborted /Users/mazhibin/project/learn/laravel/Homestead
2fc4f12  default virtualbox running /Users/mazhibin/project/learn/vagrent

The above shows information about all known Vagrant environments
on this machine. This data is cached and may not be completely
up-to-date. To interact with any of the machines, you can go to
that directory and run Vagrant, or you can use the ID directly
with Vagrant commands from any directory. For example:
"vagrant destroy 1a2b3c4d"
```

命令`global-status`会显示机器上面存在的所有vagrant实例，以及他们的运行状况。

并且可以通过显示的各个实例的`id`，来在任何目录下操作这个vagrant实例。比如：

    $ vagrant halt 2fc4f12

## vagarnt配置

vagrant对于虚拟机的控制都通过工作目录下的`Vagrantfile`文件来配置，配置文件如下：

```
# 下面是所有的Vagrant配置。
# Vagrant.configure中的数字2表示配置文件的版本。（Vagrant同时支持旧版本的配置）
Vagrant.configure(2) do |config|
  # 最常用的配置都列在下面并注明了详细的说明，完整的配置请查看https://docs.vagrantup.com

  # 每个Vagrant开发环境需要一个box。你可以在https://atlas.hashicorp.com/search上搜索
  config.vm.box = "centos6.6"

  # 关闭自动更新box。如果你关闭了自动更新，则需要手动运行`vagrant box outdated`来更新
  # config.vm.box_check_update = false

  # 建立一个正向端口映射(forwarded port mapping)
  # 比如下面的例子，在主机的8080端口上建立了与虚拟机80端口的映射
  # 这样主机可以通过127.0.0.1来访问虚拟机的80端口
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # 建立一个私有网络，指定一个IP地址，仅运行主机连接到虚拟机
  # config.vm.network "private_network", ip: "192.168.33.10"

  # 建立一个公开网络，一般对应的是桥接网络(bridged network)。
  # 桥接网络使您的虚拟机作为一个物理设备出现在网络中
  # config.vm.network "public_network"

  # 共享一个额外的目录到你的虚拟机中。
  # 第一个参数是你主机中的真实目录
  # 第二个参数是虚拟机中的目录
  # 额外参数见：https://docs.vagrantup.com/v2/synced-folders/basic_usage.html
  # config.vm.synced_folder "../data", "/vagrant_data"

  # 提供特定的参数来更好的调整各个Vagrant的虚拟机实现。
  # 比如下面就针对virtualbox环境做了特定的调整：
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end

  # 可以把Vagrant中的代码push到生产环境或者测试环境
  # 具体的请见：https://docs.vagrantup.com/v2/push/atlas.html
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # 通过shell脚本做一些准备工作
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL
end
```

如果需要端口映射，只要取消配置前的注释即可。

## 目录映射

在主机上可以访问虚拟机目录会方便很多，比如可以使用主机上的IDE编程等。

> 需要注意的一点是，目录映射是把主机上的目录映射到虚拟机中。
> 所以在初始化虚拟机时，真实主机上的目录的内容会覆盖虚拟机主机中的目录，切记切记！

默认配置：

    config.vm.synced_folder "../data", "/vagrant_data"

这会把真实主机中的`../data`目录映射到虚拟机中的`/vagrant_data`目录。在初始化虚拟机前，需要保证前者目录存在。或者你可以这样配置：

    config.vm.synced_folder "data", "/vagrant_data", create:true

这样如果主机中的目录不存在就会先创建。

默认，vagrant使用`vboxsf`来同步目录。这个性能不是太好。所以可以使用`nfs`来同步目录，配置如下：

    config.vm.network "private_network", ip: "192.168.33.10"
    config.vm.synced_folder "data", "/vagrant_data", create:true , type:"nfs"

启用nfs，必须配置虚拟机的IP地址，否则主机无法通过网络访问虚拟机，初始化时会报错：

```
NFS requires a host-only network to be created.
Please add a host-only network to the machine (with either DHCP or a
static IP) for NFS to work.
```

还有，启用nfs后，启动虚拟机时，需要输入本机密码，注意哦，是真实本机的密码。

## 参考文章
- vagrent box列表[Vagrantbox.es](http://www.vagrantbox.es/)
- [vagrant在windows下的使用 - XXIU - 博客园](http://www.cnblogs.com/ac1985482/p/4029315.html)
- [Vagrant简介和安装配置 | Rming](http://rmingwang.com/vagrant-commands-and-config.html)
- [NFS - Synced Folders - Vagrant Documentation](http://docs.vagrantup.com/v2/synced-folders/nfs.html)
- [ubuntu - How to share a folder created inside vagrant? - Stack Overflow](http://stackoverflow.com/questions/19231895/how-to-share-a-folder-created-inside-vagrant)
- [Vagrant - NFS shared folders for Mac/Linux hosts, Samba shares for Windows | Midwestern Mac, LLC](http://www.midwesternmac.com/blogs/jeff-geerling/vagrant-nfs-shared-folders)

