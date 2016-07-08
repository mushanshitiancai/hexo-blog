---
title: 【TODO】Protocol Buffers学习笔记
date: 2016-07-05 22:14:59
categories:
tags: architecture
---

公司使用Protocol Buffers（下文简称PB）作为RPC架构的基础，所以我一直认为PB是一个RPC框架。今天面试官的反问才让我意识到，PB其实是不是一个RPC框架，而是一种数据格式。PB官网对于PB是什么的描述：

> Protocol buffers are Google's language-neutral, platform-neutral, extensible mechanism for serializing structured data – think XML, but smaller, faster, and simpler. You define how you want your data to be structured once, then you can use special generated source code to easily write and read your structured data to and from a variety of data streams and using a variety of languages.

> Protocol buffers是谷歌的语言无关的，平台无关的，可扩展的用于序列化结构数据的机制。像XML，但是更小，更快，更简单。你只要按照你的需求定义数据格式一次，然后你可以用生成的特殊代码，用不同语言，从不同的数据流中，很容易地读写你的格式化数据。

Protocol Buffers目前支持生成Java, Python和C++的调用代码。如果使用新的proto3语言格式，还可以支持Go, JavaNano, Ruby, 和 C#。

## 安装Protocol Buffers

```
$ sudo yum install -y autoconf automake libtool curl make g++ unzip

$ git clone https://github.com/google/protobuf.git
$ cd protobuf
$ ./autogen.sh
$ ./configure
$ make
$ make check
$ sudo make install
$ sudo ldconfig # refresh shared library cache.
```

安装过程需要翻墙，大家自备梯子。

## 编写数据格式文件
PB使用`.proto`文件定义数据结构的格式。PB也是根据proto文件生成对应语言的调用代码。



## 参考资料
- [Protocol Buffers  |  Google Developers](https://developers.google.com/protocol-buffers/)
- [google/protobuf: Protocol Buffers - Google's data interchange format](https://github.com/google/protobuf)
- [protobuf/README.md at master · google/protobuf](https://github.com/google/protobuf/blob/master/src/README.md)
- [Protocol Buffer Basics: Java  |  Protocol Buffers  |  Google Developers](https://developers.google.com/protocol-buffers/docs/javatutorial)
- [Google Protocol Buffer 的使用和原理](http://www.ibm.com/developerworks/cn/linux/l-cn-gpb/)