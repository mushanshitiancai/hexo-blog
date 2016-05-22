---
title: 使用NFS共享目录
date: 2016-05-21 21:06:25
tags: linux
---

公司的开发机上使用samba服务让使用windows的电脑可以像操作本地文件一样操作开发机上的文件，这给开发带来许多遍历，比如开发人员可以使用自己喜爱的IDE来打开开发机上的文件。

在捣腾虚拟机的过程中，我也希望可以在宿主机上方便的操作虚拟机的文件。这里我不打算使用samba，因为samba是linux模拟windows的远程磁盘协议的一个开源软件。这是因为公司的开发人员使用的是windows。而我的机器是mac，UNIX系的，所以直接使用linux世界的远程文件系数nfs就可以了。nfs有一个好处就是现在的linux基本都默认安装了的，是一个linux世界广受支持的协议。

我现在的场景是在mac上有两个虚拟机，一个是centos，一个是Ubuntu。打算在centos上开启nfs服务，让后让mac和Ubuntu来访问centos上的文件。

<!-- more -->

## 检测是否安装了nfs
虽然centos和Ubuntu都默认安装了，我们还是检测一下为好：

```
$ rpm -qa | grep nfs
nfs-utils-1.2.3-54.el6.x86_64
nfs-utils-lib-1.1.5-9.el6.x86_64

$ rpm -qa | grep rpcbind
rpcbind-0.2.0-11.el6.x86_64
```

## 设置需要共享的目录
默认nfs不会去共享任何目录，我们可以在`/etc/exports`中指定需要共享的目录。

这里我打算共享`/home`这个目录，可以在`/etc/exports`文件中写入：

    /home *(rw)

`*(rw)`指的是可以让任何IP的人访问，访问权限是可读可写。exports文件的配置我们后面细讲，现在主要任务是尽快的走一遍共享的流程。

## 启动nfs服务

```
$ sudo service rpcbind start
$ sudo service nfs start
```

这样服务器上的设置就搞定了！

## 客户端连接nfs
先说说linux(Ubuntu)下怎么连接：

```
$ mkdir mount_dir
$ sudo mount -t nfs server_ip:/home ./mount_dir
```

如果你是按照我的步骤来的话，这会儿你应该会遇到一个错误提示：

    mount.nfs: access denied by server while mounting 192.168.33.10:/home

错误提示我们没有权限挂载远程目录。这是为啥？一番捣腾，发现可以在日志中找到答案，查看服务端的`/var/log/messages`，可以看到这么一句：

    May 22 04:17:17 localhost rpc.mountd[6463]: refused mount request from 192.168.33.1 for /home (/home): illegal port 62807

从参考资料3中得知，nfs的exports配置，默认值允许1024以下的端口接入，所以我们要放开这个限制，修改服务端的`/etc/exports`文件：

    /home *(rw,insecure)

然后重启nfs服务：

    $ service nfs restart

这样客户端就挂载成功了。

Mac上的挂载可以在finder中操作。打开finder，按下Command+K，就会打开一个链接到服务器的对话框，输入`nfs://192.168.33.10/home`，回车，就OK了。

Finder默认会把远程目录挂载到`/Volumes`目录下。

## NFS的配置文件
经过上面的步骤，我们已经成功的挂载远程目录到客户端上了，但是客户端在修改文件的时候只能享受到其他组用户的权限，很不方便，而且新建目录的话，在服务端上没有对应的用户，导致`ll`的时候，uid直接显示数字。

想要让客户端映射为服务端上具体的一个用户，这就涉及到NFS对于输出目录的权限设置了，也就需要了解exports的具体配置，我们来了解一下。

NFS的配置文件是`/etc/exports`，可以在其中指定想要共享那些目录，共享的权限设置等。默认是空的。

其配置的格式以行为单位，每行的格式是：

    <输出目录> [客户端1 选项（访问权限,用户映射,其他）] [客户端2 选项（访问权限,用户映射,其他）]

例子：

    /tmp  192.168.1.0/24(ro)   localhost(rw)   *.ev.ncku.edu.tw(ro,sync)

解释一下配置：

**输出目录：**指定打算共享的目录

**客户端：**指你打算什么IP来的用户可以访问这个目录，可以使用`*`通配符

**选项：**有多种类型的选项：

*访问权限：*指目标用户对输出目录拥有什么读写权限，有两个选择：

- ro 只读
- rw 读写

