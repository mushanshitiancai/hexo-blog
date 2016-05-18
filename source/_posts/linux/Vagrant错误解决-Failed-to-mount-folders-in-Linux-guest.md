---
title: Vagrant错误解决:Failed to mount folders in Linux guest
date: 2016-05-17 15:08:11
tags: [linux,vagrant]
---

运行`vagrant up`的时候遇到错误：

```
==> default: Mounting shared folders...
    default: /vagrant => /Users/mazhibin/project/learn/vagrant/ubuntu
Failed to mount folders in Linux guest. This is usually because
the "vboxsf" file system is not available. Please verify that
the guest additions are properly installed in the guest and
can work properly. The command attempted was:

mount -t vboxsf -o uid=`id -u vagrant`,gid=`getent group vagrant | cut -d: -f3` vagrant /vagrant
mount -t vboxsf -o uid=`id -u vagrant`,gid=`id -g vagrant` vagrant /vagrant

The error output from the last command was:

stdin: is not a tty
mount: unknown filesystem type 'vboxsf'
```

这是在vagrant尝试挂载共享文件夹时遇到了问题，这个一般是box里的`VirtualBox Guest Additions`插件版本不对，可以使用`vagrant-vbguest`这个vagrant插件，来保证插件总是最新。

安装vagrant插件：

```
$ vagrant plugin install vagrant-vbguest
```

安装过程中会有些黄字错误，那个不用管，没影响。

安装完后不需要任何配置，再次`vagrant up`，`vagrant-vbguest`就会自动更新系统里的`VirtualBox Guest Additions`了。

enjoy it!

## 参考资料
- [ubuntu - Vagrant error : Failed to mount folders in Linux guest - Stack Overflow](http://stackoverflow.com/questions/22717428/vagrant-error-failed-to-mount-folders-in-linux-guest)