---
title: Wireshark使用笔记
date: 2018-02-13 14:20:05
categories:
tags:
---


## 过滤

### 对ip进行过滤

```
ip.src==1.1.1.1
ip.dst==192.168.101.8
```

### 对端口进行过滤

```
tcp.port==80      // 源端口或者目的端口
tcp.srcport==80
tcp.dstport==80
```

[使用wireshark常用的过滤命令_百度经验](https://jingyan.baidu.com/article/7f41ececede744593c095c79.html)

## 抓取本机包

[wireshark如何抓取本机包 - Avatarx - 博客园](https://www.cnblogs.com/lvdongjie/p/6110183.html)

## Wireshark提示信息

[Wireshark的提示](http://blog.sina.com.cn/s/blog_987e00020102wq60.html)

## 参考资料
- [网络抓包工具 wireshark 入门教程 - 52php - 博客园](https://www.cnblogs.com/52php/p/6262956.html)
- [使用wireshark常用的过滤命令_百度经验](https://jingyan.baidu.com/article/7f41ececede744593c095c79.html)