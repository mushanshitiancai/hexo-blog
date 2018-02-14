---
title: Wireshark笔记-抓取本机发给本机的请求
date: 2018-02-13 16:04:33
categories:
tags: [wireshark]
---

本机调试web服务器，想抓包看看服务器响应报文，但是在wireshark中找不到具体的请求和响应，而fiddler中可以。后了解到是因为wireshark只能看到经过网卡的数据流量，而对于本机请求本机的请求，是不会走网卡的，所以wireshark默认无法抓取。

<!-- more -->

网上有几种方法，包括修改修改本机网络路由表，RawCap等，都不是很方便，目前最方便也是[官方推荐](https://wiki.wireshark.org/CaptureSetup/Loopback)的做法是使用Npcap。

wireshark默认使用WinPcap来抓取数据包，而WinPcap不支持本地环回的请求，因为没有经过网卡，而Npcap基于WinPcap开发，兼容WinPcap的基础上，支持本地环回请求抓取。

使用方法非常简单，从[Releases · nmap/npcap](https://github.com/nmap/npcap/releases)下载最新的安装包，然后安装：

![](/img/tools/wireshark-npcap.png)

安装时选中图中标出的选项。然后安装过程就会把WinPcap卸载掉。

重启Wireshark就可以看到多了一个Npcap Loopback Adapter，就可以抓取本地环回的数据包了：

![](/img/tools/wireshark-use-npcap.png)


## 参考资料
- [CaptureSetup/Loopback - The Wireshark Wiki](https://wiki.wireshark.org/CaptureSetup/Loopback)
- [wireshark如何抓取本机包 - Avatarx - 博客园](https://www.cnblogs.com/lvdongjie/p/6110183.html)
- [Wireshark 监听 localhost/127.0.0.1 环回地址的方法](https://zetaoyang.github.io/post/2016/12/04/wireshark-npcap.html)
- [localhost是不经过网卡传输的，而127.0.0.1则要通过网卡传输的，这种说法正确吗？](https://www.zhihu.com/question/26521339)
- [localhost、127.0.0.1 和 本机IP 三者的区别?](https://www.zhihu.com/question/23940717)