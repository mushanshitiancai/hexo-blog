---
title: Tomcat笔记-IDE中调试Tomcat源码
date: 2018-02-13 17:06:53
categories: [Tomcat]
tags: [tomcat,java]
---

有时候遇到疑难杂症可能会需要完整的跟踪整个请求的声明流程，这样可能需要走到Tomcat的代码中，但是默认下无法调试Tomcat的代码。

<!-- more -->

一开始想着可能要下载Tomcat的源码然后通过某种方式执行才能运行到Tomcat的代码上，但是这样好麻烦，所以一直没实践过。

后来看到[调试跟进 tomcat 源码](http://alphahinex.github.io/2015/10/14/how-to-debug-into-tomcat-sources)这篇文章，才反应过来其实很简单，只要在代码中添加tomcat的依赖就行了：

```xml
<dependency>
    <groupId>org.apache.tomcat.embed</groupId>
    <artifactId>tomcat-embed-core</artifactId>
    <version>8.5.27</version>
</dependency>
```

`8.5.27`换成你用来运行项目的tomcat的版本。然后你在Tomcat的代码中设置断点，启动服务就会到断点上了。

## 参考资料
- [调试跟进 tomcat 源码](http://alphahinex.github.io/2015/10/14/how-to-debug-into-tomcat-sources)
- [如何阅读Tomcat源代码？](https://www.zhihu.com/question/19910358)