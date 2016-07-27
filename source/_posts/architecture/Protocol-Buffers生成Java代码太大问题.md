---
title: Protocol Buffers生成Java代码太大问题
date: 2016-07-26 23:12:27
categories:
tags: [architecture,protocol-buffers]
---

一个比较长的proto文件，生成的Java代码有2.6M之多。。。而且是单文件，用IDEA打开，整个IDE都不好了。。。提示

```
File size exceeds configured limit (2560000). Code insight features not available
```

因为文件太大，IDEA都不对其进行代码分析了。。。

解决的思路有两种，一种是放宽IDEA对于文件大小的限制，可以参考[[Intellij IDEA]File size exceeds configured limit - Less is More - 开源中国社区](http://my.oschina.net/shipley/blog/510762)，但是我不认为这是一种好的做法，因为巨大的单文件对于IDE解析是一个极大的负担，会极大影响开发体验。

那么有没有办法让protoc生成代码的时候不是生成一个单一Java文件，而是生成多个呢？方法是有的，参考[protocol buffers - Protoc: How to generate multiple Java source files? - Stack Overflow](http://stackoverflow.com/questions/26162696/protoc-how-to-generate-multiple-java-source-files)，这个哥们更牛，生成的代码有6M之大。。

方法就是在protoc中添加一个配置：

```
option java_multiple_files = true;
```

这样protoc在生成Java代码的时候，是每个顶级message对应一个Java文件，这样每个文件就不会很大了。