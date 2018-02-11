---
title: Docker笔记-基本使用
date: 2018-02-10 08:13:09
categories: [Docker]
tags: [docker,linux]
toc: true
---

Docker火了不知道多少年了吧，一直没去看看是个什么技术。前几天想搭建一个ceph学习环境，需要好几个机器，掏出了以前写的关于Vagrant的文章，看看怎么搞出几个虚拟机来。虽然已经比自己安装虚拟机然方便了，但是还是好麻烦，虚拟机都比较大，尤其是还需要翻墙。网上看到文章对比Vagrant和Docker，才让我意识到，原来Docker是一种更轻量的虚拟化技术，基于进程隔离，配置和使用都比虚拟机来得方便，启动快很多，而且Docker镜像比较小，便于安装。遂试试。

<!-- more -->

[VAGRANT 和 Docker的使用场景和区别?](https://www.zhihu.com/question/32324376)
[单纯的开发环境来说 Docker 和 Vagrant 该如何选择？](https://segmentfault.com/q/1010000000690439)

## 概念

### 什么是Docker？

Docker是一个可以让开发或运维在容器中开发，发布，运行应用的平台。Docker基于Linux containers技术。

### 容器和虚拟机的区别？

容器和虚拟机都是虚拟化技术，不过两者的虚拟层面是不一样的，可以看这张图：

![](https://www.docker.com/sites/default/files/Container%402x.png)

容器直接运行在宿主操作系统上，各个容器共享操作系统中的资源。

虚拟机则是在操作系统上虚拟了一个模拟真实物理机的Hypervisor层，然后在上面运行GuestOS。这种虚拟得更加彻底，但是资源消耗和性能损耗较多。

## 安装Docker

在windows和mac上安转docker比较简单，安装包安装即可。

### 在Windows中安转Docker

之前Docker是不支持Windows的，所以之前的解决方案是在Windows上安装VirtualBox然后安转Docker。后来微软与Docker合作，让Docker支持了Windows，使用的技术是微软的Hyper-V。

首先要检测一下Windows版本，Docker支持的版本为64位的Windows 10 Pro，Enterprise和Education版本(1607 Anniversary Update, Build 14393 or later)。

下载[Install Docker for Windows](https://docs.docker.com/docker-for-windows/install/)

启动过程中会体现你电脑还没开启Hyper-V是否开启。点击OK重启电脑开启。开启Hyper-V后，VirtualBox就无法运行了。

如果手上的Windows不满足的话，而已使用VirtualBox方案：[Docker Toolbox](https://docs.docker.com/toolbox/overview/)

### 在Mac中安装Docker

Mac上是傻瓜化安装：[Install Docker for Mac](https://docs.docker.com/docker-for-mac/install/)，下载后拖动安装即可。

![](https://docs.docker.com/docker-for-mac/images/docker-app-in-apps.png)

然后点击Docker图标启动。

启动完成后在命令行中运行`docker info`检测是否安装成功。

## 简单上手

```
d:\>docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
ca4f61b1923c: Pull complete
Digest: sha256:66ef312bbac49c39a89aa9bcc3cb4f3c9e7de3788c944158df3ee0176d32b751
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://cloud.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/engine/userguide/

```

整个过程就几秒钟时间。

下载ubuntu进行，启动并运行bash命令：

```
d:\> docker run -it ubuntu bash
Unable to find image 'ubuntu:latest' locally
latest: Pulling from library/ubuntu
1be7f2b886e8: Pull complete
6fbc4a21b806: Pull complete
c71a6f8e1378: Pull complete
4be3072e5a37: Pull complete
06c6d2f59700: Pull complete
Digest: sha256:e27e9d7f7f28d67aa9e2d7540bdc2b33254b452ee8e60f388875e5b7d9b2b696
Status: Downloaded newer image for ubuntu:latest
root@5733739c8e4c:/# ls
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```

从下载ubuntu镜像，到启动容器运行bash，整个过程就几分钟时间。

`-it`是`-i -t`的缩写。

- `-i`参数表示开启容器的`STDIN`，否则我们无法向容器输入命令
- `-t`参数表示为容器分配一个伪tty终端

要创建一个命令行下能交互的容器，`-it`是最基本的参数了。

运行ps命令可以看docker中运行的程序：

```
> docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
5733739c8e4c        ubuntu              "bash"              2 minutes ago       Up 2 minutes                            quirky_hermann
```

执行exit可以退出bash，同时这个容器也退出了。

用docker运行nginx web server的例子：

```
>  docker run -d -p 80:80 --name webserver nginx
Unable to find image 'nginx:latest' locally
latest: Pulling from library/nginx
e7bb522d92ff: Pull complete
6edc05228666: Pull complete
cd866a17e81f: Pull complete
Digest: sha256:285b49d42c703fdf257d1e2422765c4ba9d3e37768d6ea83d7fe2043dad6e63d
Status: Downloaded newer image for nginx:latest
0bc0836a709f183c3aae1c49625e044a41db1dbc7aef114da1b350c13f52355d
```

`-d`参数指定运行守护式容器。容器没有交互式回话，但是会在后台保持运行。非常适合运行后台程序和服务。

通过ps命令可以看到这个容器的端口映射：

```
> docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                NAMES
0bc0836a709f        nginx               "nginx -g 'daemon of…"   6 minutes ago       Up 5 minutes        0.0.0.0:80->80/tcp   webserver
```

停止服务：

```
docker container stop webserver
```

启动服务：

```
docker start webserver
```

## Docker镜像

镜像保存在仓库中，仓库位于Registry中。默认的Registry是Docker官方维护的Docker Hub。

每个镜像仓库可以存放很多镜像。比如Ubuntu仓库保存了Ubuntu12.04等多个版本的镜像。使用TAG来区分仓库中的多个镜像：`ubuntu:12.04`

Docker Hub中有两种类型的仓库：用户仓库和顶级仓库。顶级仓库是Docker官方推出的，比如ubuntu，nginx等。用户仓库是用户自己上传的，名称由两个部分组成，用户名/仓库名。

使用`docker pull {image name}`可以拉取镜像到本地。之前使用`docker run`命令建立容器，它在发现本地没有这个镜像文件时，会自动到远程拉取。

docker命令可以直接搜索镜像：

```
> docker search ubuntu
NAME                                                      DESCRIPTION                                     STARS               OFFICIAL            AUTOMATED
ubuntu                                                    Ubuntu is a Debian-based Linux operating sys…   7234                [OK]
dorowu/ubuntu-desktop-lxde-vnc                            Ubuntu with openssh-server and NoVNC            159                                     [OK] rastasheep/ubuntu-sshd                                    Dockerized SSH service, built on top of offi…   130                                     [OK] ansible/ubuntu14.04-ansible                               Ubuntu 14.04 LTS with ansible                   90                                      [OK] ubuntu-upstart                                            Upstart is an event-based replacement for th…   81                  [OK]
```

- [Docker Hub](https://hub.docker.com/)
- [Docker Store](https://store.docker.com/)

这两个地方都可以找到Docker镜像。区别的话，按[官方的说法](https://docs.docker.com/docker-store/#licensed-content-via-docker-store-byol-program)，Docker Hub是社区维护的，任何人都可以发布镜像。Docker Store上的镜像是官方维护的，镜像需要审查后才能进入，所以会更加安全。

## 常用命令

### 容器命令

- 创建容器：`docker run {image name} {command}`
    - 设置容器的名称：`--name {container name}`
- 启动容器：`docker start {container name/id}`
- 重启容器：`docker restart {container name/id}`
- 停止容器：`docker stop {container name/id}`
- 删除容器：`docker rm {container name/id}`
- 附着到容器上：`docker attach {container name/id}`
- 查看容器内进程：`docker top {container name/id}`
- 在容器内运行进程：`docker exec {container name/id} {command}`
- 查看容器输出：`docker logs {container name/id}`
    - `-f` 监控日志，否则输出日志后直接退出
    - `-t` 为每条日志加上时间戳
- 获取容器详细信息：`docker inspect {container name/id}`

自动重启容器：
- 任何退出都自动重启：`docker run --restart=always --name xxx -d ubuntu /bin/bash -c "command"`
- 错误退出时（退出码非零）自动重启：`docker run --restart=on-failure:5 --name xxx -d ubuntu /bin/bash -c "command"`

### 镜像命令

- 列出所有本地镜像：`docker image ls`
- 删除镜像：`docker image rm {image name/id}`


## 参考资料
- 《第一本Docker书》
- 《Docker进阶与实战》
- [Get Started, Part 1: Orientation and setup | Docker Documentation](https://docs.docker.com/get-started/)
- [什么是 Docker ？ - 云+社区 - 腾讯云](https://cloud.tencent.com/developer/article/1005172)