*用户映射：*这是很重要的一个选项，指定客户端在操作目录时，映射为本地的什么用户

- all_squash        :将远程范围的**所有用户**映射为匿名用户(由anonuid/anongid指定)
- no_all_squash(默认):对远程**所有用户**不做映射
- root_squash(默认)  :将客户端的**root用户**映射为匿名用户(由anonuid/anongid指定)
- no_root_squash    :对客户端的**root用户**不错映射
- anonuid=xxx       :指定匿名用户的UID，如果不做指定，则使用默认的65534，在centos上是nfsnobody，在Ubuntu上是nobody
- anongid=xxx       :指定匿名用户的GID，如果不做指定，则使用默认的65534，在centos上是nfsnobody，在Ubuntu上是nogroup

可以看到，对于客户端的普通用户和root用户，在用户映射上是独立的配置。默认的配置是：no_all_squash,root_squash，也就是普通用户不会进行映射，而root用户会映射为匿名用户。

*其他选项：*

- secure(默认): 限制客户端只能从小于1024的TCP/IP端口连接nfs服务器
- insecure    : 允许客户端使用大于1024的TCP/IP端口连接nfs服务器
- sync(默认)  : 将数据同步写入内存缓冲和磁盘，效率低但可保持数据一致
- async       : 将数据写入内存缓冲，必要时才写入硬盘
- wdelay(默认): 将写操作收集起来统一执行，提高效率但有延迟
- no_wdelay  : 有写操作就立即执行
- subtree_check        : 如果输出目录是一个子目录，则nfs检测其父目录的权限
- no_subtree_check(默认): 如果输出目录是一个子目录，则nfs不检测其父目录的权限

这里我们注意一下`secure/insecure`选项，因为默认是secure，所以大于1024的客户端端口都是不允许的，这个我们上面提到了。

现在我们可以看懂上面的例子了：

```
/tmp  192.168.1.0/24(ro)   localhost(rw)   *.ev.ncku.edu.tw(ro,sync)
# 共享/tmp目录，192.168.1.0/24的用户端拥有自读权限，本机的用户端拥有读写权限，来自*.ev.ncku.edu.tw的用户端拥有自读权限，并且是同步的（其实默认就是同步的）
```

我现在是为了方便操作虚拟机内的文件，所以我希望来自任何IP的普通用户，都映射为本机的一个特定普通用户，这样远程操作服务端的文件就和在服务端上操作一样的，可以这样配置：

```
# 500是我想要映射的服务端上的一个用户
/home *(rw,insecure,all_squash,anonuid=500,anongid=500)
```

注意：如果使用了all_squash，那么no_root_squash就无效了。

如果你想查看附加了默认配置的最终配置，可以查看文件：`/var/lib/nfs/etab`

修改了配置后并不需要重启nfs服务，运行

    $ exportfs -av

即可。

## 客户端取消挂载

```
sudo umount mountdir
```

如果遇到了错误：`device is busy`，是因为还有进程占用了当前目录，需要找出并关闭才能umount。具体参考资料4，5。

## 小知识
### 用户和用户组的定义文件

- /etc/passwd
- /etc/group

### 如何查看某个用户的UID，GID？

- id 查看当前用户
- id user 查看具体用户

## 参考资料
1. [CentOS 6 NFS的安装配置-roothomes-ChinaUnix博客](http://blog.chinaunix.net/uid-26284318-id-3111651.html)
2. [NFS配置文件/etc/exports-cr858923-ChinaUnix博客](http://blog.chinaunix.net/uid-8038341-id-179288.html)
3. [mount.nfs: access denied by server while mounting 一个解决办法-pppStar-ChinaUnix博客](http://blog.chinaunix.net/uid-20554957-id-3444786.html)
4. [Stale NFS file handle的解决方法 - dikar云墨竹 - ITeye技术网站](http://dikar.iteye.com/blog/634862)
5. [(1)Stale NFS file handle 的解决方法_whfwind_新浪博客](http://blog.sina.com.cn/s/blog_6c9eaa15010185bt.html)
6. ✨[Linux NFS服务器的安装与配置 - David_Tang - 博客园](http://www.cnblogs.com/mchina/archive/2013/01/03/2840040.html)
7. [root_squash关于NFS参数说明](http://www.360doc.com/content/14/0527/00/17617523_381280598.shtml)
8. [exports(5): NFS server export table - Linux man page](http://linux.die.net/man/5/exports)