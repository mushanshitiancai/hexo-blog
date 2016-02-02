---
title: 从源码安装git
date: 2016-02-02 14:20:13
tags: [Linux]
---

Centos自带的git版本为1.7.1。算是比较旧了。需要新版本的话就需要自己从源码安装了。

git的参考在`git://git.kernel.org/pub/scm/git/git.git`这个git仓库中。

```
$ sudo yum -y groupinstall "Development Tools"
$ git clone git://git.kernel.org/pub/scm/git/git.git
```
