---
title: IntelliJ IDEA打开maven项目卡死
date: 2018-01-08 17:51:17
categories: [Java]
tags: [java,idea,maven]
---

今天同事遇到一个诡异的问题，IDEA打开maven项目直接卡死，没有任何报错。

<!--more-->

研究了好久，发现如果手动执行maven命令并触发他去远程下载的话，会提示错误：

```
java.net.SocketException: Unrecognized Windows Sockets error: 10106: create
```

从错误信息来看，是新建网络连接的时候返回了一个不太常规的异常。导致maven命令执行失败。不过，IDEA因为这个原因就直接卡死就有点不应该了，容错处理没做好。

参考网上的解决方法：
1. 以管理员身份打开命令提示符
2. 输入 netsh winsock reset  
3. 重启电脑

## 参考资料
- http://blog.csdn.net/feilong2483/article/details/78682205