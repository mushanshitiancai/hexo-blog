---
title: Docker笔记-基本使用
date: 2018-02-10 08:13:09
categories:
tags: [docker]
toc: true
---

Docker火了不知道多少年了吧，一直没去看看是个什么技术。前几天想搭建一个ceph学习环境，需要好几个机器，掏出了以前写的关于Vagrant的文章，看看怎么搞出几个虚拟机来。虽然已经比自己安装虚拟机然方便了，但是还是好麻烦，虚拟机都比较大，尤其是还需要翻墙。网上看到文章对比Vagrant和Docker，才让我意识到，原来Docker是一种更轻量的虚拟化技术，基于进程隔离，配置和使用都比虚拟机来得方便，启动快很多，而且Docker镜像比较小，便于安装。遂试试。

[VAGRANT 和 Docker的使用场景和区别?](https://www.zhihu.com/question/32324376)
[单纯的开发环境来说 Docker 和 Vagrant 该如何选择？](https://segmentfault.com/q/1010000000690439)

<!-- more -->

## 在Mac中安装Docker

Mac上是傻瓜化安装：[Install Docker for Mac](https://docs.docker.com/docker-for-mac/install/)，下载后拖动安装即可。

![](https://docs.docker.com/docker-for-mac/images/docker-app-in-apps.png)

然后点击Docker图标启动。



[Get started with Docker for Mac](https://docs.docker.com/docker-for-mac/)
